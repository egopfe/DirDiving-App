import Foundation

/// Pure helpers for Analysis dashboard aggregates (unit-testable).
/// SAC and temperature summaries use simple arithmetic means across sessions, not duration-weighted averages.
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
        // Intentional arithmetic mean per session (not weighted by dive duration).
        let averageSAC = sacValues.isEmpty ? nil : sacValues.reduce(0, +) / Double(sacValues.count)
        let averageTemp = tempValues.isEmpty ? nil : tempValues.reduce(0, +) / Double(tempValues.count)
        return Summary(
            diveCount: sessions.count,
            maxDepthMeters: sessions.map(\.maxDepthMeters).max() ?? 0,
            totalRuntimeMinutes: sessions.map(\.durationSeconds).reduce(0, +) / 60.0,
            averageSACLitersPerMinute: averageSAC,
            averageWaterTemperatureCelsius: averageTemp
        )
    }

    static func sessionsForAnalysis(all: [DiveSession], includeDemo: Bool) -> [DiveSession] {
        includeDemo ? all : all.filter { !$0.isDemoDive }
    }
}
