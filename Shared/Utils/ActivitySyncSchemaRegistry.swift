import Foundation

/// Central schema registry for sync/persistence surfaces (documentation + static validation).
struct ActivitySyncSchemaRecord: Equatable {
    let name: String
    let currentVersion: Int
    let ownerActivity: ActivitySyncActivityType?
    let platform: String
    let encoder: String
    let decoder: String
    let migrationPolicy: String
    let futureVersionPolicy: String
    let integrityPolicy: String
    let maximumSizeBytes: Int
    let tests: [String]
}

enum ActivitySyncSchemaRegistry {
    static let records: [ActivitySyncSchemaRecord] = [
        .init(
            name: "Diving session sync",
            currentVersion: ActivitySyncSignedTransport.envelopeSchemaVersion,
            ownerActivity: .diving,
            platform: "Watch+iOS",
            encoder: "WatchDiveSyncCodec",
            decoder: "WatchDiveSyncCodec",
            migrationPolicy: "v1 legacy; v2 HMAC+nonce; v3 signed envelope",
            futureVersionPolicy: "reject unsupportedVersion",
            integrityPolicy: "HMAC-SHA256 v2/v3 + bundle ID + nonce replay cache",
            maximumSizeBytes: ActivitySyncLargePayloadTransfer.maxPackageBytes,
            tests: ["DiveSessionSyncTransportNegativeTests", "ActivitySyncCrossDecodeRejectionTests"]
        ),
        .init(
            name: "Apnea session sync",
            currentVersion: ActivitySyncSignedTransport.envelopeSchemaVersion,
            ownerActivity: .apnea,
            platform: "Watch+iOS",
            encoder: "ApneaSessionSyncCodec",
            decoder: "ApneaSessionSyncCodec",
            migrationPolicy: "v1 legacy; v2 HMAC+nonce; v3 signed envelope",
            futureVersionPolicy: "reject unsupportedVersion",
            integrityPolicy: "HMAC-SHA256 v2/v3 + bundle ID + nonce replay cache",
            maximumSizeBytes: ActivitySyncLargePayloadTransfer.maxPackageBytes,
            tests: ["ApneaSessionSyncTransportNegativeTests", "ActivitySyncCrossDecodeRejectionTests"]
        ),
        .init(
            name: "Snorkeling session sync",
            currentVersion: ActivitySyncSignedTransport.envelopeSchemaVersion,
            ownerActivity: .snorkeling,
            platform: "Watch+iOS",
            encoder: "SnorkelingSessionSyncCodec",
            decoder: "SnorkelingSessionSyncCodec",
            migrationPolicy: "v1 legacy; v2 HMAC+nonce; v3 signed envelope",
            futureVersionPolicy: "reject unsupportedVersion",
            integrityPolicy: "HMAC-SHA256 v2/v3 + bundle ID + nonce replay cache",
            maximumSizeBytes: ActivitySyncLargePayloadTransfer.maxPackageBytes,
            tests: ["SnorkelingSessionSyncTransportNegativeTests", "ActivitySyncCrossDecodeRejectionTests"]
        ),
        .init(
            name: "Signed ACK",
            currentVersion: 2,
            ownerActivity: nil,
            platform: "Watch+iOS",
            encoder: "Per-codec ackSignature",
            decoder: "Per-codec verifyAckSignature",
            migrationPolicy: "activity-prefixed canonical strings",
            futureVersionPolicy: "reject unsigned or wrong activity ACK",
            integrityPolicy: "HMAC-SHA256 session-bound ACK",
            maximumSizeBytes: 512,
            tests: ["ActivitySyncSignedAckSymmetryTests"]
        ),
        .init(
            name: "Tombstone",
            currentVersion: ActivitySyncTombstoneRecord.currentSchemaVersion,
            ownerActivity: nil,
            platform: "Watch+iOS",
            encoder: "ActivitySyncTombstoneCodec",
            decoder: "ActivitySyncTombstoneCodec",
            migrationPolicy: "legacy diving UUID arrays + signed v1 records",
            futureVersionPolicy: "reject future schemaVersion",
            integrityPolicy: "HMAC-SHA256 per record",
            maximumSizeBytes: 64_000,
            tests: ["ActivitySyncTombstoneTests"]
        ),
        .init(
            name: "Large-transfer manifest",
            currentVersion: 1,
            ownerActivity: nil,
            platform: "Watch+iOS",
            encoder: "ActivitySyncLargePayloadTransfer",
            decoder: "ActivitySyncLargePayloadTransfer",
            migrationPolicy: "file transfer only; direct WC below 512KB",
            futureVersionPolicy: "reject unsupported schemaVersion in manifest",
            integrityPolicy: "manifest HMAC + transport signature + payload hash",
            maximumSizeBytes: ActivitySyncLargePayloadTransfer.maxPackageBytes,
            tests: ["ActivitySyncLargePayloadTransferTests"]
        ),
        .init(
            name: "Full Computer checkpoint",
            currentVersion: 1,
            ownerActivity: .diving,
            platform: "Watch",
            encoder: "FullComputerRuntimeCheckpointCodec",
            decoder: "FullComputerRuntimeCheckpointCodec",
            migrationPolicy: "v1 only; document v5 references were doc drift",
            futureVersionPolicy: "reject unsupported checkpoint schemaVersion",
            integrityPolicy: "checksum + path confinement",
            maximumSizeBytes: 256_000,
            tests: ["FullComputerRecoveryCheckpointTests"]
        ),
        .init(
            name: "Diving cloud archive",
            currentVersion: 1,
            ownerActivity: .diving,
            platform: "iOS",
            encoder: "DiveLogStore",
            decoder: "DiveLogStore",
            migrationPolicy: "CloudSyncLegacyMigrationPolicy",
            futureVersionPolicy: "reject future KVS schema",
            integrityPolicy: "iCloud KVS opt-in only",
            maximumSizeBytes: ActivitySyncLargePayloadTransfer.maxDirectPayloadBytes,
            tests: ["CloudBackupPolicyTests", "CloudBackupCapabilityTests"]
        ),
        .init(
            name: "Apnea local archive",
            currentVersion: ApneaLogbookFileEnvelope.currentSchemaVersion,
            ownerActivity: .apnea,
            platform: "Watch+iOS",
            encoder: "ApneaLogbookPersistence",
            decoder: "ApneaLogbookPersistence",
            migrationPolicy: "ApneaSchemaMigration",
            futureVersionPolicy: "reject future envelope schemaVersion",
            integrityPolicy: "atomic write + checksum envelope",
            maximumSizeBytes: ActivitySyncLargePayloadTransfer.maxPackageBytes,
            tests: ["ApneaLogbookPersistenceTests"]
        ),
        .init(
            name: "Snorkeling local archive",
            currentVersion: SnorkelingLogbookFileEnvelope.currentSchemaVersion,
            ownerActivity: .snorkeling,
            platform: "Watch+iOS",
            encoder: "SnorkelingLogbookPersistence",
            decoder: "SnorkelingLogbookPersistence",
            migrationPolicy: "SnorkelingSchemaMigration",
            futureVersionPolicy: "reject future envelope schemaVersion",
            integrityPolicy: "atomic write + checksum envelope",
            maximumSizeBytes: ActivitySyncLargePayloadTransfer.maxPackageBytes,
            tests: ["SnorkelingLogbookPersistenceTests"]
        ),
    ]

    static func record(named name: String) -> ActivitySyncSchemaRecord? {
        records.first { $0.name == name }
    }

    static func verifyUniqueCurrentVersions() -> [String] {
        var violations: [String] = []
        for record in records {
            if record.currentVersion < 1 {
                violations.append("\(record.name) invalid currentVersion")
            }
        }
        return violations
    }
}
