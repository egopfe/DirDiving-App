import Foundation

enum DiveSessionMerge {
    static func preferred(_ local: DiveSession, _ remote: DiveSession) -> DiveSession {
        let winner = newer(local, remote)
        let loser = winner.id == local.id ? remote : local
        let winnerEntryGPS = validGPS(winner.entryGPS)
        let loserEntryGPS = validGPS(loser.entryGPS)
        let winnerExitGPS = validGPS(winner.exitGPS)
        let loserExitGPS = validGPS(loser.exitGPS)
        let entryGPS = winnerEntryGPS ?? loserEntryGPS
        let exitGPS = winnerExitGPS ?? loserExitGPS
        let entryGPSFixSource: GPSFixSource
        if entryGPS == nil {
            entryGPSFixSource = .noFix
        } else {
            entryGPSFixSource = winnerEntryGPS == nil && loserEntryGPS != nil ? loser.entryGPSFixSource : winner.entryGPSFixSource
        }
        let exitGPSFixSource: GPSFixSource
        if exitGPS == nil {
            exitGPSFixSource = .noFix
        } else {
            exitGPSFixSource = winnerExitGPS == nil && loserExitGPS != nil ? loser.exitGPSFixSource : winner.exitGPSFixSource
        }
        let startDate = min(winner.startDate, loser.startDate)
        let endDate = max(max(winner.endDate, loser.endDate), startDate)
        let selectedSamples = sanitizeSamples(winner.samples.count >= loser.samples.count ? winner.samples : loser.samples)
            .filter { $0.timestamp >= startDate && $0.timestamp <= endDate }
        let duration = max(0, endDate.timeIntervalSince(startDate))
        let sampleDepths = selectedSamples.map(\.depthMeters)
        let maxDepth = sampleDepths.max() ?? maxValid(winner.maxDepthMeters, loser.maxDepthMeters)
        let avgDepth = selectedSamples.isEmpty
            ? maxValid(winner.avgDepthMeters, loser.avgDepthMeters)
            : DiveAlgorithm.timeWeightedAverageDepth(samples: selectedSamples, endDate: endDate)
        let sampleTemperatures = selectedSamples.compactMap { DiveAlgorithm.sanitizedTemperatureCelsius($0.temperatureCelsius) }
        return DiveSession(
            id: winner.id,
            startDate: startDate,
            endDate: endDate,
            durationSeconds: duration,
            maxDepthMeters: maxDepth,
            avgDepthMeters: avgDepth,
            avgWaterTemperatureCelsius: averageTemperature(sampleTemperatures, winner: winner, loser: loser),
            minWaterTemperatureCelsius: sampleTemperatures.min() ?? minOptional(winner.minWaterTemperatureCelsius, loser.minWaterTemperatureCelsius),
            maxWaterTemperatureCelsius: sampleTemperatures.max() ?? maxOptional(winner.maxWaterTemperatureCelsius, loser.maxWaterTemperatureCelsius),
            ttv: DiveAlgorithm.ttvIndex(averageDepthMeters: avgDepth, durationSeconds: duration),
            entryGPS: entryGPS,
            exitGPS: exitGPS,
            entryGPSFixSource: entryGPSFixSource,
            exitGPSFixSource: exitGPSFixSource,
            samples: selectedSamples,
            exceededSupportedDepthRange: winner.exceededSupportedDepthRange || loser.exceededSupportedDepthRange,
            isManual: winner.isManual || loser.isManual,
            hasDepthProfile: !selectedSamples.isEmpty || winner.hasDepthProfile || loser.hasDepthProfile
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
        switch (DiveAlgorithm.sanitizedTemperatureCelsius(lhs), DiveAlgorithm.sanitizedTemperatureCelsius(rhs)) {
        case let (left?, right?): return min(left, right)
        case (nil, let right?): return right
        case (let left?, nil): return left
        case (nil, nil): return nil
        }
    }

    private static func maxOptional(_ lhs: Double?, _ rhs: Double?) -> Double? {
        switch (DiveAlgorithm.sanitizedTemperatureCelsius(lhs), DiveAlgorithm.sanitizedTemperatureCelsius(rhs)) {
        case let (left?, right?): return max(left, right)
        case (nil, let right?): return right
        case (let left?, nil): return left
        case (nil, nil): return nil
        }
    }

    private static func sanitizeSamples(_ samples: [DiveSample]) -> [DiveSample] {
        DiveAlgorithm.sanitizedSamples(samples)
    }

    private static func maxValid(_ lhs: Double, _ rhs: Double) -> Double {
        max(DiveAlgorithm.sanitizedDepthMeters(lhs) ?? 0, DiveAlgorithm.sanitizedDepthMeters(rhs) ?? 0)
    }

    private static func averageTemperature(_ sampleTemperatures: [Double], winner: DiveSession, loser: DiveSession) -> Double? {
        if !sampleTemperatures.isEmpty {
            return sampleTemperatures.reduce(0, +) / Double(sampleTemperatures.count)
        }
        return DiveAlgorithm.sanitizedTemperatureCelsius(winner.avgWaterTemperatureCelsius)
            ?? DiveAlgorithm.sanitizedTemperatureCelsius(loser.avgWaterTemperatureCelsius)
    }

    private static func validGPS(_ point: GPSPoint?) -> GPSPoint? {
        guard let point,
              point.latitude.isFinite,
              point.longitude.isFinite,
              point.horizontalAccuracy.isFinite,
              point.horizontalAccuracy >= 0,
              (-90...90).contains(point.latitude),
              (-180...180).contains(point.longitude) else {
            return nil
        }
        return point
    }
}
