import Foundation

/// How DIR Diving was opened for startup routing purposes.
enum WatchLaunchEntryPoint: Sendable, Equatable {
    /// Normal user-initiated cold launch (app icon, complication, etc.).
    case userColdLaunch
    /// Explicit water-entry routing via App Intent or in-app "apply route now".
    case waterAutoLaunchIntent
}

enum WatchLaunchRoutingPolicy {
    /// Normal cold launch must never infer water submersion. Water routing applies only on explicit entry paths.
    static func shouldApplyWaterAutoOpenRouting(entry: WatchLaunchEntryPoint) -> Bool {
        switch entry {
        case .userColdLaunch:
            return false
        case .waterAutoLaunchIntent:
            return WatchWaterAutoOpenPolicy.mode != .disabled
        }
    }

    static func resolvedStartupStep(for entry: WatchLaunchEntryPoint) -> DIRStartupLaunchStep {
        if shouldApplyWaterAutoOpenRouting(entry: entry) {
            return DIRStartupSelectionPolicy.resolveWaterAutoLaunchStep()
        }
        return DIRStartupSelectionPolicy.resolveLaunchStep()
    }
}
