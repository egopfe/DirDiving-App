import Foundation

/// iOS planner preference: informational CNS Descent + Bottom warning (default on @ 15%).
enum PlannerCNSDescentBottomCheckSettings {
    static let storageKey = "dirdiving_ios_planner_cns_descent_bottom_check_enabled"
    static let thresholdStorageKey = "dirdiving_ios_planner_cns_descent_bottom_threshold_percent"
    static let scrollTargetID = "planner.cns_threshold_settings"

    static let defaultEnabled = true
    static let defaultThresholdPercent = 15
    static let minimumThresholdPercent = 5
    static let maximumThresholdPercent = 50

    static var isEnabled: Bool {
        guard UserDefaults.standard.object(forKey: storageKey) != nil else {
            return defaultEnabled
        }
        return UserDefaults.standard.bool(forKey: storageKey)
    }

    static var thresholdPercent: Int {
        guard let stored = UserDefaults.standard.object(forKey: thresholdStorageKey) as? Int else {
            return defaultThresholdPercent
        }
        return clamp(stored)
    }

    static var thresholdPercentDouble: Double {
        Double(thresholdPercent)
    }

    static func clamp(_ value: Int) -> Int {
        min(maximumThresholdPercent, max(minimumThresholdPercent, value))
    }
}
