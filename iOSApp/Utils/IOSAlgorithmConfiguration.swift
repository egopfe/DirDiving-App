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
    static let maxPlannerDepthMeters = 120.0
    static let maxImportExportDepthMeters = 300.0
    static let maxSyncDepthMeters = 350.0
    static let maxBottomTimeMinutes = 600.0
    static let maxDiveDurationSeconds: TimeInterval = 24 * 60 * 60

    static let minOxygenFraction = 0.000_001
    static let maxGasFraction = 1.0
    static let minPPO2Bar = 1.0
    static let maxPPO2Bar = 1.6
    static let minGradientFactor = 0.0
    static let maxGradientFactor = 100.0

    static let minWaterTemperatureCelsius = -2.0
    static let maxWaterTemperatureCelsius = 40.0

    static let maxProfileSampleCount = 20_000
    static let maxSyncPayloadBytes = 512 * 1024
    static let maxImportBytes = 10 * 1024 * 1024

    static let gasDensityWarningGramsPerLiter = 5.2
    static let gasDensityDangerGramsPerLiter = 6.2
    static let supportedWatchDepthLimitMeters = 40.0

    static let maxLogSessions = 40
    static let importedGPSHorizontalAccuracyMeters = 100.0
    static let routeEarthRadiusMeters = 6_371_000.0
    static let syncIssuedAtSkewSeconds: TimeInterval = 60 * 60

    static func isFinite(_ value: Double) -> Bool {
        value.isFinite && !value.isNaN
    }
}
