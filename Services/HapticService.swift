import Foundation
import WatchKit

@MainActor
final class HapticService {
    static let shared = HapticService()
    static let hapticsEnabledKey = "dirdiving_watch_haptics_enabled"
    static let experimentalHapticsEnabledKey = "dirdiving_watch_experimental_haptics_enabled"
    private var lastWarningDate: Date?
    private var lastAscentAlarmRepeatDate: Date?
    private var ascentAlarmSessionActive = false
    private var lastBuddyNearDate: Date?
    private var lastBuddyDistantDate: Date?
    private var lastReminderPulseDate: Date?

    /// Minimum interval between repeated ascent-alarm haptics while the banner is active.
    static let ascentAlarmRepeatInterval: TimeInterval = 1.75

    var testHook_now: () -> Date = { Date() }
    var testHook_playHandler: ((WKHapticType) -> Void)?

    private init() {
        if UserDefaults.standard.object(forKey: Self.hapticsEnabledKey) == nil {
            UserDefaults.standard.set(true, forKey: Self.hapticsEnabledKey)
        }
    }

    func resetThrottleStateForTests() {
        lastWarningDate = nil
        lastAscentAlarmRepeatDate = nil
        ascentAlarmSessionActive = false
        lastBuddyNearDate = nil
        lastBuddyDistantDate = nil
        lastReminderPulseDate = nil
    }

    func warnIfNeeded() {
        guard hapticsEnabled else { return }
        let now = testHook_now()
        if let lastWarningDate, now.timeIntervalSince(lastWarningDate) < 2 { return }
        lastWarningDate = now
        play(.failure)
    }

    /// Strong warning when ascent speed first exceeds the configured limit.
    func ascentAlarmTriggered() {
        ascentAlarmSessionActive = true
        lastAscentAlarmRepeatDate = testHook_now()
        guard hapticsEnabled else { return }
        lastWarningDate = testHook_now()
        play(.failure)
    }

    var isAscentAlarmSessionActive: Bool { ascentAlarmSessionActive }

    /// Repeating ascent warning while the inline alarm banner stays visible.
    func ascentAlarmRepeatIfNeeded() {
        guard hapticsEnabled, ascentAlarmSessionActive else { return }
        let now = testHook_now()
        if let lastAscentAlarmRepeatDate,
           now.timeIntervalSince(lastAscentAlarmRepeatDate) < Self.ascentAlarmRepeatInterval {
            return
        }
        lastAscentAlarmRepeatDate = now
        lastWarningDate = now
        play(.failure)
    }

    func ascentAlarmCleared() {
        ascentAlarmSessionActive = false
        lastAscentAlarmRepeatDate = nil
    }

    func confirm() {
        guard hapticsEnabled else { return }
        play(.success)
    }

    func criticalConfirm() {
        guard hapticsEnabled else { return }
        play(.notification)
    }

    func notify() {
        guard hapticsEnabled else { return }
        play(.notification)
    }

    func reminderPulseIfNeeded() {
        guard hapticsEnabled else { return }
        let now = testHook_now()
        if let lastReminderPulseDate, now.timeIntervalSince(lastReminderPulseDate) < 2 { return }
        lastReminderPulseDate = now
        play(.notification)
    }

    func tick() {
        guard experimentalHapticsEnabled else { return }
        WKInterfaceDevice.current().play(.click)
    }

    func nonCriticalFailure() {
        notify()
    }

    func buddyMessageReceived(isCritical: Bool) {
        guard hapticsEnabled else { return }
        play(isCritical ? .failure : .notification)
    }

    func buddyNearPulseIfNeeded() {
        guard hapticsEnabled else { return }
        let now = testHook_now()
        if let lastBuddyNearDate, now.timeIntervalSince(lastBuddyNearDate) < 8 { return }
        lastBuddyNearDate = now
        play(.directionUp)
    }

    func buddyDistantPulseIfNeeded() {
        guard hapticsEnabled else { return }
        let now = testHook_now()
        if let lastBuddyDistantDate, now.timeIntervalSince(lastBuddyDistantDate) < 12 { return }
        lastBuddyDistantDate = now
        play(.retry)
    }

    private func play(_ type: WKHapticType) {
        if let testHook_playHandler {
            testHook_playHandler(type)
            return
        }
        WKInterfaceDevice.current().play(type)
    }

    private var hapticsEnabled: Bool {
        UserDefaults.standard.object(forKey: Self.hapticsEnabledKey) == nil
            ? true
            : UserDefaults.standard.bool(forKey: Self.hapticsEnabledKey)
    }

    private var experimentalHapticsEnabled: Bool {
        UserDefaults.standard.object(forKey: Self.experimentalHapticsEnabledKey) == nil
            ? true
            : UserDefaults.standard.bool(forKey: Self.experimentalHapticsEnabledKey)
    }
}
