import Foundation

struct DepthCapabilityPolicy: Equatable, Sendable {
    let capability: DepthCapabilityMode

    init(capability: DepthCapabilityMode) {
        self.capability = capability
    }

    var supportsSnorkelingRuntime: Bool {
        switch capability {
        case .appleShallow, .appleFull:
            return true
        case .simulation:
            return DeveloperSettings.allowsSimulationSensorSelection
        case .none:
            return false
        }
    }

    var supportsApneaRuntime: Bool {
        supportsSnorkelingRuntime
    }

    /// Gauge remains developer/internal-only when only shallow entitlement is present.
    var supportsDivingGaugeRuntime: Bool {
        switch capability {
        case .appleFull:
            return true
        case .appleShallow:
            return DeveloperSettings.allowsSimulationSensorSelection
        case .simulation:
            return DeveloperSettings.allowsSimulationSensorSelection
        case .none:
            return false
        }
    }

    var supportsFullComputerRuntime: Bool {
        capability == .appleFull
    }

    var fullComputerDisabledReason: String? {
        guard !supportsFullComputerRuntime else { return nil }
        switch capability {
        case .appleShallow:
            return String(localized: "watch.depth_capability.full_computer.blocked_shallow")
        case .simulation:
            return String(localized: "watch.depth_capability.full_computer.blocked_simulation")
        case .none:
            return String(localized: "watch.depth_capability.full_computer.blocked_none")
        case .appleFull:
            return nil
        }
    }

    var gaugeDisabledReason: String? {
        guard !supportsDivingGaugeRuntime else { return nil }
        switch capability {
        case .appleShallow:
            return String(localized: "watch.depth_capability.gauge.blocked_shallow")
        case .none:
            return String(localized: "watch.depth_capability.gauge.blocked_none")
        default:
            return String(localized: "watch.depth_capability.gauge.blocked_generic")
        }
    }
}

extension DepthCapabilityPolicy {
    static var current: DepthCapabilityPolicy {
        DepthCapabilityPolicy(capability: DepthCapabilityResolver.resolve())
    }
}
