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

    /// Experimental branch exposes Diving, Apnea, Snorkeling, and Buddy Lab entry points.
    /// Production `main` sets this to `false` (startup flow + Settings only).
    static let hasMultipleStableModes = true
}
