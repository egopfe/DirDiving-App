import Foundation

/// One-shot flag: after legal onboarding acceptance, land on Planner mode selection.
enum IOSCompanionPostLegalEntry {
    private static var pendingPlannerModeSelectionLanding = false

    static func markPendingPlannerLanding() {
        pendingPlannerModeSelectionLanding = true
    }

    static func consumePendingPlannerLanding() -> Bool {
        let pending = pendingPlannerModeSelectionLanding
        pendingPlannerModeSelectionLanding = false
        return pending
    }

    #if DEBUG
    static func resetForTesting() {
        pendingPlannerModeSelectionLanding = false
    }
    #endif
}
