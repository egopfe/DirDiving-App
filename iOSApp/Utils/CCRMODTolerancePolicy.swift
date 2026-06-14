import Foundation

/// Documented CCR bailout MOD tolerance — intentionally looser than OC cylinder tolerance (0.05 m).
enum CCRMODTolerancePolicy {
    /// OC open-circuit switch-depth clamp uses 0.05 m slack (`GasPlan.swift`).
    static let openCircuitSwitchDepthSlackMeters = 0.05
    /// CCR bailout switch depth allows 0.5 m slack for rebreather bailout planning rounding/display.
    static let ccrBailoutSwitchDepthSlackMeters = 0.5

    static func isBailoutSwitchDepthWithinMOD(switchDepthMeters: Double, modMeters: Double) -> Bool {
        switchDepthMeters <= modMeters + ccrBailoutSwitchDepthSlackMeters
    }
}
