import Foundation

enum DeveloperSettings {
    static let developerUnlockedKey = "developer.settings.unlocked"

    static var isDeveloperSectionVisible: Bool {
        #if DEBUG
        return true
        #else
        return isTestFlightBuild
        #endif
    }

    static var allowsSimulationSensorSelection: Bool {
        #if DEBUG
        return true
        #else
        return isTestFlightBuild
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

    private static var isTestFlightBuild: Bool {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else { return false }
        return receiptURL.lastPathComponent == "sandboxReceipt"
    }
}
