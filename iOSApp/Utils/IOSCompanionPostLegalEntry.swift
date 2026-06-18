import Foundation

/// One-shot flags for post-legal Companion landing coordination.
enum IOSCompanionPostLegalEntry {
    private static var pendingPlannerModeSelectionLanding = false
    private static var pendingActivitySelectionLanding = false
    private static var pendingApneaLanding = false
    private static var pendingSnorkelingLanding = false

    static func markPendingActivitySelection() {
        pendingActivitySelectionLanding = true
    }

    static func consumePendingActivitySelection() -> Bool {
        let pending = pendingActivitySelectionLanding
        pendingActivitySelectionLanding = false
        return pending
    }

    static func markPendingPlannerLanding() {
        pendingPlannerModeSelectionLanding = true
    }

    static func consumePendingPlannerLanding() -> Bool {
        let pending = pendingPlannerModeSelectionLanding
        pendingPlannerModeSelectionLanding = false
        return pending
    }

    static func markPendingApneaLanding() {
        pendingApneaLanding = true
    }

    static func consumePendingApneaLanding() -> Bool {
        let pending = pendingApneaLanding
        pendingApneaLanding = false
        return pending
    }

    static func markPendingSnorkelingLanding() {
        pendingSnorkelingLanding = true
    }

    static func consumePendingSnorkelingLanding() -> Bool {
        let pending = pendingSnorkelingLanding
        pendingSnorkelingLanding = false
        return pending
    }

    #if DEBUG
    static func resetForTesting() {
        pendingPlannerModeSelectionLanding = false
        pendingActivitySelectionLanding = false
        pendingApneaLanding = false
        pendingSnorkelingLanding = false
    }
    #endif
}
