import Foundation

/// Activity-scoped cloud backup capability model (SYNC-P1-002).
enum CloudBackupCapability: Equatable {
    case available(configured: Bool)
    case explicitlyUnavailable(reason: UnavailableReason)

    enum UnavailableReason: Equatable {
        case notImplemented
        case localOnlyPolicy
    }

    enum Activity: CaseIterable {
        case diving
        case apnea
        case snorkeling

        var preferenceKey: String? {
            switch self {
            case .diving: return CloudBackupCapability.divingEnabledKey
            case .apnea, .snorkeling: return nil
            }
        }
    }

    static let divingEnabledKey = "dirdiving_ios_diving_cloud_backup_enabled"
    static let legacySharedEnabledKey = "dirdiving_ios_cloud_backup_enabled"
    static let migrationVersionKey = "dirdiving_ios_cloud_backup_migration_v1"

    static func capability(for activity: Activity) -> CloudBackupCapability {
        switch activity {
        case .diving:
            return .available(configured: isDivingEnabled)
        case .apnea:
            return .explicitlyUnavailable(reason: .localOnlyPolicy)
        case .snorkeling:
            return .explicitlyUnavailable(reason: .localOnlyPolicy)
        }
    }

    static var isDivingEnabled: Bool {
        UserDefaults.standard.bool(forKey: divingEnabledKey)
    }

    static func setDivingEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: divingEnabledKey)
    }

    /// One-time migration: shared opt-in applies to Diving only; Apnea/Snorkeling never auto-opted.
    static func migrateLegacySharedKeyIfNeeded() {
        let defaults = UserDefaults.standard
        guard defaults.integer(forKey: migrationVersionKey) < 1 else { return }
        if defaults.object(forKey: divingEnabledKey) == nil,
           defaults.bool(forKey: legacySharedEnabledKey) {
            defaults.set(true, forKey: divingEnabledKey)
        }
        defaults.set(1, forKey: migrationVersionKey)
    }

    var isUploadAvailable: Bool {
        switch self {
        case .available: return true
        case .explicitlyUnavailable: return false
        }
    }

    func localizationStatusKey(for activity: Activity) -> String {
        switch (activity, self) {
        case (.diving, .available(let configured)):
            return configured ? "more.cloud_backup.enabled" : "more.cloud_backup.disabled"
        case (.apnea, .explicitlyUnavailable):
            return ApneaCloudCapability.current.localizationStatusKey
        case (.snorkeling, .explicitlyUnavailable):
            return SnorkelingCloudCapability.current.localizationStatusKey
        default:
            return "more.cloud_backup.disabled"
        }
    }

    func localizationNoteKey(for activity: Activity) -> String? {
        switch (activity, self) {
        case (.diving, .available):
            return nil
        case (.apnea, .explicitlyUnavailable):
            return ApneaCloudCapability.current.localizationNoteKey
        case (.snorkeling, .explicitlyUnavailable):
            return SnorkelingCloudCapability.current.localizationNoteKey
        default:
            return nil
        }
    }
}
