import Foundation

/// Presentation solver for Full Computer NDL / TTS / ceiling / deco stops.
/// Operates on a tissue copy via `BuhlmannEngine.runtimeProjection` without mutating live state.
enum FullComputerDecoSolver {
    static let performanceBudgetSeconds: TimeInterval = 0.05
    static let ceilingViolationToleranceMeters = 0.35
    static let decoCeilingEpsilonMeters = 0.05

    private struct CacheKey: Hashable {
        let tissueState: BuhlmannTissueState
        let depthMilliMeters: Int
        let gasMixId: UUID
        let gfLowMilli: Int
        let gfHighMilli: Int
        let runtimeMinutes: Int
        let travelSignature: Int
        let decoSignature: Int
    }

    private static var cachedKey: CacheKey?
    private static var cachedPresentation: FullComputerDecoPresentation?
    private static var cachedProjection: BuhlmannRuntimeProjection?

    static func resetCacheForTests() {
        cachedKey = nil
        cachedPresentation = nil
        cachedProjection = nil
    }

    static func solve(
        input: FullComputerDecoSolverInput,
        now: Date = Date(),
        budgetSeconds: TimeInterval = performanceBudgetSeconds
    ) -> FullComputerDecoPresentation {
        let key = cacheKey(for: input)
        if key == cachedKey, let cachedPresentation {
            return cachedPresentation
        }

        let started = ProcessInfo.processInfo.systemUptime
        let projection = BuhlmannEngine.runtimeProjection(
            tissueState: input.tissueState,
            depthMeters: input.depthMeters,
            gas: input.plan.activeGas,
            gfLow: input.plan.gfLow,
            gfHigh: input.plan.gfHigh,
            plannerEnvironment: input.plan.plannerEnvironment,
            travelGases: input.plan.travelGases,
            decoGases: input.plan.decoGases,
            ascentRateMetersPerMinute: input.plan.ascentRateMetersPerMinute,
            stopIntervalMeters: input.plan.stopIntervalMeters
        )

        let elapsed = ProcessInfo.processInfo.systemUptime - started
        if elapsed > budgetSeconds, let cachedPresentation, key != cachedKey {
            return conservativeFallback(from: cachedPresentation, diagnostics: ["solver_budget_exceeded"])
        }

        let presentation = buildPresentation(
            input: input,
            projection: projection,
            usedConservativeFallback: false,
            diagnostics: projection.issues.isEmpty ? [] : ["projection_issues:\(projection.issues.count)"]
        )
        cachedKey = key
        cachedPresentation = presentation
        cachedProjection = projection
        _ = now
        return presentation
    }

    static func presentationCeilingMeters(_ exact: Double) -> Double {
        guard exact.isFinite, exact > 0 else { return 0 }
        return (exact * 10).rounded() / 10.0
    }

    static func ndlAccent(for ndlMinutes: Int) -> FullComputerNDLAccent {
        if ndlMinutes > 10 { return .green }
        if ndlMinutes > 5 { return .yellow }
        return .red
    }

    static func requiresDecompression(
        projection: BuhlmannRuntimeProjection,
        depthMeters: Double
    ) -> Bool {
        _ = depthMeters
        if let ndlMinutes = projection.ndlMinutes, ndlMinutes > 0 {
            return false
        }
        if !projection.stops.isEmpty { return true }
        return projection.rawCeilingMeters > decoCeilingEpsilonMeters
            || projection.operationalCeilingMeters > decoCeilingEpsilonMeters
    }

    private static func buildPresentation(
        input: FullComputerDecoSolverInput,
        projection: BuhlmannRuntimeProjection,
        usedConservativeFallback: Bool,
        diagnostics: [String]
    ) -> FullComputerDecoPresentation {
        let depth = max(0, input.depthMeters)
        let decoRequired = requiresDecompression(projection: projection, depthMeters: depth)
        let ceilingExact = projection.operationalCeilingMeters
        let ceilingRounded = presentationCeilingMeters(ceilingExact)
        let ceilingViolation = decoRequired
            && ceilingExact > decoCeilingEpsilonMeters
            && depth + ceilingViolationToleranceMeters < ceilingExact

        let firstStop = projection.stops.first
        let remainingStops = projection.stops.count
        let showDecoStopPanel = decoRequired && firstStop != nil

        let ascentAllowed = decoRequired
            && !ceilingViolation
            && depth + 0.2 >= ceilingExact
            && (firstStop == nil || depth <= (firstStop?.depthMeters ?? 0) + 0.5)

        if decoRequired {
            let immersionAccent: FullComputerImmersionAccent = ceilingViolation ? .ceilingViolation : .decompression
            let statusKey = ceilingViolation
                ? "live.fc.status.ceiling_violation"
                : "live.fc.status.in_deco"
            return FullComputerDecoPresentation(
                mode: .decompression,
                immersionAccent: immersionAccent,
                immersionStatusKey: statusKey,
                ndlDisplayMinutes: nil,
                ndlAccent: nil,
                ttsMinutes: projection.ttsMinutes,
                runtimeMinutes: input.runtimeMinutes,
                ceilingMetersExact: ceilingExact,
                ceilingMetersRounded: ceilingRounded,
                nextStopDepthMeters: firstStop?.depthMeters,
                nextStopMinutes: firstStop?.minutes,
                remainingStopCount: remainingStops,
                ceilingViolation: ceilingViolation,
                ascentAllowedBetweenStops: ascentAllowed,
                showDecoStopPanel: showDecoStopPanel,
                showCeilingViolationBanner: ceilingViolation,
                usedConservativeFallback: usedConservativeFallback,
                diagnostics: diagnostics,
                stopState: nil,
                stopDirection: .none,
                stopPanelAccent: .yellow,
                stopPanelTitleKey: "",
                stopInstructionKey: nil,
                stopRemainingSeconds: nil,
                activeGasLabel: input.plan.activeGas.name,
                showDecoProgressPanel: false,
                hideManualStopwatch: false,
                timerAccruing: false
            )
        }

        let ndlRounded = max(0, Int(floor(projection.ndlMinutes ?? 0)))
        let accent = ndlAccent(for: ndlRounded)
        return FullComputerDecoPresentation(
            mode: .noDecompression,
            immersionAccent: .diving,
            immersionStatusKey: "live.status.in_dive",
            ndlDisplayMinutes: ndlRounded,
            ndlAccent: accent,
            ttsMinutes: projection.ttsMinutes,
            runtimeMinutes: input.runtimeMinutes,
            ceilingMetersExact: ceilingExact,
            ceilingMetersRounded: ceilingRounded,
            nextStopDepthMeters: nil,
            nextStopMinutes: nil,
            remainingStopCount: 0,
            ceilingViolation: false,
            ascentAllowedBetweenStops: true,
            showDecoStopPanel: false,
            showCeilingViolationBanner: false,
            usedConservativeFallback: usedConservativeFallback,
            diagnostics: diagnostics,
            stopState: nil,
            stopDirection: .none,
            stopPanelAccent: .green,
            stopPanelTitleKey: "",
            stopInstructionKey: nil,
            stopRemainingSeconds: nil,
            activeGasLabel: input.plan.activeGas.name,
            showDecoProgressPanel: false,
            hideManualStopwatch: false,
            timerAccruing: false
        )
    }

    private static func conservativeFallback(
        from previous: FullComputerDecoPresentation,
        diagnostics: [String]
    ) -> FullComputerDecoPresentation {
        FullComputerDecoPresentation(
            mode: previous.mode,
            immersionAccent: previous.immersionAccent,
            immersionStatusKey: previous.immersionStatusKey,
            ndlDisplayMinutes: previous.ndlDisplayMinutes,
            ndlAccent: previous.ndlAccent,
            ttsMinutes: max(previous.ttsMinutes, previous.ttsMinutes + 1),
            runtimeMinutes: previous.runtimeMinutes,
            ceilingMetersExact: previous.ceilingMetersExact,
            ceilingMetersRounded: previous.ceilingMetersRounded,
            nextStopDepthMeters: previous.nextStopDepthMeters,
            nextStopMinutes: previous.nextStopMinutes,
            remainingStopCount: previous.remainingStopCount,
            ceilingViolation: previous.ceilingViolation,
            ascentAllowedBetweenStops: false,
            showDecoStopPanel: previous.showDecoStopPanel,
            showCeilingViolationBanner: previous.ceilingViolation,
            usedConservativeFallback: true,
            diagnostics: diagnostics,
            stopState: previous.stopState,
            stopDirection: previous.stopDirection,
            stopPanelAccent: previous.stopPanelAccent,
            stopPanelTitleKey: previous.stopPanelTitleKey,
            stopInstructionKey: previous.stopInstructionKey,
            stopRemainingSeconds: previous.stopRemainingSeconds,
            activeGasLabel: previous.activeGasLabel,
            showDecoProgressPanel: previous.showDecoProgressPanel,
            hideManualStopwatch: previous.hideManualStopwatch,
            timerAccruing: false
        )
    }

    private static func cacheKey(for input: FullComputerDecoSolverInput) -> CacheKey {
        CacheKey(
            tissueState: input.tissueState,
            depthMilliMeters: Int((input.depthMeters * 1_000).rounded()),
            gasMixId: input.plan.activeGas.gasMixId,
            gfLowMilli: Int((input.plan.gfLow * 1_000).rounded()),
            gfHighMilli: Int((input.plan.gfHigh * 1_000).rounded()),
            runtimeMinutes: input.runtimeMinutes,
            travelSignature: gasSignature(input.plan.travelGases),
            decoSignature: gasSignature(input.plan.decoGases)
        )
    }

    private static func gasSignature(_ gases: [BuhlmannGas]) -> Int {
        var hasher = Hasher()
        for gas in gases {
            hasher.combine(gas.gasMixId)
            hasher.combine(gas.switchDepthMeters)
        }
        return hasher.finalize()
    }

    static func applyingStopMachine(
        _ presentation: FullComputerDecoPresentation,
        machine: FullComputerDecoStopMachineOutput
    ) -> FullComputerDecoPresentation {
        guard presentation.mode == .decompression else { return presentation }
        return FullComputerDecoPresentation(
            mode: presentation.mode,
            immersionAccent: presentation.immersionAccent,
            immersionStatusKey: presentation.immersionStatusKey,
            ndlDisplayMinutes: presentation.ndlDisplayMinutes,
            ndlAccent: presentation.ndlAccent,
            ttsMinutes: presentation.ttsMinutes,
            runtimeMinutes: presentation.runtimeMinutes,
            ceilingMetersExact: presentation.ceilingMetersExact,
            ceilingMetersRounded: presentation.ceilingMetersRounded,
            nextStopDepthMeters: presentation.nextStopDepthMeters,
            nextStopMinutes: presentation.nextStopMinutes,
            remainingStopCount: presentation.remainingStopCount,
            ceilingViolation: presentation.ceilingViolation,
            ascentAllowedBetweenStops: presentation.ascentAllowedBetweenStops,
            showDecoStopPanel: machine.showProgressPanel,
            showCeilingViolationBanner: presentation.showCeilingViolationBanner,
            usedConservativeFallback: presentation.usedConservativeFallback,
            diagnostics: presentation.diagnostics,
            stopState: machine.state,
            stopDirection: machine.direction,
            stopPanelAccent: machine.panelAccent,
            stopPanelTitleKey: machine.titleKey,
            stopInstructionKey: machine.instructionKey,
            stopRemainingSeconds: machine.stopRemainingSeconds,
            activeGasLabel: presentation.activeGasLabel,
            showDecoProgressPanel: machine.showProgressPanel,
            hideManualStopwatch: machine.hideManualStopwatch,
            timerAccruing: machine.timerAccruing
        )
    }
}
