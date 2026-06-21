import Foundation

/// Presentation solver for Full Computer NDL / TTS / ceiling / deco stops.
/// Operates on a tissue copy via `BuhlmannEngine.runtimeProjection` without mutating live state.
enum FullComputerDecoSolver {
    static let performanceBudgetSeconds: TimeInterval = 0.05
    static let ceilingViolationToleranceMeters = 0.35
    static let decoCeilingEpsilonMeters = 0.05

    /// Instance-scoped presentation cache owned by `FullComputerRuntimeEngine` (not process-wide).
    struct Cache: Equatable {
        fileprivate struct CacheKey: Hashable {
            let tissueState: BuhlmannTissueState
            let depthMilliMeters: Int
            let gasMixId: UUID
            let gfLowMilli: Int
            let gfHighMilli: Int
            let runtimeMinutes: Int
            let travelSignature: Int
            let decoSignature: Int
        }

        fileprivate var cachedKey: CacheKey?
        fileprivate var cachedPresentation: FullComputerDecoPresentation?

        mutating func reset() {
            cachedKey = nil
            cachedPresentation = nil
        }
    }

    /// Test-only hook for suites that call static `solve(input:)` without an engine-owned cache.
    private static var uncachedTestCounter = 0

    static func resetCacheForTests() {
        uncachedTestCounter = 0
    }

    /// Builds presentation from a precomputed canonical projection (single projection per snapshot refresh).
    static func solve(
        input: FullComputerDecoSolverInput,
        projection: BuhlmannRuntimeProjection,
        cache: inout Cache?,
        budgetSeconds: TimeInterval = performanceBudgetSeconds,
        timingDegraded: Bool = false
    ) -> FullComputerDecoPresentation {
        let key = cacheKey(for: input)
        if !timingDegraded, var cache, cache.cachedKey == key, let cachedPresentation = cache.cachedPresentation {
            _ = budgetSeconds
            return cachedPresentation
        }

        let started = ProcessInfo.processInfo.systemUptime
        let elapsed = ProcessInfo.processInfo.systemUptime - started
        if elapsed > budgetSeconds, !timingDegraded, var cache, let cachedPresentation = cache.cachedPresentation, cache.cachedKey != key {
            return conservativeFallback(from: cachedPresentation, diagnostics: ["solver_budget_exceeded"])
        }

        let presentation = buildPresentation(
            input: input,
            projection: projection,
            usedConservativeFallback: false,
            diagnostics: projection.issues.isEmpty ? [] : ["projection_issues:\(projection.issues.count)"],
            timingDegraded: timingDegraded
        )
        if !timingDegraded, cache != nil {
            cache!.cachedKey = key
            cache!.cachedPresentation = presentation
        }
        return presentation
    }

    /// Uncached path for unit tests and legacy callers.
    static func solve(
        input: FullComputerDecoSolverInput,
        now: Date = Date(),
        budgetSeconds: TimeInterval = performanceBudgetSeconds
    ) -> FullComputerDecoPresentation {
        _ = now
        uncachedTestCounter &+= 1
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
        return buildPresentation(
            input: input,
            projection: projection,
            usedConservativeFallback: false,
            diagnostics: projection.issues.isEmpty ? [] : ["projection_issues:\(projection.issues.count)"]
        )
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

    static func buildPresentation(
        input: FullComputerDecoSolverInput,
        projection: BuhlmannRuntimeProjection,
        usedConservativeFallback: Bool,
        diagnostics: [String],
        timingDegraded: Bool = false
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

        var mergedDiagnostics = diagnostics
        if timingDegraded {
            mergedDiagnostics.append("timing_degraded")
        }

        if decoRequired {
            let immersionAccent: FullComputerImmersionAccent = ceilingViolation ? .ceilingViolation : .decompression
            let statusKey = timingDegraded
                ? "live.fc.status.runtime_degraded"
                : ceilingViolation
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
                ascentAllowedBetweenStops: timingDegraded ? false : ascentAllowed,
                showDecoStopPanel: showDecoStopPanel,
                showCeilingViolationBanner: ceilingViolation,
                usedConservativeFallback: usedConservativeFallback || timingDegraded,
                diagnostics: mergedDiagnostics,
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
        let statusKey = timingDegraded ? "live.fc.status.runtime_degraded" : "live.status.in_dive"
        return FullComputerDecoPresentation(
            mode: .noDecompression,
            immersionAccent: .diving,
            immersionStatusKey: statusKey,
            ndlDisplayMinutes: timingDegraded ? nil : ndlRounded,
            ndlAccent: timingDegraded ? nil : accent,
            ttsMinutes: projection.ttsMinutes,
            runtimeMinutes: input.runtimeMinutes,
            ceilingMetersExact: ceilingExact,
            ceilingMetersRounded: ceilingRounded,
            nextStopDepthMeters: nil,
            nextStopMinutes: nil,
            remainingStopCount: 0,
            ceilingViolation: false,
            ascentAllowedBetweenStops: !timingDegraded,
            showDecoStopPanel: false,
            showCeilingViolationBanner: false,
            usedConservativeFallback: usedConservativeFallback || timingDegraded,
            diagnostics: mergedDiagnostics,
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

    private static func buildPresentation(
        input: FullComputerDecoSolverInput,
        projection: BuhlmannRuntimeProjection,
        usedConservativeFallback: Bool,
        diagnostics: [String]
    ) -> FullComputerDecoPresentation {
        buildPresentation(
            input: input,
            projection: projection,
            usedConservativeFallback: usedConservativeFallback,
            diagnostics: diagnostics,
            timingDegraded: false
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

    private static func cacheKey(for input: FullComputerDecoSolverInput) -> Cache.CacheKey {
        Cache.CacheKey(
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
