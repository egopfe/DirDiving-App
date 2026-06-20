import Foundation

/// Apnea iOS Companion cloud backup capability — separate from Diving iCloud KVS logbook backup.
enum ApneaCloudCapability: Equatable {
    case notAvailable(reason: NotAvailableReason)

    enum NotAvailableReason: Equatable {
        case notImplemented
        case localOnlyPolicy
    }

    /// Current product policy: Apnea sessions remain local-only; no upload path exists on iOS Companion.
    static var current: ApneaCloudCapability {
        .notAvailable(reason: .localOnlyPolicy)
    }

    var isUploadAvailable: Bool {
        switch self {
        case .notAvailable: return false
        }
    }

    var localizationNoteKey: String {
        switch self {
        case .notAvailable(.localOnlyPolicy):
            return "apnea.ios.export.cloud_backup_unavailable"
        case .notAvailable(.notImplemented):
            return "apnea.ios.export.cloud_backup_note"
        }
    }

    var localizationStatusKey: String {
        "apnea.ios.export.cloud_backup_status_unavailable"
    }
}

/// Legacy opt-in key retained for migration tests — never triggers upload.
enum ApneaCloudBackupPreference {
    static let enabledKey = "dirdiving_ios_apnea_cloud_backup_enabled"

    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: enabledKey)
    }

    static func setEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: enabledKey)
    }

    /// Clears stale opt-in when capability is unavailable so no dead toggle state remains active.
    static func reconcileWithCapability(_ capability: ApneaCloudCapability = .current) {
        guard !capability.isUploadAvailable, isEnabled else { return }
        setEnabled(false)
    }
}
