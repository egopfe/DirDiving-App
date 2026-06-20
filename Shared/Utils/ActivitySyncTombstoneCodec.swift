import Foundation
import CryptoKit

/// Activity-scoped tombstone record propagated over WatchConnectivity applicationContext.
struct ActivitySyncTombstoneRecord: Codable, Equatable, Identifiable {
    static let currentSchemaVersion = 1

    let tombstoneID: UUID
    let activityType: String
    let sessionID: UUID
    let deletedAt: Date
    let revision: Int
    let sourceDeviceID: String
    let schemaVersion: Int

    var id: UUID { tombstoneID }

    init(
        sessionID: UUID,
        activity: ActivitySyncActivityType,
        revision: Int,
        deletedAt: Date = Date(),
        sourceDeviceID: String = ActivitySyncTombstoneRecord.defaultSourceDeviceID(),
        tombstoneID: UUID = UUID(),
        schemaVersion: Int = ActivitySyncTombstoneRecord.currentSchemaVersion
    ) {
        self.tombstoneID = tombstoneID
        self.activityType = activity.rawValue
        self.sessionID = sessionID
        self.deletedAt = deletedAt
        self.revision = revision
        self.sourceDeviceID = sourceDeviceID
        self.schemaVersion = schemaVersion
    }

    static func defaultSourceDeviceID() -> String {
        Bundle.main.bundleIdentifier ?? "unknown"
    }

    var activity: ActivitySyncActivityType? {
        ActivitySyncActivityType(rawValue: activityType)
    }
}

struct ActivitySyncSignedTombstone: Codable, Equatable {
    let record: ActivitySyncTombstoneRecord
    let nonce: String
    let bundleID: String
    let signature: String

    static func sign(
        record: ActivitySyncTombstoneRecord,
        syncKey: SymmetricKey,
        bundleID: String,
        nonce: String = UUID().uuidString
    ) throws -> ActivitySyncSignedTombstone {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        let body = try encoder.encode(record)
        let canonical = "tombstone|\(record.activityType)|\(record.sessionID.uuidString)|\(record.revision)|\(record.deletedAt.timeIntervalSince1970)|\(nonce)|\(body.base64EncodedString())"
        let code = HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: syncKey)
        return ActivitySyncSignedTombstone(
            record: record,
            nonce: nonce,
            bundleID: bundleID,
            signature: Data(code).base64EncodedString()
        )
    }

    func verify(syncKey: SymmetricKey, expectedBundleID: String) -> Bool {
        guard bundleID == expectedBundleID else { return false }
        guard record.schemaVersion <= ActivitySyncTombstoneRecord.currentSchemaVersion else { return false }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        guard let body = try? encoder.encode(record) else { return false }
        let canonical = "tombstone|\(record.activityType)|\(record.sessionID.uuidString)|\(record.revision)|\(record.deletedAt.timeIntervalSince1970)|\(nonce)|\(body.base64EncodedString())"
        let code = HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: syncKey)
        let expected = Data(code).base64EncodedString()
        guard let received = Data(base64Encoded: signature),
              let expectedData = Data(base64Encoded: expected) else {
            return false
        }
        return received.constantTimeEquals(expectedData)
    }
}

enum ActivitySyncTombstoneCodec {
    static func encodeBroadcastPayload(
        tombstones: [ActivitySyncSignedTombstone],
        broadcastKey: String
    ) -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(tombstones) else {
            return [:]
        }
        return [broadcastKey: data]
    }

    static func decodeBroadcastPayload(
        from context: [String: Any],
        broadcastKey: String
    ) -> [ActivitySyncSignedTombstone] {
        guard let data = context[broadcastKey] as? Data else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([ActivitySyncSignedTombstone].self, from: data)) ?? []
    }

    /// Legacy diving-only UUID string arrays (pre-signed tombstone format).
    static func legacyUUIDs(from context: [String: Any], key: String) -> Set<UUID> {
        guard let strings = context[key] as? [String] else { return [] }
        return Set(strings.compactMap(UUID.init(uuidString:)))
    }
}

private extension Data {
    func constantTimeEquals(_ other: Data) -> Bool {
        guard count == other.count else { return false }
        return zip(self, other).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}
