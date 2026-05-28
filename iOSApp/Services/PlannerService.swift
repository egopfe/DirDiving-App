import Foundation

enum PlannerService {
    static func makePlan(input: GasPlanInput) -> DivePlanResult {
        makePlan(input: input, repetitiveSnapshot: nil, surfaceIntervalMinutes: 0)
    }

    static func makePlan(
        input: GasPlanInput,
        repetitiveSnapshot: TissueSnapshot?,
        surfaceIntervalMinutes: Double
    ) -> DivePlanResult {
        let validation = PlannerInputValidator.validate(input)
        guard validation.isValid else {
            return unavailablePlan(input: input, validation: validation)
        }
        var working = input
        working.syncLegacyGasesFromPlannerCylinders()
        let bottom = PlannerGasSchedule.bottomGas(from: working)
        let planningDepth = working.buhlmannPlanningDepthMeters
        let buhlmann = BuhlmannPlanner.plan(depthMeters: planningDepth, bottomGas: bottom)
        let enginePlan: BuhlmannEngineResult
        if let snapshot = repetitiveSnapshot,
           let environment = try? makeEnvironment(from: working),
           let request = try? makeSeededRequest(input: working, snapshot: snapshot, surfaceIntervalMinutes: surfaceIntervalMinutes, environment: environment) {
            enginePlan = BuhlmannEngine.plan(request)
        } else {
            enginePlan = BuhlmannPlanner.enginePlan(input: working)
        }
        let analysis = GasPlanningService.analyze(input: working, enginePlan: enginePlan)
        let stops = BuhlmannPlanner.decoStops(input: working)

        let modIssues = PlannerMODValidator.validatePlannerCylinders(input: working)
        var states = mergedStates(
            validation.states,
            analysis.states,
            plannerStates(from: enginePlan.modelState),
            BuhlmannPlanner.plannerStates(from: enginePlan.issues)
        )
        if !modIssues.isEmpty {
            states = mergedStates(states, [.MODExceeded])
        }
        if stops.contains(where: { $0.states.contains(.PPO2Exceeded) }) {
            states = mergedStates(states, [.PPO2Exceeded])
        }
        let ttr = enginePlan.ttsMinutes
        let segments = BuhlmannPlanner.runtimeSegments(input: working)
        let scheduleLines = PlannerGasSchedule.roleScheduleLines(input: working)
        let gfComparisons = BuhlmannPlanner.gfComparisons(input: working)
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
            buhlmannState: enginePlan.modelState
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
            return [.validReference, .nonCertifiedReference]
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

    private static func makeEnvironment(from input: GasPlanInput) throws -> PlannerEnvironment {
        switch PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) {
        case .success(let environment):
            return environment
        case .failure:
            throw NSError(domain: "PlannerEnvironment", code: 3)
        }
    }

    private static func makeSeededRequest(
        input: GasPlanInput,
        snapshot: TissueSnapshot,
        surfaceIntervalMinutes: Double,
        environment: PlannerEnvironment
    ) throws -> BuhlmannPlanRequest {
        let base = BuhlmannPlanner.makeRequest(input: input)
        switch RepetitiveDivePlannerService.seedRequest(
            base,
            snapshot: snapshot,
            surfaceIntervalMinutes: surfaceIntervalMinutes,
            environment: environment
        ) {
        case .success(let request):
            return request
        case .failure:
            throw NSError(domain: "RepetitivePlanner", code: 1)
        }
    }
}
