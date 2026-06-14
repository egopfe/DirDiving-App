import Foundation

enum WatchSyncSchemaV1Policy {
    static let legacySchemaVersion = 1
    static let currentSchemaVersion = 2
    static let deprecationRemovalTarget = "2026-12-01"
    private static let usageCountKey = "dirdiving_ios_sync_v1_usage_count"

    enum ProtectedOperation: String, CaseIterable {
        case photoDelete
        case photoInventory
        case trustReset
        case briefingManagement
        case signedAck
    }

    static func allowsLegacyDiveSessionImport(version: Int) -> Bool {
        version == legacySchemaVersion || version == currentSchemaVersion
    }

    static func requiresNonceReplayProtection(version: Int) -> Bool {
        version >= currentSchemaVersion
    }

    static func rejectsProtectedOperationOverLegacySchema(_ operation: ProtectedOperation, payloadVersion: Int) -> Bool {
        payloadVersion < currentSchemaVersion
    }

    static func recordLegacyUsage() {
        let count = UserDefaults.standard.integer(forKey: usageCountKey)
        UserDefaults.standard.set(count + 1, forKey: usageCountKey)
    }

    static var legacyUsageCount: Int {
        UserDefaults.standard.integer(forKey: usageCountKey)
    }
}
