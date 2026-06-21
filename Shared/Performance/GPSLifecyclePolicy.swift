import CoreLocation
import Foundation

/// Documents and counts Watch GPS lifecycle transitions for battery-policy verification.
enum GPSLifecyclePolicy {
    enum Transition: String, Sendable {
        case diveSessionStart = "dive_session_start"
        case diveSessionStop = "dive_session_stop"
        case bestEffortCaptureStart = "best_effort_capture_start"
        case bestEffortCaptureStop = "best_effort_capture_stop"
        case authorizationCallbackIgnoredInactive = "auth_callback_ignored_inactive"
        case snorkelingSessionStart = "snorkeling_session_start"
        case snorkelingSessionStop = "snorkeling_session_stop"
    }

    static let diveDistanceFilterMeters: CLLocationDistance = 5
    static let diveDesiredAccuracy = "kCLLocationAccuracyBest"

    static var testHook_transitionCounts: [Transition: Int] = [:]

    static func record(_ transition: Transition) {
        testHook_transitionCounts[transition, default: 0] += 1
    }

    static func resetTestHook() {
        testHook_transitionCounts = [:]
    }

    /// GPS must not restart from authorization callbacks when no dive owner and no capture is active.
    static func shouldRestartUpdatesAfterAuthorization(
        maintainsLocationUpdates: Bool,
        hasActiveBestEffortCapture: Bool
    ) -> Bool {
        maintainsLocationUpdates || hasActiveBestEffortCapture
    }
}
