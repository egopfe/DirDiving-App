import AppIntents

struct ToggleStopwatchIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle DIR DIVING Stopwatch"
    static var description = IntentDescription("Start or stop the DIR DIVING manual stopwatch.")
    func perform() async throws -> some IntentResult { .result() }
}

struct ResetStopwatchIntent: AppIntent {
    static var title: LocalizedStringResource = "Reset DIR DIVING Stopwatch"
    static var description = IntentDescription("Reset the DIR DIVING manual stopwatch.")
    func perform() async throws -> some IntentResult { .result() }
}
