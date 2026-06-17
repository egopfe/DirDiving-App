import Foundation

/// Planner bounds and tolerances for the shared Bühlmann core (values match `IOSAlgorithmConfiguration`).
enum BuhlmannCoreConfiguration {
    static let minPlannerDepthMeters = 0.1
    static let maxPlannerDepthMeters = 120.0
    static let maxBottomTimeMinutes = 600.0
    static let minGradientFactor = 0.0
    static let maxGradientFactor = 100.0
    static let ppo2HardValidationToleranceBar = 0.000_1
    static let ppo2DecoGasSwitchDepthToleranceBar = 0.02
}
