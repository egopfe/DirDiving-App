import Foundation

/// Activity-scoped iOS navigation restoration after process death.
enum IOSCompanionNavigationPersistence {
    private static let divingTabKey = "dirdiving_ios_diving_selected_tab_v1"
    private static let settingsScopeKey = "dirdiving_ios_settings_scope_v1"
    private static let apneaTabKey = "dirdiving_ios_apnea_selected_tab_v1"
    private static let snorkelingTabKey = "dirdiving_ios_snorkeling_selected_tab_v1"

    static func restoreDivingTabToken(defaults: UserDefaults = .standard) -> String? {
        defaults.string(forKey: divingTabKey)
    }

    static func persistDivingTabToken(_ token: String, defaults: UserDefaults = .standard) {
        defaults.set(token, forKey: divingTabKey)
    }

    static func restoreSettingsScopeToken(defaults: UserDefaults = .standard) -> String? {
        defaults.string(forKey: settingsScopeKey)
    }

    static func persistSettingsScopeToken(_ token: String, defaults: UserDefaults = .standard) {
        defaults.set(token, forKey: settingsScopeKey)
    }

    static func restoreApneaTabToken(defaults: UserDefaults = .standard) -> String? {
        defaults.string(forKey: apneaTabKey)
    }

    static func persistApneaTabToken(_ token: String, defaults: UserDefaults = .standard) {
        defaults.set(token, forKey: apneaTabKey)
    }

    static func restoreSnorkelingTabToken(defaults: UserDefaults = .standard) -> String? {
        defaults.string(forKey: snorkelingTabKey)
    }

    static func persistSnorkelingTabToken(_ token: String, defaults: UserDefaults = .standard) {
        defaults.set(token, forKey: snorkelingTabKey)
    }

    #if DEBUG
    static func resetForTesting(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: divingTabKey)
        defaults.removeObject(forKey: settingsScopeKey)
        defaults.removeObject(forKey: apneaTabKey)
        defaults.removeObject(forKey: snorkelingTabKey)
    }
    #endif
}

/// Cross-activity deep-link guard — session detail routes fail closed outside owning activity.
enum IOSCompanionDeepLinkPolicy {
    static func allowsSessionDetail(requestedActivity: DIRActivityMode, activeActivity: DIRActivityMode?) -> Bool {
        guard let activeActivity else { return false }
        return requestedActivity == activeActivity
    }
}
