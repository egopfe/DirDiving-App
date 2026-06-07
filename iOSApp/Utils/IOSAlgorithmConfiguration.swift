import Foundation

enum IOSAlgorithmConfiguration {
    static let metersPerFoot = 0.3048
    static let feetPerMeter = 3.280_839_895
    static let psiPerBar = 14.503_773_8
    static let cubicFeetPerLiter = 0.035_314_666_7
    static let metersPerMinuteToFeetPerMinute = feetPerMeter
    static let metersPerBarApproximation = 10.0
    static let surfacePressureBar = 1.0

    static let minPlannerDepthMeters = 0.1
    /// Bühlmann reference planner input ceiling.
    static let maxPlannerDepthMeters = 120.0
    /// Hard ceiling for stored profile samples (logbook, Watch sync, CSV import/export, validator).
    static let maxStoredProfileDepthMeters = 350.0
    /// Legacy alias — use `maxStoredProfileDepthMeters`.
    static let maxSyncDepthMeters = maxStoredProfileDepthMeters
    /// Legacy alias — CSV uses the same storage cap as sync/logbook.
    static let maxImportExportDepthMeters = maxStoredProfileDepthMeters
    /// Documented operating envelope for UI warnings and supported-depth flags.
    static let supportedOperatingDepthMeters = maxStoredProfileDepthMeters

    static let maxBottomTimeMinutes = 600.0
    static let maxDiveDurationSeconds: TimeInterval = 24 * 60 * 60

    static let minOxygenFraction = 0.000_001
    static let maxGasFraction = 1.0
    static let minPPO2Bar = 1.0
    static let maxPPO2Bar = 1.7
    static let minGradientFactor = 0.0
    static let maxGradientFactor = 100.0

    static let minWaterTemperatureCelsius = -2.0
    static let maxWaterTemperatureCelsius = 40.0

    static let maxProfileSampleCount = 20_000
    static let maxSyncPayloadBytes = 512 * 1024

    /// Strict runtime/segment PPO₂ validation tolerance (bar).
    static let ppo2HardValidationToleranceBar = 0.000_1
    /// Switch-depth rounding tolerance for deco gas changes (bar). Slightly broader for recreational switch depths.
    static let ppo2DecoGasSwitchDepthToleranceBar = 0.02
    static let maxImportBytes = 10 * 1024 * 1024
    static let maxImportCSVColumns = 64
    static let maxImportCSVFieldCharacters = 4_096
    static let maxImportCSVRowCharacters = 16_384

    static let gasDensityWarningGramsPerLiter = 5.2
    static let gasDensityDangerGramsPerLiter = 6.2
    static let supportedWatchDepthLimitMeters = 40.0

    static let maxLogSessions = 40
    static let importedGPSHorizontalAccuracyMeters = 100.0
    static let routeEarthRadiusMeters = 6_371_000.0
    static let syncIssuedAtSkewSeconds: TimeInterval = 60 * 60
    static let pendingSyncMaxRetentionSeconds: TimeInterval = 7 * 24 * 60 * 60
    static let pendingSyncMaxAttemptCount = 64

    static func isFinite(_ value: Double) -> Bool {
        value.isFinite && !value.isNaN
    }
}