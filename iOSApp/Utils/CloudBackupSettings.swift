import Foundation

/// Diving-scoped iCloud KVS logbook backup opt-in (SYNC-P1-002). Default off for new installs.
enum CloudBackupSettings {
    static let enabledKey = CloudBackupCapability.divingEnabledKey

    static var isEnabled: Bool {
        CloudBackupCapability.migrateLegacySharedKeyIfNeeded()
        return CloudBackupCapability.isDivingEnabled
    }

    static func setEnabled(_ enabled: Bool) {
        CloudBackupCapability.migrateLegacySharedKeyIfNeeded()
        CloudBackupCapability.setDivingEnabled(enabled)
    }
}
