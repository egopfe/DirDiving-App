import Foundation
import CryptoKit

/// Publish and ingest activity-scoped signed tombstones over WatchConnectivity applicationContext.
enum ActivitySyncTombstoneBroadcast {
    static func broadcastKey(for activity: ActivitySyncActivityType) -> String {
        switch activity {
        case .diving: return "dirdiving_deleted_diving_session_tombstones"
        case .apnea: return "dirdiving_deleted_apnea_session_tombstones"
        case .snorkeling: return "dirdiving_deleted_snorkeling_session_tombstones"
        case .sharedReference: return "dirdiving_deleted_session_ids"
        }
    }

    static func makeSignedTombstones(
        sessionIDs: Set<UUID>,
        activity: ActivitySyncActivityType,
        revisionForSession: (UUID) -> Int,
        syncKey: SymmetricKey,
        bundleID: String
    ) throws -> [ActivitySyncSignedTombstone] {
        try sessionIDs.map { sessionID in
            let record = ActivitySyncTombstoneRecord(
                sessionID: sessionID,
                activity: activity,
                revision: revisionForSession(sessionID)
            )
            return try ActivitySyncSignedTombstone.sign(
                record: record,
                syncKey: syncKey,
                bundleID: bundleID
            )
        }
    }

    static func mergeBroadcastPayload(
        existing context: [String: Any],
        incoming signed: [ActivitySyncSignedTombstone],
        activity: ActivitySyncActivityType
    ) -> [String: Any] {
        let key = broadcastKey(for: activity)
        let existingRecords = ActivitySyncTombstoneCodec.decodeBroadcastPayload(from: context, broadcastKey: key)
        let mergedRecords = ActivitySyncTombstonePolicy.mergedTombstones(
            existing: existingRecords.map(\.record),
            incoming: signed.map(\.record)
        )
        let mergedSigned = signed + existingRecords.filter { existing in
            !mergedRecords.contains(where: { $0.sessionID == existing.record.sessionID && $0.revision >= existing.record.revision })
        }
        return ActivitySyncTombstoneCodec.encodeBroadcastPayload(
            tombstones: dedupeSigned(mergedSigned),
            broadcastKey: key
        )
    }

    static func verifiedSessionIDs(
        from context: [String: Any],
        activity: ActivitySyncActivityType,
        syncKey: SymmetricKey,
        expectedBundleID: String
    ) -> Set<UUID> {
        let key = broadcastKey(for: activity)
        let signed = ActivitySyncTombstoneCodec.decodeBroadcastPayload(from: context, broadcastKey: key)
        var ids: Set<UUID> = []
        for entry in signed {
            guard entry.verify(syncKey: syncKey, expectedBundleID: expectedBundleID),
                  entry.record.activity == activity else { continue }
            ids.insert(entry.record.sessionID)
        }
        return ids
    }

    private static func dedupeSigned(_ entries: [ActivitySyncSignedTombstone]) -> [ActivitySyncSignedTombstone] {
        var bySession: [UUID: ActivitySyncSignedTombstone] = [:]
        for entry in entries {
            if let current = bySession[entry.record.sessionID] {
                if entry.record.revision >= current.record.revision {
                    bySession[entry.record.sessionID] = entry
                }
            } else {
                bySession[entry.record.sessionID] = entry
            }
        }
        return Array(bySession.values)
    }
}
