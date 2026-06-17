import Foundation

struct ApneaSyncPendingTransfer: Codable, Equatable {
    var session: ApneaSession
    var lastIssuedAt: Date?
    var queuedAt: Date
    var lastAttemptAt: Date?
    var attemptCount: Int

    init(session: ApneaSession, queuedAt: Date = Date()) {
        self.session = ApneaLogbookPolicy.normalizedSession(session)
        self.lastIssuedAt = nil
        self.queuedAt = queuedAt
        self.lastAttemptAt = nil
        self.attemptCount = 0
    }
}
