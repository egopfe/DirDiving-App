import AppIntents
import Foundation

struct ToggleStopwatchIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle DIR DIVING Stopwatch"
    static var description = IntentDescription("Start or stop the DIR DIVING manual stopwatch.")

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
    static var title: LocalizedStringResource = "Reset DIR DIVING Stopwatch"
    static var description = IntentDescription("Reset the DIR DIVING manual stopwatch.")

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            guard let manager = DiveManager.shared else {
                throw DIRDivingShortcutError.appStateUnavailable
            }
            manager.resetStopwatch()
        }
        return .result()
    }
}

struct StartManualDiveIntent: AppIntent {
    static var title: LocalizedStringResource = "Start DIR DIVING Manual Dive"
    static var description = IntentDescription("Start a manual DIR DIVING session when depth automation is unavailable.")

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
    static var title: LocalizedStringResource = "End DIR DIVING Manual Dive"
    static var description = IntentDescription("End the current manual DIR DIVING session.")

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
    static var title: LocalizedStringResource = "Set DIR DIVING Bearing"
    static var description = IntentDescription("Save the current compass heading as the DIR DIVING bearing.")

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
    static var title: LocalizedStringResource = "Clear DIR DIVING Bearing"
    static var description = IntentDescription("Clear the saved DIR DIVING bearing.")

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            guard let compass = CompassManager.shared else {
                throw DIRDivingShortcutError.appStateUnavailable
            }
            compass.clearBearing()
            HapticService.shared.notify()
        }
        return .result()
    }
}

struct AcknowledgeAlarmIntent: AppIntent {
    static var title: LocalizedStringResource = "Acknowledge DIR DIVING Alarm"
    static var description = IntentDescription("Dismiss the current depth, time, or battery alarm banner.")

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

    var errorDescription: String? {
        "DIR DIVING non e pronto: apri l'app sul Watch e riprova."
    }
}

struct DIRDivingAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ToggleStopwatchIntent(),
            phrases: ["Toggle stopwatch in \(.applicationName)"],
            shortTitle: "Stopwatch",
            systemImageName: "stopwatch"
        )
        AppShortcut(
            intent: ResetStopwatchIntent(),
            phrases: ["Reset stopwatch in \(.applicationName)"],
            shortTitle: "Reset Stopwatch",
            systemImageName: "arrow.counterclockwise"
        )
    }
}
