import Foundation

enum WatchWaterAutoOpenMode: String, Codable, CaseIterable, Identifiable, Sendable {
    case disabled
    case lastSelectedMode
    case preferredMode

    var id: String { rawValue }
}

struct WatchWaterPreferredLaunchDestination: Codable, Equatable, Sendable {
    var activity: DIRActivityMode
    var divingMode: DIRDivingMode
}

enum WatchWaterAutoOpenPolicy {
    static let modeKey = "dirdiving_watch_water_auto_open_mode"
    static let preferredActivityKey = "dirdiving_watch_water_auto_open_preferred_activity"
    static let preferredDivingModeKey = "dirdiving_watch_water_auto_open_preferred_diving_mode"
    static let lastSelectedActivityKey = "dirdiving_watch_water_auto_open_last_selected_activity"
    static let lastSelectedDivingModeKey = "dirdiving_watch_water_auto_open_last_selected_diving_mode"
    static let migratedKey = "dirdiving_watch_water_auto_open_migrated_v1"

    static var mode: WatchWaterAutoOpenMode {
        get {
            migrateIfNeeded()
            guard
                let raw = UserDefaults.standard.string(forKey: modeKey),
                let value = WatchWaterAutoOpenMode(rawValue: raw)
            else { return .disabled }
            return value
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: modeKey) }
    }

    static var preferredDestination: WatchWaterPreferredLaunchDestination {
        get {
            migrateIfNeeded()
            return sanitizedDestination(
                activityRaw: UserDefaults.standard.string(forKey: preferredActivityKey),
                divingModeRaw: UserDefaults.standard.string(forKey: preferredDivingModeKey),
                fallbackActivity: DIRStartupSelectionPolicy.defaultActivityMode,
                fallbackDivingMode: DIRStartupSelectionPolicy.defaultDivingMode
            )
        }
        set {
            let sanitized = sanitize(newValue)
            UserDefaults.standard.set(sanitized.activity.rawValue, forKey: preferredActivityKey)
            UserDefaults.standard.set(sanitized.divingMode.rawValue, forKey: preferredDivingModeKey)
        }
    }

    static var lastSelectedDestination: WatchWaterPreferredLaunchDestination {
        get {
            migrateIfNeeded()
            return sanitizedDestination(
                activityRaw: UserDefaults.standard.string(forKey: lastSelectedActivityKey),
                divingModeRaw: UserDefaults.standard.string(forKey: lastSelectedDivingModeKey),
                fallbackActivity: defaultFallbackActivity,
                fallbackDivingMode: defaultFallbackDivingMode
            )
        }
        set {
            let sanitized = sanitize(newValue)
            UserDefaults.standard.set(sanitized.activity.rawValue, forKey: lastSelectedActivityKey)
            UserDefaults.standard.set(sanitized.divingMode.rawValue, forKey: lastSelectedDivingModeKey)
        }
    }

    static func migrateIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: migratedKey) else { return }
        let defaults = UserDefaults.standard
        if defaults.string(forKey: modeKey) == nil {
            defaults.set(WatchWaterAutoOpenMode.disabled.rawValue, forKey: modeKey)
        }
        if defaults.string(forKey: preferredActivityKey) == nil {
            defaults.set(DIRStartupSelectionPolicy.defaultActivityMode.rawValue, forKey: preferredActivityKey)
        }
        if defaults.string(forKey: preferredDivingModeKey) == nil {
            defaults.set(DIRStartupSelectionPolicy.defaultDivingMode.rawValue, forKey: preferredDivingModeKey)
        }
        if defaults.string(forKey: lastSelectedActivityKey) == nil {
            defaults.set(defaultFallbackActivity.rawValue, forKey: lastSelectedActivityKey)
        }
        if defaults.string(forKey: lastSelectedDivingModeKey) == nil {
            defaults.set(defaultFallbackDivingMode.rawValue, forKey: lastSelectedDivingModeKey)
        }
        defaults.set(true, forKey: migratedKey)
    }

    static func recordSelectedDestination(activity: DIRActivityMode, divingMode: DIRDivingMode) {
        lastSelectedDestination = WatchWaterPreferredLaunchDestination(activity: activity, divingMode: divingMode)
    }

    static func activeDestination() -> WatchWaterPreferredLaunchDestination {
        switch mode {
        case .disabled:
            return WatchWaterPreferredLaunchDestination(
                activity: DIRStartupSelectionPolicy.defaultActivityMode,
                divingMode: DIRStartupSelectionPolicy.defaultDivingMode
            )
        case .lastSelectedMode:
            return lastSelectedDestination
        case .preferredMode:
            return preferredDestination
        }
    }

    private static var defaultFallbackActivity: DIRActivityMode {
        DIRStartupSelectionPolicy.defaultActivityMode
    }

    private static var defaultFallbackDivingMode: DIRDivingMode {
        DIRStartupSelectionPolicy.defaultDivingMode
    }

    private static func sanitizedDestination(
        activityRaw: String?,
        divingModeRaw: String?,
        fallbackActivity: DIRActivityMode,
        fallbackDivingMode: DIRDivingMode
    ) -> WatchWaterPreferredLaunchDestination {
        let activity = activityRaw.flatMap(DIRActivityMode.init(rawValue:)) ?? fallbackActivity
        let divingMode = divingModeRaw.flatMap(DIRDivingMode.init(rawValue:)) ?? fallbackDivingMode
        return sanitize(WatchWaterPreferredLaunchDestination(activity: activity, divingMode: divingMode))
    }

    private static func sanitize(_ destination: WatchWaterPreferredLaunchDestination) -> WatchWaterPreferredLaunchDestination {
        var sanitized = destination
        if sanitized.activity != .diving {
            sanitized.divingMode = .gauge
        }
        return sanitized
    }

    #if DEBUG
    static func resetForTests() {
        let defaults = UserDefaults.standard
        [
            modeKey,
            preferredActivityKey,
            preferredDivingModeKey,
            lastSelectedActivityKey,
            lastSelectedDivingModeKey,
            migratedKey
        ].forEach { defaults.removeObject(forKey: $0) }
    }
    #endif
}

extension WatchWaterAutoOpenMode {
    var localizedLabel: String {
        switch self {
        case .disabled:
            return String(localized: "settings.water_auto_open.mode.disabled")
        case .lastSelectedMode:
            return String(localized: "settings.water_auto_open.mode.last_selected")
        case .preferredMode:
            return String(localized: "settings.water_auto_open.mode.preferred")
        }
    }

    var settingsSubtitleKey: String {
        switch self {
        case .disabled:
            return "settings.water_auto_open.subtitle.disabled"
        case .lastSelectedMode:
            return "settings.water_auto_open.subtitle.last_selected"
        case .preferredMode:
            return "settings.water_auto_open.subtitle.preferred"
        }
    }

    var accessibilityLabel: String {
        String(localized: String.LocalizationValue(settingsSubtitleKey))
    }
}
