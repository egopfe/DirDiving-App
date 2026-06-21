import Foundation

enum FullComputerRuntimeConfiguration {
    static let nominalTickSeconds: TimeInterval = 1.0
    /// Maximum tissue-integration sub-step duration (seconds).
    static let maxSubStepSeconds: TimeInterval = 30.0
    /// Elapsed gap (seconds) after which tick/restore marks runtime `degraded` (integration is not capped).
    static let maxMissedTickSeconds: TimeInterval = 120.0
    /// Secondary threshold for marking degraded on moderately delayed ticks.
    static let missedTickDegradedThresholdSeconds: TimeInterval = nominalTickSeconds * 2
    /// Depth delta beyond which immediate projection refresh is forced (meters).
    static let criticalDepthChangeMeters = 1.0
    static let defaultGFLow = 30.0
    static let defaultGFHigh = 70.0
    static let algorithmVersion = DivePlanPackageCodec.algorithmVersion
}
