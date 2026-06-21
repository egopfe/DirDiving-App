import Foundation

/// Deterministic Watch Settings presentation inputs for FC_UI_04 (Command 14).
struct WatchSettingsActivityDefaultSnapshot: Equatable, Hashable {
    var showActivitySelectionAtLaunch: Bool
    var defaultActivityMode: DIRActivityMode
    var defaultDivingMode: DIRDivingMode
    var gaugeShowsTTV: Bool
    var selectedActivity: DIRActivityMode
}

enum WatchSettingsMockupFixtures {
    static let fixtureKey = "settings_activity_default"

    /// Matches FC_UI_04 — startup section with activity default visible (diving selected).
    static func settingsActivityDefault() -> WatchSettingsActivityDefaultSnapshot {
        WatchSettingsActivityDefaultSnapshot(
            showActivitySelectionAtLaunch: true,
            defaultActivityMode: .diving,
            defaultDivingMode: .fullComputer,
            gaugeShowsTTV: false,
            selectedActivity: .diving
        )
    }
}
