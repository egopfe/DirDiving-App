import Foundation

enum DiveSessionMerge {
    static func preferred(_ local: DiveSession, _ remote: DiveSession) -> DiveSession {
        let winner = newer(local, remote)
        let loser = winner.id == local.id ? remote : local
        let entryGPS = winner.entryGPS ?? loser.entryGPS
        let exitGPS = winner.exitGPS ?? loser.exitGPS
        let entryGPSFixSource = winner.entryGPS == nil && loser.entryGPS != nil ? loser.entryGPSFixSource : winner.entryGPSFixSource
        let exitGPSFixSource = winner.exitGPS == nil && loser.exitGPS != nil ? loser.exitGPSFixSource : winner.exitGPSFixSource
        return DiveSession(
            id: winner.id,
            startDate: min(winner.startDate, loser.startDate),
            endDate: max(winner.endDate, loser.endDate),
            durationSeconds: max(winner.durationSeconds, loser.durationSeconds),
            maxDepthMeters: max(winner.maxDepthMeters, loser.maxDepthMeters),
            avgDepthMeters: winner.samples.count >= loser.samples.count ? winner.avgDepthMeters : loser.avgDepthMeters,
            avgWaterTemperatureCelsius: winner.avgWaterTemperatureCelsius ?? loser.avgWaterTemperatureCelsius,
            minWaterTemperatureCelsius: minOptional(winner.minWaterTemperatureCelsius, loser.minWaterTemperatureCelsius),
            maxWaterTemperatureCelsius: maxOptional(winner.maxWaterTemperatureCelsius, loser.maxWaterTemperatureCelsius),
            ttv: max(winner.ttv, loser.ttv),
            entryGPS: entryGPS,
            exitGPS: exitGPS,
            entryGPSFixSource: entryGPSFixSource,
            exitGPSFixSource: exitGPSFixSource,
            samples: winner.samples.count >= loser.samples.count ? winner.samples : loser.samples
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

    private static func minOptional(_ lhs: Double?, _ rhs: Double?) -> Double? {
        switch (lhs, rhs) {
        case let (left?, right?): return min(left, right)
        case (nil, let right?): return right
        case (let left?, nil): return left
        case (nil, nil): return nil
        }
    }

    private static func maxOptional(_ lhs: Double?, _ rhs: Double?) -> Double? {
        switch (lhs, rhs) {
        case let (left?, right?): return max(left, right)
        case (nil, let right?): return right
        case (let left?, nil): return left
        case (nil, nil): return nil
        }
    }
}
