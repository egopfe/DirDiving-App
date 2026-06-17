import Foundation

/// Surface GPS capture for an Apnea session (no dependency on Watch-only GPSPoint).
struct ApneaSurfaceGPSPoint: Codable, Hashable, Sendable {
    var latitude: Double
    var longitude: Double
    var horizontalAccuracyMeters: Double?
    var capturedAt: Date

    init(
        latitude: Double,
        longitude: Double,
        horizontalAccuracyMeters: Double? = nil,
        capturedAt: Date = Date()
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracyMeters = horizontalAccuracyMeters
        self.capturedAt = capturedAt
    }
}
