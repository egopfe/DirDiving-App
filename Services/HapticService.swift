import Foundation
import WatchKit

@MainActor
final class HapticService {
    static let shared = HapticService()
    static let experimentalHapticsEnabledKey = "dirdiving_watch_experimental_haptics_enabled"
    private var lastWarningDate: Date?
    private var lastBuddyNearDate: Date?
    private var lastBuddyDistantDate: Date?
    private init() {}

    func warnIfNeeded() {
        guard hapticsEnabled else { return }
        let now = Date()
        if let lastWarningDate, now.timeIntervalSince(lastWarningDate) < 2 { return }
        lastWarningDate = now
        WKInterfaceDevice.current().play(.failure)
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

    func confirm() {
        guard hapticsEnabled else { return }
        WKInterfaceDevice.current().play(.success)
    }

    func notify() {
        guard hapticsEnabled else { return }
        WKInterfaceDevice.current().play(.notification)
    }

    func tick() {
        guard hapticsEnabled else { return }
        WKInterfaceDevice.current().play(.click)
    }

    private var hapticsEnabled: Bool {
        UserDefaults.standard.object(forKey: Self.experimentalHapticsEnabledKey) == nil
            ? true
            : UserDefaults.standard.bool(forKey: Self.experimentalHapticsEnabledKey)
    }
}
