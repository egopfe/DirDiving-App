import Foundation

enum DiveSessionMerge {
    static func preferred(_ local: DiveSession, _ remote: DiveSession) -> DiveSession {
        let winner = newer(local, remote)
        let loser = winner.id == local.id ? remote : local
        var merged = winner
        merged.siteName = winner.siteName ?? loser.siteName
        merged.buddy = winner.buddy ?? loser.buddy
        merged.notes = winner.notes ?? loser.notes
        merged.sacLitersMinute = winner.sacLitersMinute ?? loser.sacLitersMinute
        merged.entryGPS = winner.entryGPS ?? loser.entryGPS
        merged.exitGPS = winner.exitGPS ?? loser.exitGPS
        merged.isDemo = winner.isDemo || loser.isDemo
        if loser.samples.count > winner.samples.count {
            merged = DiveSession(
                id: winner.id,
                startDate: min(winner.startDate, loser.startDate),
                endDate: max(winner.endDate, loser.endDate),
                durationSeconds: max(winner.durationSeconds, loser.durationSeconds),
                maxDepthMeters: max(winner.maxDepthMeters, loser.maxDepthMeters),
                avgDepthMeters: loser.avgDepthMeters,
                avgWaterTemperatureCelsius: winner.avgWaterTemperatureCelsius ?? loser.avgWaterTemperatureCelsius,
                ttv: max(winner.ttv, loser.ttv),
                entryGPS: merged.entryGPS,
                exitGPS: merged.exitGPS,
                samples: loser.samples,
                siteName: merged.siteName,
                buddy: merged.buddy,
                notes: merged.notes,
                gasLabel: winner.gasLabel,
                sacLitersMinute: merged.sacLitersMinute,
                isDemo: merged.isDemo
            )
        }
        return merged
    }

    private static func newer(_ lhs: DiveSession, _ rhs: DiveSession) -> DiveSession {
        if lhs.endDate != rhs.endDate {
            return lhs.endDate >= rhs.endDate ? lhs : rhs
        }
        if lhs.samples.count != rhs.samples.count {
            return lhs.samples.count >= rhs.samples.count ? lhs : rhs
        }
        if lhs.durationSeconds != rhs.durationSeconds {
            return lhs.durationSeconds >= rhs.durationSeconds ? lhs : rhs
        }
        return lhs
    }
}
