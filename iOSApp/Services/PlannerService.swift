import Foundation

enum PlannerService {
    static func makePlan(input: GasPlanInput) -> DivePlanResult {
        var working = input
        working.syncLegacyGasesFromPlannerCylinders()
        let ndl = BuhlmannPlanner.plan(depthMeters: working.plannedDepthMeters, o2Fraction: working.bottomGas.oxygen).ndlMinutes
        let needsDeco = working.plannedBottomMinutes > ndl || working.plannedDepthMeters >= 35
        let analysis = GasPlanningService.analyze(input: working)
        let decoCylinders = working.plannerCylinders.filter { $0.role == .deco }
        let deco1 = decoCylinders.first
        let deco2 = decoCylinders.dropFirst().first
        let deco1Depth = deco1?.switchDepthMeters ?? 21
        let deco2Depth = deco2?.switchDepthMeters ?? 9
        let deco1MOD = PlannerMODValidator.modMeters(for: working.decoGas1)
        let deco2MOD = PlannerMODValidator.modMeters(for: working.decoGas2)

        let requestedStops: [DecoStop]
        let stops: [DecoStop]
        if needsDeco {
            requestedStops = [
                DecoStop(depthMeters: deco1Depth, minutes: 2, gas: working.decoGas1.label, ppO2: min(1.6, working.decoGas1.oxygen * (deco1Depth / 10.0 + 1.0))),
                DecoStop(depthMeters: 15, minutes: 3, gas: working.decoGas1.label, ppO2: min(1.6, working.decoGas1.oxygen * 2.5)),
                DecoStop(depthMeters: deco2Depth, minutes: 5, gas: working.decoGas2.label, ppO2: min(1.6, working.decoGas2.oxygen * (deco2Depth / 10.0 + 1.0))),
                DecoStop(depthMeters: min(6, deco2MOD), minutes: 8, gas: working.decoGas2.label, ppO2: min(1.6, working.decoGas2.oxygen * 1.6)),
                DecoStop(depthMeters: min(3, deco2MOD), minutes: 4, gas: working.decoGas2.label, ppO2: min(1.6, working.decoGas2.oxygen * 1.3))
            ]
            stops = [
                requestedStops[0],
                requestedStops[1],
                DecoStop(
                    depthMeters: min(deco2Depth, deco2MOD),
                    minutes: requestedStops[2].minutes,
                    gas: requestedStops[2].gas,
                    ppO2: requestedStops[2].ppO2
                ),
                requestedStops[3],
                requestedStops[4]
            ]
        } else {
            requestedStops = [DecoStop(depthMeters: 5, minutes: 3, gas: working.bottomGas.label, ppO2: working.bottomGas.oxygen * 1.5)]
            stops = requestedStops
        }

        let modIssues = PlannerMODValidator.validateAll(input: working, requestedStops: requestedStops)
        let ttr = Int(working.plannedBottomMinutes) + stops.map(\.minutes).reduce(0,+) + Int(working.plannedDepthMeters / 10.0)
        let segments = GasPlanningService.profileSegments(input: working, stops: stops)
        let gfComparisons = GasPlanningService.gfComparisons(input: working, baseTTS: ttr, stopCount: stops.count)
        let contingencies = GasPlanningService.contingencyPlans(input: working, baseAnalysis: analysis, baseTTS: ttr)
        let teamMatches = GasPlanningService.teamGasMatches(input: working, minimumGasLiters: analysis.rockBottomLiters)
        let briefing = GasPlanningService.briefingLines(input: working, analysis: analysis, tts: ttr, stops: stops)
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
            briefingLines: briefing,
            modValidationIssues: modIssues
        )
    }
}
