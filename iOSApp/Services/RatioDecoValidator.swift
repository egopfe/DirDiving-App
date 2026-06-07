import Foundation

enum RatioDecoValidator {
    static func validate(
        schedule: RatioDecoSchedule,
        input: GasPlanInput,
        mode: PlannerMode,
        enginePlan: BuhlmannEngineResult,
        request: BuhlmannPlanRequest,
        environment: PlannerEnvironment
    ) -> RatioDecoValidationResult {
        if mode == .base {
            return RatioDecoValidationResult(
                isBuhlmannCompatible: false,
                warnings: [.unavailableInBaseMode],
                firstViolationRuntime: nil,
                firstViolationDepthMeters: nil,
                requiredCeilingMeters: nil
            )
        }

        if mode == .deco, input.plannedDepthMeters > PlannerModeLimits.decoMaximumDepthMeters(for: input) + 0.01 {
            return RatioDecoValidationResult(
                isBuhlmannCompatible: false,
                warnings: [.decoDepthLimitExceeded],
                firstViolationRuntime: nil,
                firstViolationDepthMeters: input.plannedDepthMeters,
                requiredCeilingMeters: nil
            )
        }

        guard !schedule.stops.isEmpty else {
            return RatioDecoValidationResult(
                isBuhlmannCompatible: schedule.warnings.isEmpty,
                warnings: [],
                firstViolationRuntime: nil,
                firstViolationDepthMeters: nil,
                requiredCeilingMeters: nil
            )
        }

        var warnings: [RatioDecoValidationWarning] = []
        var tissue = tissueStateAtEndOfBottom(
            request: request,
            enginePlan: enginePlan,
            environment: environment
        )
        let gfLow = request.gfLow / 100.0
        var currentDepth = input.plannedDepthMeters
        var runtime = enginePlan.descentMinutes + enginePlan.bottomMinutes

        for stop in schedule.stops {
            if stop.depthMeters < currentDepth - 0.05 {
                let ascentMinutes = max(0, (currentDepth - stop.depthMeters) / 9.0)
                let gas = BuhlmannGas(gas: stop.gasMix ?? input.bottomGas, role: .deco, switchDepthMeters: stop.depthMeters)
                tissue = tissue.loadedLinearDepth(
                    fromDepthMeters: currentDepth,
                    toDepthMeters: stop.depthMeters,
                    minutes: ascentMinutes,
                    gas: gas,
                    environment: environment
                )
                runtime += ascentMinutes
                currentDepth = stop.depthMeters
            }

            let ceiling = tissue.ceiling(gf: gfLow, environment: environment).depthMeters
            if stop.depthMeters + 0.05 < ceiling {
                warnings.append(
                    .ceilingViolation(
                        requiredCeilingMeters: ceiling,
                        stopDepthMeters: stop.depthMeters,
                        runtimeMinute: runtime
                    )
                )
                return RatioDecoValidationResult(
                    isBuhlmannCompatible: false,
                    warnings: warnings,
                    firstViolationRuntime: runtime,
                    firstViolationDepthMeters: stop.depthMeters,
                    requiredCeilingMeters: ceiling
                )
            }

            if let gas = stop.gasMix,
               PlannerMODValidator.validateGasSwitch(depthMeters: stop.depthMeters, gas: gas, role: .deco, environment: environment) != nil {
                warnings.append(.modExceeded(depthMeters: stop.depthMeters, gasLabel: stop.gasLabel))
            }

            let gas = BuhlmannGas(gas: stop.gasMix ?? input.bottomGas, role: .deco, switchDepthMeters: stop.depthMeters)
            tissue = tissue.loadedConstantDepth(depthMeters: stop.depthMeters, minutes: stop.durationMinutes, gas: gas, environment: environment)
            runtime += stop.durationMinutes
        }

        return RatioDecoValidationResult(
            isBuhlmannCompatible: warnings.isEmpty,
            warnings: warnings,
            firstViolationRuntime: nil,
            firstViolationDepthMeters: nil,
            requiredCeilingMeters: nil
        )
    }

    /// Replays Bühlmann engine segments through the bottom phase without modifying Bühlmann internals.
    private static func tissueStateAtEndOfBottom(
        request: BuhlmannPlanRequest,
        enginePlan: BuhlmannEngineResult,
        environment: PlannerEnvironment
    ) -> BuhlmannTissueState {
        var state = request.initialTissueState
        guard let lastBottomIndex = enginePlan.segments.lastIndex(where: { $0.kind == .bottom }) else {
            let gas = request.bottomGas
            let descended = state.loadedLinearDepth(
                fromDepthMeters: 0,
                toDepthMeters: request.maxDepthMeters,
                minutes: enginePlan.descentMinutes,
                gas: gas,
                environment: environment
            )
            return descended.loadedConstantDepth(
                depthMeters: request.maxDepthMeters,
                minutes: enginePlan.bottomMinutes,
                gas: gas,
                environment: environment
            )
        }

        var currentDepth = 0.0
        for segment in enginePlan.segments[...lastBottomIndex] {
            switch segment.kind {
            case .descent, .ascent:
                state = state.loadedLinearDepth(
                    fromDepthMeters: currentDepth,
                    toDepthMeters: segment.depthMeters,
                    minutes: segment.minutes,
                    gas: segment.gas,
                    environment: environment
                )
                currentDepth = segment.depthMeters
            case .bottom, .stop, .gasSwitch:
                state = state.loadedConstantDepth(
                    depthMeters: segment.depthMeters,
                    minutes: segment.minutes,
                    gas: segment.gas,
                    environment: environment
                )
                currentDepth = segment.depthMeters
            }
        }
        return state
    }
}
