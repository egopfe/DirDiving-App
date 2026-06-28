import Foundation

enum DeveloperSettings {
    static let developerUnlockedKey = "developer.settings.unlocked"
    static let shallowDepthDivingTestingKey = "developer.shallow_depth_diving_testing_enabled"
    static let shallowGaugeTestingKey = "developer.shallow_gauge_testing_enabled"

    static var isDeveloperSectionVisible: Bool {
        #if DEBUG
        return true
        #else
        return isTestFlightBuild
        #endif
    }

    /// Simulation depth is DEBUG/TestFlight-only with explicit acknowledgment (SEC-P2-004).
    static var allowsSimulationSensorSelection: Bool {
        #if DEBUG
        return true
        #else
        return TestFlightSimulationSafetyPolicy.isTestFlightBuild
            && TestFlightSimulationSafetyPolicy.hasAcknowledgedSimulation
        #endif
    }

    static var sensorSourceMode: SensorSourceMode {
        SensorSourceMode.runtimeMode
    }

    static func persistSensorSource(_ mode: SensorSourceMode) {
        SensorSourceMode.persist(mode)
    }

    static func unlockDeveloperSection() {
        UserDefaults.standard.set(true, forKey: developerUnlockedKey)
    }

    /// DEBUG/TestFlight-only: allow Gauge runtime when resolved capability is appleShallow (~6 m).
    static var allowsShallowGaugeTesting: Bool {
        guard DepthCapabilityEntitlementProbe.hasShallowEntitlement else { return false }
        return resolvedShallowTestingFlag(key: shallowGaugeTestingKey)
    }

    /// DEBUG/TestFlight-only: allow Full Computer runtime when resolved capability is appleShallow (~6 m).
    static var allowsShallowDepthDivingTesting: Bool {
        guard DepthCapabilityEntitlementProbe.hasShallowEntitlement else { return false }
        return resolvedShallowTestingFlag(key: shallowDepthDivingTestingKey)
    }

    static func setShallowGaugeTestingEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: shallowGaugeTestingKey)
    }

    static func setShallowDepthDivingTestingEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: shallowDepthDivingTestingKey)
    }

    #if DEBUG
    static func resetShallowDepthDivingTestingForTests() {
        UserDefaults.standard.removeObject(forKey: shallowDepthDivingTestingKey)
        UserDefaults.standard.removeObject(forKey: shallowGaugeTestingKey)
    }
    #endif

    private static func resolvedShallowTestingFlag(key: String) -> Bool {
        guard isDeveloperSectionVisible else { return false }
        #if DEBUG
        if UserDefaults.standard.object(forKey: key) == nil {
            return true
        }
        #endif
        return UserDefaults.standard.bool(forKey: key)
    }

    private static var isTestFlightBuild: Bool {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else { return false }
        return receiptURL.lastPathComponent == "sandboxReceipt"
    }
}
