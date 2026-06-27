import Foundation

enum DepthSensorUnavailableReason: String, Equatable, Sendable {
    case shallowEntitlementMissing
    case fullEntitlementMissing
    case simulationDisabledInRelease
    case appleSensorUnavailable
    case capabilityNone
}

/// Explicit unavailable provider — never masquerades as simulation or Apple sensor.
@MainActor
final class UnavailableDepthSensorProvider: DepthSensorProvider {
    let reason: DepthSensorUnavailableReason

    var onDepthMeasurement: ((Double?, Date, Double?) -> Void)?
    var onSubmersionState: ((DepthSensorSubmersionState) -> Void)?
    var onTemperature: ((Double?, Date) -> Void)?
    var onError: ((String) -> Void)?

    init(reason: DepthSensorUnavailableReason) {
        self.reason = reason
    }

    func start() {
        onError?(reason.localizedMessage)
    }

    func stop() {}
}

extension DepthSensorUnavailableReason {
    var localizedMessage: String {
        switch self {
        case .shallowEntitlementMissing:
            return String(localized: "watch.depth_sensor.unavailable.shallow_entitlement")
        case .fullEntitlementMissing:
            return String(localized: "watch.depth_sensor.unavailable.full_entitlement")
        case .simulationDisabledInRelease:
            return String(localized: "watch.depth_sensor.unavailable.simulation_release")
        case .appleSensorUnavailable:
            return String(localized: "watch.depth_sensor.unavailable.apple_sensor")
        case .capabilityNone:
            return String(localized: "watch.depth_sensor.unavailable.generic")
        }
    }
}
