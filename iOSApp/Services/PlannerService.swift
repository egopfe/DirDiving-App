import Foundation

enum PlannerService {
    static func makePlan(input: GasPlanInput) -> DivePlanResult {
        makePlan(input: input, repetitivePlanningEnabled: false, repetitiveSnapshot: nil, surfaceIntervalMinutes: 0)
    }

    static func makePlan(
        input: GasPlanInput,
        repetitivePlanningEnabled: Bool,
        repetitiveSnapshot: TissueSnapshot?,
        surfaceIntervalMinutes: Double
    ) -> DivePlanResult {
        let validation = PlannerInputValidator.validate(input)
        guard validation.isValid else {
            return unavailablePlan(
                input: input,
                validation: validation,
                repetitivePlanningEnabled: repetitivePlanningEnabled,
                repetitiveSnapshot: repetitiveSnapshot,
                surfaceIntervalMinutes: surfaceIntervalMinutes
            )
        }
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            var invalidValidation = validation
            invalidValidation.add(.invalidEnvironment)
            return unavailablePlan(
                input: input,
                validation: invalidValidation,
                repetitivePlanningEnabled: repetitivePlanningEnabled,
                repetitiveSnapshot: repetitiveSnapshot,
                surfaceIntervalMinutes: surfaceIntervalMinutes
            )
        }

        var working = input
        working.syncLegacyGasesFromPlannerCylinders()
        let baseRequest = BuhlmannPlanner.makeRequest(input: working, environment: environment)

        let request: BuhlmannPlanRequest
        var repetitiveStates: [PlannerResultState] = []
        if repetitivePlanningEnabled {
            let seeded = seedRepetitiveRequest(
                baseRequest: baseRequest,
                snapshot: repetitiveSnapshot,
                surfaceIntervalMinutes: surfaceIntervalMinutes,
                environment: environment
            )
            if let seededRequest = seeded.request {
                request = seededRequest
                repetitiveStates = [.repetitivePlanningActive]
            } else {
                request = baseRequest
                repetitiveStates = seeded.issue.map { [$0] } ?? [.snapshotMissing]
            }
        } else {
            request = baseRequest
        }

        let repetitiveContext = makeRepetitiveContext(
            enabled: repetitivePlanningEnabled,
            snapshot: repetitiveSnapshot,
            surfaceIntervalMinutes: surfaceIntervalMinutes,
            tissueStateApplied: repetitiveStates.contains(.repetitivePlanningActive),
            snapshotIssue: repetitiveStates.first(where: { isSnapshotIssue($0) })
        )

        let enginePlan = BuhlmannEngine.plan(request)
        let oxygenCarryover = resolvedOxygenCarryover(
            repetitivePlanningEnabled: repetitivePlanningEnabled,
            snapshot: repetitiveSnapshot,
            surfaceIntervalMinutes: surfaceIntervalMinutes
        )
        let ledgerResult = ScheduleGasConsumptionService.analyze(input: working, enginePlan: enginePlan, environment: environment)
        let analysis = GasPlanningService.analyze(input: working, enginePlan: enginePlan, oxygenCarryover: oxygenCarryover)
        let rawStops = BuhlmannPlanner.decoStops(from: enginePlan)
        let completenessResolution = PlanCalculationCompletenessResolver.resolve(
            enginePlan: enginePlan,
            stops: rawStops
        )
        let stops = completenessResolution.presentationStops

        let modIssues = PlannerMODValidator.validatePlannerCylinders(input: working, environment: environment)
        var states = mergedStates(
            validation.states,
            analysis.states,
            repetitiveStates,
            plannerStates(from: enginePlan.modelState),
            BuhlmannPlanner.plannerStates(from: enginePlan.issues),
            engineIssueStates(from: enginePlan.issues),
            completenessResolution.extraStates
        )
        if !modIssues.isEmpty {
            states = mergedStates(states, [.MODExceeded])
        }
        if stops.contains(where: { $0.states.contains(.PPO2Exceeded) }) {
            states = mergedStates(states, [.PPO2Exceeded])
        }

        let gasLedgerFailure = ledgerFailureReason(from: ledgerResult)
        if gasLedgerFailure != nil {
            states = mergedStates(states, [.gasAllocationIncomplete])
        }
        if let missingCylinderState = missingCylinderState(from: ledgerResult) {
            states = mergedStates(states, [missingCylinderState])
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

        let environmentSummary = PlannerUserFacingCopy.environmentSummary(for: environment)
        let resultHeader = PlannerPresentationSupport.resultHeader(
            stops: stops,
            states: states,
            repetitiveContext: repetitiveContext,
            environment: environment
        )
        var userFacingWarnings = PlannerUserFacingCopy.userFacingWarnings(from: states)
        if let ledgerFailure = gasLedgerFailure {
            userFacingWarnings.append(ledgerFailure.userFacingMessage)
        }
        if case .success(let ledger) = ledgerResult {
            for warning in ledger.warnings {
                userFacingWarnings.append(PlannerUserFacingCopy.gasUsageWarning(for: warning))
            }
        }

        return DivePlanResult(
            ndlMinutes: enginePlan.ndlMinutes ?? 0,
            ttrMinutes: ttr,
            calculationCompleteness: completenessResolution.completeness,
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
            buhlmannState: enginePlan.modelState,
            resultHeader: resultHeader,
            repetitiveContext: repetitiveContext,
            environmentSummary: environmentSummary,
            gasLedger: try? ledgerResult.get(),
            gasLedgerFailure: gasLedgerFailure,
            userFacingWarnings: uniqueWarnings(userFacingWarnings)
        )
    }

    private static func unavailablePlan(
        input: GasPlanInput,
        validation: PlannerValidationResult,
        repetitivePlanningEnabled: Bool,
        repetitiveSnapshot: TissueSnapshot?,
        surfaceIntervalMinutes: Double
    ) -> DivePlanResult {
        let analysis = GasPlanningService.analyze(input: input)
        let states = validation.states.isEmpty ? [.invalidInput] : validation.states
        let environmentSummary: PlannerEnvironmentSummary?
        if case .failure(let error) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) {
            environmentSummary = PlannerUserFacingCopy.invalidEnvironmentSummary(for: input, error: error)
        } else if case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) {
            environmentSummary = PlannerUserFacingCopy.environmentSummary(for: environment)
        } else {
            environmentSummary = nil
        }
        let repetitiveContext = makeRepetitiveContext(
            enabled: repetitivePlanningEnabled,
            snapshot: repetitiveSnapshot,
            surfaceIntervalMinutes: surfaceIntervalMinutes,
            tissueStateApplied: false,
            snapshotIssue: repetitivePlanningEnabled ? snapshotIssue(from: repetitiveSnapshot, environment: nil) : nil
        )
        let resultHeader = PlannerPresentationSupport.resultHeader(
            stops: [],
            states: states,
            repetitiveContext: repetitiveContext,
            environment: .seaLevelSaltWater
        )
        return DivePlanResult(
            ndlMinutes: 0,
            ttrMinutes: 0,
            calculationCompleteness: .noDecompressionSolution,
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
            buhlmannState: .invalidInput,
            resultHeader: resultHeader,
            repetitiveContext: repetitiveContext,
            environmentSummary: environmentSummary,
            gasLedger: nil,
            gasLedgerFailure: nil,
            userFacingWarnings: PlannerUserFacingCopy.userFacingWarnings(from: states)
        )
    }

    private static func makeRepetitiveContext(
        enabled: Bool,
        snapshot: TissueSnapshot?,
        surfaceIntervalMinutes: Double,
        tissueStateApplied: Bool,
        snapshotIssue: PlannerResultState?
    ) -> RepetitivePlanningContext? {
        guard enabled else { return nil }
        return RepetitivePlanningContext(
            enabled: true,
            surfaceIntervalMinutes: surfaceIntervalMinutes,
            snapshotAvailable: snapshot != nil,
            snapshotCreatedAt: snapshot?.createdAt,
            snapshotSource: snapshot == nil ? nil : String(localized: "planner.repetitive.snapshot.source"),
            tissueStateApplied: tissueStateApplied,
            snapshotIssue: tissueStateApplied ? nil : snapshotIssue
        )
    }

    private static func snapshotIssue(from snapshot: TissueSnapshot?, environment: PlannerEnvironment?) -> PlannerResultState? {
        switch RepetitiveDivePlannerService.validateSnapshot(snapshot) {
        case .failure(let error):
            return PlannerUserFacingCopy.snapshotIssue(for: error)
        case .success(let valid):
            guard let environment else { return .snapshotEnvironmentMismatch }
            guard valid.plannerEnvironment == environment else { return .snapshotEnvironmentMismatch }
            let interval = SurfaceIntervalModel(minutes: 0)
            if interval.offGas(valid.tissueState, environment: environment) == nil {
                return .snapshotCorrupt
            }
            return nil
        }
    }

    private static func isSnapshotIssue(_ state: PlannerResultState) -> Bool {
        [
            .snapshotMissing,
            .snapshotStale,
            .snapshotCorrupt,
            .snapshotSchemaMismatch,
            .snapshotEnvironmentMismatch,
            .surfaceIntervalRejected
        ].contains(state)
    }

    private static func resolvedOxygenCarryover(
        repetitivePlanningEnabled: Bool,
        snapshot: TissueSnapshot?,
        surfaceIntervalMinutes: Double
    ) -> OxygenExposureCarryover {
        guard repetitivePlanningEnabled, let snapshot else { return .zero }
        let base = snapshot.oxygenCarryover ?? .zero
        return OxygenExposureModel.applySurfaceInterval(to: base, minutes: surfaceIntervalMinutes)
    }

    private static func seedRepetitiveRequest(
        baseRequest: BuhlmannPlanRequest,
        snapshot: TissueSnapshot?,
        surfaceIntervalMinutes: Double,
        environment: PlannerEnvironment
    ) -> (request: BuhlmannPlanRequest?, issue: PlannerResultState?) {
        switch RepetitiveDivePlannerService.seedRequest(
            baseRequest,
            snapshot: snapshot,
            surfaceIntervalMinutes: surfaceIntervalMinutes,
            environment: environment
        ) {
        case .success(let request):
            return (request, nil)
        case .failure(let error):
            return (nil, PlannerUserFacingCopy.snapshotIssue(for: error))
        }
    }

    private static func ledgerFailureReason(
        from result: Result<GasConsumptionLedger, ScheduleGasConsumptionService.Error>
    ) -> GasLedgerFailureReason? {
        switch result {
        case .success:
            return nil
        case .failure(.invalidSegment):
            return .invalidSegment
        case .failure(.invalidCylinder):
            return .invalidCylinder
        case .failure(.missingCylinderAllocation(let id)):
            return .missingCylinder(id)
        }
    }

    private static func missingCylinderState(
        from result: Result<GasConsumptionLedger, ScheduleGasConsumptionService.Error>
    ) -> PlannerResultState? {
        if case .failure(.missingCylinderAllocation) = result {
            return .missingCylinder
        }
        return nil
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

    private static func engineIssueStates(from issues: [BuhlmannPlanIssue]) -> [PlannerResultState] {
        var states: [PlannerResultState] = []
        for issue in issues {
            switch issue {
            case .invalidProfile:
                states.append(.unsupportedProfile)
            case .calculationLimitReached:
                break
            default:
                continue
            }
        }
        return unique(states)
    }

    private static func mergedStates(_ groups: [PlannerResultState]...) -> [PlannerResultState] {
        var seen = Set<PlannerResultState>()
        var merged: [PlannerResultState] = []
        for state in groups.flatMap({ $0 }) where seen.insert(state).inserted {
            merged.append(state)
        }
        return merged
    }

    private static func uniqueWarnings(_ warnings: [PlannerUserFacingMessage]) -> [PlannerUserFacingMessage] {
        var seen = Set<String>()
        return warnings.filter { seen.insert($0.id).inserted }
    }

    private static func unique<T: Hashable>(_ values: [T]) -> [T] {
        var seen = Set<T>()
        return values.filter { seen.insert($0).inserted }
    }
}
