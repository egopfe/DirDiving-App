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

struct OpenBuddyAssistIntent: AppIntent {
    static var title: LocalizedStringResource = "Open DIR DIVING Buddy Assist"
    static var description = IntentDescription("Open the DIR DIVING Buddy Assist screen.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            AppNavigationStore.shared?.openBuddyAssist()
        }
        return .result()
    }
}
