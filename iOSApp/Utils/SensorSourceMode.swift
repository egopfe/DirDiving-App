import Foundation

enum SensorSourceMode: String, CaseIterable, Identifiable {
    case automatic
    case appleSensor
    case simulation

    var id: String { rawValue }

    static let storageKey = "developer.sensorSource"

    static var persisted: SensorSourceMode {
        let raw = UserDefaults.standard.string(forKey: storageKey) ?? SensorSourceMode.simulation.rawValue
        return SensorSourceMode(rawValue: raw) ?? .simulation
    }

    static func persist(_ mode: SensorSourceMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: storageKey)
    }
}
