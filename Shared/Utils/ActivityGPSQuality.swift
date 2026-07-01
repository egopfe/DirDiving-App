import Foundation

enum WatchSurfaceLocationFixSource: String, Codable, Hashable, Sendable {
    case measured
    case stale
    case unavailable
    case denied
    case restricted
    case failed
}

struct WatchSurfaceLocationFix: Codable, Hashable, Sendable {
    var latitude: Double
    var longitude: Double
    var horizontalAccuracyMeters: Double
    var altitudeMeters: Double?
    var speedMetersPerSecond: Double?
    var courseDegrees: Double?
    var capturedAt: Date
    var source: WatchSurfaceLocationFixSource
}

enum ActivityGPSQuality: String, Codable, Hashable, Sendable {
    case measured
    case stale
    case unavailable
    case denied
    case restricted
    case failed
}
