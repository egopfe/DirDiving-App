import Foundation
import WatchKit

@MainActor
final class HapticService {
    static let shared = HapticService()
    static let hapticsEnabledKey = "dirdiving_watch_haptics_enabled"
    private var lastWarningDate: Date?
    private var lastAscentAlarmRepeatDate: Date?
    private var ascentAlarmSessionActive = false
    private var lastBuddyNearDate: Date?
    private var lastBuddyDistantDate: Date?

    /// Minimum interval between repeated ascent-alarm haptics while the banner is active.
    static let ascentAlarmRepeatInterval: TimeInterval = 1.75

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

    /// Strong warning when ascent speed first exceeds the configured limit.
    func ascentAlarmTriggered() {
        guard hapticsEnabled else { return }
        ascentAlarmSessionActive = true
        lastAscentAlarmRepeatDate = Date()
        lastWarningDate = Date()
        WKInterfaceDevice.current().play(.failure)
    }

    /// Repeating ascent warning while the inline alarm banner stays visible.
    func ascentAlarmRepeatIfNeeded() {
        guard hapticsEnabled, ascentAlarmSessionActive else { return }
        let now = Date()
        if let lastAscentAlarmRepeatDate,
           now.timeIntervalSince(lastAscentAlarmRepeatDate) < Self.ascentAlarmRepeatInterval {
            return
        }
        lastAscentAlarmRepeatDate = now
        lastWarningDate = now
        WKInterfaceDevice.current().play(.failure)
    }

    func ascentAlarmCleared() {
        ascentAlarmSessionActive = false
        lastAscentAlarmRepeatDate = nil
    }

    func confirm() {
        guard hapticsEnabled else { return }
        WKInterfaceDevice.current().play(.success)
    }

    func criticalConfirm() {
        guard hapticsEnabled else { return }
        WKInterfaceDevice.current().play(.notification)
    }

    func notify() {
        guard hapticsEnabled else { return }
        WKInterfaceDevice.current().play(.notification)
    }

    func nonCriticalFailure() {
        notify()
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
