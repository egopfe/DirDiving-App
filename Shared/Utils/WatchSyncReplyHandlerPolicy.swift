import Foundation

/// WC sendMessage reply handlers are transport hints only; signed ACK is authoritative (SEC-P3-004).
enum WatchSyncReplyHandlerPolicy {
    static let statusKey = "status"
    static let ackSignatureKey = "ackSignature"
    static let sessionIDKey = "sessionID"
    static let issuedAtKey = "issuedAt"

    enum ReplyDisposition: Equatable {
        case ignore
        case transportHintOnly
        case signedAckCandidate
    }

    static func disposition(for reply: [String: Any]) -> ReplyDisposition {
        if reply[ackSignatureKey] != nil {
            return .signedAckCandidate
        }
        if reply[statusKey] != nil {
            return .transportHintOnly
        }
        return .ignore
    }

    static func mayDequeuePendingTransfer(
        reply: [String: Any],
        expectedSessionID: UUID,
        expectedIssuedAt: Date,
        verifySignature: (String, UUID, Date) -> Bool
    ) -> Bool {
        guard disposition(for: reply) == .signedAckCandidate,
              let signature = reply[ackSignatureKey] as? String,
              !signature.isEmpty else {
            return false
        }
        if let rawID = reply[sessionIDKey] as? String,
           let parsed = UUID(uuidString: rawID),
           parsed != expectedSessionID {
            return false
        }
        if let issuedRaw = reply[issuedAtKey] as? TimeInterval {
            let issuedAt = Date(timeIntervalSince1970: issuedRaw)
            if abs(issuedAt.timeIntervalSince(expectedIssuedAt)) > 1 {
                return false
            }
        }
        return verifySignature(signature, expectedSessionID, expectedIssuedAt)
    }

    static func forgedReplyCannotDequeue(
        reply: [String: Any],
        expectedSessionID: UUID,
        expectedIssuedAt: Date,
        verifySignature: (String, UUID, Date) -> Bool
    ) -> Bool {
        !mayDequeuePendingTransfer(
            reply: reply,
            expectedSessionID: expectedSessionID,
            expectedIssuedAt: expectedIssuedAt,
            verifySignature: verifySignature
        )
    }
}
