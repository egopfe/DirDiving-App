import Foundation

/// Pure helpers for Analysis dashboard aggregates (unit-testable).
enum AnalysisDashboardMath {
    struct Summary: Equatable {
        let diveCount: Int
        let maxDepthMeters: Double
        let totalRuntimeMinutes: Double
        let averageSACLitersPerMinute: Double?
        let averageWaterTemperatureCelsius: Double?
    }

    static func summary(from sessions: [DiveSession]) -> Summary {
        guard !sessions.isEmpty else {
            return Summary(
                diveCount: 0,
                maxDepthMeters: 0,
                totalRuntimeMinutes: 0,
                averageSACLitersPerMinute: nil,
                averageWaterTemperatureCelsius: nil
            )
        }
        let sacValues = sessions.compactMap(\.sacLitersMinute)
        let tempValues = sessions.compactMap(\.avgWaterTemperatureCelsius)
        return Summary(
            diveCount: sessions.count,
            maxDepthMeters: sessions.map(\.maxDepthMeters).max() ?? 0,
            totalRuntimeMinutes: sessions.map(\.durationSeconds).reduce(0, +) / 60.0,
            averageSACLitersPerMinute: sacValues.isEmpty ? nil : sacValues.reduce(0, +) / Double(sacValues.count),
            averageWaterTemperatureCelsius: tempValues.isEmpty ? nil : tempValues.reduce(0, +) / Double(tempValues.count)
        )
    }

    static func sessionsForAnalysis(all: [DiveSession], includeDemo: Bool) -> [DiveSession] {
        includeDemo ? all : all.filter { !$0.isDemoDive }
    }
}
