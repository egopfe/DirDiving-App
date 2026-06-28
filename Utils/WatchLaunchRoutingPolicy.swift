import Foundation

/// How DIR Diving was opened for startup routing purposes.
enum WatchLaunchEntryPoint: Sendable, Equatable {
    /// Normal user-initiated cold launch (app icon, complication, etc.) on the surface.
    case userColdLaunch
    /// watchOS submerged auto-launch after a submersion probe at cold launch.
    case systemWaterAutoLaunch
    /// Explicit water-entry routing via App Intent or in-app "apply route now".
    case waterAutoLaunchIntent
}

enum WatchLaunchRoutingPolicy {
    static func shouldApplyWaterAutoOpenRouting(entry: WatchLaunchEntryPoint) -> Bool {
        switch entry {
        case .userColdLaunch:
            return false
        case .systemWaterAutoLaunch, .waterAutoLaunchIntent:
            return WatchWaterAutoOpenPolicy.mode != .disabled
        }
    }

    /// Resolves cold-launch entry after optional submersion probe. Icon launch on the surface stays normal.
    static func resolveColdLaunchEntryPoint(isSubmergedAtLaunch: Bool) -> WatchLaunchEntryPoint {
        guard isSubmergedAtLaunch,
              WatchAutomaticDepthLaunchConfiguration.isEnabled,
              WatchWaterAutoOpenPolicy.mode != .disabled else {
            return .userColdLaunch
        }
        return .systemWaterAutoLaunch
    }

    static func resolvedStartupStep(for entry: WatchLaunchEntryPoint) -> DIRStartupLaunchStep {
        if shouldApplyWaterAutoOpenRouting(entry: entry) {
            return DIRStartupSelectionPolicy.resolveWaterAutoLaunchStep()
        }
        return DIRStartupSelectionPolicy.resolveLaunchStep()
    }
}
