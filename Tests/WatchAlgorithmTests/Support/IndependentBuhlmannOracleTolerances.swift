import Foundation

/// Documented numerical tolerances for independent-oracle vs production comparisons.
/// Rationale: production FullComputerRuntimeEngine sub-steps long intervals; solver rounds ceilings to 0.1 m.
enum IndependentBuhlmannOracleTolerances {
    /// Compartment inert gas partial pressure (bar).
    static let tissuePressureBar = 0.000_2

    /// Raw / operational ceiling depth (m).
    static let ceilingMeters = 0.2

    /// NDL minutes when both sides finite.
    static let ndlMinutes = 0.6

    /// TTS minutes when both sides require decompression.
    static let ttsMinutes = 3.0

    /// Analytic Schreiner vs repeated 1 s integration over a segment.
    static let schreinerAnalyticSegmentBar = 0.000_5

    /// Controlling compartment index must match when ceilings agree within tolerance.
    static let controllingCompartmentCeilingSlackMeters = 0.05
}
