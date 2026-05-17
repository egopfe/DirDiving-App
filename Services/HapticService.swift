import Foundation
import WatchKit

@MainActor
final class HapticService {
    static let shared = HapticService()
    static let hapticsEnabledKey = "dirdiving_watch_haptics_enabled"
    private var lastWarningDate: Date?
    private var lastBuddyNearDate: Date?
    private var lastBuddyDistantDate: Date?

    private init() {
        if UserDefaults.standard.object(forKey: Self.hapticsEnabledKey) == nil {
            UserDefaults.standard.set(true, forKey: Self.hapticsEnabledKey)
        }
    }

    func warnIfNeeded() {
        guard hapticsEnabled else { return }
        let now = Date()
        if let lastWarningDate, now.timeIntervalSince(lastWarningDate) < 2 { return }
        lastWarningDate = now
        WKInterfaceDevice.current().play(.failure)
    }

    func confirm() {
        guard hapticsEnabled else { return }
        WKInterfaceDevice.current().play(.success)
    }

    func notify() {
        guard hapticsEnabled else { return }
        WKInterfaceDevice.current().play(.notification)
    }

    func buddyMessageReceived(isCritical: Bool) {
        guard hapticsEnabled else { return }
        WKInterfaceDevice.current().play(isCritical ? .failure : .notification)
    }

    func buddyNearPulseIfNeeded() {
        guard hapticsEnabled else { return }
        let now = Date()
        if let lastBuddyNearDate, now.timeIntervalSince(lastBuddyNearDate) < 8 { return }
        lastBuddyNearDate = now
        WKInterfaceDevice.current().play(.directionUp)
    }

    func buddyDistantPulseIfNeeded() {
        guard hapticsEnabled else { return }
        let now = Date()
        if let lastBuddyDistantDate, now.timeIntervalSince(lastBuddyDistantDate) < 12 { return }
        lastBuddyDistantDate = now
        WKInterfaceDevice.current().play(.retry)
    }

    private var hapticsEnabled: Bool {
        UserDefaults.standard.object(forKey: Self.hapticsEnabledKey) == nil
            ? true
            : UserDefaults.standard.bool(forKey: Self.hapticsEnabledKey)
    }
}
