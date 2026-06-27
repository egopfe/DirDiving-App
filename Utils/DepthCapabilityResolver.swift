import CoreMotion
import Foundation

struct DepthCapabilityResolver {
    /// Test override for deterministic unit tests.
    var testHook_capability: DepthCapabilityMode?

    init(testHook_capability: DepthCapabilityMode? = nil) {
        self.testHook_capability = testHook_capability
    }

    func resolve(selectedMode: SensorSourceMode = .runtimeMode) -> DepthCapabilityMode {
        if let testHook_capability { return testHook_capability }
        switch selectedMode {
        case .simulation:
            return DeveloperSettings.allowsSimulationSensorSelection ? .simulation : .none
        case .automatic, .appleSensor, .appleShallow, .appleFull:
            return resolveHardwareCapability()
        }
    }

    func resolveHardwareCapability() -> DepthCapabilityMode {
        if DepthCapabilityEntitlementProbe.hasFullEntitlement {
            return .appleFull
        }
        if DepthCapabilityEntitlementProbe.hasShallowEntitlement {
            return .appleShallow
        }
        #if DEBUG
        if CMWaterSubmersionManager.waterSubmersionAvailable {
            return .appleShallow
        }
        #endif
        return .none
    }

    private var apiAvailable: Bool {
        CMWaterSubmersionManager.waterSubmersionAvailable
    }
}

extension DepthCapabilityResolver {
    static let shared = DepthCapabilityResolver()
    static func resolve() -> DepthCapabilityMode { shared.resolve() }
    static func resolveHardwareCapability() -> DepthCapabilityMode { shared.resolveHardwareCapability() }
}
