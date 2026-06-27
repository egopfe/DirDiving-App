import Foundation

/// Resolved depth input path for Watch MAIN runtime (display/diagnostics only).
enum DepthSensorSourceResolution: String, Equatable, Codable {
    case appleShallow
    case appleFull
    case mockFallback
    case simulation
    case unavailable

    /// Legacy persisted value.
    case appleSensor

    var localizedLabel: String {
        switch self {
        case .appleShallow:
            return String(localized: "watch.depth_source.apple_shallow")
        case .appleFull:
            return String(localized: "watch.depth_source.apple_full")
        case .appleSensor:
            return String(localized: "watch.depth_source.apple_sensor")
        case .mockFallback:
            return String(localized: "watch.depth_source.mock_fallback")
        case .simulation:
            return String(localized: "watch.depth_source.simulation_active")
        case .unavailable:
            return String(localized: "watch.depth_source.unavailable")
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .appleShallow:
            return String(localized: "watch.depth_source.apple_shallow.a11y")
        default:
            return localizedLabel
        }
    }

    var sampleSource: DepthSampleSource {
        switch self {
        case .appleShallow, .appleSensor:
            return .appleShallow
        case .appleFull:
            return .appleFull
        case .simulation, .mockFallback:
            return .simulation
        case .unavailable:
            return .unavailable
        }
    }

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        if raw == "appleSensor" {
            self = .appleShallow
        } else {
            self = DepthSensorSourceResolution(rawValue: raw) ?? .unavailable
        }
    }
}
