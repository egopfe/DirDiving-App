import Foundation

/// Full iCloud KVS logbook backup opt-in (SEC-P1-003). Default off for new installs.
enum CloudBackupSettings {
    static let enabledKey = "dirdiving_ios_cloud_backup_enabled"

    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: enabledKey)
    }

    static func setEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: enabledKey)
    }
}
