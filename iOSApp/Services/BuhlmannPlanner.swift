import Foundation

enum BuhlmannPlanner {
    static func plan(depthMeters: Double, bottomGas: GasMix) -> BuhlmannPlanResult {
        plan(depthMeters: depthMeters, o2Fraction: bottomGas.oxygen, heliumFraction: bottomGas.helium, maxPPO2: bottomGas.maxPPO2)
    }

    static func plan(depthMeters: Double, o2Fraction: Double, heliumFraction: Double = 0) -> BuhlmannPlanResult {
        plan(depthMeters: depthMeters, o2Fraction: o2Fraction, heliumFraction: heliumFraction, maxPPO2: 1.4)
    }

    static func plan(depthMeters: Double, o2Fraction: Double, heliumFraction: Double = 0, maxPPO2: Double) -> BuhlmannPlanResult {
        guard depthMeters.isFinite,
              depthMeters >= IOSAlgorithmConfiguration.minPlannerDepthMeters,
              depthMeters <= IOSAlgorithmConfiguration.maxPlannerDepthMeters else {
            return BuhlmannPlanResult(
                depthMeters: max(0, depthMeters.isFinite ? depthMeters : 0),
                gasO2Fraction: o2Fraction,
                heliumFraction: heliumFraction,
                nitrogenFraction: 0,
                ndlMinutes: 0,
                curve: [],
                warning: "Buhlmann non disponibile per input non validi.",
                modelState: .invalidInput
            )
        }

        let gas = BuhlmannGas(
            name: "Reference gas",
            role: .bottom,
            oxygenFraction: o2Fraction,
            heliumFraction: heliumFraction,
            maxPPO2Bar: maxPPO2,
            switchDepthMeters: depthMeters
        )
        guard gas.isCompositionValid else {
            return BuhlmannPlanResult(
                depthMeters: depthMeters,
                gasO2Fraction: o2Fraction,
                heliumFraction: heliumFraction,
                nitrogenFraction: 0,
                ndlMinutes: 0,
                curve: [],
                warning: "Miscela non valida: Buhlmann non disponibile.",
                modelState: .invalidInput
            )
        }

        let previewRequest = BuhlmannPlanRequest(
            maxDepthMeters: depthMeters,
            bottomMinutes: 0,
            bottomGas: gas,
            travelGases: [],
            decoGases: [],
            gfLow: 30,
            gfHigh: 85
        )
        guard BuhlmannEngine.validate(previewRequest).isEmpty else {
            return BuhlmannPlanResult(
                depthMeters: depthMeters,
                gasO2Fraction: o2Fraction,
                heliumFraction: heliumFraction,
                nitrogenFraction: max(0, gas.nitrogenFraction),
                ndlMinutes: 0,
                curve: [],
                warning: "Buhlmann non disponibile: profilo o miscela fuori dai limiti validati.",
                modelState: .invalidInput
            )
        }

        let ndlValue = BuhlmannEngine.noDecompressionLimit(depthMeters: depthMeters, gas: gas, gfHigh: 85) ?? 0
        return BuhlmannPlanResult(
            depthMeters: depthMeters,
            gasO2Fraction: o2Fraction,
            heliumFraction: heliumFraction,
            nitrogenFraction: max(0, gas.nitrogenFraction),
            ndlMinutes: ndlValue,
            curve: ndlCurve(for: gas),
            warning: "Buhlmann ZHL-16C N2+He multigas reference-only: non e un piano decompressivo certificato.",
            modelState: .validReference
        )
    }

    static func enginePlan(input: GasPlanInput) -> BuhlmannEngineResult {
        BuhlmannEngine.plan(makeRequest(input: input))
    }

    static func decoStops(input: GasPlanInput) -> [DecoStop] {
        enginePlan(input: input).stops.map(makeDecoStop)
    }

    static func runtimeSegments(input: GasPlanInput) -> [DivePlanSegment] {
        enginePlan(input: input).segments.map { segment in
            DivePlanSegment(
                kind: segment.kind,
                depthMeters: segment.depthMeters,
                minutes: segment.minutes,
                gas: segment.gas.label,
                note: segment.note
            )
        }
    }

    static func gfComparisons(input: GasPlanInput) -> [GFComparison] {
        let presets: [(String, Double, Double)] = [
            ("20/80", 20, 80),
            ("30/70", 30, 70),
            ("40/85", 40, 85),
            ("CUSTOM", input.gfLow, input.gfHigh)
        ]
        return presets.map { label, low, high in
            var copy = input
            copy.gfLow = low
            copy.gfHigh = high
            let result = enginePlan(input: copy)
            let note = high <= 70 ? "Conservativo" : "Piu aggressivo"
            return GFComparison(
                label: label,
                gfLow: low,
                gfHigh: high,
                ttsMinutes: result.ttsMinutes,
                stopCount: result.stops.count,
                conservatismNote: note
            )
        }
    }

    static func ndl(depthMeters: Double, nitrogenFraction: Double) -> Double? {
        guard depthMeters.isFinite,
              nitrogenFraction.isFinite,
              depthMeters >= IOSAlgorithmConfiguration.minPlannerDepthMeters,
              nitrogenFraction > 0,
              nitrogenFraction <= 1 else {
            return nil
        }
        let gas = BuhlmannGas(
            name: "N2 reference",
            role: .bottom,
            oxygenFraction: max(0.000_001, 1.0 - nitrogenFraction),
            heliumFraction: 0,
            maxPPO2Bar: 1.6,
            switchDepthMeters: depthMeters
        )
        return BuhlmannEngine.noDecompressionLimit(depthMeters: depthMeters, gas: gas, gfHigh: 85)
    }

    static func plannerStates(from issues: [BuhlmannPlanIssue]) -> [PlannerResultState] {
        var states: [PlannerResultState] = []
        for issue in issues {
            switch issue {
            case .invalidProfile:
                states.append(.invalidInput)
            case .invalidGas:
                states.append(.unsupportedGas)
            case .hypoxicGasTooShallow:
                states.append(.unsupportedGas)
            case .ppo2Exceeded:
                states.append(.PPO2Exceeded)
            case .modExceeded, .gasSwitchTooDeep:
                states.append(.MODExceeded)
            case .gasNotOperationalInSegment:
                states.append(.unsupportedGas)
            case .calculationLimitReached:
                states.append(.modelIncomplete)
            }
        }
        return unique(states)
    }

    static func makeRequest(input: GasPlanInput) -> BuhlmannPlanRequest {
        var working = input
        working.syncLegacyGasesFromPlannerCylinders()
        let plannerEnvironment: PlannerEnvironment
        switch PlannerEnvironment.make(altitudeMeters: working.altitudeMeters, salinity: working.salinity) {
        case .success(let environment):
            plannerEnvironment = environment
        case .failure:
            plannerEnvironment = .seaLevelSaltWater
        }
        let bottomEntry = working.plannerCylinders.first(where: { $0.role == .bottom })
        let bottomGas = BuhlmannGas(
            gas: bottomEntry?.gas ?? working.bottomGas,
            role: .bottom,
            switchDepthMeters: working.plannedDepthMeters
        )
        let travelGases = working.plannerCylinders
            .filter { $0.role == .travel }
            .map { BuhlmannGas(gas: $0.gas, role: .travel, switchDepthMeters: $0.switchDepthMeters) }
            .sorted { $0.switchDepthMeters < $1.switchDepthMeters }
        let decoGases = working.plannerCylinders
            .filter { $0.role == .deco }
            .map { BuhlmannGas(gas: $0.gas, role: .deco, switchDepthMeters: $0.switchDepthMeters) }
            .sorted { $0.switchDepthMeters > $1.switchDepthMeters }
        return BuhlmannPlanRequest(
            maxDepthMeters: working.plannedDepthMeters,
            bottomMinutes: working.plannedBottomMinutes,
            bottomGas: bottomGas,
            travelGases: travelGases,
            decoGases: decoGases,
            gfLow: working.gfLow,
            gfHigh: working.gfHigh,
            initialTissueState: BuhlmannTissueState.airSaturated(surfacePressureBar: plannerEnvironment.surfacePressureBar),
            plannerEnvironment: plannerEnvironment
        )
    }

    private static func ndlCurve(for gas: BuhlmannGas) -> [NDLPoint] {
        stride(from: 6.0, through: 60.0, by: 3.0).map { depth in
            let ndlValue = BuhlmannEngine.noDecompressionLimit(depthMeters: depth, gas: gas, gfHigh: 85) ?? 0
            let group: String
            switch depth {
            case ..<18: group = "1-4"
            case ..<30: group = "5-8"
            case ..<45: group = "9-12"
            default: group = "13-16"
            }
            return NDLPoint(depthMeters: depth, ndlMinutes: ndlValue, compartmentGroup: group)
        }
    }

    private static func makeDecoStop(_ stop: BuhlmannDecompressionStop) -> DecoStop {
        let states: [PlannerResultState] = stop.ppO2 > stop.maxPPO2 ? [.PPO2Exceeded] : []
        return DecoStop(
            depthMeters: stop.depthMeters,
            minutes: stop.minutes,
            gas: stop.gas.label,
            ppO2: stop.ppO2,
            maxPPO2: stop.maxPPO2,
            states: states
        )
    }

    private static func unique(_ states: [PlannerResultState]) -> [PlannerResultState] {
        var seen = Set<PlannerResultState>()
        var result: [PlannerResultState] = []
        for state in states where seen.insert(state).inserted {
            result.append(state)
        }
        return result
    }
}
