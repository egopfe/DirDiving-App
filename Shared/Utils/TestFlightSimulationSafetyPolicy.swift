import Foundation

/// Diving session simulation eligibility (SEC-P2-004).
enum DivingRecordEligibilityPolicy {
    static let simulatedSourceTag = "simulation"

    static func isSimulatedSession(depthSensorSourceTag: String?) -> Bool {
        depthSensorSourceTag == simulatedSourceTag
    }
}

enum TestFlightSimulationSafetyPolicy {
    static let acknowledgmentKey = "dirdiving_testflight_simulation_acknowledged_v1"
    static let disclosureRequiredKey = "dirdiving_testflight_simulation_disclosure_required"

    static var isTestFlightBuild: Bool {
        #if DEBUG
        return false
        #else
        guard let receiptURL = Bundle.main.appStoreReceiptURL else { return false }
        return receiptURL.lastPathComponent == "sandboxReceipt"
        #endif
    }

    static var isAppStoreReleaseBuild: Bool {
        #if DEBUG
        return false
        #else
        return !isTestFlightBuild
        #endif
    }

    static var requiresSimulationDisclosure: Bool {
        isTestFlightBuild
    }

    static var hasAcknowledgedSimulation: Bool {
        UserDefaults.standard.bool(forKey: acknowledgmentKey)
    }

    static func acknowledgeSimulationRisk() {
        UserDefaults.standard.set(true, forKey: acknowledgmentKey)
    }

    static func normalizeSensorSourceForRelease(stored: String) -> String {
        if isAppStoreReleaseBuild, stored == DivingRecordEligibilityPolicy.simulatedSourceTag {
            return "automatic"
        }
        return stored
    }
}
