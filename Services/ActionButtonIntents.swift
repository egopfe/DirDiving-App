import AppIntents
import Foundation

struct ToggleStopwatchIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.toggle_stopwatch.title"
    static var description: IntentDescription {
        IntentDescription(LocalizedStringResource("intent.toggle_stopwatch.description"))
    }

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            guard let manager = DiveManager.shared else {
                throw DIRDivingShortcutError.appStateUnavailable
            }
            manager.toggleStopwatch()
        }
        return .result()
    }
}

struct ResetStopwatchIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.reset_stopwatch.title"
    static var description: IntentDescription {
        IntentDescription(LocalizedStringResource("intent.reset_stopwatch.description"))
    }

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            guard let manager = DiveManager.shared else {
                throw DIRDivingShortcutError.appStateUnavailable
            }
            if manager.stopwatchTime > 0 {
                throw DIRDivingShortcutError.stopwatchResetBlocked
            }
            manager.resetStopwatch()
        }
        return .result()
    }
}

struct StartManualDiveIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.start_manual_dive.title"
    static var description: IntentDescription {
        IntentDescription(LocalizedStringResource("intent.start_manual_dive.description"))
    }

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            guard let manager = DiveManager.shared else {
                throw DIRDivingShortcutError.appStateUnavailable
            }
            manager.startManualDive()
        }
        return .result()
    }
}

struct EndManualDiveIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.end_manual_dive.title"
    static var description: IntentDescription {
        IntentDescription(LocalizedStringResource("intent.end_manual_dive.description"))
    }

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            guard let manager = DiveManager.shared else {
                throw DIRDivingShortcutError.appStateUnavailable
            }
            manager.endManualDive()
        }
        return .result()
    }
}

struct SetBearingIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.set_bearing.title"
    static var description: IntentDescription {
        IntentDescription(LocalizedStringResource("intent.set_bearing.description"))
    }

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            guard let compass = CompassManager.shared else {
                throw DIRDivingShortcutError.appStateUnavailable
            }
            compass.setBearing()
            HapticService.shared.confirm()
        }
        return .result()
    }
}

struct ClearBearingIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.clear_bearing.title"
    static var description: IntentDescription {
        IntentDescription(LocalizedStringResource("intent.clear_bearing.description"))
    }

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            guard let compass = CompassManager.shared else {
                throw DIRDivingShortcutError.appStateUnavailable
            }
            compass.clearBearing()
            HapticService.shared.confirm()
        }
        return .result()
    }
}

struct AcknowledgeAlarmIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.ack_alarm.title"
    static var description: IntentDescription {
        IntentDescription(LocalizedStringResource("intent.ack_alarm.description"))
    }

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            guard let manager = DiveManager.shared else {
                throw DIRDivingShortcutError.appStateUnavailable
            }
            manager.dismissAlarmWarning()
        }
        return .result()
    }
}

private enum DIRDivingShortcutError: LocalizedError {
    case appStateUnavailable
    case stopwatchResetBlocked

    var errorDescription: String? {
        switch self {
        case .appStateUnavailable:
            return String(localized: "shortcut.error.app_unavailable")
        case .stopwatchResetBlocked:
            return String(localized: "shortcut.error.stopwatch_reset_blocked")
        }
    }
}

struct DIRDivingAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ToggleStopwatchIntent(),
            phrases: [
                "Toggle stopwatch in \(.applicationName)",
                "Start or stop stopwatch in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("intent.shortcut.stopwatch"),
            systemImageName: "stopwatch"
        )
        AppShortcut(
            intent: ResetStopwatchIntent(),
            phrases: [
                "Reset stopwatch in \(.applicationName)",
                "Reset DIR stopwatch in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("intent.shortcut.reset_stopwatch"),
            systemImageName: "arrow.counterclockwise"
        )
        AppShortcut(
            intent: StartManualDiveIntent(),
            phrases: ["Start manual dive in \(.applicationName)"],
            shortTitle: LocalizedStringResource("intent.shortcut.manual_start"),
            systemImageName: "figure.water.fitness"
        )
        AppShortcut(
            intent: EndManualDiveIntent(),
            phrases: ["End manual dive in \(.applicationName)"],
            shortTitle: LocalizedStringResource("intent.shortcut.manual_end"),
            systemImageName: "figure.water.fitness"
        )
        AppShortcut(
            intent: SetBearingIntent(),
            phrases: ["Set bearing in \(.applicationName)"],
            shortTitle: LocalizedStringResource("intent.shortcut.set_bearing"),
            systemImageName: "location.north.line"
        )
        AppShortcut(
            intent: ClearBearingIntent(),
            phrases: ["Clear bearing in \(.applicationName)"],
            shortTitle: LocalizedStringResource("intent.shortcut.clear_bearing"),
            systemImageName: "location.slash"
        )
        AppShortcut(
            intent: AcknowledgeAlarmIntent(),
            phrases: ["Acknowledge alarm in \(.applicationName)"],
            shortTitle: LocalizedStringResource("intent.shortcut.ack_alarm"),
            systemImageName: "bell.slash"
        )
    }
}
