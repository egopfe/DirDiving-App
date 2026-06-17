import Foundation

enum ApneaLogbookPersistenceClass: Equatable {
    case exportable
    case invalid(reason: String)
}

enum ApneaLogbookPolicy {
    static let maxSessions = 80

    static func classify(_ session: ApneaSession) -> ApneaLogbookPersistenceClass {
        if !ApneaDomainValidator.isValid(session: session) {
            return .invalid(reason: "validation_failed")
        }
        if session.dives.isEmpty, session.state == .completed {
            return .invalid(reason: "completed_without_dives")
        }
        return .exportable
    }

    static func normalizedSession(_ session: ApneaSession) -> ApneaSession {
        var normalized = session
        normalized.dives = deduplicatedDives(session.dives)
        normalized.statistics = normalized.refreshedStatistics()
        return normalized
    }

    static func mergedAndCapped(
        local: [ApneaSession],
        cloud: [ApneaSession]?,
        deletedIDs: Set<UUID>
    ) -> [ApneaSession] {
        var byID: [UUID: ApneaSession] = [:]
        for session in local {
            let normalized = normalizedSession(session)
            byID[normalized.id] = normalized
        }
        if let cloud {
            for session in cloud {
                let normalized = normalizedSession(session)
                if let existing = byID[normalized.id] {
                    byID[normalized.id] = ApneaSessionMerge.preferred(existing, normalized)
                } else {
                    byID[normalized.id] = normalized
                }
            }
        }
        return normalizedAndCapped(Array(byID.values), deletedIDs: deletedIDs)
    }

    static func normalizedAndCapped(_ source: [ApneaSession], deletedIDs: Set<UUID>) -> [ApneaSession] {
        Array(
            source
                .map { normalizedSession($0) }
                .filter { !deletedIDs.contains($0.id) }
                .sorted {
                    if $0.createdAt != $1.createdAt {
                        return $0.createdAt > $1.createdAt
                    }
                    return $0.id.uuidString < $1.id.uuidString
                }
                .prefix(maxSessions)
        )
    }

    static func filterValidLoadedSessions(_ source: [ApneaSession]) -> (sessions: [ApneaSession], quarantinedCount: Int) {
        var quarantined = 0
        let sessions = source.compactMap { session -> ApneaSession? in
            switch classify(session) {
            case .invalid:
                quarantined += 1
                return nil
            case .exportable:
                return normalizedSession(session)
            }
        }
        return (sessions, quarantined)
    }

    private static func deduplicatedDives(_ dives: [ApneaDive]) -> [ApneaDive] {
        var byID: [UUID: ApneaDive] = [:]
        for dive in dives {
            if let existing = byID[dive.id] {
                byID[dive.id] = preferredDive(existing, dive)
            } else {
                byID[dive.id] = dive
            }
        }
        return byID.values.sorted { $0.startedAtMonotonicSeconds < $1.startedAtMonotonicSeconds }
    }

    private static func preferredDive(_ local: ApneaDive, _ remote: ApneaDive) -> ApneaDive {
        if remote.samples.count > local.samples.count { return remote }
        if remote.events.count > local.events.count { return remote }
        if remote.durationSeconds > local.durationSeconds { return remote }
        return local
    }
}
