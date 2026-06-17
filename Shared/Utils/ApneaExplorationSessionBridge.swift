import Foundation

struct ApneaLegacyDiveSnapshot: Equatable, Codable, Sendable {
    var id: UUID
    var durationSeconds: TimeInterval
    var maxDepthMeters: Double
    var recoverySeconds: TimeInterval
}

struct ApneaExplorationSessionSnapshot: Equatable, Sendable {
    var dives: [ApneaLegacyDiveSnapshot]
    var dataQualityDegraded: Bool
    var sessionWarnings: [ApneaSessionWarning]
}

enum ApneaExplorationSessionBridge {
    static func makeCompletedSession(
        from snapshot: ApneaExplorationSessionSnapshot,
        sessionID: UUID = UUID(),
        createdAt: Date = Date()
    ) -> ApneaSession {
        let dives = snapshot.dives.enumerated().map { index, record in
            ApneaSchemaMigration.migrateLegacyDiveRecord(
                id: record.id,
                durationSeconds: record.durationSeconds,
                maxDepthMeters: record.maxDepthMeters,
                recoverySeconds: record.recoverySeconds
            ).withSequentialStart(index: index)
        }
        var warnings = snapshot.sessionWarnings
        if snapshot.dataQualityDegraded {
            warnings.append(.dataQualityDegraded)
        }
        var session = ApneaSession(
            id: sessionID,
            startMode: .watch,
            state: .completed,
            createdAt: createdAt,
            startedAtMonotonicSeconds: 0,
            endedAtMonotonicSeconds: dives.last.map { $0.endedAtMonotonicSeconds ?? $0.durationSeconds } ?? 0,
            dives: dives,
            warnings: Array(Set(warnings))
        )
        session.statistics = session.refreshedStatistics()
        return session
    }
}

private extension ApneaDive {
    func withSequentialStart(index: Int) -> ApneaDive {
        var dive = self
        let offset = TimeInterval(index * 1_000)
        dive.startedAtMonotonicSeconds = offset
        dive.endedAtMonotonicSeconds = offset + dive.durationSeconds
        return dive
    }
}
