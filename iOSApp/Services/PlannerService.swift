import Foundation

enum PlannerService {
    static func makePlan(input: GasPlanInput) -> DivePlanResult {
        var working = input
        working.syncLegacyGasesFromPlannerCylinders()
        let bottom = PlannerGasSchedule.bottomGas(from: working)
        let ndl = BuhlmannPlanner.plan(depthMeters: working.plannedDepthMeters, bottomGas: bottom).ndlMinutes
        let needsDeco = working.plannedBottomMinutes > ndl || working.plannedDepthMeters >= 35
        let analysis = GasPlanningService.analyze(input: working)
        let stopPlan = PlannerGasSchedule.buildDecoStops(needsDeco: needsDeco, input: working)
        let requestedStops = stopPlan.requested
        let stops = stopPlan.applied

        let modIssues = PlannerMODValidator.validateAll(input: working, requestedStops: requestedStops)
        let ttr = Int(working.plannedBottomMinutes) + stops.map(\.minutes).reduce(0,+) + Int(working.plannedDepthMeters / 10.0)
        let segments = GasPlanningService.profileSegments(input: working, stops: stops)
        let scheduleLines = PlannerGasSchedule.roleScheduleLines(input: working)
        let gfComparisons = GasPlanningService.gfComparisons(input: working, baseTTS: ttr, stopCount: stops.count)
        let contingencies = GasPlanningService.contingencyPlans(input: working, baseAnalysis: analysis, baseTTS: ttr)
        let teamMatches = GasPlanningService.teamGasMatches(input: working, minimumGasLiters: analysis.rockBottomLiters)
        var briefing = GasPlanningService.briefingLines(input: working, analysis: analysis, tts: ttr, stops: stops)
        briefing.insert(contentsOf: scheduleLines, at: min(1, briefing.count))
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
