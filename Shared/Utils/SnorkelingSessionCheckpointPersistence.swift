import CryptoKit
import Foundation

/// Runtime wrapper state persisted alongside the engine checkpoint.
struct SnorkelingCheckpointRuntimeState: Codable, Hashable, Sendable {
    var sessionArmed: Bool
    var sessionStarted: Bool
    var missionModeEnabled: Bool
    var hapticsEnabled: Bool

    static let idle = SnorkelingCheckpointRuntimeState(
        sessionArmed: false,
        sessionStarted: false,
        missionModeEnabled: false,
        hapticsEnabled: true
    )
}

struct SnorkelingSessionCheckpointPayload: Codable, Hashable, Sendable {
    static let currentEnvelopeSchemaVersion = 1
    static let namespace = "dirdiving_snorkeling_session"

    var envelopeSchemaVersion: Int
    var checkpoint: SnorkelingSessionCheckpoint
    var runtime: SnorkelingCheckpointRuntimeState

    init(checkpoint: SnorkelingSessionCheckpoint, runtime: SnorkelingCheckpointRuntimeState) {
        envelopeSchemaVersion = Self.currentEnvelopeSchemaVersion
        self.checkpoint = checkpoint
        self.runtime = runtime
    }
}

struct SnorkelingSessionCheckpointEnvelope: Codable, Hashable, Sendable {
    var payloadData: Data
    var checksum: String
}

enum SnorkelingSessionCheckpointIntegrity {
    static func encodePayload(_ payload: SnorkelingSessionCheckpointPayload) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return try encoder.encode(payload)
    }

    static func decodePayload(_ data: Data) throws -> SnorkelingSessionCheckpointPayload {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return try decoder.decode(SnorkelingSessionCheckpointPayload.self, from: data)
    }

    static func checksum(for data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    static func makeEnvelope(payload: SnorkelingSessionCheckpointPayload) throws -> SnorkelingSessionCheckpointEnvelope {
        let data = try encodePayload(payload)
        return SnorkelingSessionCheckpointEnvelope(payloadData: data, checksum: checksum(for: data))
    }

    static func payload(from envelope: SnorkelingSessionCheckpointEnvelope) throws -> SnorkelingSessionCheckpointPayload {
        guard checksum(for: envelope.payloadData) == envelope.checksum else {
            throw SnorkelingCheckpointPersistenceError.checksumMismatch
        }
        return try decodePayload(envelope.payloadData)
    }

    static func canonicalStateFingerprint(payload: SnorkelingSessionCheckpointPayload) throws -> String {
        var normalized = payload
        normalized.checkpoint.savedAtWallClock = Date(timeIntervalSince1970: 0)
        normalized.checkpoint.savedAtMonotonicSeconds = 0
        return checksum(for: try encodePayload(normalized))
    }
}

enum SnorkelingCheckpointPersistenceError: Error, Equatable {
    case checksumMismatch
    case corruptEnvelope
    case unsupportedSchema(Int)
}

enum SnorkelingSessionCheckpointStore {
    static let checkpointFileName = "dirdiving_snorkeling_session_checkpoint.json"
    static let previousCheckpointFileName = "dirdiving_snorkeling_session_checkpoint.previous.json"
    private static let quarantineDirectoryName = "Diagnostics/SnorkelingQuarantine"

    static func write(_ envelope: SnorkelingSessionCheckpointEnvelope, to fileURL: URL) throws {
        _ = try SnorkelingSessionCheckpointIntegrity.payload(from: envelope)
        let data = try JSONEncoder().encode(envelope)
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let previousURL = fileURL.deletingLastPathComponent().appendingPathComponent(previousCheckpointFileName)
            _ = try? FileManager.default.removeItem(at: previousURL)
            try? FileManager.default.copyItem(at: fileURL, to: previousURL)
        }
        let tempURL = fileURL.appendingPathExtension("tmp")
        try data.write(to: tempURL, options: .atomic)
        let staged = try Data(contentsOf: tempURL)
        let stagedEnvelope = try JSONDecoder().decode(SnorkelingSessionCheckpointEnvelope.self, from: staged)
        _ = try SnorkelingSessionCheckpointIntegrity.payload(from: stagedEnvelope)
        _ = try? FileManager.default.removeItem(at: fileURL)
        try FileManager.default.moveItem(at: tempURL, to: fileURL)
    }

    static func read(from fileURL: URL) throws -> SnorkelingSessionCheckpointEnvelope {
        let data = try Data(contentsOf: fileURL)
        let envelope = try JSONDecoder().decode(SnorkelingSessionCheckpointEnvelope.self, from: data)
        _ = try SnorkelingSessionCheckpointIntegrity.payload(from: envelope)
        return envelope
    }

    static func readWithPreviousFallback(currentURL: URL, previousURL: URL) throws -> SnorkelingSessionCheckpointEnvelope {
        if FileManager.default.fileExists(atPath: currentURL.path) {
            do {
                return try read(from: currentURL)
            } catch {
                if FileManager.default.fileExists(atPath: previousURL.path) {
                    return try read(from: previousURL)
                }
                throw error
            }
        }
        if FileManager.default.fileExists(atPath: previousURL.path) {
            return try read(from: previousURL)
        }
        throw SnorkelingCheckpointPersistenceError.corruptEnvelope
    }

    static func quarantineCorruptFile(at fileURL: URL, baseDirectory: URL) throws {
        let quarantineDirectory = baseDirectory.appendingPathComponent(quarantineDirectoryName, isDirectory: true)
        try FileManager.default.createDirectory(at: quarantineDirectory, withIntermediateDirectories: true)
        let stamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let destination = quarantineDirectory.appendingPathComponent("snorkeling_checkpoint_\(stamp).json")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            _ = try? FileManager.default.removeItem(at: destination)
            try FileManager.default.moveItem(at: fileURL, to: destination)
        }
    }

    static func clearCheckpointFiles(currentURL: URL, previousURL: URL) {
        try? FileManager.default.removeItem(at: currentURL)
        try? FileManager.default.removeItem(at: previousURL)
    }
}

extension SnorkelingSessionEngine {
    mutating func exportCheckpointEnvelope(
        runtime: SnorkelingCheckpointRuntimeState,
        now: Date = Date(),
        uptime: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) throws -> SnorkelingSessionCheckpointEnvelope {
        let payload = SnorkelingSessionCheckpointPayload(
            checkpoint: exportCheckpoint(now: now, uptime: uptime),
            runtime: runtime
        )
        return try SnorkelingSessionCheckpointIntegrity.makeEnvelope(payload: payload)
    }

    init(checkpointEnvelope: SnorkelingSessionCheckpointEnvelope) throws {
        let payload = try SnorkelingSessionCheckpointIntegrity.payload(from: checkpointEnvelope)
        if payload.envelopeSchemaVersion > SnorkelingSessionCheckpointPayload.currentEnvelopeSchemaVersion {
            // Future envelope tolerated; domain migration handles session schema separately.
        }
        self.init(checkpoint: payload.checkpoint)
    }

    static func restoreState(from envelope: SnorkelingSessionCheckpointEnvelope) throws -> (
        engine: SnorkelingSessionEngine,
        runtime: SnorkelingCheckpointRuntimeState
    ) {
        let payload = try SnorkelingSessionCheckpointIntegrity.payload(from: envelope)
        return (SnorkelingSessionEngine(checkpoint: payload.checkpoint), payload.runtime)
    }
}
