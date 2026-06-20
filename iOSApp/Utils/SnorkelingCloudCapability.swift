import Foundation

/// Snorkeling iOS Companion cloud backup capability — separate from Diving iCloud KVS logbook backup.
enum SnorkelingCloudCapability: Equatable {
    case notAvailable(reason: NotAvailableReason)

    enum NotAvailableReason: Equatable {
        case notImplemented
        case localOnlyPolicy
    }

    /// Current product policy: Snorkeling sessions remain local-only; no upload path exists on iOS Companion.
    static var current: SnorkelingCloudCapability {
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
            return "snorkeling.ios.export.cloud_backup_unavailable"
        case .notAvailable(.notImplemented):
            return "snorkeling.ios.export.cloud_backup_note"
        }
    }

    var localizationStatusKey: String {
        "snorkeling.ios.export.cloud_backup_status_unavailable"
    }
}

enum SnorkelingCloudBackupPreference {
    static let enabledKey = "dirdiving_ios_snorkeling_cloud_backup_enabled"

    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: enabledKey)
    }

    static func setEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: enabledKey)
    }

    static func reconcileWithCapability(_ capability: SnorkelingCloudCapability = .current) {
        guard !capability.isUploadAvailable, isEnabled else { return }
        setEnabled(false)
    }
}
