import Foundation

enum DiveSessionMerge {
    static func preferred(_ local: DiveSession, _ remote: DiveSession) -> DiveSession {
        let winner = newer(local, remote)
        let loser = winner.id == local.id ? remote : local
        let entryGPS = winner.entryGPS ?? loser.entryGPS
        let exitGPS = winner.exitGPS ?? loser.exitGPS
        let entryGPSFixSource = winner.entryGPS == nil && loser.entryGPS != nil ? loser.entryGPSFixSource : winner.entryGPSFixSource
        let exitGPSFixSource = winner.exitGPS == nil && loser.exitGPS != nil ? loser.exitGPSFixSource : winner.exitGPSFixSource
        let siteName = winner.siteName ?? loser.siteName
        let buddy = winner.buddy ?? loser.buddy
        let notes = winner.notes ?? loser.notes
        let sacLitersMinute = winner.sacLitersMinute ?? loser.sacLitersMinute
        let isDemo = winner.isDemo || loser.isDemo
        let useLoserSamples = loser.samples.count > winner.samples.count

        return DiveSession(
            id: winner.id,
            startDate: useLoserSamples ? min(winner.startDate, loser.startDate) : winner.startDate,
            endDate: useLoserSamples ? max(winner.endDate, loser.endDate) : winner.endDate,
            durationSeconds: useLoserSamples ? max(winner.durationSeconds, loser.durationSeconds) : winner.durationSeconds,
            maxDepthMeters: useLoserSamples ? max(winner.maxDepthMeters, loser.maxDepthMeters) : winner.maxDepthMeters,
            avgDepthMeters: useLoserSamples ? loser.avgDepthMeters : winner.avgDepthMeters,
            avgWaterTemperatureCelsius: winner.avgWaterTemperatureCelsius ?? loser.avgWaterTemperatureCelsius,
            ttv: useLoserSamples ? max(winner.ttv, loser.ttv) : winner.ttv,
            entryGPS: entryGPS,
            exitGPS: exitGPS,
            entryGPSFixSource: entryGPSFixSource,
            exitGPSFixSource: exitGPSFixSource,
            samples: useLoserSamples ? loser.samples : winner.samples,
            siteName: siteName,
            buddy: buddy,
            notes: notes,
            gasLabel: winner.gasLabel,
            sacLitersMinute: sacLitersMinute,
            isDemo: isDemo,
            exceededSupportedDepthRange: winner.exceededSupportedDepthRange || loser.exceededSupportedDepthRange
        )
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
