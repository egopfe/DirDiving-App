import Foundation

struct DiveProfileSummary: Hashable {
    let samples: [DiveSample]
    let durationSeconds: TimeInterval
    let maxDepthMeters: Double
    let averageDepthMeters: Double
    let averageTemperatureCelsius: Double?
    let ttv: Double
    let exceededSupportedDepthRange: Bool
}

enum DiveProfileMath {
    static func sanitizedDepthMeters(
        _ depth: Double,
        maxDepthMeters: Double = IOSAlgorithmConfiguration.maxSyncDepthMeters
    ) -> Double? {
        guard depth.isFinite, depth >= 0, depth <= maxDepthMeters else { return nil }
        return depth
    }

    static func sanitizedTemperatureCelsius(_ temperature: Double?) -> Double? {
        guard let temperature else { return nil }
        guard temperature.isFinite,
              temperature >= IOSAlgorithmConfiguration.minWaterTemperatureCelsius,
              temperature <= IOSAlgorithmConfiguration.maxWaterTemperatureCelsius else {
            return nil
        }
        return temperature
    }

    static func isValidGPS(_ point: GPSPoint?) -> Bool {
        guard let point else { return false }
        return point.latitude.isFinite
            && point.longitude.isFinite
            && point.horizontalAccuracy.isFinite
            && point.latitude >= -90
            && point.latitude <= 90
            && point.longitude >= -180
            && point.longitude <= 180
            && point.horizontalAccuracy >= 0
    }

    static func sanitizedGPS(_ point: GPSPoint?) -> GPSPoint? {
        isValidGPS(point) ? point : nil
    }

    static func sanitizedSamples(
        _ samples: [DiveSample],
        maxDepthMeters: Double = IOSAlgorithmConfiguration.maxSyncDepthMeters
    ) -> [DiveSample] {
        let sorted = samples
            .compactMap { sample -> DiveSample? in
                guard let depth = sanitizedDepthMeters(sample.depthMeters, maxDepthMeters: maxDepthMeters) else {
                    return nil
                }
                return DiveSample(
                    id: sample.id,
                    timestamp: sample.timestamp,
                    depthMeters: depth,
                    temperatureCelsius: sanitizedTemperatureCelsius(sample.temperatureCelsius)
                )
            }
            .sorted { $0.timestamp < $1.timestamp }

        var deduped: [DiveSample] = []
        for sample in sorted {
            if let last = deduped.last,
               abs(last.timestamp.timeIntervalSince(sample.timestamp)) < .ulpOfOne {
                let replacement = sample.depthMeters >= last.depthMeters ? sample : last
                deduped[deduped.count - 1] = replacement
            } else {
                deduped.append(sample)
            }
        }
        return deduped
    }

    static func timeWeightedAverageDepth(samples: [DiveSample], endDate: Date? = nil) -> Double {
        let sorted = sanitizedSamples(samples)
        guard let first = sorted.first else { return 0 }
        guard sorted.count > 1 else { return first.depthMeters }

        var weightedDepthSeconds = 0.0
        var totalSeconds = 0.0

        for pair in zip(sorted, sorted.dropFirst()) {
            let delta = pair.1.timestamp.timeIntervalSince(pair.0.timestamp)
            guard delta > 0, delta.isFinite else { continue }
            weightedDepthSeconds += pair.0.depthMeters * delta
            totalSeconds += delta
        }

        if let endDate, endDate > sorted.last!.timestamp {
            let delta = endDate.timeIntervalSince(sorted.last!.timestamp)
            if delta.isFinite, delta > 0 {
                weightedDepthSeconds += sorted.last!.depthMeters * delta
                totalSeconds += delta
            }
        }

        guard totalSeconds > 0 else { return first.depthMeters }
        return weightedDepthSeconds / totalSeconds
    }

    static func ttvIndex(averageDepthMeters: Double, durationSeconds: TimeInterval) -> Double {
        let safeAverage = averageDepthMeters.isFinite ? max(0, averageDepthMeters) : 0
        let safeDuration = durationSeconds.isFinite ? max(0, durationSeconds) : 0
        return safeAverage + safeDuration / 60.0
    }

    static func timeWeightedAverageTemperature(samples: [DiveSample], endDate: Date? = nil) -> Double? {
        let sorted = sanitizedSamples(samples)
        guard let first = sorted.first else { return nil }

        var weightedTemperatureSeconds = 0.0
        var totalSeconds = 0.0

        for pair in zip(sorted, sorted.dropFirst()) {
            let delta = pair.1.timestamp.timeIntervalSince(pair.0.timestamp)
            guard delta > 0, delta.isFinite else { continue }
            guard let temperature = sanitizedTemperatureCelsius(pair.0.temperatureCelsius) else { continue }
            weightedTemperatureSeconds += temperature * delta
            totalSeconds += delta
        }

        if let endDate, endDate > sorted.last!.timestamp {
            let delta = endDate.timeIntervalSince(sorted.last!.timestamp)
            if delta.isFinite, delta > 0,
               let temperature = sanitizedTemperatureCelsius(sorted.last!.temperatureCelsius) {
                weightedTemperatureSeconds += temperature * delta
                totalSeconds += delta
            }
        }

        if totalSeconds <= 0 {
            return sanitizedTemperatureCelsius(first.temperatureCelsius)
        }
        return weightedTemperatureSeconds / totalSeconds
    }

    static func summary(
        samples: [DiveSample],
        startDate: Date,
        endDate: Date,
        maxDepthLimit: Double = IOSAlgorithmConfiguration.maxSyncDepthMeters
    ) -> DiveProfileSummary {
        let cleanSamples = sanitizedSamples(samples, maxDepthMeters: maxDepthLimit)
            .filter { $0.timestamp >= startDate && $0.timestamp <= endDate }
        let duration = max(0, endDate.timeIntervalSince(startDate))
        let maxDepth = cleanSamples.map(\.depthMeters).max() ?? 0
        let averageDepth = timeWeightedAverageDepth(samples: cleanSamples, endDate: endDate)
        let averageTemperature = timeWeightedAverageTemperature(samples: cleanSamples, endDate: endDate)
        return DiveProfileSummary(
            samples: cleanSamples,
            durationSeconds: duration,
            maxDepthMeters: maxDepth,
            averageDepthMeters: averageDepth,
            averageTemperatureCelsius: averageTemperature,
            ttv: ttvIndex(averageDepthMeters: averageDepth, durationSeconds: duration),
            exceededSupportedDepthRange: maxDepth >= IOSAlgorithmConfiguration.supportedWatchDepthLimitMeters
        )
    }

    static func normalizedSession(
        _ session: DiveSession,
        maxDepthLimit: Double = IOSAlgorithmConfiguration.maxSyncDepthMeters
    ) -> DiveSession {
        let summary = summary(
            samples: session.samples,
            startDate: session.startDate,
            endDate: session.endDate,
            maxDepthLimit: maxDepthLimit
        )
        let duration = session.endDate >= session.startDate
            ? summary.durationSeconds
            : max(0, session.durationSeconds)
        let maxDepth = summary.samples.isEmpty
            ? (sanitizedDepthMeters(session.maxDepthMeters, maxDepthMeters: maxDepthLimit) ?? 0)
            : summary.maxDepthMeters
        let averageDepth = summary.samples.isEmpty
            ? min(sanitizedDepthMeters(session.avgDepthMeters, maxDepthMeters: maxDepthLimit) ?? 0, maxDepth)
            : summary.averageDepthMeters
        let temperature = summary.averageTemperatureCelsius ?? sanitizedTemperatureCelsius(session.avgWaterTemperatureCelsius)
        return DiveSession(
            id: session.id,
            startDate: session.startDate,
            endDate: session.endDate,
            durationSeconds: duration,
            maxDepthMeters: maxDepth,
            avgDepthMeters: averageDepth,
            avgWaterTemperatureCelsius: temperature,
            ttv: ttvIndex(averageDepthMeters: averageDepth, durationSeconds: duration),
            entryGPS: sanitizedGPS(session.entryGPS),
            exitGPS: sanitizedGPS(session.exitGPS),
            entryGPSFixSource: sanitizedGPS(session.entryGPS) == nil ? .noFix : session.entryGPSFixSource,
            exitGPSFixSource: sanitizedGPS(session.exitGPS) == nil ? .noFix : session.exitGPSFixSource,
            samples: summary.samples,
            siteName: session.siteName,
            buddy: session.buddy,
            notes: session.notes,
            gasLabel: session.gasLabel,
            sacLitersMinute: session.sacLitersMinute,
            isDemo: session.isDemo,
            exceededSupportedDepthRange: session.exceededSupportedDepthRange || summary.exceededSupportedDepthRange,
            isManual: session.isManual,
            equipmentUsed: session.equipmentUsed,
            entryPressureText: session.entryPressureText,
            exitPressureText: session.exitPressureText,
            decompressionNotes: session.decompressionNotes
        )
    }
}
