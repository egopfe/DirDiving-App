import UIKit

/// Centralized haptic vocabulary for iOS destructive, import/export and sync
/// events (PHASE 5). The Watch retains its own `HapticService`; this is the
/// iPhone-side companion wrapper. All calls are main-actor noops on devices
/// without a Taptic Engine — UIKit handles that downgrade transparently.
@MainActor
enum HapticFeedback {
    /// Successful CSV import, conflict resolved, sync retry succeeded.
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// CSV import failure, Watch sync error, conflict rejected.
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    /// Soft confirmation for non-destructive actions (push to Watch, share).
    static func notify() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    /// Tap acknowledgement for tappable buttons that do not change data.
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// Confirmation impact for state-changing buttons (retry, sync now).
    static func confirm() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    /// Sharp impact used for destructive confirmations (delete dive, reset trust).
    static func destructive() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
}
