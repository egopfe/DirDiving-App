import Foundation

/// Reference gas density estimate for CCR inspired gas approximation.
/// Uses setpoint PPO2 plus diluent inert fractions scaled by available inert pressure.
enum CCRGasDensityEstimator {
    static func estimateGramsPerLiter(
        setpointBar: Double,
        diluent: CCRDiluent,
        depthMeters: Double,
        environment: PlannerEnvironment
    ) -> Double? {
        guard let inspired = CCRInspiredGasModel.inspiredPressures(
            depthMeters: depthMeters,
            setpointBar: setpointBar,
            diluent: diluent,
            environment: environment
        ) else { return nil }
        let ambient = CCRInspiredGasModel.ambientPressureBar(depthMeters: depthMeters, environment: environment)
        guard ambient.isFinite, ambient > 0 else { return nil }
        let o2Fraction = min(1, setpointBar / ambient)
        let n2Fraction = inspired.ppN2 / ambient
        let heFraction = inspired.ppHe / ambient
        return o2Fraction * 1.429 + n2Fraction * 1.251 + heFraction * 0.1786
    }
}
