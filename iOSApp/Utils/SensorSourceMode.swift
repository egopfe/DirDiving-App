import Foundation

enum SensorSourceMode: String, CaseIterable, Identifiable {
    case automatic
    case appleShallow
    case appleFull
    case simulation
    case appleSensor

    var id: String { rawValue }

    static let storageKey = "developer.sensorSource"

    static var persisted: SensorSourceMode {
        guard let raw = UserDefaults.standard.string(forKey: storageKey),
              let mode = SensorSourceMode(rawValue: raw) else {
            return .automatic
        }
        return mode
    }

    static var runtimeMode: SensorSourceMode {
        let stored = persisted
        guard stored == .simulation, !DeveloperSettings.allowsSimulationSensorSelection else {
            return stored
        }
        return .automatic
    }

    static var selectableModes: [SensorSourceMode] {
        if DeveloperSettings.allowsSimulationSensorSelection {
            return [.automatic, .appleSensor, .simulation]
        }
        return [.automatic, .appleSensor]
    }

    static func persist(_ mode: SensorSourceMode) {
        let sanitized: SensorSourceMode
        if mode == .simulation, !DeveloperSettings.allowsSimulationSensorSelection {
            sanitized = .automatic
        } else {
            sanitized = mode
        }
        UserDefaults.standard.set(sanitized.rawValue, forKey: storageKey)
    }

    static func applyReleaseSafeMigrationIfNeeded() {
        guard !DeveloperSettings.allowsSimulationSensorSelection else { return }
        guard persisted == .simulation else { return }
        persist(.automatic)
    }
}

extension SensorSourceMode {
    var displayName: String {
        switch self {
        case .automatic:
            return String(localized: "developer.sensor_source.automatic")
        case .appleSensor, .appleShallow, .appleFull:
            return String(localized: "developer.sensor_source.apple_sensor")
        case .simulation:
            return String(localized: "developer.sensor_source.simulation")
        }
    }
}
