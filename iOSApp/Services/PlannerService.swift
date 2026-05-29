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
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            var invalidValidation = validation
            invalidValidation.add(.invalidEnvironment, message: "Ambiente planner non valido.")
            return unavailablePlan(input: input, validation: invalidValidation)
        }

        var working = input
        working.syncLegacyGasesFromPlannerCylinders()
        let baseRequest = BuhlmannPlanner.makeRequest(input: working, environment: environment)
        let request: BuhlmannPlanRequest
        if let snapshot = repetitiveSnapshot,
           let seeded = try? makeSeededRequest(
               input: working,
               baseRequest: baseRequest,
               snapshot: snapshot,
               surfaceIntervalMinutes: surfaceIntervalMinutes,
               environment: environment
           ) {
            request = seeded
        } else {
            request = baseRequest
        }

        let enginePlan = BuhlmannEngine.plan(request)
        let analysis = GasPlanningService.analyze(input: working, enginePlan: enginePlan)
        let stops = BuhlmannPlanner.decoStops(from: enginePlan)

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
        let segments = BuhlmannPlanner.runtimeSegments(from: enginePlan)
        let scheduleLines = PlannerGasSchedule.roleScheduleLines(input: working)
        let gfComparisons = BuhlmannPlanner.gfComparisons(baseRequest: {
            var seededBase = baseRequest
            seededBase.initialTissueState = request.initialTissueState
            return seededBase
        }())
        let contingencies = GasPlanningService.contingencyPlans(input: working, baseAnalysis: analysis, baseTTS: ttr, environment: environment)
        let teamMatches = GasPlanningService.teamGasMatches(input: working, minimumGasLiters: analysis.rockBottomLiters)
        var briefing = GasPlanningService.briefingLines(input: working, analysis: analysis, tts: ttr, stops: stops)
        briefing.insert(contentsOf: scheduleLines, at: min(1, briefing.count))
        return DivePlanResult(
            ndlMinutes: enginePlan.ndlMinutes ?? 0,
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

    private static func makeSeededRequest(
        input: GasPlanInput,
        baseRequest: BuhlmannPlanRequest,
        snapshot: TissueSnapshot,
        surfaceIntervalMinutes: Double,
        environment: PlannerEnvironment
    ) throws -> BuhlmannPlanRequest {
        switch RepetitiveDivePlannerService.seedRequest(
            baseRequest,
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
