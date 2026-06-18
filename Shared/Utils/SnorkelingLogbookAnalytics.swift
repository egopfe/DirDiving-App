import Foundation

enum SnorkelingStatisticsRange: String, Codable, CaseIterable, Hashable, Sendable {
    case last7Days
    case last30Days
    case lastYear
    case allTime
}

struct SnorkelingAggregateStatistics: Equatable, Hashable, Sendable {
    var sessionCount: Int
    var totalDipCount: Int
    var bestSessionMaxDepthMeters: Double
    var longestDipSeconds: TimeInterval
    var bestSessionDistanceMeters: Double
    var averageSessionMaxDepthMeters: Double
    var averageDipDurationSeconds: TimeInterval
    var totalMeasuredDistanceMeters: Double
    var totalWaterTimeSeconds: TimeInterval
    var averageSurfaceSpeedMetersPerSecond: Double
    var totalMarkerCount: Int
    var mostDipsInSession: Int
    var longestSessionDurationSeconds: TimeInterval

    static let empty = SnorkelingAggregateStatistics(
        sessionCount: 0,
        totalDipCount: 0,
        bestSessionMaxDepthMeters: 0,
        longestDipSeconds: 0,
        bestSessionDistanceMeters: 0,
        averageSessionMaxDepthMeters: 0,
        averageDipDurationSeconds: 0,
        totalMeasuredDistanceMeters: 0,
        totalWaterTimeSeconds: 0,
        averageSurfaceSpeedMetersPerSecond: 0,
        totalMarkerCount: 0,
        mostDipsInSession: 0,
        longestSessionDurationSeconds: 0
    )
}

enum SnorkelingLogbookAnalytics {
    static func filteredSessions(
        in range: SnorkelingStatisticsRange,
        from source: [SnorkelingSession],
        referenceDate: Date = Date()
    ) -> [SnorkelingSession] {
        let eligible = source.filter { SnorkelingRecordEligibilityPolicy.isEligibleForStatistics($0) }
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
        from sessions: [SnorkelingSession],
        range: SnorkelingStatisticsRange = .allTime,
        referenceDate: Date = Date()
    ) -> SnorkelingAggregateStatistics {
        let scoped = filteredSessions(in: range, from: sessions, referenceDate: referenceDate)
        guard !scoped.isEmpty else { return .empty }

        let stats = scoped.map(\.statistics)
        let totalDips = stats.reduce(0) { $0 + $1.dipCount }
        let waterTime = stats.reduce(0) { $0 + $1.totalDipSeconds }
        let distance = stats.reduce(0) { $0 + $1.totalDistanceMeters }
        let markers = stats.reduce(0) { $0 + $1.markerCount }
        let bestDepth = stats.map(\.sessionMaxDepthMeters).max() ?? 0
        let bestDistance = stats.map(\.totalDistanceMeters).max() ?? 0
        let longestDip = scoped.flatMap(\.dips).map(\.durationSeconds).max() ?? 0
        let averageDepth = stats.map(\.sessionMaxDepthMeters).reduce(0, +) / Double(stats.count)
        let averageDip = totalDips > 0 ? waterTime / Double(totalDips) : 0
        let speeds = stats.map(\.averageSpeedMetersPerSecond).filter { $0.isFinite && $0 > 0 }
        let averageSpeed = speeds.isEmpty ? 0 : speeds.reduce(0, +) / Double(speeds.count)
        let mostDips = stats.map(\.dipCount).max() ?? 0
        let longestSession = stats.map(\.sessionDurationSeconds).max() ?? 0

        return SnorkelingAggregateStatistics(
            sessionCount: scoped.count,
            totalDipCount: totalDips,
            bestSessionMaxDepthMeters: bestDepth,
            longestDipSeconds: longestDip,
            bestSessionDistanceMeters: bestDistance,
            averageSessionMaxDepthMeters: averageDepth,
            averageDipDurationSeconds: averageDip,
            totalMeasuredDistanceMeters: distance,
            totalWaterTimeSeconds: waterTime,
            averageSurfaceSpeedMetersPerSecond: averageSpeed,
            totalMarkerCount: markers,
            mostDipsInSession: mostDips,
            longestSessionDurationSeconds: longestSession
        )
    }
}
