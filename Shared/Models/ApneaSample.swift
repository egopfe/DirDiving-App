import Foundation

/// One depth/time reading in an Apnea dive profile.
struct ApneaSample: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    /// Monotonic elapsed seconds from dive start (must not decrease within a dive).
    var monotonicRelativeTimestampSeconds: TimeInterval
    /// Optional wall-clock capture time when available.
    var wallClockTimestamp: Date?
    var depthMeters: Double
    var temperatureCelsius: Double?
    var verticalSpeedMetersPerSecond: Double
    var quality: ApneaDataQuality

    init(
        id: UUID = UUID(),
        monotonicRelativeTimestampSeconds: TimeInterval,
        wallClockTimestamp: Date? = nil,
        depthMeters: Double,
        temperatureCelsius: Double? = nil,
        verticalSpeedMetersPerSecond: Double = 0,
        quality: ApneaDataQuality = .measured
    ) {
        self.id = id
        self.monotonicRelativeTimestampSeconds = monotonicRelativeTimestampSeconds
        self.wallClockTimestamp = wallClockTimestamp
        self.depthMeters = depthMeters
        self.temperatureCelsius = temperatureCelsius
        self.verticalSpeedMetersPerSecond = verticalSpeedMetersPerSecond
        self.quality = quality
    }
}
