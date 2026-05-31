import Foundation

enum WatchModeSelectionPreferences {
    static let skipWhenSingleModeKey = "dirdiving_watch_skip_mode_selection_when_single"

    /// When true and only Diving is available, cold launch opens Live instead of Mode Selection.
    static var skipWhenSingleMode: Bool {
        get {
            if UserDefaults.standard.object(forKey: skipWhenSingleModeKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: skipWhenSingleModeKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: skipWhenSingleModeKey) }
    }

    /// Dormant until Snorkeling/Apnea ship in MAIN; Mode Selection stays hidden when false.
    static let hasMultipleStableModes = false
}
