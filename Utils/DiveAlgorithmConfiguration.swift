import Foundation

enum DiveAlgorithmConfiguration {
    static let automaticStartDepthMeters = 1.0
    static let automaticStartRequiredSamples = 2
    static let automaticStopDepthMeters = 0.3
    static let automaticStopDwellSeconds: TimeInterval = 8
    static let staleDepthSampleSeconds: TimeInterval = 8
    static let maximumFutureDepthSampleSkewSeconds: TimeInterval = 1
    static let frozenDepthSampleSeconds: TimeInterval = 30
    static let frozenDepthToleranceMeters = 0.001
    static let ascentRateWindowSeconds: TimeInterval = 5
    static let minimumAscentDeltaSeconds: TimeInterval = 1
    static let maximumPlausibleDepthMeters = 350.0
    static let maximumPlausibleDepthChangeMetersPerMinute = 90.0
    static let activeDiveDraftExpirationSeconds: TimeInterval = 12 * 60 * 60
}

enum DiveAlgorithm {
    static func sanitizedDepthMeters(_ rawDepth: Double?) -> Double? {
        guard let rawDepth, rawDepth.isFinite else { return nil }
        guard rawDepth <= DiveAlgorithmConfiguration.maximumPlausibleDepthMeters else { return nil }
        return max(0, rawDepth)
    }

    static func sanitizedTemperatureCelsius(_ rawTemperature: Double?) -> Double? {
        guard let rawTemperature, rawTemperature.isFinite else { return nil }
        return rawTemperature
    }

    static func sanitizedSamples(_ source: [DiveSample]) -> [DiveSample] {
        source
            .sorted { $0.timestamp < $1.timestamp }
            .compactMap { sample in
                guard let depth = sanitizedDepthMeters(sample.depthMeters) else { return nil }
                return DiveSample(
                    id: sample.id,
                    timestamp: sample.timestamp,
                    depthMeters: depth,
                    temperatureCelsius: sanitizedTemperatureCelsius(sample.temperatureCelsius)
                )
            }
    }

    static func timeWeightedAverageDepth(samples: [DiveSample], endDate: Date? = nil) -> Double {
        let ordered = sanitizedSamples(samples)
        guard !ordered.isEmpty else { return 0 }
        guard ordered.count > 1 else { return ordered[0].depthMeters }

        var weightedSum = 0.0
        var totalTime: TimeInterval = 0

        for index in ordered.indices.dropLast() {
            let current = ordered[index]
            let next = ordered[index + 1]
            let interval = max(0, next.timestamp.timeIntervalSince(current.timestamp))
            weightedSum += current.depthMeters * interval
            totalTime += interval
        }

        if let endDate {
            let last = ordered[ordered.count - 1]
            let tailInterval = max(0, endDate.timeIntervalSince(last.timestamp))
            weightedSum += last.depthMeters * tailInterval
            totalTime += tailInterval
        }

        if totalTime > 0 {
            return weightedSum / totalTime
        }

        return ordered.map(\.depthMeters).reduce(0, +) / Double(ordered.count)
    }

    static func ttvIndex(averageDepthMeters: Double, durationSeconds: TimeInterval) -> Double {
        let safeAverage = averageDepthMeters.isFinite ? max(0, averageDepthMeters) : 0
        let safeDuration = durationSeconds.isFinite ? max(0, durationSeconds) : 0
        return safeAverage + (safeDuration / 60.0)
    }

    static func ascentRateMetersPerMinute(samples: [DiveSample], current sample: DiveSample) -> Double {
        guard let currentDepth = sanitizedDepthMeters(sample.depthMeters) else { return 0 }
        let currentSample = DiveSample(
            id: sample.id,
            timestamp: sample.timestamp,
            depthMeters: currentDepth,
            temperatureCelsius: sanitizedTemperatureCelsius(sample.temperatureCelsius)
        )
        var sourceSamples = samples.filter { $0.id != currentSample.id }
        sourceSamples.append(currentSample)
        let ordered = sanitizedSamples(sourceSamples)
            .filter { $0.timestamp <= currentSample.timestamp }
            .sorted { $0.timestamp < $1.timestamp }
        guard ordered.count > 1 else { return 0 }

        let windowStart = currentSample.timestamp.addingTimeInterval(-DiveAlgorithmConfiguration.ascentRateWindowSeconds)
        let earlierSamples = ordered.filter { $0.timestamp < currentSample.timestamp }
        let candidates = earlierSamples.filter { $0.timestamp >= windowStart }
        let reference = candidates.first ?? earlierSamples.last
        guard let reference else { return 0 }

        let deltaTime = currentSample.timestamp.timeIntervalSince(reference.timestamp)
        guard deltaTime >= DiveAlgorithmConfiguration.minimumAscentDeltaSeconds else { return 0 }

        let deltaDepth = reference.depthMeters - currentSample.depthMeters
        let rawRate = max(0, (deltaDepth / deltaTime) * 60.0)
        guard rawRate.isFinite else { return 0 }
        return min(rawRate, DiveAlgorithmConfiguration.maximumPlausibleDepthChangeMetersPerMinute)
    }

    static func normalizedDegrees(_ degrees: Double) -> Double {
        guard degrees.isFinite else { return 0 }
        return (degrees.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
    }

    static func signedBearingDeltaDegrees(from heading: Double, to bearing: Double) -> Double {
        let normalizedHeading = normalizedDegrees(heading)
        let normalizedBearing = normalizedDegrees(bearing)
        var delta = normalizedBearing - normalizedHeading
        if delta > 180 { delta -= 360 }
        if delta < -180 { delta += 360 }
        return delta
    }

    static func isPlausibleDepthTransition(from previous: DiveSample?, to sample: DiveSample) -> Bool {
        guard sample.depthMeters.isFinite, sample.depthMeters >= 0 else { return false }
        guard let previous else { return true }
        guard previous.depthMeters.isFinite, previous.depthMeters >= 0 else { return true }
        let deltaTime = sample.timestamp.timeIntervalSince(previous.timestamp)
        guard deltaTime > 0 else { return false }
        let rate = abs(sample.depthMeters - previous.depthMeters) / deltaTime * 60.0
        return rate <= DiveAlgorithmConfiguration.maximumPlausibleDepthChangeMetersPerMinute
    }
}
