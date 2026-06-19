import Foundation

enum SnorkelingSessionMerge {
    static func preferred(_ local: SnorkelingSession, _ remote: SnorkelingSession) -> SnorkelingSession {
        if local.id != remote.id {
            return SnorkelingLogbookPolicy.normalizedSession(local)
        }

        let localScore = completenessScore(local)
        let remoteScore = completenessScore(remote)
        let winner = remoteScore > localScore ? remote : local
        let loser = winner.id == local.id ? remote : local

        var merged = SnorkelingLogbookPolicy.normalizedSession(winner)
        if merged.trackPoints.isEmpty, !loser.trackPoints.isEmpty {
            merged.trackPoints = loser.trackPoints
        }
        if merged.dips.isEmpty, !loser.dips.isEmpty {
            merged.dips = loser.dips
        }
        if merged.markers.isEmpty, !loser.markers.isEmpty {
            merged.markers = loser.markers
        }
        if merged.events.isEmpty, !loser.events.isEmpty {
            merged.events = loser.events
        }
        if merged.routePlans.isEmpty, !loser.routePlans.isEmpty {
            merged.routePlans = loser.routePlans
        }
        if merged.alarms.isEmpty, !loser.alarms.isEmpty {
            merged.alarms = loser.alarms
        }
        if merged.entryPoint == nil {
            merged.entryPoint = loser.entryPoint
        }
        if merged.profile == nil {
            merged.profile = loser.profile
        }
        if merged.equipment == nil {
            merged.equipment = loser.equipment
        }
        if merged.buddy == nil {
            merged.buddy = loser.buddy
        }
        if merged.activeRoutePlanID == nil {
            merged.activeRoutePlanID = loser.activeRoutePlanID
        }
        merged.warnings = Array(Set(merged.warnings + loser.warnings))
        merged.statistics = merged.refreshedStatistics()
        return merged
    }

    private static func completenessScore(_ session: SnorkelingSession) -> Int {
        var score = 0
        score += session.trackPoints.count
        score += session.dips.count * 10
        score += session.dips.reduce(0) { $0 + $1.samples.count }
        score += session.markers.count * 3
        score += session.events.count * 2
        if session.state == .completed { score += 5 }
        if let end = session.endedAtMonotonicSeconds { score += Int(end) % 1_000 }
        return score
    }
}
