import Foundation

struct SnorkelingSyncPendingTransfer: Codable, Equatable {
    var session: SnorkelingSession
    var lastIssuedAt: Date?
    var queuedAt: Date
    var lastAttemptAt: Date?
    var attemptCount: Int

    init(session: SnorkelingSession, queuedAt: Date = Date()) {
        self.session = SnorkelingLogbookPolicy.normalizedSession(session)
        self.lastIssuedAt = nil
        self.queuedAt = queuedAt
        self.lastAttemptAt = nil
        self.attemptCount = 0
    }
}
