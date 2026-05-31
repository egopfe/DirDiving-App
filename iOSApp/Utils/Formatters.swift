import Foundation

enum IOSUnitPreference: String, CaseIterable, Identifiable {
    case metric = "Metrico (m, °C)"
    case imperial = "Imperiale (ft, °F)"

    var id: String { rawValue }

    var shortLabel: String {
        switch self {
        case .metric: return "Metrico"
        case .imperial: return "Imperiale"
        }
    }

    static func fromStorage(_ value: String) -> IOSUnitPreference {
        IOSUnitPreference(rawValue: value) ?? .metric
    }
}

struct DisplayMeasurement {
    let value: String
    let unit: String

    var text: String { "\(value) \(unit)" }
}

enum Formatters {
    private static let clockFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let detailFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy - HH:mm"
        return formatter
    }()

    static func clock(_ date: Date) -> String {
        clockFormatter.string(from: date)
    }

    static func detailTitle(_ date: Date) -> String {
        detailFormatter.string(from: date)
    }

    static func time(_ interval: TimeInterval) -> String {
        let minutes = max(0, Int((interval / 60).rounded()))
        return String(format: "%02d", minutes)
    }
    static func stopwatch(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return h > 0 ? String(format: "%02d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
    }
    static func one(_ value: Double) -> String { String(format: "%.1f", value) }
    static func zero(_ value: Double) -> String { String(format: "%.0f", value) }

    static func depth(_ meters: Double, units: IOSUnitPreference) -> DisplayMeasurement {
        switch units {
        case .metric:
            return DisplayMeasurement(value: one(meters), unit: "m")
        case .imperial:
            return DisplayMeasurement(value: zero(IOSUnitConversions.feet(fromMeters: meters)), unit: "ft")
        }
    }

    static func depthValue(_ meters: Double, units: IOSUnitPreference) -> Double {
        switch units {
        case .metric: return meters
        case .imperial: return IOSUnitConversions.feet(fromMeters: meters)
        }
    }

    static func temperature(_ celsius: Double, units: IOSUnitPreference) -> DisplayMeasurement {
        switch units {
        case .metric:
            return DisplayMeasurement(value: one(celsius), unit: "C")
        case .imperial:
            return DisplayMeasurement(value: one(IOSUnitConversions.fahrenheit(fromCelsius: celsius)), unit: "F")
        }
    }

    static func optionalTemperature(_ celsius: Double?, units: IOSUnitPreference) -> String {
        guard let celsius else {
            switch units {
            case .metric: return "--.- C"
            case .imperial: return "--.- F"
            }
        }
        return temperature(celsius, units: units).text
    }

    static func distance(_ meters: Double, units: IOSUnitPreference, prefersLargeUnit: Bool = false) -> DisplayMeasurement {
        switch units {
        case .metric:
            if prefersLargeUnit || meters >= 1000 {
                return DisplayMeasurement(value: one(IOSUnitConversions.kilometers(fromMeters: meters)), unit: "km")
            }
            return DisplayMeasurement(value: zero(meters), unit: "m")
        case .imperial:
            if prefersLargeUnit || meters >= 1609.344 {
                return DisplayMeasurement(value: one(IOSUnitConversions.miles(fromMeters: meters)), unit: "mi")
            }
            return DisplayMeasurement(value: zero(IOSUnitConversions.feet(fromMeters: meters)), unit: "ft")
        }
    }

    static func sac(_ litersMinute: Double, units: IOSUnitPreference) -> DisplayMeasurement {
        switch units {
        case .metric:
            return DisplayMeasurement(value: one(litersMinute), unit: "l/min")
        case .imperial:
            return DisplayMeasurement(value: one(IOSUnitConversions.cubicFeet(fromLiters: litersMinute)), unit: "cu ft/min")
        }
    }
}
