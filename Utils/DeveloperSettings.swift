import Foundation

enum DeveloperSettings {
    static let developerUnlockedKey = "developer.settings.unlocked"

    static var isDeveloperSectionVisible: Bool {
        #if DEBUG
        return true
        #else
        if UserDefaults.standard.bool(forKey: developerUnlockedKey) {
            return true
        }
        return isTestFlightBuild
        #endif
    }

    static var sensorSourceMode: SensorSourceMode {
        SensorSourceMode.persisted
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
