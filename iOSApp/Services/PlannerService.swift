import Foundation

enum PlannerService {
    static func makePlan(input: GasPlanInput) -> DivePlanResult {
        let ndl = BuhlmannPlanner.plan(depthMeters: input.plannedDepthMeters, o2Fraction: input.bottomGas.oxygen).ndlMinutes
        let needsDeco = input.plannedBottomMinutes > ndl || input.plannedDepthMeters >= 35
        let analysis = GasPlanningService.analyze(input: input)
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
        let segments = GasPlanningService.profileSegments(input: input, stops: stops)
        let gfComparisons = GasPlanningService.gfComparisons(input: input, baseTTS: ttr, stopCount: stops.count)
        let contingencies = GasPlanningService.contingencyPlans(input: input, baseAnalysis: analysis, baseTTS: ttr)
        let teamMatches = GasPlanningService.teamGasMatches(input: input, minimumGasLiters: analysis.rockBottomLiters)
        let briefing = GasPlanningService.briefingLines(input: input, analysis: analysis, tts: ttr, stops: stops)
        return DivePlanResult(
            ndlMinutes: ndl,
            ttrMinutes: ttr,
            decoStops: stops,
            cnsPercent: analysis.cnsPercent,
            otu: analysis.otu,
            gasAnalysis: analysis,
            segments: segments,
            gfComparisons: gfComparisons,
            contingencyPlans: contingencies,
            teamMatches: teamMatches,
            briefingLines: briefing
        )
    }
}
