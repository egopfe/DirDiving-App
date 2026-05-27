import Foundation

enum DiveSessionMerge {
    static func preferred(_ local: DiveSession, _ remote: DiveSession) -> DiveSession {
        let winner = newer(local, remote)
        let loser = winner.id == local.id ? remote : local
        let entryGPS = validGPS(winner.entryGPS) ?? validGPS(loser.entryGPS)
        let exitGPS = validGPS(winner.exitGPS) ?? validGPS(loser.exitGPS)
        let entryGPSFixSource = validGPS(winner.entryGPS) == nil && validGPS(loser.entryGPS) != nil ? loser.entryGPSFixSource : winner.entryGPSFixSource
        let exitGPSFixSource = validGPS(winner.exitGPS) == nil && validGPS(loser.exitGPS) != nil ? loser.exitGPSFixSource : winner.exitGPSFixSource
        let siteName = winner.siteName ?? loser.siteName
        let buddy = winner.buddy ?? loser.buddy
        let notes = winner.notes ?? loser.notes
        let sacLitersMinute = winner.sacLitersMinute ?? loser.sacLitersMinute
        let isDemo = winner.isDemo || loser.isDemo
        let selectedSamples = canonicalSamples(winner: winner, loser: loser)
        let metrics = DiveProfileMath.derivedMetrics(
            samples: selectedSamples,
            fallbackStart: winner.startDate,
            fallbackEnd: winner.endDate
        )

        return DiveSession(
            id: winner.id,
            startDate: metrics.startDate,
            endDate: metrics.endDate,
            durationSeconds: metrics.durationSeconds,
            maxDepthMeters: metrics.maxDepthMeters,
            avgDepthMeters: metrics.avgDepthMeters,
            avgWaterTemperatureCelsius: metrics.avgWaterTemperatureCelsius ?? winner.avgWaterTemperatureCelsius ?? loser.avgWaterTemperatureCelsius,
            minWaterTemperatureCelsius: metrics.minWaterTemperatureCelsius,
            maxWaterTemperatureCelsius: metrics.maxWaterTemperatureCelsius,
            ttv: metrics.ttv,
            entryGPS: entryGPS,
            exitGPS: exitGPS,
            entryGPSFixSource: entryGPSFixSource,
            exitGPSFixSource: exitGPSFixSource,
            samples: metrics.samples,
            siteName: siteName,
            buddy: buddy,
            notes: notes,
            gasLabel: winner.gasLabel,
            sacLitersMinute: sacLitersMinute,
            isDemo: isDemo,
            exceededSupportedDepthRange: winner.exceededSupportedDepthRange || loser.exceededSupportedDepthRange || metrics.exceededSupportedDepthRange
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

    private static func canonicalSamples(winner: DiveSession, loser: DiveSession) -> [DiveSample] {
        let winnerSamples = DiveProfileMath.sanitizedSamples(winner.samples)
        let loserSamples = DiveProfileMath.sanitizedSamples(loser.samples)
        if winnerSamples.count != loserSamples.count {
            return winnerSamples.count > loserSamples.count ? winnerSamples : loserSamples
        }
        if winner.endDate != loser.endDate {
            return winner.endDate >= loser.endDate ? winnerSamples : loserSamples
        }
        return winnerSamples
    }

    private static func validGPS(_ point: GPSPoint?) -> GPSPoint? {
        DiveSessionAlgorithmValidator.validGPS(point) ? point : nil
    }
}
