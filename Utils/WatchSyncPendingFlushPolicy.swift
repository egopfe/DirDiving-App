import Foundation

/// Prevents duplicate in-flight Watch→iPhone session sends during concurrent flushes.
enum WatchSyncPendingFlushPolicy {
    static let inFlightRetryIntervalSeconds: TimeInterval = 30

    static func sessionsEligibleForSend<T>(
        transfers: [T],
        sessionID: (T) -> UUID,
        lastAttemptAt: (T) -> Date?,
        inFlightSessionIDs: Set<UUID>,
        now: Date = Date()
    ) -> [T] {
        transfers.filter { transfer in
            let id = sessionID(transfer)
            guard !inFlightSessionIDs.contains(id) else { return false }
            guard let lastAttempt = lastAttemptAt(transfer) else { return true }
            return now.timeIntervalSince(lastAttempt) >= inFlightRetryIntervalSeconds
        }
    }

    static func shouldMarkInFlight(lastAttemptAt: Date?, now: Date = Date()) -> Bool {
        guard let lastAttemptAt else { return true }
        return now.timeIntervalSince(lastAttemptAt) >= inFlightRetryIntervalSeconds
    }
}
