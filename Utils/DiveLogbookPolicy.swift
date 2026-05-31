import Foundation

enum DiveLogbookPolicy {
    static let maxSessions = 40

    static func mergedAndCapped(local: [DiveSession], cloud: [DiveSession]?, deletedIDs: Set<UUID>) -> [DiveSession] {
        var byID: [UUID: DiveSession] = [:]
        for session in local {
            let normalized = DiveSessionMerge.preferred(session, session)
            byID[normalized.id] = normalized
        }

        if let cloud {
            for session in cloud {
                let normalized = DiveSessionMerge.preferred(session, session)
                if let existing = byID[normalized.id] {
                    byID[normalized.id] = DiveSessionMerge.preferred(existing, normalized)
                } else {
                    byID[normalized.id] = normalized
                }
            }
        }

        return normalizedAndCapped(Array(byID.values), deletedIDs: deletedIDs)
    }

    static func normalizedAndCapped(_ source: [DiveSession], deletedIDs: Set<UUID>) -> [DiveSession] {
        Array(
            source
                .map { DiveSessionMerge.preferred($0, $0) }
                .filter { !deletedIDs.contains($0.id) }
                .sorted {
                    if $0.startDate != $1.startDate {
                        return $0.startDate > $1.startDate
                    }
                    return $0.id.uuidString < $1.id.uuidString
                }
                .prefix(maxSessions)
        )
    }
}

