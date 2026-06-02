import Foundation

enum ManualDiveEditorDefaults {
    static let defaultMaxDepthMeters = 30.0
    static let defaultAverageDepthMeters = 18.0

    static func defaultMaxDepthInput(units: IOSUnitPreference) -> Double {
        switch units {
        case .metric:
            return defaultMaxDepthMeters
        case .imperial:
            return Formatters.depthValue(defaultMaxDepthMeters, units: .imperial)
        }
    }

    static func defaultAverageDepthInput(units: IOSUnitPreference) -> Double {
        switch units {
        case .metric:
            return defaultAverageDepthMeters
        case .imperial:
            return Formatters.depthValue(defaultAverageDepthMeters, units: .imperial)
        }
    }

    static func depthMeters(fromInput value: Double, units: IOSUnitPreference) -> Double {
        switch units {
        case .metric:
            return value
        case .imperial:
            return IOSUnitConversions.meters(fromFeet: value)
        }
    }
}
