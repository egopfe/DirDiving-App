import Foundation

/// Documented numerical tolerances for Full Computer release-hard differential validation (Command 12).
///
/// Rationale:
/// - Planner uses segment-based decompression simulation; runtime uses 1 Hz ticks and linear depth interpolation.
/// - Stop rounding and GF interpolation introduce small drift that must not be treated as regressions.
enum FullComputerReleaseHardTolerances {
    /// Planner `ttsMinutes` vs runtime snapshot after a constant-depth bottom phase.
    static let plannerRuntimeTTSMinutes: Double = 3.0

    /// Bühlmann compartment pressure after continuous ingest vs replay.
    static let tissuePressureBar: Double = 0.000_1

    /// NDL minutes between planner projection and runtime solver at the same tissue state.
    static let ndlMinutes: Double = 1.0

    /// Ceiling depth in meters between planner and runtime projection.
    static let ceilingMeters: Double = 0.5

    /// Maximum allowed Full Computer deco solver wall time per solve (see `FullComputerDecoSolver.performanceBudgetSeconds`).
    static let decoSolverBudgetSeconds: TimeInterval = 0.05

    /// Maximum allowed checkpoint encode+decode wall time on simulator hardware.
    static let checkpointRoundTripBudgetSeconds: TimeInterval = 0.05
}
