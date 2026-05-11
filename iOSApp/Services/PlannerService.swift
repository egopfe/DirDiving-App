import Foundation

enum PlannerService {
    static func makePlan(input: GasPlanInput) -> DivePlanResult {
        let ndl = BuhlmannPlanner.plan(depthMeters: input.plannedDepthMeters, o2Fraction: input.bottomGas.oxygen).ndlMinutes
        let needsDeco = input.plannedBottomMinutes > ndl || input.plannedDepthMeters >= 35
        let stops: [DecoStop]
        if needsDeco {
            stops = [
                DecoStop(depthMeters: 21, minutes: 2, gas: input.decoGas1.label, ppO2: min(1.6, input.decoGas1.oxygen * 3.1)),
                DecoStop(depthMeters: 15, minutes: 3, gas: input.decoGas1.label, ppO2: min(1.6, input.decoGas1.oxygen * 2.5)),
                DecoStop(depthMeters: 9, minutes: 5, gas: input.decoGas2.label, ppO2: min(1.6, input.decoGas2.oxygen * 1.9)),
                DecoStop(depthMeters: 6, minutes: 8, gas: input.decoGas2.label, ppO2: min(1.6, input.decoGas2.oxygen * 1.6)),
                DecoStop(depthMeters: 3, minutes: 4, gas: input.decoGas2.label, ppO2: min(1.6, input.decoGas2.oxygen * 1.3))
            ]
        } else {
            stops = [DecoStop(depthMeters: 5, minutes: 3, gas: input.bottomGas.label, ppO2: input.bottomGas.oxygen * 1.5)]
        }
        let ttr = Int(input.plannedBottomMinutes) + stops.map(\.minutes).reduce(0,+) + Int(input.plannedDepthMeters / 10.0)
        let cns = min(100, input.plannedBottomMinutes * max(0, input.bottomGas.oxygen * input.ambientPressureBar - 0.5) * 2.2)
        let otu = max(0, input.plannedBottomMinutes * pow(max(0.5, input.bottomGas.oxygen * input.ambientPressureBar) - 0.5, 0.83) * 5)
        return DivePlanResult(ndlMinutes: ndl, ttrMinutes: ttr, decoStops: stops, cnsPercent: cns, otu: otu)
    }
}
