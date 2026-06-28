import Foundation

/// Reads Watch Info.plist flags related to watchOS submerged auto-launch eligibility.
enum WatchAutomaticDepthLaunchConfiguration {
    static var isEnabled: Bool {
        Bundle.main.infoDictionary?["WKSupportsAutomaticDepthLaunch"] as? Bool ?? false
    }

    static var hasUnderwaterDepthBackgroundMode: Bool {
        let modes = Bundle.main.infoDictionary?["WKBackgroundModes"] as? [String] ?? []
        return modes.contains("underwater-depth")
    }
}
