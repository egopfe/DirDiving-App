import Foundation

enum PlannerService {
    static func makePlan(input: GasPlanInput) -> DivePlanResult {
        let buhlmann = BuhlmannPlanner.plan(depthMeters: input.plannedDepthMeters, o2Fraction: input.bottomGas.oxygen)
        let ndl = buhlmann.ndlMinutes
        let needsDeco = input.plannedBottomMinutes > ndl || input.plannedDepthMeters >= 35
        var warnings: [String] = ["Modello Buhlmann ZH-L16C semplificato: verificare sempre con strumenti certificati."]
        if let warning = buhlmann.warning { warnings.append(warning) }
        if input.bottomGas.modMeters < input.plannedDepthMeters {
            warnings.append("MOD gas fondo inferiore alla profondita pianificata.")
        }
        if input.estimatedRemainingLiters < 0 {
            warnings.append("Gas stimato insufficiente rispetto a SAC, volume e riserva impostati.")
        }

        var stops: [DecoStop] = []
        if needsDeco {
            let ceiling = min(21, max(3, floor(input.plannedDepthMeters / 3) * 3 - 3))
            let stopDepths = stride(from: ceiling, through: 3.0, by: -3.0).map { $0 }
            let overrun = max(0, input.plannedBottomMinutes - ndl)
            stops = stopDepths.map { depth in
                let gas = depth >= 12 ? input.decoGas1 : input.decoGas2
                let pressure = 1.0 + depth / 10.0
                let base = depth <= 6 ? 5 : depth <= 12 ? 3 : 2
                let extra = Int((overrun / 10.0).rounded(.up))
                return DecoStop(depthMeters: depth, minutes: base + extra, gas: gas.label, ppO2: min(gas.maxPPO2, gas.oxygen * pressure))
            }
        } else {
            stops = [DecoStop(depthMeters: 5, minutes: 3, gas: input.bottomGas.label, ppO2: input.bottomGas.oxygen * 1.5)]
        }
        let ttr = Int(input.plannedBottomMinutes) + stops.map(\.minutes).reduce(0,+) + Int(input.plannedDepthMeters / 10.0)
        let cns = min(100, input.plannedBottomMinutes * max(0, input.bottomGas.oxygen * input.ambientPressureBar - 0.5) * 2.2)
        let otu = max(0, input.plannedBottomMinutes * pow(max(0.5, input.bottomGas.oxygen * input.ambientPressureBar) - 0.5, 0.83) * 5)
        return DivePlanResult(ndlMinutes: ndl, ttrMinutes: ttr, decoStops: stops, cnsPercent: cns, otu: otu, warnings: warnings)
    }
}
