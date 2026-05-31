import Foundation

enum MissionModeSettings {
    static let autoEnableOnDiveStartKey = "dirdiving.missionMode.autoEnableOnDiveStart"
}

/// Watch MAIN runtime tuning only. Mission Mode never changes dive math, sampling, logging, or alerts.
struct MissionModeRuntimeProfile {
    let uiRefreshInterval: TimeInterval
    let animationsEnabled: Bool
    let decorativeEffectsEnabled: Bool

    static let standard = MissionModeRuntimeProfile(
        uiRefreshInterval: 1.0,
        animationsEnabled: true,
        decorativeEffectsEnabled: true
    )

    static let mission = MissionModeRuntimeProfile(
        uiRefreshInterval: 1.0,
        animationsEnabled: false,
        decorativeEffectsEnabled: false
    )
}
