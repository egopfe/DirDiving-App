import Foundation

struct FullComputerRuntimePlan: Hashable, Codable {
    var activeGas: BuhlmannGas
    var gfLow: Double
    var gfHigh: Double
    var plannerEnvironment: PlannerEnvironment
    var travelGases: [BuhlmannGas]
    var decoGases: [BuhlmannGas]
    var ascentRateMetersPerMinute: Double
    var stopIntervalMeters: Double

    static var defaultAirGF3070: FullComputerRuntimePlan {
        FullComputerRuntimePlan(profile: .defaultAirGF3070)
    }

    init(
        activeGas: BuhlmannGas,
        gfLow: Double,
        gfHigh: Double,
        plannerEnvironment: PlannerEnvironment,
        travelGases: [BuhlmannGas],
        decoGases: [BuhlmannGas],
        ascentRateMetersPerMinute: Double,
        stopIntervalMeters: Double
    ) {
        self.activeGas = activeGas
        self.gfLow = gfLow
        self.gfHigh = gfHigh
        self.plannerEnvironment = plannerEnvironment
        self.travelGases = travelGases
        self.decoGases = decoGases
        self.ascentRateMetersPerMinute = ascentRateMetersPerMinute
        self.stopIntervalMeters = stopIntervalMeters
    }

    init(profile: FullComputerGasProfile, plannerEnvironment: PlannerEnvironment = .seaLevelSaltWater) {
        let bottom = profile.bottomGas.toBuhlmannGas()
        let deco = profile.enabledDecoGases.map { $0.toBuhlmannGas() }
        let travel = profile.enabledTravelGases.map { $0.toBuhlmannGas() }
        self.init(
            activeGas: bottom,
            gfLow: profile.gfLow,
            gfHigh: profile.gfHigh,
            plannerEnvironment: plannerEnvironment,
            travelGases: profile.futureGasTTSPolicy == .enabledSwitchGasesOnly ? travel : [],
            decoGases: profile.futureGasTTSPolicy == .enabledSwitchGasesOnly ? deco : [],
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
