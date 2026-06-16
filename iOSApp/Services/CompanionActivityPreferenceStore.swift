import Combine
import Foundation

@MainActor
final class CompanionActivityPreferenceStore: ObservableObject {
    @Published private(set) var preference: CompanionActivityPreference
    @Published private(set) var shouldPresentSelectionScreen = false
    @Published private(set) var watchActiveSessionNote: String?

    private let defaults: UserDefaults
    private let storageKey = "dirdiving_ios_companion_activity_preference_v1"
    private let legalTimestampKey = "dirdiving_legal_acceptance_timestamp"
    private var consumedLaunchSelectionThisSession = false
    private var forceSelectionPresentation = false

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(CompanionActivityPreference.self, from: data) {
            preference = decoded
        } else {
            preference = Self.migrateLegacyIfNeeded(defaults: defaults)
            persist()
        }
        refreshPresentationState()
    }

    var selectedMode: DIRActivityMode? { preference.selectedMode }

    func refreshPresentationState() {
        if forceSelectionPresentation {
            shouldPresentSelectionScreen = true
            return
        }
        if !preference.hasCompletedPostOnboardingSelection {
            shouldPresentSelectionScreen = true
            return
        }
        if preference.showActivitySelectionAtLaunch && !consumedLaunchSelectionThisSession {
            shouldPresentSelectionScreen = true
            return
        }
        shouldPresentSelectionScreen = false
    }

    func requestActivitySelectionFromSettings() {
        forceSelectionPresentation = true
        refreshPresentationState()
    }

    func dismissSelectionScreenAfterChoice() {
        forceSelectionPresentation = false
        consumedLaunchSelectionThisSession = true
        refreshPresentationState()
    }

    func setShowActivitySelectionAtLaunch(_ enabled: Bool) {
        preference.showActivitySelectionAtLaunch = enabled
        persist()
        refreshPresentationState()
    }

    func select(_ mode: DIRActivityMode, watchReportsActiveSession: Bool = false) -> Bool {
        guard CompanionActivityAvailability.isAvailable(mode) else { return false }
        preference.selectedMode = mode
        preference.hasCompletedPostOnboardingSelection = true
        preference.schemaVersion = CompanionActivityPreference.currentSchemaVersion
        persist()
        updateWatchActiveSessionNote(watchReportsActiveSession: watchReportsActiveSession)
        dismissSelectionScreenAfterChoice()
        if mode == .diving {
            IOSCompanionPostLegalEntry.markPendingPlannerLanding()
        }
        return true
    }

    func updateWatchActiveSessionNote(watchReportsActiveSession: Bool) {
        if CompanionActivityWatchSessionGuard.shouldDeferPreferenceSync(
            watchReportsActiveSession: watchReportsActiveSession
        ) {
            watchActiveSessionNote = DIRIOSLocalizer.string("companion.activitySelection.watch_active_note")
        } else {
            watchActiveSessionNote = nil
        }
    }

    func localizedCurrentActivityTitle() -> String {
        guard let mode = preference.selectedMode else {
            return DIRIOSLocalizer.string("companion.settings.activity.none")
        }
        return CompanionActivityCopy.title(for: mode)
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(preference) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private static func migrateLegacyIfNeeded(defaults: UserDefaults) -> CompanionActivityPreference {
        // Users who accepted legal onboarding before this feature shipped keep Diving access.
        if defaults.object(forKey: "dirdiving_legal_acceptance_timestamp") != nil {
            return .legacyDivingMigration()
        }
        return .initial
    }

    #if DEBUG
    func resetForTesting() {
        defaults.removeObject(forKey: storageKey)
        preference = .initial
        consumedLaunchSelectionThisSession = false
        forceSelectionPresentation = false
        watchActiveSessionNote = nil
        refreshPresentationState()
    }

    func applyPreferenceForTesting(_ preference: CompanionActivityPreference) {
        self.preference = preference
        persist()
        refreshPresentationState()
    }
    #endif
}
