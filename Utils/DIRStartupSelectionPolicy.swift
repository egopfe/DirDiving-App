import Foundation

/// Persisted startup / diving-mode preferences and cold-launch routing (Watch MAIN).
enum DIRStartupSelectionPolicy {
    static let showActivitySelectionAtLaunchKey = "dirdiving_watch_show_activity_selection_at_launch"
    static let defaultActivityModeKey = "dirdiving_watch_default_activity_mode"
    static let defaultDivingModeKey = "dirdiving_watch_default_diving_mode"
    static let gaugeShowTTVKey = "dirdiving_watch_gauge_show_ttv"
    static let preferencesMigratedKey = "dirdiving_watch_startup_preferences_migrated_v1"

    /// When true, cold launch shows activity selection before Live Dive.
    static var showActivitySelectionAtLaunch: Bool {
        get {
            migrateLegacyPreferencesIfNeeded()
            if UserDefaults.standard.object(forKey: showActivitySelectionAtLaunchKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: showActivitySelectionAtLaunchKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: showActivitySelectionAtLaunchKey) }
    }

    static var defaultActivityMode: DIRActivityMode {
        get {
            migrateLegacyPreferencesIfNeeded()
            guard
                let raw = UserDefaults.standard.string(forKey: defaultActivityModeKey),
                let mode = DIRActivityMode(rawValue: raw)
            else { return .diving }
            return mode
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: defaultActivityModeKey) }
    }

    static var defaultDivingMode: DIRDivingMode {
        get {
            migrateLegacyPreferencesIfNeeded()
            guard
                let raw = UserDefaults.standard.string(forKey: defaultDivingModeKey),
                let mode = DIRDivingMode(rawValue: raw)
            else { return .gauge }
            return mode
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: defaultDivingModeKey) }
    }

    /// Gauge-only: TTV panel hidden by default (F-04 / Command 02).
    static var gaugeShowsTTV: Bool {
        get {
            if UserDefaults.standard.object(forKey: gaugeShowTTVKey) == nil {
                return false
            }
            return UserDefaults.standard.bool(forKey: gaugeShowTTVKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: gaugeShowTTVKey) }
    }

    static func applySyncedGaugeShowsTTV(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: gaugeShowTTVKey)
    }

    /// Full Computer always requires an explicit pre-dive confirmation screen.
    static func requiresFullComputerPrediveConfirmation(divingMode: DIRDivingMode) -> Bool {
        divingMode == .fullComputer
    }

    static func resolveLaunchStep() -> DIRStartupLaunchStep {
        if showActivitySelectionAtLaunch {
            return .activitySelection
        }
        return resolveAutomaticStep(
            activity: defaultActivityMode,
            divingMode: defaultDivingMode
        )
    }

    /// Routes startup when watchOS opens DIR Diving after water entry (or via water App Intent).
    static func resolveWaterAutoLaunchStep() -> DIRStartupLaunchStep {
        WatchWaterAutoOpenPolicy.migrateIfNeeded()
        switch WatchWaterAutoOpenPolicy.mode {
        case .disabled:
            return resolveLaunchStep()
        case .lastSelectedMode, .preferredMode:
            let destination = WatchWaterAutoOpenPolicy.activeDestination()
            return resolveAutomaticStep(
                activity: destination.activity,
                divingMode: destination.divingMode
            )
        }
    }

    static func resolveAutomaticStep(
        activity: DIRActivityMode,
        divingMode: DIRDivingMode
    ) -> DIRStartupLaunchStep {
        guard activity.isLaunchableOnWatchMAIN else {
            return .comingSoon(activity: activity)
        }
        let policy = DepthCapabilityPolicy.current
        var effectiveMode = divingMode
        if divingMode == .fullComputer, !policy.supportsFullComputerRuntime {
            if policy.supportsDivingGaugeRuntime {
                effectiveMode = .gauge
            } else {
                return .divingModeSelection(activity: activity)
            }
        } else if divingMode == .gauge, !policy.supportsDivingGaugeRuntime {
            return .divingModeSelection(activity: activity)
        }
        if effectiveMode == .fullComputer {
            return .fullComputerPrediveConfiguration
        }
        return .ready(activity: activity, divingMode: effectiveMode)
    }

    static func nextStepAfterActivitySelection(_ activity: DIRActivityMode) -> DIRStartupLaunchStep {
        guard activity.isLaunchableOnWatchMAIN else {
            return .comingSoon(activity: activity)
        }
        switch activity {
        case .apnea:
            return .ready(activity: .apnea, divingMode: .gauge)
        case .diving:
            return .divingModeSelection(activity: .diving)
        case .snorkeling:
            return .ready(activity: .snorkeling, divingMode: .gauge)
        }
    }

    static func nextStepAfterDivingModeSelection(
        activity: DIRActivityMode,
        divingMode: DIRDivingMode
    ) -> DIRStartupLaunchStep {
        if divingMode == .fullComputer {
            return .fullComputerPrediveConfiguration
        }
        return .ready(activity: activity, divingMode: divingMode)
    }

    static func nextStepAfterFullComputerConfiguration() -> DIRStartupLaunchStep {
        .fullComputerConfirmation
    }

    private static func migrateLegacyPreferencesIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: preferencesMigratedKey) else { return }
        let legacySkipKey = WatchModeSelectionPreferences.skipWhenSingleModeKey
        if UserDefaults.standard.object(forKey: legacySkipKey) != nil {
            let skip = UserDefaults.standard.bool(forKey: legacySkipKey)
            UserDefaults.standard.set(!skip, forKey: showActivitySelectionAtLaunchKey)
        }
        UserDefaults.standard.set(true, forKey: preferencesMigratedKey)
    }

    #if DEBUG
    static func resetForTests() {
        let defaults = UserDefaults.standard
        [
            showActivitySelectionAtLaunchKey,
            defaultActivityModeKey,
            defaultDivingModeKey,
            gaugeShowTTVKey,
            preferencesMigratedKey,
            WatchModeSelectionPreferences.skipWhenSingleModeKey
        ].forEach { defaults.removeObject(forKey: $0) }
        WatchWaterAutoOpenPolicy.resetForTests()
    }
    #endif
}
