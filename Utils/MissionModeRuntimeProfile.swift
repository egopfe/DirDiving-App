import Foundation

enum MissionModeSettings {
    static let autoEnableOnDiveStartKey = "dirdiving.missionMode.autoEnableOnDiveStart"
}

/// How Mission Mode became active for the current dive session (runtime only).
enum MissionModeActivationSource: String, Equatable {
    case automatic
    case manual
    case restored
}

/// Pure lifecycle rules for Mission Mode (testable; Watch MAIN runtime/UI only).
enum MissionModeLifecycle {
    /// Applies at dive start and after active-dive draft restore.
    static func shouldActivateRuntime(
        autoEnablePreference: Bool,
        manualPendingForSession: Bool
    ) -> Bool {
        autoEnablePreference || manualPendingForSession
    }

    static func activationSource(
        autoEnablePreference: Bool,
        manualPendingForSession: Bool,
        restored: Bool
    ) -> MissionModeActivationSource? {
        guard shouldActivateRuntime(autoEnablePreference: autoEnablePreference, manualPendingForSession: manualPendingForSession) else {
            return nil
        }
        if restored && autoEnablePreference {
            return .restored
        }
        if autoEnablePreference {
            return .automatic
        }
        if manualPendingForSession {
            return .manual
        }
        return nil
    }
}

/// Watch MAIN runtime tuning only. Mission Mode never changes dive math, sampling, logging, or alerts.
struct MissionModeRuntimeProfile {
    let animationsEnabled: Bool
    let decorativeEffectsEnabled: Bool

    static let standard = MissionModeRuntimeProfile(
        animationsEnabled: true,
        decorativeEffectsEnabled: true
    )

    static let mission = MissionModeRuntimeProfile(
        animationsEnabled: false,
        decorativeEffectsEnabled: false
    )
}
