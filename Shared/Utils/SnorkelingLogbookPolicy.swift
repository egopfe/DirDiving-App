import Foundation

enum SnorkelingLogbookPersistenceClass: Equatable {
    case exportable
    case invalid(reason: String)
}

/// Retention and validation policy for snorkeling logbook sessions.
/// Raw depth/GPS audit trails remain capped at 2048 samples per feed inside active sessions.
enum SnorkelingLogbookPolicy {
    static let maxSessions = 80

    static func classify(_ session: SnorkelingSession) -> SnorkelingLogbookPersistenceClass {
        if !SnorkelingDomainValidator.validate(session: session).isEmpty {
            return .invalid(reason: "validation_failed")
        }
        switch session.state {
        case .completed, .aborted:
            return .exportable
        case .active, .paused, .navigation, .returnMode, .planned:
            return .invalid(reason: "incomplete_session")
        }
    }

    static func normalizedSession(_ session: SnorkelingSession) -> SnorkelingSession {
        var normalized = session
        normalized.dips = deduplicatedDips(session.dips)
        normalized.trackPoints = SnorkelingDomainSupport.normalizedTrackPoints(session.trackPoints)
        normalized.statistics = normalized.refreshedStatistics()
        return normalized
    }

    static func normalizedAndCapped(_ source: [SnorkelingSession], deletedIDs: Set<UUID> = []) -> [SnorkelingSession] {
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

    static func filterValidLoadedSessions(_ source: [SnorkelingSession]) -> (sessions: [SnorkelingSession], quarantinedCount: Int) {
        var quarantined = 0
        let sessions = source.compactMap { session -> SnorkelingSession? in
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

    private static func deduplicatedDips(_ dips: [SnorkelingDip]) -> [SnorkelingDip] {
        var seen = Set<UUID>()
        return dips.filter { seen.insert($0.id).inserted }
    }
}
