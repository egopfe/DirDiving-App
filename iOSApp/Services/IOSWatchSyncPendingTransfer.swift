import Foundation

/// Metadata for an iPhone→Watch dive session awaiting signed Watch import ACK.
struct IOSWatchSyncPendingTransfer: Codable, Equatable {
    var session: DiveSession
    var lastIssuedAt: Date?
    var queuedAt: Date
    var lastAttemptAt: Date?
    var userInfoDeliveredAt: Date?
    var attemptCount: Int

    init(session: DiveSession, queuedAt: Date = Date()) {
        self.session = DiveSessionMerge.preferred(session, session)
        self.lastIssuedAt = nil
        self.queuedAt = queuedAt
        self.lastAttemptAt = nil
        self.userInfoDeliveredAt = nil
        self.attemptCount = 0
    }

    var isRetentionExpired: Bool {
        Date().timeIntervalSince(queuedAt) > IOSAlgorithmConfiguration.pendingSyncMaxRetentionSeconds
    }

    var exceededAttemptBudget: Bool {
        attemptCount >= IOSAlgorithmConfiguration.pendingSyncMaxAttemptCount
    }
}

enum IOSWatchSyncPendingQueuePolicy {
    static func normalizedTransfers(_ transfers: [IOSWatchSyncPendingTransfer]) -> [IOSWatchSyncPendingTransfer] {
        transfers
            .map { entry in
                var copy = entry
                copy.session = DiveSessionMerge.preferred(entry.session, entry.session)
                return copy
            }
            .sorted { $0.session.startDate > $1.session.startDate }
    }

    static func dequeueAfterSignedAck(
        transfers: [IOSWatchSyncPendingTransfer],
        sessionID: UUID
    ) -> [IOSWatchSyncPendingTransfer] {
        transfers.filter { $0.session.id != sessionID }
    }
}
