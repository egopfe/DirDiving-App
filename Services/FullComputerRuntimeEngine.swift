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

    static func canStart(
        plan: FullComputerRuntimePlan = .defaultAirGF3070,
        algorithmSelfCheckFailures: [String] = DiveAlgorithmSelfCheck.failures()
    ) -> (ready: Bool, diagnostics: [String]) {
        var diagnostics = plan.validate()
        if !algorithmSelfCheckFailures.isEmpty {
            diagnostics.append(contentsOf: algorithmSelfCheckFailures.map { "self_check:\($0)" })
        }
        return (diagnostics.isEmpty, diagnostics)
    }

    init(plan: FullComputerRuntimePlan = .defaultAirGF3070, sessionStart: Date) throws {
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
        snapshot = Self.makeSnapshot(
            engineState: .valid,
            tissueState: tissueState,
            plan: plan,
            depthMeters: 0,
            monotonicElapsedSeconds: 0,
            lastSampleTimestamp: nil,
            diagnostics: []
        )
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
            refreshSnapshot(engineState: nextState, diagnostics: [])
        } else {
            refreshSnapshot(engineState: nextState, diagnostics: snapshot.diagnostics)
        }
        previousEngineState = nextState
        return true
    }

    /// Nominal 1 Hz tick using real elapsed time; applies constant-depth load when no fresh sample arrives.
    mutating func tick(now: Date = Date()) {
        let delta = now.timeIntervalSince(lastComputedTimestamp)
        guard delta > 0 else { return }

        let capped = min(delta, FullComputerRuntimeConfiguration.maxMissedTickSeconds)
        advanceTissuesConstant(depthMeters: lastDepthMeters, durationSeconds: capped)
        lastComputedTimestamp = lastComputedTimestamp.addingTimeInterval(capped)

        let diagnostics: [String]
        let nextState: FullComputerRuntimeEngineState
        if delta > FullComputerRuntimeConfiguration.nominalTickSeconds * 2 {
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
        refreshSnapshot(engineState: nextState, diagnostics: diagnostics)
        previousEngineState = nextState
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
        refreshSnapshot(engineState: .valid, diagnostics: ["gas_switch:\(gas.name)"])
        previousEngineState = .valid
    }

    mutating func replaySamples(_ samples: [DiveSample]) {
        for sample in samples.sorted(by: { $0.timestamp < $1.timestamp }) {
            _ = ingestSample(depthMeters: sample.depthMeters, timestamp: sample.timestamp)
        }
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
        snapshot = Self.makeSnapshot(
            engineState: engineState,
            tissueState: tissueState,
            plan: plan,
            depthMeters: lastDepthMeters,
            monotonicElapsedSeconds: monotonicClock.elapsed(),
            lastSampleTimestamp: lastSampleTimestamp,
            diagnostics: diagnostics
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
        diagnostics: [String]
    ) -> FullComputerRuntimeSnapshot {
        let projection = BuhlmannEngine.runtimeProjection(
            tissueState: tissueState,
            depthMeters: depthMeters,
            gas: plan.activeGas,
            gfLow: plan.gfLow,
            gfHigh: plan.gfHigh,
            plannerEnvironment: plan.plannerEnvironment,
            travelGases: plan.travelGases,
            decoGases: plan.decoGases,
            ascentRateMetersPerMinute: plan.ascentRateMetersPerMinute,
            stopIntervalMeters: plan.stopIntervalMeters
        )
        let ambient = AmbientPressureModel.ambientPressureBar(
            depthMeters: depthMeters,
            environment: plan.plannerEnvironment
        ) ?? plan.plannerEnvironment.surfacePressureBar
        let runtimeMinutes = max(0, Int(monotonicElapsedSeconds / 60.0))
        let decoPresentation = FullComputerDecoSolver.solve(
            input: FullComputerDecoSolverInput(
                tissueState: tissueState,
                depthMeters: depthMeters,
                plan: plan,
                runtimeMinutes: runtimeMinutes
            )
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
            decoPresentation: decoPresentation
        )
    }
}
