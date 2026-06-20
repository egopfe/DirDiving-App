import Foundation

/// Per-entity monotonic revision handling for out-of-order delivery.
enum ActivitySyncRevisionPolicy {
    enum CompareOutcome: Equatable {
        case acceptIncoming
        case stale
        case idempotent
        case conflictSameRevisionDifferentHash
    }

    static func compare(existing: Int, incoming: Int) -> CompareOutcome {
        if incoming > existing {
            return .acceptIncoming
        }
        if incoming < existing {
            return .stale
        }
        return .idempotent
    }

    static func compare(
        existing: Int,
        incoming: Int,
        existingContentHash: String,
        incomingContentHash: String
    ) -> CompareOutcome {
        let base = compare(existing: existing, incoming: incoming)
        if base == .idempotent, existingContentHash != incomingContentHash {
            return .conflictSameRevisionDifferentHash
        }
        return base
    }

    static func sessionRevision(for updatedAt: Date, explicitRevision: Int? = nil) -> Int {
        if let explicitRevision, explicitRevision > 0 {
            return explicitRevision
        }
        return max(1, Int(updatedAt.timeIntervalSince1970))
    }
}
