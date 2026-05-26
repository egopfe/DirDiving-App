import Foundation

/// Presentation-level unit preference (canonical storage remains metric internally).
enum DIRUnitPreference: String, CaseIterable, Identifiable, Codable {
    case metric
    case imperial

    var id: String { rawValue }

    static let storageKey = "dirdiving_watch_units"
    static let iosStorageKey = "dirdiving_ios_units"

    static func fromStorage(_ value: String) -> DIRUnitPreference {
        DIRUnitPreference(rawValue: value) ?? .metric
    }

    var depthUnitLabel: String {
        switch self {
        case .metric: return "m"
        case .imperial: return "ft"
        }
    }

    var pressureUnitLabel: String {
        switch self {
        case .metric: return "bar"
        case .imperial: return "psi"
        }
    }

    var temperatureUnitLabel: String {
        switch self {
        case .metric: return "\u{00B0}C"
        case .imperial: return "\u{00B0}F"
        }
    }

    var ascentRateUnitLabel: String {
        switch self {
        case .metric: return "m/min"
        case .imperial: return "ft/min"
        }
    }

    func depthDisplay(meters: Double) -> (value: Double, unit: String) {
        switch self {
        case .metric: return (meters, "m")
        case .imperial: return (meters * 3.280839895, "ft")
        }
    }

    func depthValue(meters: Double) -> Double {
        depthDisplay(meters: meters).value
    }

    func depthInputToMeters(_ value: Double) -> Double {
        switch self {
        case .metric: return value
        case .imperial: return value / 3.280839895
        }
    }

    func temperatureDisplay(celsius: Double) -> (value: Double, unit: String) {
        switch self {
        case .metric: return (celsius, "\u{00B0}C")
        case .imperial: return (celsius * 9.0 / 5.0 + 32.0, "\u{00B0}F")
        }
    }

    func pressureDisplay(bar: Double) -> (value: Double, unit: String) {
        switch self {
        case .metric: return (bar, "bar")
        case .imperial: return (bar * 14.5037738, "psi")
        }
    }

    func ascentRateDisplay(metersPerMinute: Double) -> (value: Double, unit: String) {
        switch self {
        case .metric: return (metersPerMinute, "m/min")
        case .imperial: return (metersPerMinute * 3.280839895, "ft/min")
        }
    }
}
