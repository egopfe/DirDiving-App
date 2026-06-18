import Foundation

/// One depth/time reading during a snorkeling dip.
struct SnorkelingDipSample: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var monotonicRelativeTimestampSeconds: TimeInterval
    var wallClockTimestamp: Date?
    var depthMeters: Double
    var temperatureCelsius: Double?
    var verticalSpeedMetersPerSecond: Double
    var depthQuality: SnorkelingDepthQuality

    init(
        id: UUID = UUID(),
        monotonicRelativeTimestampSeconds: TimeInterval,
        wallClockTimestamp: Date? = nil,
        depthMeters: Double,
        temperatureCelsius: Double? = nil,
        verticalSpeedMetersPerSecond: Double = 0,
        depthQuality: SnorkelingDepthQuality = .measured
    ) {
        self.id = id
        self.monotonicRelativeTimestampSeconds = monotonicRelativeTimestampSeconds
        self.wallClockTimestamp = wallClockTimestamp
        self.depthMeters = depthMeters
        self.temperatureCelsius = temperatureCelsius
        self.verticalSpeedMetersPerSecond = verticalSpeedMetersPerSecond
        self.depthQuality = depthQuality
    }
}
