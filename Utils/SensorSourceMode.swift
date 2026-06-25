import Foundation

enum SensorSourceMode: String, CaseIterable, Identifiable {
    case automatic
    case appleShallow
    case appleFull
    case simulation
    /// Legacy persisted/UI alias — resolved to shallow/full at runtime.
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

    /// Release-safe mode used by depth runtime (SEC-P1-002).
    static var runtimeMode: SensorSourceMode {
        let stored = persisted
        guard stored == .simulation, !DeveloperSettings.allowsSimulationSensorSelection else {
            return stored
        }
        return .automatic
    }

    /// Developer UI modes — keeps the three-option workflow.
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

    /// Migrates legacy `.simulation` default on first launch after security remediation.
    static func applyReleaseSafeMigrationIfNeeded() {
        guard !DeveloperSettings.allowsSimulationSensorSelection else { return }
        guard persisted == .simulation else { return }
        persist(.automatic)
    }

    /// Maps UI/legacy selection to explicit Apple tier requests for the factory.
    func explicitAppleRequest(resolver: DepthCapabilityResolver = .shared) -> SensorSourceMode {
        switch self {
        case .appleSensor:
            switch resolver.resolveHardwareCapability() {
            case .appleFull:
                return .appleFull
            case .appleShallow:
                return .appleShallow
            default:
                return .appleShallow
            }
        default:
            return self
        }
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
