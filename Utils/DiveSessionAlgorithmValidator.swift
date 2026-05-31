import Foundation

enum DiveSessionAlgorithmValidationError: Error, Equatable {
    case invalidSession
}

enum DiveSessionAlgorithmValidator {
    static let maxDurationSeconds: TimeInterval = 86_400
    static let maxSamples = 20_000

    static func validate(_ session: DiveSession) throws {
        guard session.endDate >= session.startDate,
              session.durationSeconds.isFinite,
              session.durationSeconds >= 0,
              session.durationSeconds <= maxDurationSeconds,
              session.maxDepthMeters.isFinite,
              session.avgDepthMeters.isFinite,
              session.ttv.isFinite,
              session.maxDepthMeters >= 0,
              session.avgDepthMeters >= 0,
              session.ttv >= 0,
              session.maxDepthMeters <= DiveAlgorithmConfiguration.maximumPlausibleDepthMeters,
              session.avgDepthMeters <= DiveAlgorithmConfiguration.maximumPlausibleDepthMeters,
              session.samples.count <= maxSamples,
              validTemperature(session.avgWaterTemperatureCelsius),
              validTemperature(session.minWaterTemperatureCelsius),
              validTemperature(session.maxWaterTemperatureCelsius),
              validGPS(session.entryGPS),
              validGPS(session.exitGPS) else {
            throw DiveSessionAlgorithmValidationError.invalidSession
        }

        if session.samples.isEmpty {
            guard session.isManual, !session.hasDepthProfile else {
                throw DiveSessionAlgorithmValidationError.invalidSession
            }
            let normalized = DiveSessionMerge.preferred(session, session)
            guard abs(normalized.durationSeconds - session.durationSeconds) < 0.001,
                  abs(normalized.ttv - session.ttv) < 0.001 else {
                throw DiveSessionAlgorithmValidationError.invalidSession
            }
            return
        }

        var previousSample: DiveSample?
        for sample in session.samples {
            guard let sanitizedDepth = DiveAlgorithm.sanitizedDepthMeters(sample.depthMeters),
                  sample.timestamp >= session.startDate,
                  sample.timestamp <= session.endDate,
                  validTemperature(sample.temperatureCelsius) else {
                throw DiveSessionAlgorithmValidationError.invalidSession
            }
            let sanitizedSample = DiveSample(
                id: sample.id,
                timestamp: sample.timestamp,
                depthMeters: sanitizedDepth,
                temperatureCelsius: DiveAlgorithm.sanitizedTemperatureCelsius(sample.temperatureCelsius)
            )
            if let previousSample {
                guard sample.timestamp > previousSample.timestamp,
                      DiveAlgorithm.isPlausibleDepthTransition(from: previousSample, to: sanitizedSample) else {
                    throw DiveSessionAlgorithmValidationError.invalidSession
                }
            }
            previousSample = sanitizedSample
        }

        if let minTemp = session.minWaterTemperatureCelsius,
           let maxTemp = session.maxWaterTemperatureCelsius,
           minTemp > maxTemp {
            throw DiveSessionAlgorithmValidationError.invalidSession
        }
        if let avgTemp = session.avgWaterTemperatureCelsius,
           let minTemp = session.minWaterTemperatureCelsius,
           avgTemp < minTemp {
            throw DiveSessionAlgorithmValidationError.invalidSession
        }
        if let avgTemp = session.avgWaterTemperatureCelsius,
           let maxTemp = session.maxWaterTemperatureCelsius,
           avgTemp > maxTemp {
                throw DiveSessionAlgorithmValidationError.invalidSession
            }

        let normalized = DiveSessionMerge.preferred(session, session)
        guard abs(normalized.durationSeconds - session.durationSeconds) < 0.001,
              abs(normalized.maxDepthMeters - session.maxDepthMeters) < 0.001,
              abs(normalized.avgDepthMeters - session.avgDepthMeters) < 0.001,
              abs(normalized.ttv - session.ttv) < 0.001 else {
            throw DiveSessionAlgorithmValidationError.invalidSession
        }
    }

    private static func validTemperature(_ value: Double?) -> Bool {
        guard let value else { return true }
        return DiveAlgorithm.sanitizedTemperatureCelsius(value) != nil
    }

    private static func validGPS(_ point: GPSPoint?) -> Bool {
        guard let point else { return true }
        return point.latitude.isFinite
            && point.longitude.isFinite
            && point.horizontalAccuracy.isFinite
            && point.horizontalAccuracy >= 0
            && (-90...90).contains(point.latitude)
            && (-180...180).contains(point.longitude)
    }
}
