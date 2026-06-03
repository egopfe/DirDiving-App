import Foundation

enum DiveSessionCollectionIntegrity {
    struct DeduplicationResult: Equatable {
        let sessions: [DiveSession]
        let duplicateSessionIDs: [UUID]
    }

    /// Deterministically collapses duplicate session IDs, keeping the newest valid session.
    static func deduplicated(_ sessions: [DiveSession]) -> DeduplicationResult {
        var grouped: [UUID: [DiveSession]] = [:]
        for session in sessions {
            grouped[session.id, default: []].append(session)
        }

        var duplicateSessionIDs: [UUID] = []
        var resolved: [DiveSession] = []
        for id in grouped.keys.sorted(by: { $0.uuidString < $1.uuidString }) {
            guard let group = grouped[id] else { continue }
            if group.count > 1 {
                duplicateSessionIDs.append(id)
            }
            resolved.append(preferredSession(from: group))
        }
        return DeduplicationResult(sessions: resolved, duplicateSessionIDs: duplicateSessionIDs)
    }

    static func preferredSession(from group: [DiveSession]) -> DiveSession {
        group.max(by: isLessPreferred) ?? group[0]
    }

    private static func isLessPreferred(_ lhs: DiveSession, _ rhs: DiveSession) -> Bool {
        if lhs.endDate != rhs.endDate { return lhs.endDate < rhs.endDate }
        if lhs.startDate != rhs.startDate { return lhs.startDate < rhs.startDate }
        if lhs.samples.count != rhs.samples.count { return lhs.samples.count < rhs.samples.count }
        return lhs.durationSeconds < rhs.durationSeconds
    }
}
