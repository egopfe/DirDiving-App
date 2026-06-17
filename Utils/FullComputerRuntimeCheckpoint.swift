import Foundation
import CryptoKit

enum FullComputerRuntimeCheckpointError: Error, Equatable {
    case unsupportedSchema(Int)
    case checksumMismatch
    case invalidPayload
    case sessionMismatch
}

/// Atomic Full Computer runtime checkpoint for crash recovery (draft persistence).
struct FullComputerRuntimeCheckpointPayload: Codable, Equatable {
    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let sessionID: UUID
    let watchDivingMode: String
    let plan: FullComputerRuntimePlan
    let tissueState: BuhlmannTissueState
    let gasSwitchTracker: FullComputerGasSwitchTracker
    let decoStopTracker: FullComputerDecoStopTracker
    let lastDepthMeters: Double
    let lastSampleTimestamp: Date?
    let lastComputedTimestamp: Date
    let monotonicClock: MonotonicElapsedClock.Snapshot
    let previousEngineState: FullComputerRuntimeEngineState
    let snapshotNDLMinutes: Double?
    let snapshotCeilingMeters: Double
    let snapshotTTSMinutes: Int
    let snapshotStopState: FullComputerDecoStopState?
    let snapshotEngagedStopDepthMeters: Double?
    let wallClockSavedAt: Date
}

struct FullComputerRuntimeCheckpoint: Codable, Equatable {
    let payload: FullComputerRuntimeCheckpointPayload
    let checksumHex: String
}

enum FullComputerRuntimeCheckpointCodec {
    static func encode(_ checkpoint: FullComputerRuntimeCheckpoint) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(checkpoint)
    }

    static func decode(_ data: Data) throws -> FullComputerRuntimeCheckpoint {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let checkpoint = try decoder.decode(FullComputerRuntimeCheckpoint.self, from: data)
        try validate(checkpoint)
        return checkpoint
    }

    static func make(from payload: FullComputerRuntimeCheckpointPayload) throws -> FullComputerRuntimeCheckpoint {
        guard payload.schemaVersion == FullComputerRuntimeCheckpointPayload.currentSchemaVersion else {
            throw FullComputerRuntimeCheckpointError.unsupportedSchema(payload.schemaVersion)
        }
        let checksum = try checksumHex(for: payload)
        return FullComputerRuntimeCheckpoint(payload: payload, checksumHex: checksum)
    }

    static func validate(_ checkpoint: FullComputerRuntimeCheckpoint) throws {
        guard checkpoint.payload.schemaVersion == FullComputerRuntimeCheckpointPayload.currentSchemaVersion else {
            throw FullComputerRuntimeCheckpointError.unsupportedSchema(checkpoint.payload.schemaVersion)
        }
        let expected = try checksumHex(for: checkpoint.payload)
        guard checkpoint.checksumHex == expected else {
            throw FullComputerRuntimeCheckpointError.checksumMismatch
        }
    }

    private static func checksumHex(for payload: FullComputerRuntimeCheckpointPayload) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        let body = try encoder.encode(payload)
        let digest = SHA256.hash(data: body)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
