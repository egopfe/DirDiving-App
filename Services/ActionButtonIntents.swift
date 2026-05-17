import AppIntents

struct ToggleStopwatchIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle DIR DIVING Stopwatch"
    static var description = IntentDescription("Start or stop the DIR DIVING manual stopwatch.")

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            DiveManager.shared?.toggleStopwatch()
        }
        return .result()
    }
}

struct ResetStopwatchIntent: AppIntent {
    static var title: LocalizedStringResource = "Reset DIR DIVING Stopwatch"
    static var description = IntentDescription("Reset the DIR DIVING manual stopwatch.")

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            DiveManager.shared?.resetStopwatch()
        }
        return .result()
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
