import Foundation

enum ApneaPersonalRecordKind: String, CaseIterable, Codable, Hashable, Sendable {
    case deepestDive
    case longestApnea
    case mostDivesInSession
    case greatestSessionDepth
    case greatestCumulativeDepth
}

struct ApneaPersonalRecordTie: Equatable, Hashable, Sendable {
    var sessionID: UUID
    var sessionDate: Date
    var diveIndex: Int?
}

struct ApneaPersonalRecordEntry: Equatable, Identifiable, Hashable, Sendable {
    var id: String { kind.rawValue }
    var kind: ApneaPersonalRecordKind
    var value: Double
    var sessionID: UUID
    var sessionDate: Date
    var diveIndex: Int?
    var profileName: String?
    var ties: [ApneaPersonalRecordTie]
}

struct ApneaPersonalRecordsSummary: Equatable, Hashable, Sendable {
    var records: [ApneaPersonalRecordEntry]
    var eligibleSessionCount: Int
    var excludedSessionCount: Int
}

enum ApneaPersonalRecordsEngine {
    static func compute(
        from sessions: [ApneaSession],
        options: ApneaRecordEligibilityOptions = .default
    ) -> ApneaPersonalRecordsSummary {
        let eligible = ApneaRecordEligibilityPolicy.eligibleSessions(from: sessions, options: options)
        let excluded = sessions.count - eligible.count
        guard !eligible.isEmpty else {
            return ApneaPersonalRecordsSummary(records: [], eligibleSessionCount: 0, excludedSessionCount: excluded)
        }

        var records: [ApneaPersonalRecordEntry] = []
        records.append(makeDepthRecord(from: eligible, kind: .deepestDive))
        records.append(makeDurationRecord(from: eligible, kind: .longestApnea))
        records.append(makeCountRecord(from: eligible))
        records.append(makeSessionDepthRecord(from: eligible))
        records.append(makeCumulativeDepthRecord(from: eligible))
        return ApneaPersonalRecordsSummary(
            records: records.filter { $0.value > 0 },
            eligibleSessionCount: eligible.count,
            excludedSessionCount: excluded
        )
    }

    private static func profileName(for session: ApneaSession) -> String? {
        guard let name = session.profile?.displayName, !name.isEmpty else { return nil }
        return name
    }

    private static func makeDepthRecord(
        from sessions: [ApneaSession],
        kind: ApneaPersonalRecordKind
    ) -> ApneaPersonalRecordEntry {
        var bestValue = 0.0
        var bestSessionID = sessions[0].id
        var bestDate = sessions[0].createdAt
        var bestDiveIndex: Int?
        var bestProfile: String?
        var ties: [ApneaPersonalRecordTie] = []

        for session in sessions {
            for (index, dive) in session.dives.enumerated() {
                let depth = dive.maxDepthMeters
                if depth > bestValue + 0.001 {
                    bestValue = depth
                    bestSessionID = session.id
                    bestDate = session.createdAt
                    bestDiveIndex = index
                    bestProfile = profileName(for: session)
                    ties = []
                } else if abs(depth - bestValue) <= 0.001, bestValue > 0 {
                    ties.append(
                        ApneaPersonalRecordTie(sessionID: session.id, sessionDate: session.createdAt, diveIndex: index)
                    )
                }
            }
        }

        return ApneaPersonalRecordEntry(
            kind: kind,
            value: bestValue,
            sessionID: bestSessionID,
            sessionDate: bestDate,
            diveIndex: bestDiveIndex,
            profileName: bestProfile,
            ties: ties
        )
    }

    private static func makeDurationRecord(
        from sessions: [ApneaSession],
        kind: ApneaPersonalRecordKind
    ) -> ApneaPersonalRecordEntry {
        var bestValue = 0.0
        var bestSessionID = sessions[0].id
        var bestDate = sessions[0].createdAt
        var bestDiveIndex: Int?
        var bestProfile: String?
        var ties: [ApneaPersonalRecordTie] = []

        for session in sessions {
            for (index, dive) in session.dives.enumerated() {
                let duration = dive.durationSeconds
                if duration > bestValue + 0.001 {
                    bestValue = duration
                    bestSessionID = session.id
                    bestDate = session.createdAt
                    bestDiveIndex = index
                    bestProfile = profileName(for: session)
                    ties = []
                } else if abs(duration - bestValue) <= 0.001, bestValue > 0 {
                    ties.append(
                        ApneaPersonalRecordTie(sessionID: session.id, sessionDate: session.createdAt, diveIndex: index)
                    )
                }
            }
        }

        return ApneaPersonalRecordEntry(
            kind: kind,
            value: bestValue,
            sessionID: bestSessionID,
            sessionDate: bestDate,
            diveIndex: bestDiveIndex,
            profileName: bestProfile,
            ties: ties
        )
    }

    private static func makeCountRecord(from sessions: [ApneaSession]) -> ApneaPersonalRecordEntry {
        pickSessionMetric(
            from: sessions,
            kind: .mostDivesInSession,
            value: { Double($0.refreshedStatistics().diveCount) }
        )
    }

    private static func makeSessionDepthRecord(from sessions: [ApneaSession]) -> ApneaPersonalRecordEntry {
        pickSessionMetric(
            from: sessions,
            kind: .greatestSessionDepth,
            value: { $0.refreshedStatistics().sessionMaxDepthMeters }
        )
    }

    private static func makeCumulativeDepthRecord(from sessions: [ApneaSession]) -> ApneaPersonalRecordEntry {
        pickSessionMetric(
            from: sessions,
            kind: .greatestCumulativeDepth,
            value: { $0.refreshedStatistics().cumulativeDepthMeters }
        )
    }

    private static func pickSessionMetric(
        from sessions: [ApneaSession],
        kind: ApneaPersonalRecordKind,
        value: (ApneaSession) -> Double
    ) -> ApneaPersonalRecordEntry {
        var bestValue = 0.0
        var bestSession = sessions[0]
        var ties: [ApneaPersonalRecordTie] = []

        for session in sessions {
            let metric = value(session)
            if metric > bestValue + 0.001 {
                bestValue = metric
                bestSession = session
                ties = []
            } else if abs(metric - bestValue) <= 0.001, bestValue > 0, session.id != bestSession.id {
                ties.append(ApneaPersonalRecordTie(sessionID: session.id, sessionDate: session.createdAt, diveIndex: nil))
            }
        }

        return ApneaPersonalRecordEntry(
            kind: kind,
            value: bestValue,
            sessionID: bestSession.id,
            sessionDate: bestSession.createdAt,
            diveIndex: nil,
            profileName: profileName(for: bestSession),
            ties: ties
        )
    }
}
