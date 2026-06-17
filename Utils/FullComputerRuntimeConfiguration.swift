import Foundation

enum FullComputerRuntimeConfiguration {
    static let nominalTickSeconds: TimeInterval = 1.0
    /// Maximum tissue-integration sub-step duration (seconds).
    static let maxSubStepSeconds: TimeInterval = 30.0
    /// Conservative cap for missed/stale tick advancement (seconds).
    static let maxMissedTickSeconds: TimeInterval = 120.0
    /// Depth delta beyond which immediate projection refresh is forced (meters).
    static let criticalDepthChangeMeters = 1.0
    static let defaultGFLow = 30.0
    static let defaultGFHigh = 70.0
    static let algorithmVersion = DivePlanPackageCodec.algorithmVersion
}
