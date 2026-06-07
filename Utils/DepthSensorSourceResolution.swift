import Foundation

/// Resolved depth input path for Watch MAIN runtime (display/diagnostics only).
enum DepthSensorSourceResolution: String, Equatable, Codable {
    case appleSensor
    case mockFallback
    case simulation
    case unavailable

    var localizedLabel: String {
        switch self {
        case .appleSensor:
            return String(localized: "watch.depth_source.apple_sensor")
        case .mockFallback:
            return String(localized: "watch.depth_source.mock_fallback")
        case .simulation:
            return String(localized: "developer.sensor_source.simulation")
        case .unavailable:
            return String(localized: "watch.depth_source.unavailable")
        }
    }
}
