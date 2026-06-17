import Foundation

enum ApneaStatisticsRange: String, Codable, CaseIterable, Hashable, Sendable {
    case last7Days
    case last30Days
    case lastYear
    case allTime
}

struct ApneaAggregateStatistics: Codable, Hashable, Sendable {
    var sessionCount: Int
    var totalDiveCount: Int
    var bestSessionMaxDepthMeters: Double
    var bestDiveDurationSeconds: TimeInterval
    var averageSessionMaxDepthMeters: Double
    var averageDiveDurationSeconds: TimeInterval
    var totalUnderwaterSeconds: TimeInterval
    var cumulativeDepthMeters: Double
    var averageRecoverySeconds: TimeInterval
    var apneaRecoveryRatio: Double
    var totalEventCount: Int
    var mostDivesInSession: Int

    static let empty = ApneaAggregateStatistics(
        sessionCount: 0,
        totalDiveCount: 0,
        bestSessionMaxDepthMeters: 0,
        bestDiveDurationSeconds: 0,
        averageSessionMaxDepthMeters: 0,
        averageDiveDurationSeconds: 0,
        totalUnderwaterSeconds: 0,
        cumulativeDepthMeters: 0,
        averageRecoverySeconds: 0,
        apneaRecoveryRatio: 0,
        totalEventCount: 0,
        mostDivesInSession: 0
    )
}

enum ApneaLogbookStatistics {
    static func filteredSessions(
        in range: ApneaStatisticsRange,
        from source: [ApneaSession],
        referenceDate: Date = Date()
    ) -> [ApneaSession] {
        let eligible = source.filter { isEligibleForStatistics($0) }
        guard range != .allTime else { return eligible }
        let cutoff: Date
        switch range {
        case .last7Days:
            cutoff = Calendar.current.date(byAdding: .day, value: -7, to: referenceDate) ?? referenceDate
        case .last30Days:
            cutoff = Calendar.current.date(byAdding: .day, value: -30, to: referenceDate) ?? referenceDate
        case .lastYear:
            cutoff = Calendar.current.date(byAdding: .year, value: -1, to: referenceDate) ?? referenceDate
        case .allTime:
            cutoff = .distantPast
        }
        return eligible.filter { $0.createdAt >= cutoff }
    }

    static func aggregate(
        from sessions: [ApneaSession],
        range: ApneaStatisticsRange = .allTime,
        referenceDate: Date = Date()
    ) -> ApneaAggregateStatistics {
        let scoped = filteredSessions(in: range, from: sessions, referenceDate: referenceDate)
        guard !scoped.isEmpty else { return .empty }

        let stats = scoped.map { normalizedStatistics(for: $0) }
        let totalDives = stats.reduce(0) { $0 + $1.diveCount }
        let totalUnderwater = stats.reduce(0) { $0 + $1.totalUnderwaterSeconds }
        let totalRecovery = stats.reduce(0) { $0 + $1.totalRecoverySeconds }
        let cumulativeDepth = stats.reduce(0) { $0 + $1.cumulativeDepthMeters }
        let totalEvents = stats.reduce(0) { $0 + $1.eventCount }
        let bestDepth = stats.map(\.sessionMaxDepthMeters).max() ?? 0
        let bestDuration = stats.map(\.bestDiveDurationSeconds).max() ?? 0
        let averageSessionMax = stats.map(\.sessionMaxDepthMeters).reduce(0, +) / Double(stats.count)
        let averageDiveDuration = totalDives > 0 ? totalUnderwater / Double(totalDives) : 0
        let averageRecovery = totalDives > 0 ? totalRecovery / Double(totalDives) : 0
        let ratio = totalRecovery > 0 ? totalUnderwater / totalRecovery : 0
        let mostDives = stats.map(\.diveCount).max() ?? 0

        return ApneaAggregateStatistics(
            sessionCount: scoped.count,
            totalDiveCount: totalDives,
            bestSessionMaxDepthMeters: bestDepth,
            bestDiveDurationSeconds: bestDuration,
            averageSessionMaxDepthMeters: averageSessionMax,
            averageDiveDurationSeconds: averageDiveDuration,
            totalUnderwaterSeconds: totalUnderwater,
            cumulativeDepthMeters: cumulativeDepth,
            averageRecoverySeconds: averageRecovery,
            apneaRecoveryRatio: ratio,
            totalEventCount: totalEvents,
            mostDivesInSession: mostDives
        )
    }

    static func normalizedStatistics(for session: ApneaSession) -> ApneaSessionStatistics {
        session.refreshedStatistics()
    }

    static func isEligibleForStatistics(_ session: ApneaSession) -> Bool {
        guard ApneaDomainValidator.isValid(session: session) else { return false }
        guard session.state == .completed || session.state == .aborted else { return false }
        return session.dives.contains { $0.durationSeconds > 0 || !$0.samples.isEmpty }
    }
}
