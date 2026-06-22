import Foundation

/// iOS Companion activity preference — separate from Watch runtime startup state.
struct CompanionActivityPreference: Codable, Equatable {
    static let currentSchemaVersion = 2

    var selectedMode: DIRActivityMode?
    /// When true, cold launch shows activity selection before the activity root.
    var showActivitySelectionAtLaunch: Bool
    var hasCompletedPostOnboardingSelection: Bool
    var schemaVersion: Int

    static let initial = CompanionActivityPreference(
        selectedMode: nil,
        showActivitySelectionAtLaunch: true,
        hasCompletedPostOnboardingSelection: false,
        schemaVersion: currentSchemaVersion
    )

    static func legacyDivingMigration() -> CompanionActivityPreference {
        CompanionActivityPreference(
            selectedMode: .diving,
            showActivitySelectionAtLaunch: true,
            hasCompletedPostOnboardingSelection: true,
            schemaVersion: currentSchemaVersion
        )
    }

    /// One-time policy upgrade: launch selection on by default for saved v1 preferences.
    static func applyingLaunchSelectionPolicyMigration(_ preference: CompanionActivityPreference) -> CompanionActivityPreference {
        guard preference.schemaVersion < 2 else { return preference }
        var migrated = preference
        migrated.showActivitySelectionAtLaunch = true
        migrated.schemaVersion = currentSchemaVersion
        return migrated
    }
}

enum CompanionActivityAvailability {
    static func isAvailable(_ mode: DIRActivityMode) -> Bool {
        mode.isLaunchableOnIOSCompanionMAIN
    }
}

enum CompanionActivityWatchSessionGuard {
    /// iOS navigation may change locally; defer Watch preference sync when a session is active.
    static func shouldDeferPreferenceSync(watchReportsActiveSession: Bool) -> Bool {
        watchReportsActiveSession
    }
}
