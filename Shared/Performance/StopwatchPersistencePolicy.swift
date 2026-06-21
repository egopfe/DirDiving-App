import Foundation

/// Accepted low-frequency UserDefaults persistence for manual stopwatch state.
/// Runtime ticks must never write UserDefaults.
enum StopwatchPersistencePolicy {
    static let storageKind = "UserDefaults"
    static let accumulatedTimeKey = "dirdiving_watch_stopwatch_accumulated"
    static let runningKey = "dirdiving_watch_stopwatch_running"
    static let startedAtKey = "dirdiving_watch_stopwatch_started_at"

    static var acceptedKeys: Set<String> {
        [accumulatedTimeKey, runningKey, startedAtKey]
    }

    /// Test-only write counter; production writes call `recordPersist` from DiveManager lifecycle hooks.
    static var testHook_writeCount = 0

    static func recordPersist() {
        testHook_writeCount += 1
    }

    static func resetTestHook() {
        testHook_writeCount = 0
    }

    /// Validates that only bounded non-sensitive stopwatch fields are persisted.
    static func isAcceptedPayload(accumulatedTime: Double, isRunning: Bool, startedAt: Date?) -> Bool {
        accumulatedTime.isFinite && accumulatedTime >= 0 && accumulatedTime <= 86_400
    }
}
