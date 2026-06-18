import Foundation

/// One position sample on a snorkeling session track (surface GPS or estimated/absent underwater).
struct SnorkelingTrackPoint: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var monotonicRelativeTimestampSeconds: TimeInterval
    var wallClockTimestamp: Date?
    var latitude: Double?
    var longitude: Double?
    var horizontalAccuracyMeters: Double?
    var altitudeMeters: Double?
    var speedMetersPerSecond: Double?
    var courseDegrees: Double?
    var gpsQuality: SnorkelingGPSQuality
    var depthMeters: Double?
    var depthQuality: SnorkelingDepthQuality
    /// True when the diver is submerged; surface GPS must not be assumed measured.
    var isUnderwater: Bool

    init(
        id: UUID = UUID(),
        monotonicRelativeTimestampSeconds: TimeInterval,
        wallClockTimestamp: Date? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        horizontalAccuracyMeters: Double? = nil,
        altitudeMeters: Double? = nil,
        speedMetersPerSecond: Double? = nil,
        courseDegrees: Double? = nil,
        gpsQuality: SnorkelingGPSQuality = .unavailable,
        depthMeters: Double? = nil,
        depthQuality: SnorkelingDepthQuality = .unavailable,
        isUnderwater: Bool = false
    ) {
        self.id = id
        self.monotonicRelativeTimestampSeconds = monotonicRelativeTimestampSeconds
        self.wallClockTimestamp = wallClockTimestamp
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracyMeters = horizontalAccuracyMeters
        self.altitudeMeters = altitudeMeters
        self.speedMetersPerSecond = speedMetersPerSecond
        self.courseDegrees = courseDegrees
        self.gpsQuality = gpsQuality
        self.depthMeters = depthMeters
        self.depthQuality = depthQuality
        self.isUnderwater = isUnderwater
    }
}
