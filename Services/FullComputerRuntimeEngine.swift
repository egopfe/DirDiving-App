import Foundation

/// UI-independent Bühlmann decompressive runtime for Watch Full Computer mode.
struct FullComputerRuntimeEngine: Equatable {
    private(set) var snapshot: FullComputerRuntimeSnapshot
    private var plan: FullComputerRuntimePlan
    private var tissueState: BuhlmannTissueState
    private var lastDepthMeters: Double
    private var lastSampleTimestamp: Date?
    private var lastComputedTimestamp: Date
    private var monotonicClock: MonotonicElapsedClock
    private var previousEngineState: FullComputerRuntimeEngineState
    private var decoStopTracker: FullComputerDecoStopTracker
    private var gasSwitchTracker: FullComputerGasSwitchTracker
    private var lastTickTimestamp: Date
    private var decoSolverCache = FullComputerDecoSolver.Cache()
#if DEBUG
    private var testHookDefersSnapshotRefresh = false
    private var testHookDeferredEngineState: FullComputerRuntimeEngineState?
    private var testHookDeferredDiagnostics: [String] = []
#endif

    var gasSwitchAuditTrail: [FullComputerGasSwitchAuditEvent] { gasSwitchTracker.events }
    var persistedGasSwitchTracker: FullComputerGasSwitchTracker { gasSwitchTracker }

#if DEBUG
    /// Test-only tissue read without an extra decompression solve beyond the last refresh.
    var testHook_tissueState: BuhlmannTissueState { tissueState }

    /// Test-only explicit snapshot refresh for Audit regression recorders.
    mutating func testHook_refreshSnapshotForTests(
        engineState: FullComputerRuntimeEngineState? = nil,
        diagnostics: [String]? = nil
    ) {
        refreshSnapshot(
            engineState: engineState ?? testHookDeferredEngineState ?? snapshot.engineState,
            diagnostics: diagnostics ?? testHookDeferredDiagnostics
        )
        testHookDeferredEngineState = nil
        testHookDeferredDiagnostics = []
    }

    mutating func testHook_setDeferSnapshotRefresh(_ deferRefresh: Bool) {
        testHookDefersSnapshotRefresh = deferRefresh
        if !deferRefresh {
            testHook_refreshSnapshotForTests()
        }
    }
#endif

    mutating func restoreGasSwitchTracker(_ tracker: FullComputerGasSwitchTracker) {
        gasSwitchTracker = tracker
        refreshSnapshot(engineState: snapshot.engineState, diagnostics: snapshot.diagnostics)
    }

    static func canStart(
        plan: FullComputerRuntimePlan,
        algorithmSelfCheckFailures: [String] = DiveAlgorithmSelfCheck.failures()
    ) -> (ready: Bool, diagnostics: [String]) {
        var diagnostics = plan.validate()
        if !algorithmSelfCheckFailures.isEmpty {
            diagnostics.append(contentsOf: algorithmSelfCheckFailures.map { "self_check:\($0)" })
        }
        return (diagnostics.isEmpty, diagnostics)
    }

    init(plan: FullComputerRuntimePlan, sessionStart: Date) throws {
        let readiness = Self.canStart(plan: plan)
        guard readiness.ready else {
            throw FullComputerRuntimeStartupFailure.invalidPlan(readiness.diagnostics)
        }
        self.plan = plan
        tissueState = BuhlmannTissueState.airSaturated(surfacePressureBar: plan.plannerEnvironment.surfacePressureBar)
        lastDepthMeters = 0
        lastSampleTimestamp = nil
        lastComputedTimestamp = sessionStart
        monotonicClock = MonotonicElapsedClock()
        monotonicClock.reset(anchorDate: sessionStart)
        previousEngineState = .valid
        decoStopTracker = .initial
        gasSwitchTracker = .initial
        gasSwitchTracker.bootstrap(bottomGasMixId: plan.activeGas.gasMixId)
        lastTickTimestamp = sessionStart
        var tracker = FullComputerDecoStopTracker.initial
        var localGasTracker = gasSwitchTracker
        var localSolverCache = FullComputerDecoSolver.Cache()
        snapshot = Self.makeSnapshot(
            engineState: .valid,
            tissueState: tissueState,
            plan: plan,
            depthMeters: 0,
            monotonicElapsedSeconds: 0,
            lastSampleTimestamp: nil,
            diagnostics: [],
            decoStopTracker: &tracker,
            gasSwitchTracker: &localGasTracker,
            decoSolverCache: &localSolverCache,
            deltaSeconds: 0
        )
        decoStopTracker = tracker
        gasSwitchTracker = localGasTracker
        decoSolverCache = localSolverCache
    }

    mutating func ingestSample(depthMeters: Double, timestamp: Date) -> Bool {
        guard depthMeters.isFinite, depthMeters >= 0 else {
            markUnavailable("non_finite_depth")
            return false
        }
        if let lastSampleTimestamp, timestamp < lastSampleTimestamp {
            markDegraded("non_monotonic_timestamp")
            return false
        }

        let delta = timestamp.timeIntervalSince(lastComputedTimestamp)
        if delta > 0 {
            advanceTissuesLinear(
                fromDepthMeters: lastDepthMeters,
                toDepthMeters: depthMeters,
                durationSeconds: delta
            )
            lastComputedTimestamp = timestamp
        }

        let depthDelta = abs(depthMeters - lastDepthMeters)
        lastDepthMeters = depthMeters
        lastSampleTimestamp = timestamp

        let nextState: FullComputerRuntimeEngineState
        if previousEngineState == .degraded || previousEngineState == .unavailable {
            nextState = .recovered
        } else {
            nextState = .valid
        }
        if depthDelta >= FullComputerRuntimeConfiguration.criticalDepthChangeMeters {
            finishIngestSampleRefresh(engineState: nextState, diagnostics: [])
        } else {
            finishIngestSampleRefresh(engineState: nextState, diagnostics: snapshot.diagnostics)
        }
        previousEngineState = nextState
        return true
    }

    private mutating func finishIngestSampleRefresh(
        engineState: FullComputerRuntimeEngineState,
        diagnostics: [String]
    ) {
#if DEBUG
        if testHookDefersSnapshotRefresh {
            testHookDeferredEngineState = engineState
            testHookDeferredDiagnostics = diagnostics
            return
        }
#endif
        refreshSnapshot(engineState: engineState, diagnostics: diagnostics)
    }

    /// Nominal 1 Hz tick using real elapsed time; integrates the full elapsed interval (sub-stepped).
    mutating func tick(now: Date = Date()) {
        let delta = now.timeIntervalSince(lastComputedTimestamp)
        guard delta > 0 else { return }

        advanceTissuesConstant(depthMeters: lastDepthMeters, durationSeconds: delta)
        lastComputedTimestamp = now

        let diagnostics: [String]
        let nextState: FullComputerRuntimeEngineState
        if delta > FullComputerRuntimeConfiguration.maxMissedTickSeconds {
            diagnostics = ["missed_tick:\(Int(delta.rounded()))s"]
            nextState = .degraded
        } else if delta > FullComputerRuntimeConfiguration.missedTickDegradedThresholdSeconds {
            diagnostics = ["missed_tick:\(Int(delta.rounded()))s"]
            nextState = .degraded
        } else if previousEngineState == .unavailable {
            diagnostics = snapshot.diagnostics
            nextState = .recovered
        } else if previousEngineState == .degraded {
            diagnostics = []
            nextState = .recovered
        } else {
            diagnostics = []
            nextState = .valid
        }
        finishTickRefresh(engineState: nextState, diagnostics: diagnostics)
        previousEngineState = nextState
    }

    private mutating func finishTickRefresh(
        engineState: FullComputerRuntimeEngineState,
        diagnostics: [String]
    ) {
#if DEBUG
        if testHookDefersSnapshotRefresh {
            testHookDeferredEngineState = engineState
            testHookDeferredDiagnostics = diagnostics
            return
        }
#endif
        refreshSnapshot(engineState: engineState, diagnostics: diagnostics)
    }

    mutating func changeGas(_ gas: BuhlmannGas, at timestamp: Date = Date()) {
        guard gas.isCompositionValid else {
            markDegraded("invalid_gas_switch")
            return
        }
        if timestamp > lastComputedTimestamp {
            let delta = timestamp.timeIntervalSince(lastComputedTimestamp)
            advanceTissuesConstant(depthMeters: lastDepthMeters, durationSeconds: delta)
            lastComputedTimestamp = timestamp
        }
        plan.activeGas = gas
        let switchSeconds = BuhlmannConstants.gasSwitchMinutes * 60.0
        tissueState = tissueState.loadedConstantDepth(
            depthMeters: lastDepthMeters,
            minutes: BuhlmannConstants.gasSwitchMinutes,
            gas: gas,
            environment: plan.plannerEnvironment
        )
        lastComputedTimestamp = lastComputedTimestamp.addingTimeInterval(switchSeconds)
        gasSwitchTracker.confirmedGasMixIds.insert(gas.gasMixId)
        gasSwitchTracker.activeMissedGasMixId = nil
        refreshSnapshot(engineState: .valid, diagnostics: ["gas_switch:\(gas.name)"])
        previousEngineState = .valid
    }

    mutating func confirmGasSwitch(to gasMixId: UUID, at timestamp: Date = Date()) -> Bool {
        guard !gasSwitchTracker.unavailableGasMixIds.contains(gasMixId) else { return false }
        guard let gas = plannedSwitchGases().first(where: { $0.gasMixId == gasMixId }) else { return false }
        guard FullComputerGasSwitchPolicy.isBreathable(
            gas,
            depthMeters: lastDepthMeters,
            environment: plan.plannerEnvironment
        ) else { return false }
        let fromID = plan.activeGas.gasMixId
        changeGas(gas, at: timestamp)
        gasSwitchTracker.events.append(
            FullComputerGasSwitchAuditEvent(
                timestamp: timestamp,
                kind: .confirmed,
                depthMeters: lastDepthMeters,
                fromGasMixId: fromID,
                toGasMixId: gasMixId
            )
        )
        return true
    }

    mutating func confirmOffPlanGasSwitch(_ gas: BuhlmannGas, at timestamp: Date = Date()) -> Bool {
        guard gas.isCompositionValid else { return false }
        guard FullComputerGasSwitchPolicy.isBreathable(
            gas,
            depthMeters: lastDepthMeters,
            environment: plan.plannerEnvironment
        ) else { return false }
        let fromID = plan.activeGas.gasMixId
        changeGas(gas, at: timestamp)
        gasSwitchTracker.events.append(
            FullComputerGasSwitchAuditEvent(
                timestamp: timestamp,
                kind: .offPlan,
                depthMeters: lastDepthMeters,
                fromGasMixId: fromID,
                toGasMixId: gas.gasMixId,
                note: gas.name
            )
        )
        return true
    }

    mutating func ignoreSuggestedGasSwitch(gasMixId: UUID, at timestamp: Date = Date()) {
        guard let gas = plannedSwitchGases().first(where: { $0.gasMixId == gasMixId }) else { return }
        let key = FullComputerGasSwitchTracker.opportunityKey(
            gasMixId: gasMixId,
            switchDepthMeters: gas.switchDepthMeters
        )
        gasSwitchTracker.ignoredOpportunityKeys.insert(key)
        gasSwitchTracker.activeMissedGasMixId = gasMixId
        gasSwitchTracker.events.append(
            FullComputerGasSwitchAuditEvent(
                timestamp: timestamp,
                kind: .ignored,
                depthMeters: lastDepthMeters,
                fromGasMixId: plan.activeGas.gasMixId,
                toGasMixId: gasMixId
            )
        )
        refreshSnapshot(engineState: snapshot.engineState, diagnostics: snapshot.diagnostics)
    }

    mutating func dismissMissedGasSwitchPrompt() {
        gasSwitchTracker.activeMissedGasMixId = nil
        refreshSnapshot(engineState: snapshot.engineState, diagnostics: snapshot.diagnostics)
    }

    mutating func markGasUnavailable(gasMixId: UUID, at timestamp: Date = Date()) {
        gasSwitchTracker.unavailableGasMixIds.insert(gasMixId)
        gasSwitchTracker.events.append(
            FullComputerGasSwitchAuditEvent(
                timestamp: timestamp,
                kind: .unavailable,
                depthMeters: lastDepthMeters,
                fromGasMixId: plan.activeGas.gasMixId,
                toGasMixId: gasMixId
            )
        )
        if gasSwitchTracker.activeMissedGasMixId == gasMixId {
            gasSwitchTracker.activeMissedGasMixId = nil
        }
        refreshSnapshot(engineState: snapshot.engineState, diagnostics: snapshot.diagnostics)
    }

    private func plannedSwitchGases() -> [BuhlmannGas] {
        plan.decoGases + plan.travelGases
    }

    mutating func replaySamples(_ samples: [DiveSample]) {
        for sample in samples.sorted(by: { $0.timestamp < $1.timestamp }) {
            _ = ingestSample(depthMeters: sample.depthMeters, timestamp: sample.timestamp)
        }
    }

    var runtimePlan: FullComputerRuntimePlan { plan }
    var persistedDecoStopTracker: FullComputerDecoStopTracker { decoStopTracker }

    mutating func exportCheckpointPayload(
        sessionID: UUID,
        watchDivingMode: String,
        savedAt: Date = Date()
    ) -> FullComputerRuntimeCheckpointPayload {
        FullComputerRuntimeCheckpointPayload(
            schemaVersion: FullComputerRuntimeCheckpointPayload.currentSchemaVersion,
            sessionID: sessionID,
            watchDivingMode: watchDivingMode,
            plan: plan,
            tissueState: tissueState,
            gasSwitchTracker: gasSwitchTracker,
            decoStopTracker: decoStopTracker,
            lastDepthMeters: lastDepthMeters,
            lastSampleTimestamp: lastSampleTimestamp,
            lastComputedTimestamp: lastComputedTimestamp,
            monotonicClock: monotonicClock.exportSnapshot(),
            previousEngineState: previousEngineState,
            snapshotNDLMinutes: snapshot.ndlMinutes,
            snapshotCeilingMeters: snapshot.operationalCeilingMeters,
            snapshotTTSMinutes: snapshot.ttsMinutes,
            snapshotStopState: snapshot.decoPresentation.stopState,
            snapshotEngagedStopDepthMeters: decoStopTracker.engagedStopDepthMeters,
            wallClockSavedAt: savedAt
        )
    }

    mutating func exportCheckpoint(sessionID: UUID, watchDivingMode: String) throws -> FullComputerRuntimeCheckpoint {
        let payload = exportCheckpointPayload(sessionID: sessionID, watchDivingMode: watchDivingMode)
        return try FullComputerRuntimeCheckpointCodec.make(from: payload)
    }

    static func restoreEngine(
        from checkpoint: FullComputerRuntimeCheckpoint,
        sessionStart: Date
    ) throws -> FullComputerRuntimeEngine {
        try FullComputerRuntimeCheckpointCodec.validate(checkpoint)
        let readiness = canStart(plan: checkpoint.payload.plan)
        guard readiness.ready else {
            throw FullComputerRuntimeStartupFailure.invalidPlan(readiness.diagnostics)
        }
        return FullComputerRuntimeEngine(restoredFrom: checkpoint.payload, sessionStart: sessionStart)
    }

    mutating func applyConservativeCatchUp(now: Date = Date()) {
        let elapsed = now.timeIntervalSince(lastComputedTimestamp)
        guard elapsed > 0 else { return }
        advanceTissuesConstant(depthMeters: lastDepthMeters, durationSeconds: elapsed)
        lastComputedTimestamp = now
        let degraded = elapsed > FullComputerRuntimeConfiguration.maxMissedTickSeconds
        refreshSnapshot(
            engineState: degraded ? .degraded : snapshot.engineState,
            diagnostics: degraded ? ["missed_tick:\(Int(elapsed.rounded()))s"] : snapshot.diagnostics
        )
        if degraded { previousEngineState = .degraded }
    }

    mutating func replaySamplesAfterCheckpoint(_ samples: [DiveSample], checkpointTimestamp: Date?) {
        for sample in samples.sorted(by: { $0.timestamp < $1.timestamp }) {
            if let checkpointTimestamp, sample.timestamp <= checkpointTimestamp { continue }
            _ = ingestSample(depthMeters: sample.depthMeters, timestamp: sample.timestamp)
        }
    }

    func recoverySelfCheckDiagnostics(lastKnownDepthMeters: Double) -> [String] {
        var diagnostics = plan.validate()
        if lastKnownDepthMeters > 1,
           tissueState == BuhlmannTissueState.airSaturated(surfacePressureBar: plan.plannerEnvironment.surfacePressureBar) {
            diagnostics.append("recovery_tissue_reset_detected")
        }
        return diagnostics
    }

    private init(restoredFrom payload: FullComputerRuntimeCheckpointPayload, sessionStart: Date) {
        plan = payload.plan
        tissueState = payload.tissueState
        lastDepthMeters = payload.lastDepthMeters
        lastSampleTimestamp = payload.lastSampleTimestamp
        lastComputedTimestamp = payload.lastComputedTimestamp
        monotonicClock = MonotonicElapsedClock()
        monotonicClock.restore(from: payload.monotonicClock)
        previousEngineState = payload.previousEngineState
        decoStopTracker = payload.decoStopTracker
        gasSwitchTracker = payload.gasSwitchTracker
        lastTickTimestamp = payload.lastComputedTimestamp
        var tracker = payload.decoStopTracker
        var gasTracker = payload.gasSwitchTracker
        var localSolverCache = FullComputerDecoSolver.Cache()
        snapshot = Self.makeSnapshot(
            engineState: payload.previousEngineState,
            tissueState: payload.tissueState,
            plan: payload.plan,
            depthMeters: payload.lastDepthMeters,
            monotonicElapsedSeconds: payload.monotonicClock.lastElapsed,
            lastSampleTimestamp: payload.lastSampleTimestamp,
            diagnostics: payload.previousEngineState == .degraded ? ["restored_degraded"] : [],
            decoStopTracker: &tracker,
            gasSwitchTracker: &gasTracker,
            decoSolverCache: &localSolverCache,
            deltaSeconds: 0
        )
        decoStopTracker = tracker
        gasSwitchTracker = gasTracker
        decoSolverCache = localSolverCache
        _ = sessionStart
    }

    // MARK: - Tissue integration

    private mutating func advanceTissuesLinear(
        fromDepthMeters: Double,
        toDepthMeters: Double,
        durationSeconds: TimeInterval
    ) {
        guard durationSeconds > 0 else { return }
        var elapsed: TimeInterval = 0
        while elapsed < durationSeconds {
            let stepDuration = min(FullComputerRuntimeConfiguration.maxSubStepSeconds, durationSeconds - elapsed)
            let stepEnd = elapsed + stepDuration
            let startFraction = elapsed / durationSeconds
            let endFraction = stepEnd / durationSeconds
            let stepStartDepth = fromDepthMeters + (toDepthMeters - fromDepthMeters) * startFraction
            let stepEndDepth = fromDepthMeters + (toDepthMeters - fromDepthMeters) * endFraction
            tissueState = tissueState.loadedLinearDepth(
                fromDepthMeters: stepStartDepth,
                toDepthMeters: stepEndDepth,
                minutes: stepDuration / 60.0,
                gas: plan.activeGas,
                environment: plan.plannerEnvironment
            )
            elapsed = stepEnd
        }
    }

    private mutating func advanceTissuesConstant(depthMeters: Double, durationSeconds: TimeInterval) {
        guard durationSeconds > 0 else { return }
        var remaining = durationSeconds
        while remaining > 0 {
            let step = min(remaining, FullComputerRuntimeConfiguration.maxSubStepSeconds)
            tissueState = tissueState.loadedConstantDepth(
                depthMeters: depthMeters,
                minutes: step / 60.0,
                gas: plan.activeGas,
                environment: plan.plannerEnvironment
            )
            remaining -= step
        }
    }

    private mutating func refreshSnapshot(
        engineState: FullComputerRuntimeEngineState,
        diagnostics: [String]
    ) {
        let delta = max(0, lastComputedTimestamp.timeIntervalSince(lastTickTimestamp))
        lastTickTimestamp = lastComputedTimestamp
        snapshot = Self.makeSnapshot(
            engineState: engineState,
            tissueState: tissueState,
            plan: plan,
            depthMeters: lastDepthMeters,
            monotonicElapsedSeconds: monotonicClock.elapsed(),
            lastSampleTimestamp: lastSampleTimestamp,
            diagnostics: diagnostics,
            decoStopTracker: &decoStopTracker,
            gasSwitchTracker: &gasSwitchTracker,
            decoSolverCache: &decoSolverCache,
            deltaSeconds: delta
        )
    }

    private mutating func markDegraded(_ code: String) {
        refreshSnapshot(engineState: .degraded, diagnostics: [code])
        previousEngineState = .degraded
    }

    private mutating func markUnavailable(_ code: String) {
        refreshSnapshot(engineState: .unavailable, diagnostics: [code])
        previousEngineState = .unavailable
    }

    private static func makeSnapshot(
        engineState: FullComputerRuntimeEngineState,
        tissueState: BuhlmannTissueState,
        plan: FullComputerRuntimePlan,
        depthMeters: Double,
        monotonicElapsedSeconds: TimeInterval,
        lastSampleTimestamp: Date?,
        diagnostics: [String],
        decoStopTracker: inout FullComputerDecoStopTracker,
        gasSwitchTracker: inout FullComputerGasSwitchTracker,
        decoSolverCache: inout FullComputerDecoSolver.Cache,
        deltaSeconds: TimeInterval
    ) -> FullComputerRuntimeSnapshot {
        let projectionGases = FullComputerGasSwitchPolicy.projectionGases(from: plan, tracker: gasSwitchTracker)
        let projection = BuhlmannEngine.runtimeProjection(
            tissueState: tissueState,
            depthMeters: depthMeters,
            gas: plan.activeGas,
            gfLow: plan.gfLow,
            gfHigh: plan.gfHigh,
            plannerEnvironment: plan.plannerEnvironment,
            travelGases: projectionGases.travel,
            decoGases: projectionGases.deco,
            ascentRateMetersPerMinute: plan.ascentRateMetersPerMinute,
            stopIntervalMeters: plan.stopIntervalMeters
        )
        let ambient = AmbientPressureModel.ambientPressureBar(
            depthMeters: depthMeters,
            environment: plan.plannerEnvironment
        ) ?? plan.plannerEnvironment.surfacePressureBar
        let runtimeMinutes = max(0, Int(monotonicElapsedSeconds / 60.0))
        var projectionPlan = plan
        projectionPlan.travelGases = projectionGases.travel
        projectionPlan.decoGases = projectionGases.deco
        let timingDegraded = engineState == .degraded || engineState == .unavailable
            || diagnostics.contains(where: { $0.hasPrefix("missed_tick:") })
        let solverInput = FullComputerDecoSolverInput(
            tissueState: tissueState,
            depthMeters: depthMeters,
            plan: projectionPlan,
            runtimeMinutes: runtimeMinutes
        )
        var solverCacheBox: FullComputerDecoSolver.Cache? = decoSolverCache
        let basePresentation = FullComputerDecoSolver.solve(
            input: solverInput,
            projection: projection,
            cache: &solverCacheBox,
            timingDegraded: timingDegraded
        )
        decoSolverCache = solverCacheBox ?? decoSolverCache
        let decoRequired = basePresentation.mode == .decompression
        let machine = FullComputerDecoStopStateMachine.evaluate(
            input: FullComputerDecoStopMachineInput(
                depthMeters: depthMeters,
                stopDepthMeters: basePresentation.nextStopDepthMeters,
                modelRemainingMinutes: basePresentation.nextStopMinutes,
                remainingStopCount: basePresentation.remainingStopCount,
                ceilingViolation: basePresentation.ceilingViolation,
                ceilingMetersExact: basePresentation.ceilingMetersExact,
                decoRequired: decoRequired,
                deltaSeconds: deltaSeconds
            ),
            tracker: decoStopTracker
        )
        decoStopTracker = machine.tracker
        let decoPresentation = FullComputerDecoSolver.applyingStopMachine(basePresentation, machine: machine)
        let planned = plan.decoGases + plan.travelGases
        let gasSwitchSurface = FullComputerGasSwitchPolicy.evaluateSurface(
            activeGas: plan.activeGas,
            depthMeters: depthMeters,
            plannedGases: planned,
            tracker: gasSwitchTracker,
            environment: plan.plannerEnvironment
        )
        let runtimeGasRows = FullComputerGasSwitchPolicy.runtimeGasRows(
            activeGas: plan.activeGas,
            depthMeters: depthMeters,
            plannedGases: planned,
            tracker: gasSwitchTracker,
            environment: plan.plannerEnvironment
        )
        return FullComputerRuntimeSnapshot(
            engineState: engineState,
            tissueState: tissueState,
            activeGas: plan.activeGas,
            gfLow: plan.gfLow,
            gfHigh: plan.gfHigh,
            monotonicElapsedSeconds: monotonicElapsedSeconds,
            lastSampleTimestamp: lastSampleTimestamp,
            depthMeters: depthMeters,
            ambientPressureBar: ambient,
            ndlMinutes: projection.ndlMinutes,
            rawCeilingMeters: projection.rawCeilingMeters,
            operationalCeilingMeters: projection.operationalCeilingMeters,
            controllingCompartmentRaw: projection.rawCeiling.controllingCompartment,
            controllingCompartmentOperational: projection.operationalCeiling.controllingCompartment,
            ttsMinutes: projection.ttsMinutes,
            stops: projection.stops,
            modelState: projection.modelState,
            diagnostics: diagnostics,
            decoPresentation: decoPresentation,
            gasSwitchSurface: gasSwitchSurface,
            runtimeGasRows: runtimeGasRows,
            gasSwitchAuditEvents: gasSwitchTracker.events
        )
    }
}
