import Foundation

/// Immutable snapshot for off-main-thread OC planner computation.
struct PlannerOCCalculationInput: Sendable {
    let mode: PlannerMode
    let input: GasPlanInput
    let repetitivePlanningEnabled: Bool
    let lastTissueSnapshot: TissueSnapshot?
    let surfaceIntervalMinutes: Double
    let decompressionMethod: PlannerDecompressionMethod
    let ratioDecoPreset: RatioDecoPreset
    let ascentSpeedSettings: PlannerAscentSpeedSettings
    let precomputedAnalysis: TechnicalGasAnalysis?
}

struct PlannerOCCalculationResult: Sendable {
    let plan: DivePlanResult
    let buhlmann: BuhlmannPlanResult
    let analysis: TechnicalGasAnalysis
    let lastTissueSnapshot: TissueSnapshot?
    let tissueAnalytics: TissueAnalyticsPresentation?
    let chartSnapshots: PlannerChartSnapshots
}

/// Heavy Bühlmann / planner math runs here — never on `@MainActor`.
enum PlannerBackgroundCalculation {
    static func compute(
        snapshot: PlannerOCCalculationInput,
        generation: UInt,
        persistSnapshot: Bool
    ) -> PlannerOCCalculationResult {
        let signpost = DIRPerformanceSignpost.begin(.iosPlannerCalculation)
        defer { signpost.end() }

        var workingInput = snapshot.input
        workingInput.syncLegacyGasesFromPlannerCylinders()
        let active = PlannerModePolicy.activePlanInput(from: workingInput, mode: snapshot.mode)

        let analysis: TechnicalGasAnalysis
        if let precomputed = snapshot.precomputedAnalysis {
            analysis = precomputed
        } else {
            analysis = GasPlanningService.analyze(
                input: workingInput,
                mode: snapshot.mode,
                ascentSpeedSettings: snapshot.ascentSpeedSettings
            )
        }

        let plan = PlannerService.makePlan(
            input: workingInput,
            mode: snapshot.mode,
            repetitivePlanningEnabled: snapshot.repetitivePlanningEnabled,
            repetitiveSnapshot: snapshot.repetitivePlanningEnabled ? snapshot.lastTissueSnapshot : nil,
            surfaceIntervalMinutes: snapshot.surfaceIntervalMinutes,
            decompressionMethod: snapshot.decompressionMethod,
            ratioDecoPreset: snapshot.ratioDecoPreset,
            unitPreference: .metric,
            ascentSpeedSettings: snapshot.ascentSpeedSettings,
            precomputedAnalysis: analysis
        )

        let buhlmann: BuhlmannPlanResult
        if case .success(let environment) = PlannerEnvironment.make(
            altitudeMeters: active.altitudeMeters,
            salinity: active.salinity
        ) {
            buhlmann = BuhlmannPlanner.planPresentation(
                depthMeters: active.buhlmannPlanningDepthMeters,
                bottomGas: active.buhlmannBackGas,
                environment: environment,
                gfHigh: active.gfHigh,
                engineNDLMinutes: plan.ndlMinutes > 0 ? plan.ndlMinutes : nil
            )
        } else {
            buhlmann = BuhlmannPlanner.plan(
                depthMeters: active.buhlmannPlanningDepthMeters,
                bottomGas: active.buhlmannBackGas
            )
        }

        var tissueSnapshot = snapshot.lastTissueSnapshot
        if persistSnapshot,
           let environment = try? makeEnvironment(from: active),
           let nextSnapshot = RepetitiveDivePlannerService.makeSnapshot(
               from: BuhlmannPlanner.enginePlan(input: active),
               environment: environment
           ) {
            tissueSnapshot = nextSnapshot
        }

        let chartSnapshots = PlannerChartSnapshots.make(
            from: plan,
            buhlmann: buhlmann,
            generation: generation
        )

        let tissueAnalytics = TissueAnalyticsService.presentationForPlanner(
            plan: plan,
            input: workingInput,
            mode: snapshot.mode
        )

        return PlannerOCCalculationResult(
            plan: plan,
            buhlmann: buhlmann,
            analysis: analysis,
            lastTissueSnapshot: tissueSnapshot,
            tissueAnalytics: tissueAnalytics,
            chartSnapshots: chartSnapshots
        )
    }

    private static func makeEnvironment(from input: GasPlanInput) throws -> PlannerEnvironment {
        switch PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) {
        case .success(let environment):
            return environment
        case .failure:
            throw NSError(domain: "PlannerEnvironment", code: 2)
        }
    }
}
