import Foundation

@MainActor
enum WatchIntentSafetyPolicy {
    static func isAnySessionActive() -> Bool {
        if let apnea = ApneaWatchRuntimeStore.shared, apnea.isSessionActive {
            return true
        }
        if let snorkeling = SnorkelingWatchRuntimeStore.shared, snorkeling.isSessionActive {
            return true
        }
        guard let dive = DiveManager.shared else { return false }
        return dive.isDiveActive
    }

    static func isDivingSessionActive() -> Bool {
        DiveManager.shared?.isDiveActive == true
    }

    /// Routes through the underwater primary-action router when any session is active. Returns true when handled.
    static func routePrimaryActionIfUnderwaterSession() throws -> Bool {
        guard isAnySessionActive() else { return false }
        guard let router = WatchUnderwaterActionRouter.shared else {
            throw DIRDivingShortcutError.appStateUnavailable
        }
        try router.executePrimaryAction()
        return true
    }

    static func requireNoActiveUnderwaterSessionForLegacyIntent() throws {
        if isAnySessionActive() {
            throw DIRDivingShortcutError.legacyIntentBlockedDuringActiveSession
        }
    }

    static func requireActiveDivingSessionForEndManualDive() throws {
        if ApneaWatchRuntimeStore.shared?.isSessionActive == true
            || SnorkelingWatchRuntimeStore.shared?.isSessionActive == true {
            throw DIRDivingShortcutError.legacyIntentBlockedDuringActiveSession
        }
        guard DiveManager.shared?.isDiveActive == true else {
            throw DIRDivingShortcutError.noActiveDivingSession
        }
    }
}
