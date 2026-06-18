import Foundation

/// Shared depth measurement before Apnea/Diving-specific lifecycle handling.
struct DepthMeasurementRaw: Codable, Equatable, Hashable, Sendable {
    let depthMeters: Double?
    let sensorTimestamp: Date
    let receivedAt: Date
    let temperatureCelsius: Double?

    init(
        depthMeters: Double?,
        sensorTimestamp: Date,
        receivedAt: Date = Date(),
        temperatureCelsius: Double? = nil
    ) {
        self.depthMeters = depthMeters
        self.sensorTimestamp = sensorTimestamp
        self.receivedAt = receivedAt
        self.temperatureCelsius = temperatureCelsius
    }
}

struct DepthMeasurementAccepted: Codable, Equatable, Hashable, Sendable {
    let depthMeters: Double
    let sensorTimestamp: Date
    let receivedAt: Date
    let temperatureCelsius: Double?
    let verticalSpeedMetersPerSecond: Double
    let deltaSeconds: TimeInterval

    init(
        depthMeters: Double,
        sensorTimestamp: Date,
        receivedAt: Date,
        temperatureCelsius: Double?,
        verticalSpeedMetersPerSecond: Double,
        deltaSeconds: TimeInterval
    ) {
        self.depthMeters = depthMeters
        self.sensorTimestamp = sensorTimestamp
        self.receivedAt = receivedAt
        self.temperatureCelsius = temperatureCelsius
        self.verticalSpeedMetersPerSecond = verticalSpeedMetersPerSecond
        self.deltaSeconds = deltaSeconds
    }
}

enum DepthFeedQuality: String, Codable, CaseIterable, Hashable, Sendable {
    case accepted
    case missing
    case nonFinite
    case spikeRejected
    case regressiveTimestamp
    case stale
    case outOfRange
}

struct DepthFeedIngestResult: Equatable, Hashable, Sendable {
    let raw: DepthMeasurementRaw
    let quality: DepthFeedQuality
    let accepted: DepthMeasurementAccepted?
}

struct DepthMeasurementFeedConfiguration: Codable, Hashable, Sendable {
    var maximumPlausibleDepthMeters: Double
    var maximumDescentRateMetersPerSecond: Double
    var maximumAscentRateMetersPerSecond: Double
    var regressiveTimestampToleranceSeconds: TimeInterval
    var staleSampleSeconds: TimeInterval

    static let apneaDefault = DepthMeasurementFeedConfiguration(
        maximumPlausibleDepthMeters: 60,
        maximumDescentRateMetersPerSecond: 3.5,
        maximumAscentRateMetersPerSecond: 3.5,
        regressiveTimestampToleranceSeconds: 0.001,
        staleSampleSeconds: 8
    )

    static let snorkelingDefault = DepthMeasurementFeedConfiguration(
        maximumPlausibleDepthMeters: 25,
        maximumDescentRateMetersPerSecond: 2.5,
        maximumAscentRateMetersPerSecond: 2.5,
        regressiveTimestampToleranceSeconds: 0.001,
        staleSampleSeconds: 10
    )
}

struct DepthMeasurementFeedState: Codable, Hashable {
    var lastAccepted: DepthMeasurementAccepted?
    var lastSensorTimestamp: Date?

    static let initial = DepthMeasurementFeedState()
}

/// Reusable depth feed processor — UI-free, independent from Dive lifecycle.
enum DepthMeasurementFeed {
    static func ingest(
        raw: DepthMeasurementRaw,
        state: inout DepthMeasurementFeedState,
        configuration: DepthMeasurementFeedConfiguration = .apneaDefault
    ) -> DepthFeedIngestResult {
        guard let rawDepth = raw.depthMeters else {
            return DepthFeedIngestResult(raw: raw, quality: .missing, accepted: nil)
        }
        guard rawDepth.isFinite else {
            return DepthFeedIngestResult(raw: raw, quality: .nonFinite, accepted: nil)
        }
        guard rawDepth >= 0, rawDepth <= configuration.maximumPlausibleDepthMeters else {
            return DepthFeedIngestResult(raw: raw, quality: .outOfRange, accepted: nil)
        }

        if let lastTimestamp = state.lastSensorTimestamp,
           raw.sensorTimestamp.timeIntervalSince(lastTimestamp) < -configuration.regressiveTimestampToleranceSeconds {
            return DepthFeedIngestResult(raw: raw, quality: .regressiveTimestamp, accepted: nil)
        }

        if let lastAccepted = state.lastAccepted {
            let delta = max(
                raw.receivedAt.timeIntervalSince(lastAccepted.receivedAt),
                raw.sensorTimestamp.timeIntervalSince(lastAccepted.sensorTimestamp),
                0.001
            )

            let speed = (rawDepth - lastAccepted.depthMeters) / delta
            if speed > configuration.maximumDescentRateMetersPerSecond
                || -speed > configuration.maximumAscentRateMetersPerSecond {
                return DepthFeedIngestResult(raw: raw, quality: .spikeRejected, accepted: nil)
            }

            let accepted = DepthMeasurementAccepted(
                depthMeters: rawDepth,
                sensorTimestamp: raw.sensorTimestamp,
                receivedAt: raw.receivedAt,
                temperatureCelsius: sanitizedTemperature(raw.temperatureCelsius),
                verticalSpeedMetersPerSecond: speed,
                deltaSeconds: delta
            )
            state.lastAccepted = accepted
            state.lastSensorTimestamp = raw.sensorTimestamp
            return DepthFeedIngestResult(raw: raw, quality: .accepted, accepted: accepted)
        }

        let accepted = DepthMeasurementAccepted(
            depthMeters: rawDepth,
            sensorTimestamp: raw.sensorTimestamp,
            receivedAt: raw.receivedAt,
            temperatureCelsius: sanitizedTemperature(raw.temperatureCelsius),
            verticalSpeedMetersPerSecond: 0,
            deltaSeconds: 0
        )
        state.lastAccepted = accepted
        state.lastSensorTimestamp = raw.sensorTimestamp
        return DepthFeedIngestResult(raw: raw, quality: .accepted, accepted: accepted)
    }

    private static func sanitizedTemperature(_ value: Double?) -> Double? {
        guard let value, value.isFinite else { return nil }
        return value
    }
}

extension DepthFeedQuality {
    var apneaDataQuality: ApneaDataQuality {
        switch self {
        case .accepted: return .measured
        case .missing: return .missing
        case .nonFinite, .spikeRejected, .regressiveTimestamp, .stale, .outOfRange: return .rejected
        }
    }
}
