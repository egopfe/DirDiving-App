import Foundation

enum SnorkelingPersonalRecordKind: String, CaseIterable, Codable, Hashable, Sendable {
    case deepestDip
    case longestDip
    case greatestSessionDepth
    case greatestSessionDistance
    case mostDipsInSession
    case longestSessionDuration
}

struct SnorkelingPersonalRecordTie: Equatable, Hashable, Sendable {
    var sessionID: UUID
    var sessionDate: Date
    var dipIndex: Int?
}

struct SnorkelingPersonalRecordEntry: Equatable, Identifiable, Hashable, Sendable {
    var id: String { kind.rawValue }
    var kind: SnorkelingPersonalRecordKind
    var value: Double
    var sessionID: UUID
    var sessionDate: Date
    var dipIndex: Int?
    var profileName: String?
    var ties: [SnorkelingPersonalRecordTie]
}

struct SnorkelingPersonalRecordsSummary: Equatable, Hashable, Sendable {
    var records: [SnorkelingPersonalRecordEntry]
    var eligibleSessionCount: Int
    var excludedSessionCount: Int
}

enum SnorkelingPersonalRecordsEngine {
    static func compute(
        from sessions: [SnorkelingSession],
        options: SnorkelingRecordEligibilityOptions = .default
    ) -> SnorkelingPersonalRecordsSummary {
        let eligible = SnorkelingRecordEligibilityPolicy.eligibleSessions(from: sessions, options: options)
        let excluded = sessions.count - eligible.count
        guard !eligible.isEmpty else {
            return SnorkelingPersonalRecordsSummary(records: [], eligibleSessionCount: 0, excludedSessionCount: excluded)
        }

        var records: [SnorkelingPersonalRecordEntry] = []
        records.append(makeDepthRecord(from: eligible, kind: .deepestDip))
        records.append(makeDurationRecord(from: eligible, kind: .longestDip))
        records.append(makeSessionMetric(from: eligible, kind: .greatestSessionDepth) { $0.statistics.sessionMaxDepthMeters })
        records.append(makeSessionMetric(from: eligible, kind: .greatestSessionDistance) { $0.statistics.totalDistanceMeters })
        records.append(makeSessionMetric(from: eligible, kind: .mostDipsInSession) { Double($0.statistics.dipCount) })
        records.append(makeSessionMetric(from: eligible, kind: .longestSessionDuration) { $0.statistics.sessionDurationSeconds })

        return SnorkelingPersonalRecordsSummary(
            records: records.filter { $0.value > 0 },
            eligibleSessionCount: eligible.count,
            excludedSessionCount: excluded
        )
    }

    private static func profileName(for session: SnorkelingSession) -> String? {
        guard let name = session.profile?.displayName, !name.isEmpty else { return nil }
        return name
    }

    private static func makeDepthRecord(
        from sessions: [SnorkelingSession],
        kind: SnorkelingPersonalRecordKind
    ) -> SnorkelingPersonalRecordEntry {
        var bestValue = 0.0
        var bestSessionID = sessions[0].id
        var bestDate = sessions[0].createdAt
        var bestDipIndex: Int?
        var bestProfile: String?
        var ties: [SnorkelingPersonalRecordTie] = []

        for session in sessions {
            for (index, dip) in session.dips.enumerated() {
                let depth = dip.maxDepthMeters
                if depth > bestValue + 0.001 {
                    bestValue = depth
                    bestSessionID = session.id
                    bestDate = session.createdAt
                    bestDipIndex = index
                    bestProfile = profileName(for: session)
                    ties = []
                } else if abs(depth - bestValue) <= 0.001, bestValue > 0 {
                    ties.append(
                        SnorkelingPersonalRecordTie(sessionID: session.id, sessionDate: session.createdAt, dipIndex: index)
                    )
                }
            }
        }

        return SnorkelingPersonalRecordEntry(
            kind: kind,
            value: bestValue,
            sessionID: bestSessionID,
            sessionDate: bestDate,
            dipIndex: bestDipIndex,
            profileName: bestProfile,
            ties: ties
        )
    }

    private static func makeDurationRecord(
        from sessions: [SnorkelingSession],
        kind: SnorkelingPersonalRecordKind
    ) -> SnorkelingPersonalRecordEntry {
        var bestValue = 0.0
        var bestSessionID = sessions[0].id
        var bestDate = sessions[0].createdAt
        var bestDipIndex: Int?
        var bestProfile: String?
        var ties: [SnorkelingPersonalRecordTie] = []

        for session in sessions {
            for (index, dip) in session.dips.enumerated() {
                let duration = dip.durationSeconds
                if duration > bestValue + 0.001 {
                    bestValue = duration
                    bestSessionID = session.id
                    bestDate = session.createdAt
                    bestDipIndex = index
                    bestProfile = profileName(for: session)
                    ties = []
                } else if abs(duration - bestValue) <= 0.001, bestValue > 0 {
                    ties.append(
                        SnorkelingPersonalRecordTie(sessionID: session.id, sessionDate: session.createdAt, dipIndex: index)
                    )
                }
            }
        }

        return SnorkelingPersonalRecordEntry(
            kind: kind,
            value: bestValue,
            sessionID: bestSessionID,
            sessionDate: bestDate,
            dipIndex: bestDipIndex,
            profileName: bestProfile,
            ties: ties
        )
    }

    private static func makeSessionMetric(
        from sessions: [SnorkelingSession],
        kind: SnorkelingPersonalRecordKind,
        value: (SnorkelingSession) -> Double
    ) -> SnorkelingPersonalRecordEntry {
        var bestValue = 0.0
        var bestSession = sessions[0]
        var ties: [SnorkelingPersonalRecordTie] = []

        for session in sessions {
            let metric = value(session)
            if metric > bestValue + 0.001 {
                bestValue = metric
                bestSession = session
                ties = []
            } else if abs(metric - bestValue) <= 0.001, bestValue > 0, session.id != bestSession.id {
                ties.append(
                    SnorkelingPersonalRecordTie(sessionID: session.id, sessionDate: session.createdAt, dipIndex: nil)
                )
            }
        }

        return SnorkelingPersonalRecordEntry(
            kind: kind,
            value: bestValue,
            sessionID: bestSession.id,
            sessionDate: bestSession.createdAt,
            dipIndex: nil,
            profileName: profileName(for: bestSession),
            ties: ties
        )
    }
}
