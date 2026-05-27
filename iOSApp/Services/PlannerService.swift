import Foundation

enum PlannerService {
    static func makePlan(input: GasPlanInput) -> DivePlanResult {
        let validation = PlannerInputValidator.validate(input)
        guard validation.isValid else {
            return unavailablePlan(input: input, validation: validation)
        }
        var working = input
        working.syncLegacyGasesFromPlannerCylinders()
        let bottom = PlannerGasSchedule.bottomGas(from: working)
        let planningDepth = working.buhlmannPlanningDepthMeters
        let buhlmann = BuhlmannPlanner.plan(depthMeters: planningDepth, bottomGas: bottom)
        let needsDeco = buhlmann.modelState == .simplifiedReferenceOnly
            && (working.plannedBottomMinutes > buhlmann.ndlMinutes || planningDepth >= 35)
        let analysis = GasPlanningService.analyze(input: working)
        let stopPlan = PlannerGasSchedule.buildDecoStops(needsDeco: needsDeco, input: working)
        let requestedStops = stopPlan.requested
        let stops = stopPlan.applied

        let modIssues = PlannerMODValidator.validateAll(input: working, requestedStops: requestedStops)
        var states = mergedStates(validation.states, analysis.states, plannerStates(from: buhlmann.modelState))
        if !modIssues.isEmpty {
            states = mergedStates(states, [.MODExceeded])
        }
        if stops.contains(where: { $0.states.contains(.PPO2Exceeded) }) {
            states = mergedStates(states, [.PPO2Exceeded])
        }
        let ttr = Int(working.plannedBottomMinutes)
            + stops.map(\.minutes).reduce(0,+)
            + Int(working.plannedDepthMeters / IOSAlgorithmConfiguration.metersPerBarApproximation)
        let segments = GasPlanningService.profileSegments(input: working, stops: stops)
        let scheduleLines = PlannerGasSchedule.roleScheduleLines(input: working)
        let gfComparisons = GasPlanningService.gfComparisons(input: working, baseTTS: ttr, stopCount: stops.count)
        let contingencies = GasPlanningService.contingencyPlans(input: working, baseAnalysis: analysis, baseTTS: ttr)
        let teamMatches = GasPlanningService.teamGasMatches(input: working, minimumGasLiters: analysis.rockBottomLiters)
        var briefing = GasPlanningService.briefingLines(input: working, analysis: analysis, tts: ttr, stops: stops)
        briefing.insert(contentsOf: scheduleLines, at: min(1, briefing.count))
        return DivePlanResult(
            ndlMinutes: buhlmann.ndlMinutes,
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
            modValidationIssues: modIssues,
            states: states,
            buhlmannState: buhlmann.modelState
        )
    }

    private static func unavailablePlan(input: GasPlanInput, validation: PlannerValidationResult) -> DivePlanResult {
        let analysis = GasPlanningService.analyze(input: input)
        let states = validation.states.isEmpty ? [.invalidInput] : validation.states
        return DivePlanResult(
            ndlMinutes: 0,
            ttrMinutes: 0,
            decoStops: [],
            cnsPercent: 0,
            otu: 0,
            gasAnalysis: analysis,
            segments: [],
            gfComparisons: [],
            contingencyPlans: [],
            teamMatches: [],
            briefingLines: validation.messages,
            modValidationIssues: [],
            states: states,
            buhlmannState: .invalidInput
        )
    }

    private static func plannerStates(from buhlmannState: BuhlmannModelState) -> [PlannerResultState] {
        switch buhlmannState {
        case .validReference:
            return [.validReference]
        case .simplifiedReferenceOnly:
            return [.simplifiedReferenceOnly]
        case .unsupportedTrimix:
            return [.unsupportedTrimix, .modelIncomplete]
        case .modelIncomplete:
            return [.modelIncomplete]
        case .unavailable:
            return [.unavailable]
        case .invalidInput:
            return [.invalidInput]
        }
    }

    private static func mergedStates(_ groups: [PlannerResultState]...) -> [PlannerResultState] {
        var seen = Set<PlannerResultState>()
        var merged: [PlannerResultState] = []
        for state in groups.flatMap({ $0 }) where seen.insert(state).inserted {
            merged.append(state)
        }
        return merged
    }
}
