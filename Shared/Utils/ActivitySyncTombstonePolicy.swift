import Foundation

/// Deterministic tombstone vs upsert ordering (revision-first, not wall-clock only).
enum ActivitySyncTombstonePolicy {
    enum MergeOutcome: Equatable {
        case acceptUpsert
        case acceptTombstone
        case stale
        case idempotent
        case conflictSameRevisionDifferentHash
    }

    static func compareUpsert(
        existingRevision: Int,
        incomingRevision: Int,
        isDeleted: Bool
    ) -> MergeOutcome {
        if isDeleted {
            return .acceptTombstone
        }
        switch ActivitySyncRevisionPolicy.compare(existing: existingRevision, incoming: incomingRevision) {
        case .acceptIncoming: return .acceptUpsert
        case .stale: return .stale
        case .idempotent: return .idempotent
        case .conflictSameRevisionDifferentHash: return .conflictSameRevisionDifferentHash
        }
    }

    static func compareTombstone(
        existingRevision: Int,
        tombstoneRevision: Int
    ) -> MergeOutcome {
        switch ActivitySyncRevisionPolicy.compare(existing: existingRevision, incoming: tombstoneRevision) {
        case .acceptIncoming:
            return .acceptTombstone
        case .stale:
            return .stale
        case .idempotent:
            return .idempotent
        case .conflictSameRevisionDifferentHash:
            return .conflictSameRevisionDifferentHash
        }
    }

    static func shouldApplyRemoteTombstone(
        localRevision: Int,
        tombstone: ActivitySyncTombstoneRecord,
        alreadyDeleted: Bool
    ) -> Bool {
        if alreadyDeleted { return false }
        switch compareTombstone(existingRevision: localRevision, tombstoneRevision: tombstone.revision) {
        case .acceptTombstone, .idempotent:
            return true
        case .acceptUpsert, .stale, .conflictSameRevisionDifferentHash:
            return false
        }
    }

    static func mergedTombstones(
        existing: [ActivitySyncTombstoneRecord],
        incoming: [ActivitySyncTombstoneRecord]
    ) -> [ActivitySyncTombstoneRecord] {
        var bySession: [UUID: ActivitySyncTombstoneRecord] = [:]
        for record in existing {
            bySession[record.sessionID] = record
        }
        for record in incoming {
            if let current = bySession[record.sessionID] {
                if record.revision >= current.revision {
                    bySession[record.sessionID] = record
                }
            } else {
                bySession[record.sessionID] = record
            }
        }
        return Array(bySession.values).sorted { $0.deletedAt < $1.deletedAt }
    }
}
