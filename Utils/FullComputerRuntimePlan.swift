import Foundation

struct FullComputerRuntimePlan: Hashable {
    var activeGas: BuhlmannGas
    var gfLow: Double
    var gfHigh: Double
    var plannerEnvironment: PlannerEnvironment
    var travelGases: [BuhlmannGas]
    var decoGases: [BuhlmannGas]
    var ascentRateMetersPerMinute: Double
    var stopIntervalMeters: Double

    static var defaultAirGF3070: FullComputerRuntimePlan {
        FullComputerRuntimePlan(
            activeGas: BuhlmannGas(
                name: "Air",
                role: .bottom,
                oxygenFraction: BuhlmannConstants.oxygenFractionAir,
                heliumFraction: 0,
                maxPPO2Bar: 1.4,
                switchDepthMeters: 0
            ),
            gfLow: FullComputerRuntimeConfiguration.defaultGFLow,
            gfHigh: FullComputerRuntimeConfiguration.defaultGFHigh,
            plannerEnvironment: .seaLevelSaltWater,
            travelGases: [],
            decoGases: [],
            ascentRateMetersPerMinute: BuhlmannConstants.defaultAscentRateMetersPerMinute,
            stopIntervalMeters: BuhlmannConstants.stopIntervalMeters
        )
    }

    func validate() -> [String] {
        var errors: [String] = []
        if !activeGas.isCompositionValid {
            errors.append("invalid_active_gas")
        }
        guard gfLow.isFinite, gfHigh.isFinite,
              gfLow >= BuhlmannCoreConfiguration.minGradientFactor,
              gfHigh <= BuhlmannCoreConfiguration.maxGradientFactor,
              gfLow < gfHigh else {
            errors.append("invalid_gradient_factors")
            return errors
        }
        for gas in travelGases + decoGases where !gas.isCompositionValid {
            errors.append("invalid_switch_gas:\(gas.name)")
        }
        if !ascentRateMetersPerMinute.isFinite || ascentRateMetersPerMinute <= 0 {
            errors.append("invalid_ascent_rate")
        }
        if !stopIntervalMeters.isFinite || stopIntervalMeters <= 0 {
            errors.append("invalid_stop_interval")
        }
        return errors
    }
}
