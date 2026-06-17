import Foundation

/// Documented tolerances for Apnea release-hard validation (Command 12).
enum ApneaReleaseHardTolerances {
    /// Minimum recovery seconds enforced by legacy exploration recovery helper.
    static let minimumRecoverySeconds: TimeInterval = 30

    /// Signed sync ACK / package issued-at skew (shared with `ApneaSyncCodec`).
    static let syncIssuedAtSkewSeconds: TimeInterval = 5 * 60

    /// Apnea session checkpoint encode+decode budget on simulator hardware.
    static let checkpointRoundTripBudgetSeconds: TimeInterval = 0.05

    /// Lifecycle sensor-loss timeout before `sensorDegraded` phase (see `ApneaLifecycleStateMachine`).
    static let sensorLossTimeoutSeconds: TimeInterval = 3
}
