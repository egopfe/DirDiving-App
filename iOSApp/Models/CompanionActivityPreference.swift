import Foundation

/// iOS Companion activity preference — separate from Watch runtime startup state.
struct CompanionActivityPreference: Codable, Equatable {
    static let currentSchemaVersion = 1

    var selectedMode: DIRActivityMode?
    var showActivitySelectionAtLaunch: Bool
    var hasCompletedPostOnboardingSelection: Bool
    var schemaVersion: Int

    static let initial = CompanionActivityPreference(
        selectedMode: nil,
        showActivitySelectionAtLaunch: false,
        hasCompletedPostOnboardingSelection: false,
        schemaVersion: currentSchemaVersion
    )

    static func legacyDivingMigration() -> CompanionActivityPreference {
        CompanionActivityPreference(
            selectedMode: .diving,
            showActivitySelectionAtLaunch: false,
            hasCompletedPostOnboardingSelection: true,
            schemaVersion: currentSchemaVersion
        )
    }
}

enum CompanionActivityAvailability {
    static func isAvailable(_ mode: DIRActivityMode) -> Bool {
        mode.isLaunchableInMAIN
    }
}

enum CompanionActivityWatchSessionGuard {
    /// iOS navigation may change locally; defer Watch preference sync when a session is active.
    static func shouldDeferPreferenceSync(watchReportsActiveSession: Bool) -> Bool {
        watchReportsActiveSession
    }
}
