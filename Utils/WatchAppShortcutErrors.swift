import Foundation

enum DIRDivingShortcutError: LocalizedError {
    case appStateUnavailable
    case stopwatchResetBlocked
    case legalAcceptanceRequired
    case legacyIntentBlockedDuringActiveSession
    case noActiveDivingSession
    case waterAutoOpenModeDisabled

    var errorDescription: String? {
        switch self {
        case .appStateUnavailable:
            return String(localized: "shortcut.error.app_unavailable")
        case .stopwatchResetBlocked:
            return String(localized: "shortcut.error.stopwatch_reset_blocked")
        case .legalAcceptanceRequired:
            return String(localized: "shortcut.error.legal_acceptance_required")
        case .legacyIntentBlockedDuringActiveSession:
            return String(localized: "shortcut.error.legacy_blocked_active_session")
        case .noActiveDivingSession:
            return String(localized: "shortcut.error.no_active_diving_session")
        case .waterAutoOpenModeDisabled:
            return String(localized: "shortcut.error.water_auto_open_disabled")
        }
    }
}
