import Foundation

/// Metadata for a Watch→iPhone dive session awaiting signed companion ACK.
struct WatchSyncPendingTransfer: Codable, Equatable {
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
        Date().timeIntervalSince(queuedAt) > DiveAlgorithmConfiguration.pendingSyncMaxRetentionSeconds
    }

    var exceededAttemptBudget: Bool {
        attemptCount >= DiveAlgorithmConfiguration.pendingSyncMaxAttemptCount
    }
}

enum WatchSyncPendingQueuePolicy {
    static func normalizedTransfers(_ transfers: [WatchSyncPendingTransfer]) -> [WatchSyncPendingTransfer] {
        transfers
            .map { entry in
                var copy = entry
                copy.session = DiveSessionMerge.preferred(entry.session, entry.session)
                return copy
            }
            .sorted { $0.session.startDate > $1.session.startDate }
    }

    static func dequeueAfterSignedAck(
        transfers: [WatchSyncPendingTransfer],
        sessionID: UUID
    ) -> [WatchSyncPendingTransfer] {
        transfers.filter { $0.session.id != sessionID }
    }
}
