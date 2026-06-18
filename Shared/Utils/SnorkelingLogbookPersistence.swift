import Foundation

struct SnorkelingLogbookFileEnvelope: Codable, Hashable, Sendable {
    static let currentSchemaVersion = 1
    static let namespace = "dirdiving_snorkeling_sessions"

    var schemaVersion: Int
    var sessionsData: Data
    var checksum: String
}

enum SnorkelingLogbookPersistence {
    private static let quarantineDirectoryName = "Diagnostics/SnorkelingQuarantine"

    static func checksum(for data: Data) -> String {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in data {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }
        return String(hash, radix: 16)
    }

    static func makeEnvelope(sessions: [SnorkelingSession]) throws -> SnorkelingLogbookFileEnvelope {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let data = try encoder.encode(sessions)
        return SnorkelingLogbookFileEnvelope(
            schemaVersion: SnorkelingLogbookFileEnvelope.currentSchemaVersion,
            sessionsData: data,
            checksum: checksum(for: data)
        )
    }

    static func sessions(from envelope: SnorkelingLogbookFileEnvelope) throws -> [SnorkelingSession] {
        guard checksum(for: envelope.sessionsData) == envelope.checksum else {
            throw NSError(domain: "SnorkelingLogbookPersistence", code: 2, userInfo: [NSLocalizedDescriptionKey: "Snorkeling logbook checksum mismatch"])
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return try decoder.decode([SnorkelingSession].self, from: envelope.sessionsData)
    }

    static func writeEnvelope(_ envelope: SnorkelingLogbookFileEnvelope, to fileURL: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(envelope)
        let tempURL = fileURL.appendingPathExtension("tmp")
        try data.write(to: tempURL, options: .atomic)
        _ = try? FileManager.default.removeItem(at: fileURL)
        try FileManager.default.moveItem(at: tempURL, to: fileURL)
    }

    static func readEnvelope(from fileURL: URL) throws -> SnorkelingLogbookFileEnvelope {
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(SnorkelingLogbookFileEnvelope.self, from: data)
    }

    static func decodeSessionsResiliently(from data: Data) throws -> [SnorkelingSession] {
        if let envelope = try? JSONDecoder().decode(SnorkelingLogbookFileEnvelope.self, from: data) {
            return try sessions(from: envelope)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return try decoder.decode([SnorkelingSession].self, from: data)
    }

    static func quarantineCorruptFile(at fileURL: URL, baseDirectory: URL) throws {
        let quarantineDirectory = baseDirectory.appendingPathComponent(quarantineDirectoryName, isDirectory: true)
        try FileManager.default.createDirectory(at: quarantineDirectory, withIntermediateDirectories: true)
        let stamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let destination = quarantineDirectory.appendingPathComponent("snorkeling_logbook_\(stamp).json")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            _ = try? FileManager.default.removeItem(at: destination)
            try FileManager.default.moveItem(at: fileURL, to: destination)
        }
    }

    static func exportData(for sessions: [SnorkelingSession]) throws -> Data {
        try JSONEncoder().encode(makeEnvelope(sessions: sessions))
    }
}
