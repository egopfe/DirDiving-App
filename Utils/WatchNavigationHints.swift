import Foundation

/// AppStorage keys and helpers for first-run Watch navigation coach marks.
enum WatchNavigationHints {
    static let crownHintDismissedKey = "dirdiving_watch_crown_hint_dismissed"

    static var crownHintDismissed: Bool {
        UserDefaults.standard.bool(forKey: crownHintDismissedKey)
    }

    static func dismissCrownHint() {
        UserDefaults.standard.set(true, forKey: crownHintDismissedKey)
    }
}
