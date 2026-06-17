import Foundation

/// Pressure-scaled inspired gas density for CCR reference metrics (g/L).
enum CCRGasDensityEstimator {
    static func estimate(
        setpointBar: Double,
        diluent: CCRDiluent,
        depthMeters: Double,
        environment: PlannerEnvironment
    ) -> CCRGasDensityResult {
        guard setpointBar.isFinite, setpointBar > 0 else {
            return .unavailable(reason: .invalidSetpoint)
        }
        guard depthMeters.isFinite, depthMeters >= 0 else {
            return .unavailable(reason: .invalidDepth)
        }
        guard environment.surfacePressureBar.isFinite, environment.surfacePressureBar > 0 else {
            return .unavailable(reason: .invalidEnvironment)
        }

        guard let inspired = CCRInspiredGasModel.inspiredPressures(
            depthMeters: depthMeters,
            setpointBar: setpointBar,
            diluent: diluent,
            environment: environment
        ) else {
            return .unavailable(reason: .inspiredGasUnavailable)
        }

        let ambient = CCRInspiredGasModel.ambientPressureBar(depthMeters: depthMeters, environment: environment)
        guard ambient.isFinite else { return .unavailable(reason: .invalidEnvironment) }
        let dryAmbient = max(0, ambient - BuhlmannConstants.waterVaporPressureBar)
        if dryAmbient <= setpointBar + 0.000_1 {
            if dryAmbient < setpointBar - 0.000_1 {
                return .unavailable(reason: .setpointAboveDryAmbient)
            }
        }

        let density =
            CCRGasDensityConstants.oxygenGramsPerLiterPerBar * inspired.ppO2
            + CCRGasDensityConstants.nitrogenGramsPerLiterPerBar * inspired.ppN2
            + CCRGasDensityConstants.heliumGramsPerLiterPerBar * inspired.ppHe

        guard density.isFinite, density >= 0 else {
            return .unavailable(reason: .nonFiniteInput)
        }
        return .available(valueGramsPerLiter: density)
    }

    /// Legacy optional API — nil when unavailable (never coerces to zero).
    static func estimateGramsPerLiter(
        setpointBar: Double,
        diluent: CCRDiluent,
        depthMeters: Double,
        environment: PlannerEnvironment
    ) -> Double? {
        estimate(
            setpointBar: setpointBar,
            diluent: diluent,
            depthMeters: depthMeters,
            environment: environment
        ).gramsPerLiter
    }
}
