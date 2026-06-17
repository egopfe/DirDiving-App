import Foundation

enum ApneaSessionMerge {
    static func preferred(_ local: ApneaSession, _ remote: ApneaSession) -> ApneaSession {
        if local.id != remote.id {
            return ApneaLogbookPolicy.normalizedSession(local)
        }

        let localScore = completenessScore(local)
        let remoteScore = completenessScore(remote)
        let winner = remoteScore > localScore ? remote : local
        let loser = winner.id == local.id ? remote : local

        var merged = ApneaLogbookPolicy.normalizedSession(winner)
        if merged.dives.isEmpty, !loser.dives.isEmpty {
            merged.dives = loser.dives
        }
        if merged.surfaceGPSPoints.isEmpty, !loser.surfaceGPSPoints.isEmpty {
            merged.surfaceGPSPoints = loser.surfaceGPSPoints
        }
        if merged.profile == nil {
            merged.profile = loser.profile
        }
        merged.warnings = Array(Set(merged.warnings + loser.warnings))
        merged.statistics = merged.refreshedStatistics()
        return merged
    }

    private static func completenessScore(_ session: ApneaSession) -> Int {
        var score = 0
        score += session.dives.count * 10
        score += session.dives.reduce(0) { $0 + $1.samples.count }
        score += session.dives.reduce(0) { $0 + $1.events.count }
        if session.state == .completed { score += 5 }
        if let end = session.endedAtMonotonicSeconds { score += Int(end) % 1_000 }
        return score
    }
}
