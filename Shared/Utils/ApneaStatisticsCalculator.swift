import Foundation

struct ApneaExtendedStatistics: Codable, Hashable, Sendable {
    var aggregate: ApneaAggregateStatistics
    var bestStaticHoldSeconds: TimeInterval
    var bestDepthMeters: Double
    var sessionCount: Int
    var holdCount: Int
    var averageHoldSeconds: TimeInterval
    var averageRecoverySeconds: TimeInterval
    var recoveryConsistencyScore: Double
    var weeklySessionCount: Int
    var sessionsByProfileKind: [ApneaProfileKind: Int]
    var trendAverageHoldSeconds: [TimeInterval]
    var trendMaxDepthMeters: [Double]
}

enum ApneaStatisticsCalculator {
    static func isDemoSession(_ session: ApneaSession) -> Bool {
        DemoApneaSessionCatalog.isDemoSession(id: session.id)
    }

    static func realSessions(from source: [ApneaSession]) -> [ApneaSession] {
        source.filter { !isDemoSession($0) && ApneaLogbookStatistics.isEligibleForStatistics($0) }
    }

    static func compute(
        from sessions: [ApneaSession],
        profileKindResolver: (ApneaSession) -> ApneaProfileKind = { _ in .freeTraining },
        referenceDate: Date = Date()
    ) -> ApneaExtendedStatistics {
        let real = realSessions(from: sessions)
        let aggregate = ApneaLogbookStatistics.aggregate(from: real, range: .allTime, referenceDate: referenceDate)
        let stats = real.map { $0.refreshedStatistics() }
        let staticHolds = real.flatMap { session -> [TimeInterval] in
            session.dives.map(\.durationSeconds).filter { $0 > 0 }
        }
        let recoveries = real.flatMap { session in
            session.dives.compactMap { $0.recoveryAfter?.completedSeconds ?? $0.recoveryAfter?.plannedSeconds }
        }

        let weeklyCutoff = Calendar.current.date(byAdding: .day, value: -7, to: referenceDate) ?? referenceDate
        let weeklyCount = real.filter { $0.createdAt >= weeklyCutoff }.count

        var byProfile: [ApneaProfileKind: Int] = [:]
        for session in real {
            let kind = profileKindResolver(session)
            byProfile[kind, default: 0] += 1
        }

        let recoveryConsistency = recoveryConsistencyScore(from: recoveries)
        let sortedByDate = real.sorted { $0.createdAt < $1.createdAt }
        let trendHolds = sortedByDate.map { $0.refreshedStatistics().averageDiveDurationSeconds }
        let trendDepths = sortedByDate.map { $0.refreshedStatistics().sessionMaxDepthMeters }

        return ApneaExtendedStatistics(
            aggregate: aggregate,
            bestStaticHoldSeconds: staticHolds.max() ?? 0,
            bestDepthMeters: aggregate.bestSessionMaxDepthMeters,
            sessionCount: aggregate.sessionCount,
            holdCount: aggregate.totalDiveCount,
            averageHoldSeconds: aggregate.averageDiveDurationSeconds,
            averageRecoverySeconds: aggregate.averageRecoverySeconds,
            recoveryConsistencyScore: recoveryConsistency,
            weeklySessionCount: weeklyCount,
            sessionsByProfileKind: byProfile,
            trendAverageHoldSeconds: trendHolds,
            trendMaxDepthMeters: trendDepths
        )
    }

    private static func recoveryConsistencyScore(from recoveries: [TimeInterval]) -> Double {
        guard recoveries.count >= 2 else { return recoveries.isEmpty ? 0 : 1 }
        let mean = recoveries.reduce(0, +) / Double(recoveries.count)
        guard mean > 0 else { return 0 }
        let variance = recoveries.reduce(0) { $0 + pow($1 - mean, 2) } / Double(recoveries.count)
        let cv = sqrt(variance) / mean
        return max(0, min(1, 1 - cv))
    }
}

struct ApneaPersonalBestEntry: Codable, Hashable, Sendable, Identifiable {
    let id: UUID
    var profileKind: ApneaProfileKind
    var bestHoldSeconds: TimeInterval
    var bestDepthMeters: Double
    var sessionID: UUID
    var isIncomplete: Bool
}

enum ApneaPersonalBestCalculator {
    static func compute(
        from sessions: [ApneaSession],
        profileKindResolver: (ApneaSession) -> ApneaProfileKind
    ) -> [ApneaPersonalBestEntry] {
        let eligible = ApneaStatisticsCalculator.realSessions(from: sessions)
            .filter { ApneaRecordEligibilityPolicy.isEligibleForRecords($0) }

        var bestByKind: [ApneaProfileKind: ApneaPersonalBestEntry] = [:]
        for session in eligible {
            let kind = profileKindResolver(session)
            let stats = session.refreshedStatistics()
            let incomplete = session.warnings.contains(.dataQualityDegraded) || session.warnings.contains(.sparseSamples)
            if var existing = bestByKind[kind] {
                if stats.bestDiveDurationSeconds > existing.bestHoldSeconds {
                    existing.bestHoldSeconds = stats.bestDiveDurationSeconds
                    existing.sessionID = session.id
                }
                if stats.sessionMaxDepthMeters > existing.bestDepthMeters {
                    existing.bestDepthMeters = stats.sessionMaxDepthMeters
                    existing.sessionID = session.id
                }
                existing.isIncomplete = incomplete
                bestByKind[kind] = existing
            } else {
                bestByKind[kind] = ApneaPersonalBestEntry(
                    id: UUID(),
                    profileKind: kind,
                    bestHoldSeconds: stats.bestDiveDurationSeconds,
                    bestDepthMeters: stats.sessionMaxDepthMeters,
                    sessionID: session.id,
                    isIncomplete: incomplete
                )
            }
        }
        return ApneaProfileKind.allCases.compactMap { bestByKind[$0] }
    }
}

struct ApneaRecoveryAnalysis: Codable, Hashable, Sendable {
    var averageActualRatio: Double
    var averageTargetRatio: Double
    var consistencyScore: Double
    var shortRecoveryEventCount: Int
    var warnings: [String]
}

enum ApneaRecoveryAnalysisCalculator {
    static func analyze(session: ApneaSession, policy: ApneaRecoveryPolicy) -> ApneaRecoveryAnalysis {
        var actualRatios: [Double] = []
        var targetRatios: [Double] = []
        var shortEvents = 0
        var warnings: [String] = []

        for dive in session.dives where dive.durationSeconds > 0 {
            let hold = dive.durationSeconds
            let target = ApneaRecoveryTargetCalculator.targetSeconds(policy: policy, lastHoldSeconds: hold)
            let actual = dive.recoveryAfter?.completedSeconds ?? dive.recoveryAfter?.plannedSeconds ?? 0
            if hold > 0 {
                actualRatios.append(actual / hold)
                targetRatios.append(target / hold)
            }
            if actual > 0, actual < target {
                shortEvents += 1
            }
        }

        if shortEvents > 0 {
            warnings.append("apnea.recovery.analysis.shorter_than_target")
        }

        let avgActual = actualRatios.isEmpty ? 0 : actualRatios.reduce(0, +) / Double(actualRatios.count)
        let avgTarget = targetRatios.isEmpty ? 0 : targetRatios.reduce(0, +) / Double(targetRatios.count)
        let consistency = ApneaStatisticsCalculator.compute(from: [session]).recoveryConsistencyScore

        return ApneaRecoveryAnalysis(
            averageActualRatio: avgActual,
            averageTargetRatio: avgTarget,
            consistencyScore: consistency,
            shortRecoveryEventCount: shortEvents,
            warnings: warnings
        )
    }
}
