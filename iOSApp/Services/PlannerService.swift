import Foundation

enum PlannerService {
    static func makePlan(input: GasPlanInput) -> DivePlanResult {
        guard case .success = PlannerInputValidator.validate(input) else {
            return invalidResult(input: input, states: [.invalidInput, .unavailable])
        }

        var states: Set<PlannerResultState> = [.simplifiedReferenceOnly]
        let bottomGasAnalysis = GasMixValidator.analysis(for: input.bottomGas, depthMeters: input.plannedDepthMeters)
        if bottomGasAnalysis == nil {
            states.insert(.unsupportedGas)
            states.insert(.unavailable)
            return invalidResult(input: input, states: states)
        }
        if let bottomGasAnalysis,
           bottomGasAnalysis.gasDensityGramsPerLiter > IOSAlgorithmConfiguration.gasDensityWarningGramsPerLiter {
            states.insert(.gasDensityHigh)
        }
        let buhlmann = BuhlmannPlanner.plan(depthMeters: input.plannedDepthMeters, gas: input.bottomGas)
        if input.bottomGas.helium > 0 {
            states.insert(.unsupportedTrimix)
            states.insert(.modelIncomplete)
            return invalidResult(input: input, states: states, buhlmann: buhlmann)
        }
        if input.estimatedRemainingLiters < 0 {
            states.insert(.insufficientGas)
            states.insert(.belowReserve)
        }

        switch buhlmann.modelState {
        case .simplifiedReferenceOnly:
            states.insert(.validReference)
        case .unsupportedTrimix:
            states.formUnion([.unsupportedTrimix, .modelIncomplete, .unavailable])
        case .invalidInput:
            states.formUnion([.invalidInput, .unavailable])
        case .unsupportedDepth:
            states.formUnion([.unsupportedDepth, .unavailable])
        case .unavailable:
            states.formUnion([.unavailable, .modelIncomplete])
        }
        guard buhlmann.modelState.isReferenceAvailable else {
            return invalidResult(input: input, states: states, buhlmann: buhlmann)
        }

        let ndl = buhlmann.ndlMinutes
        let needsDeco = input.plannedBottomMinutes > ndl || input.plannedDepthMeters >= 35
        var extraWarnings: [String] = ["Modello Buhlmann N2-only semplificato: verificare sempre con strumenti certificati."]
        if let warning = buhlmann.warning { extraWarnings.append(warning) }
        if input.bottomGas.modMeters < input.plannedDepthMeters {
            states.insert(.MODExceeded)
        }
        if input.estimatedRemainingLiters < 0 {
            extraWarnings.append("Gas stimato insufficiente rispetto a SAC, volume e riserva impostati.")
        }

        var stops: [DecoStop] = []
        if needsDeco {
            let ceiling = min(21, max(3, floor(input.plannedDepthMeters / 3) * 3 - 3))
            let stopDepths = stride(from: ceiling, through: 3.0, by: -3.0).map { $0 }
            let overrun = max(0, input.plannedBottomMinutes - ndl)
            stops = stopDepths.map { depth in
                let gas = depth >= 12 ? input.decoGas1 : input.decoGas2
                let pressure = IOSUnitConversions.ambientPressureBar(depthMeters: depth)
                let base = depth <= 6 ? 5 : depth <= 12 ? 3 : 2
                let extra = Int((overrun / 10.0).rounded(.up))
                let actualPPO2 = gas.oxygen * pressure
                if actualPPO2 > gas.maxPPO2 {
                    states.insert(.PPO2Exceeded)
                }
                return DecoStop(
                    depthMeters: depth,
                    minutes: base + extra,
                    gas: gas.label,
                    ppO2: actualPPO2,
                    maxPPO2: gas.maxPPO2,
                    isPPO2Exceeded: actualPPO2 > gas.maxPPO2
                )
            }
        } else {
            let actualPPO2 = input.bottomGas.oxygen * 1.5
            stops = [
                DecoStop(
                    depthMeters: 5,
                    minutes: 3,
                    gas: input.bottomGas.label,
                    ppO2: actualPPO2,
                    maxPPO2: input.bottomGas.maxPPO2,
                    isPPO2Exceeded: actualPPO2 > input.bottomGas.maxPPO2
                )
            ]
        }
        let ttr = Int(input.plannedBottomMinutes) + stops.map(\.minutes).reduce(0,+) + Int(input.plannedDepthMeters / 10.0)
        let cns = min(100, input.plannedBottomMinutes * max(0, input.bottomGas.oxygen * input.ambientPressureBar - 0.5) * 2.2)
        let otu = max(0, input.plannedBottomMinutes * pow(max(0.5, input.bottomGas.oxygen * input.ambientPressureBar) - 0.5, 0.83) * 5)
        return DivePlanResult(
            ndlMinutes: ndl,
            ttrMinutes: ttr,
            decoStops: stops,
            cnsPercent: cns,
            otu: otu,
            warnings: warningMessages(states: states, extra: extraWarnings),
            states: states,
            modelState: buhlmann.modelState
        )
    }

    private static func invalidResult(input: GasPlanInput, states: Set<PlannerResultState>, buhlmann: BuhlmannPlanResult? = nil) -> DivePlanResult {
        let resultState = states.isEmpty ? Set([PlannerResultState.invalidInput]) : states
        return DivePlanResult(
            ndlMinutes: 0,
            ttrMinutes: 0,
            decoStops: [],
            cnsPercent: 0,
            otu: 0,
            warnings: warningMessages(states: resultState, extra: [PlannerInputValidator.errorMessage(for: input)].compactMap { $0 }),
            states: resultState,
            modelState: buhlmann?.modelState ?? .unavailable
        )
    }

    private static func warningMessages(states: Set<PlannerResultState>, extra: [String]) -> [String] {
        var messages = ["DIR DIVING iOS resta informativo e non certificato per gestione decompressiva."]
        messages.append(contentsOf: states.sorted { $0.rawValue < $1.rawValue }.map(\.message))
        messages.append(contentsOf: extra)
        var seen = Set<String>()
        return messages.filter { seen.insert($0).inserted }
    }
}
