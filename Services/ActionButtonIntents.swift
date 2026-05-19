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
