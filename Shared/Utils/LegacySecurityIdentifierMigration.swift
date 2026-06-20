import Foundation

/// Central registry for legacy `dirmotion` identifier migrations (SEC-P3-001).
enum LegacySecurityIdentifierMigration {
    static let migrationVersionKey = "dirdiving_legacy_security_identifier_migration_v1"
    static let completedVersion = 1

    struct LegacyKeychainServices {
        static let watchSync = "com.egopfe.dirmotion.watch-sync"
        static let canonicalWatchSync = "com.egopfe.dirdiving.watch-sync"
    }

    struct LegacyUserDefaultsKeys {
        static let ascentRateLimits = "dirmotion_ascent_rate_limits"
        static let canonicalAscentRateLimits = "dirdiving_ascent_rate_limits"
    }

    static func markCompletedIfNeeded() {
        let defaults = UserDefaults.standard
        guard defaults.integer(forKey: migrationVersionKey) < completedVersion else { return }
        defaults.set(completedVersion, forKey: migrationVersionKey)
    }

    static var isMigrationComplete: Bool {
        UserDefaults.standard.integer(forKey: migrationVersionKey) >= completedVersion
    }
}
