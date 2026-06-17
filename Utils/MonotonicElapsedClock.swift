import Foundation

/// Dive runtime / stopwatch elapsed time — **not** per-sample `DiveSample.timestamp`.
/// Reconciles wall-clock elapsed with `ProcessInfo.processInfo.systemUptime` so runtime
/// does not decrease when the system clock moves backward and does not jump forward on large skew.
/// Depth samples keep sensor `timestamp` for profile math; this clock is for monotonic session elapsed only.
/// See `Docs/WATCH_DEPTH_SAMPLE_TIMESTAMP_POLICY.md`.
struct MonotonicElapsedClock: Equatable {
    private(set) var anchorDate: Date?
    private(set) var anchorUptime: TimeInterval?
    private(set) var lastElapsed: TimeInterval = 0

    private static let forwardSkewToleranceSeconds: TimeInterval = 120

    mutating func reset(anchorDate: Date, uptime: TimeInterval = ProcessInfo.processInfo.systemUptime) {
        self.anchorDate = anchorDate
        anchorUptime = uptime
        lastElapsed = 0
    }

    mutating func clear() {
        anchorDate = nil
        anchorUptime = nil
        lastElapsed = 0
    }

    mutating func elapsed(
        now: Date = Date(),
        uptime: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) -> TimeInterval {
        guard let anchorDate, let anchorUptime else { return max(0, lastElapsed) }

        let dateElapsed = max(0, now.timeIntervalSince(anchorDate))
        let monotonicElapsed = max(0, uptime - anchorUptime)
        let resolved: TimeInterval
        if dateElapsed + 1 < monotonicElapsed {
            resolved = monotonicElapsed
        } else if dateElapsed > monotonicElapsed + Self.forwardSkewToleranceSeconds {
            resolved = monotonicElapsed
        } else {
            resolved = max(dateElapsed, monotonicElapsed)
        }
        lastElapsed = max(lastElapsed, resolved)
        return lastElapsed
    }

    struct Snapshot: Codable, Equatable, Hashable {
        let anchorDate: Date?
        let anchorUptime: TimeInterval?
        let lastElapsed: TimeInterval
    }

    func exportSnapshot() -> Snapshot {
        Snapshot(anchorDate: anchorDate, anchorUptime: anchorUptime, lastElapsed: lastElapsed)
    }

    mutating func restore(from snapshot: Snapshot) {
        anchorDate = snapshot.anchorDate
        anchorUptime = snapshot.anchorUptime
        lastElapsed = snapshot.lastElapsed
    }
}
