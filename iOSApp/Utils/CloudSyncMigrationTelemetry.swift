import Foundation

/// Non-sensitive counters for legacy KVS migration monitoring (no dive payload data).
enum CloudSyncMigrationTelemetry {
    private static let legacyOversizedKey = "dirdiving.cloud.migration.legacy_oversized_ignored"
    private static let partialMigrationKey = "dirdiving.cloud.migration.partial_kept_local"
    private static let migrationAttemptKey = "dirdiving.cloud.migration.attempt_count"

    static func recordLegacyOversizedIgnored(storageKey: String) {
        increment(legacyOversizedKey)
        _ = storageKey
    }

    static func recordPartialMigrationKeptLocal() {
        increment(partialMigrationKey)
    }

    static func recordMigrationAttempt() {
        increment(migrationAttemptKey)
    }

    static var legacyOversizedIgnoredCount: Int {
        UserDefaults.standard.integer(forKey: legacyOversizedKey)
    }

    static var partialMigrationKeptLocalCount: Int {
        UserDefaults.standard.integer(forKey: partialMigrationKey)
    }

    static var migrationAttemptCount: Int {
        UserDefaults.standard.integer(forKey: migrationAttemptKey)
    }

    static func resetForTests() {
        UserDefaults.standard.removeObject(forKey: legacyOversizedKey)
        UserDefaults.standard.removeObject(forKey: partialMigrationKey)
        UserDefaults.standard.removeObject(forKey: migrationAttemptKey)
    }

    private static func increment(_ key: String) {
        let value = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(value + 1, forKey: key)
    }
}
