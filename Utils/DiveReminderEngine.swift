import Foundation

enum DiveReminderEngine {
    static func evaluate(
        runtimeSeconds: TimeInterval,
        runtimeMinute: Int,
        settings: DiveReminderSettings,
        state: inout DiveReminderRuntimeState
    ) -> [DiveReminder] {
        guard settings.remindersEnabled else { return [] }
        var triggered: [DiveReminder] = []
        for reminder in settings.reminders where reminder.enabled {
            switch reminder.type {
            case .single:
                let threshold = TimeInterval(reminder.triggerMinute * 60)
                guard runtimeSeconds >= threshold, !state.firedSingleReminderIDs.contains(reminder.id) else { continue }
                state.firedSingleReminderIDs.insert(reminder.id)
                triggered.append(reminder)
            case .recurring:
                let interval = reminder.repeatEveryMinutes ?? reminder.triggerMinute
                guard interval >= DiveReminderLimits.minuteRange.lowerBound,
                      runtimeMinute >= interval,
                      runtimeMinute > 0,
                      runtimeMinute % interval == 0 else { continue }
                guard state.lastFiredMinuteByReminderID[reminder.id] != runtimeMinute else { continue }
                state.lastFiredMinuteByReminderID[reminder.id] = runtimeMinute
                triggered.append(reminder)
            }
        }
        return triggered
    }

    static func makeOverlay(for reminders: [DiveReminder], runtimeMinute: Int) -> DiveReminderOverlayContent {
        let messages = reminders.map(\.message)
        let shouldHaptic = reminders.contains(where: \.hapticEnabled)
        if reminders.count == 1 {
            return DiveReminderOverlayContent(
                title: String(localized: "dive_reminder.overlay.single_title"),
                messages: messages,
                hiddenCount: 0,
                runtimeMinute: runtimeMinute,
                shouldHaptic: shouldHaptic
            )
        }
        let visible = Array(messages.prefix(2))
        let hiddenCount = max(0, messages.count - visible.count)
        return DiveReminderOverlayContent(
            title: String(format: String(localized: "dive_reminder.overlay.multiple_title_format"), reminders.count),
            messages: visible,
            hiddenCount: hiddenCount,
            runtimeMinute: runtimeMinute,
            shouldHaptic: shouldHaptic
        )
    }
}
