import Foundation

struct ApneaLogbookFileEnvelope: Codable, Hashable, Sendable {
    static let currentSchemaVersion = 1

    var schemaVersion: Int
    var sessionsData: Data
    var checksum: String
}

enum ApneaLogbookPersistence {
    private static let quarantineDirectoryName = "Diagnostics/ApneaQuarantine"

    static func checksum(for data: Data) -> String {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in data {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }
        return String(hash, radix: 16)
    }

    static func makeEnvelope(sessions: [ApneaSession]) throws -> ApneaLogbookFileEnvelope {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let data = try encoder.encode(sessions)
        return ApneaLogbookFileEnvelope(
            schemaVersion: ApneaLogbookFileEnvelope.currentSchemaVersion,
            sessionsData: data,
            checksum: checksum(for: data)
        )
    }

    static func sessions(from envelope: ApneaLogbookFileEnvelope) throws -> [ApneaSession] {
        guard checksum(for: envelope.sessionsData) == envelope.checksum else {
            throw NSError(domain: "ApneaLogbookPersistence", code: 2, userInfo: [NSLocalizedDescriptionKey: "Apnea logbook checksum mismatch"])
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return try decoder.decode([ApneaSession].self, from: envelope.sessionsData)
    }

    static func writeEnvelope(_ envelope: ApneaLogbookFileEnvelope, to fileURL: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(envelope)
        let tempURL = fileURL.appendingPathExtension("tmp")
        try data.write(to: tempURL, options: .atomic)
        _ = try? FileManager.default.removeItem(at: fileURL)
        try FileManager.default.moveItem(at: tempURL, to: fileURL)
    }

    static func readEnvelope(from fileURL: URL) throws -> ApneaLogbookFileEnvelope {
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(ApneaLogbookFileEnvelope.self, from: data)
    }

    static func decodeSessionsResiliently(from data: Data) throws -> [ApneaSession] {
        if let envelope = try? JSONDecoder().decode(ApneaLogbookFileEnvelope.self, from: data) {
            return try sessions(from: envelope)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        if let sessions = try? decoder.decode([ApneaSession].self, from: data) {
            return sessions
        }
        guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [Any] else {
            throw CocoaError(.propertyListReadCorrupt)
        }
        var sessions: [ApneaSession] = []
        for element in jsonArray {
            guard JSONSerialization.isValidJSONObject(element),
                  let elementData = try? JSONSerialization.data(withJSONObject: element),
                  let session = try? decoder.decode(ApneaSession.self, from: elementData) else {
                continue
            }
            sessions.append(session)
        }
        return sessions
    }

    static func quarantineCorruptFile(at fileURL: URL, baseDirectory: URL) throws {
        let quarantineDirectory = baseDirectory.appendingPathComponent(quarantineDirectoryName, isDirectory: true)
        try FileManager.default.createDirectory(at: quarantineDirectory, withIntermediateDirectories: true)
        let stamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let destination = quarantineDirectory.appendingPathComponent("apnea_logbook_\(stamp).json")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            _ = try? FileManager.default.removeItem(at: destination)
            try FileManager.default.moveItem(at: fileURL, to: destination)
        }
    }

    static func exportData(for sessions: [ApneaSession]) throws -> Data {
        try JSONEncoder().encode(makeEnvelope(sessions: sessions))
    }
}
