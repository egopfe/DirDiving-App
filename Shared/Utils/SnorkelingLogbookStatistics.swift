import Foundation

struct SnorkelingLogbookStatistics: Equatable, Hashable, Sendable {
    var sessionCount: Int
    var totalDipCount: Int
    var bestSessionMaxDepthMeters: Double
    var longestDipSeconds: TimeInterval
    var totalMeasuredDistanceMeters: Double
    var totalWaterTimeSeconds: TimeInterval
    var totalMarkerCount: Int
    var recoveredSessionCount: Int

    static let empty = SnorkelingLogbookStatistics(
        sessionCount: 0,
        totalDipCount: 0,
        bestSessionMaxDepthMeters: 0,
        longestDipSeconds: 0,
        totalMeasuredDistanceMeters: 0,
        totalWaterTimeSeconds: 0,
        totalMarkerCount: 0,
        recoveredSessionCount: 0
    )

    static func aggregate(from sessions: [SnorkelingSession]) -> SnorkelingLogbookStatistics {
        guard !sessions.isEmpty else { return .empty }
        let eligible = sessions.filter { SnorkelingRecordEligibilityPolicy.isEligibleForStatistics($0) }
        guard !eligible.isEmpty else { return .empty }

        let dipCount = eligible.reduce(0) { $0 + $1.statistics.dipCount }
        let bestDepth = eligible.map(\.statistics.sessionMaxDepthMeters).max() ?? 0
        let longestDip = eligible
            .flatMap(\.dips)
            .map(\.durationSeconds)
            .max() ?? 0
        let distance = eligible.map(\.statistics.totalDistanceMeters).reduce(0, +)
        let waterTime = eligible.map(\.statistics.totalDipSeconds).reduce(0, +)
        let markers = eligible.map(\.statistics.markerCount).reduce(0, +)
        let recovered = eligible.filter { $0.warnings.contains(.dataQualityDegraded) || $0.warnings.contains(.schemaMigrated) }.count

        return SnorkelingLogbookStatistics(
            sessionCount: eligible.count,
            totalDipCount: dipCount,
            bestSessionMaxDepthMeters: bestDepth,
            longestDipSeconds: longestDip,
            totalMeasuredDistanceMeters: distance,
            totalWaterTimeSeconds: waterTime,
            totalMarkerCount: markers,
            recoveredSessionCount: recovered
        )
    }
}
