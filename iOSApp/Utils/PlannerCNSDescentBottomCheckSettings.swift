import Foundation

/// iOS planner preference: informational 15% CNS Descent + Bottom warning (default on).
enum PlannerCNSDescentBottomCheckSettings {
    static let storageKey = "dirdiving_ios_planner_cns_descent_bottom_check_enabled"
    static let defaultEnabled = true

    static var isEnabled: Bool {
        guard UserDefaults.standard.object(forKey: storageKey) != nil else {
            return defaultEnabled
        }
        return UserDefaults.standard.bool(forKey: storageKey)
    }
}
