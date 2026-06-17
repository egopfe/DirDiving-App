import Foundation

enum CCRPlannerEngine {
    struct EngineOutput {
        let segments: [BuhlmannRuntimeSegment]
        let scheduleRows: [CCRScheduleRow]
        let stops: [BuhlmannDecompressionStop]
        let decoStops: [DecoStop]
        let tissueHistory: BuhlmannTissueHistory
        let ttsMinutes: Int
        let totalRuntimeMinutes: Int
        let timeline: [CCRTimelineSample]
        let exposureSegments: [(kind: DiveSegmentKind, fromDepth: Double, toDepth: Double, minutes: Double, setpointBar: Double)]
        let modelState: BuhlmannModelState
        let finalTissueState: BuhlmannTissueState
    }

    static func plan(input: CCRPlanInput, environment: PlannerEnvironment) -> EngineOutput {
        let profile = input.setpointProfile
        let diluent = input.diluent
        var runtimeSegments: [BuhlmannRuntimeSegment] = []
        var scheduleRows: [CCRScheduleRow] = []
        var exposureSegments: [(kind: DiveSegmentKind, fromDepth: Double, toDepth: Double, minutes: Double, setpointBar: Double)] = []
        var runtimeMinutes = 0.0
        var timeline: [CCRTimelineSample] = []

        func activeSetpoint(at depth: Double) -> Double {
            profile.activeSetpointBar(depthMeters: depth)
        }

        func appendTimeline(depth: Double, setpoint: Double, minutes: Double) {
            guard let inspired = CCRInspiredGasModel.inspiredPressures(
                depthMeters: depth,
                setpointBar: setpoint,
                diluent: diluent,
                environment: environment
            ) else { return }
            let end = CCRInspiredGasModel.endMeters(depthMeters: depth, setpointBar: setpoint, diluent: diluent, environment: environment)
            let density = CCRGasDensityEstimator.estimate(
                setpointBar: setpoint,
                diluent: diluent,
                depthMeters: depth,
                environment: environment
            )
            timeline.append(
                CCRTimelineSample(
                    runtimeMinutes: runtimeMinutes,
                    depthMeters: depth,
                    ppO2Bar: inspired.ppO2,
                    ppN2Bar: inspired.ppN2,
                    endMeters: end,
                    gasDensityResult: density
                )
            )
        }

        func recordSegment(
            kind: DiveSegmentKind,
            fromDepth: Double,
            toDepth: Double,
            minutes: Double,
            setpoint: Double,
            note: String,
            ceiling: Double? = nil,
            gf: Double? = nil
        ) {
            guard minutes > 0 else { return }
            runtimeMinutes += minutes
            appendTimeline(depth: toDepth, setpoint: setpoint, minutes: minutes)
            let labelGas = CCRInspiredGasModel.labelGas(
                diluent: diluent,
                setpointBar: setpoint,
                depthMeters: toDepth,
                environment: environment
            )
            runtimeSegments.append(
                BuhlmannRuntimeSegment(kind: kind, depthMeters: toDepth, minutes: minutes, gas: labelGas, note: note)
            )
            exposureSegments.append((kind, fromDepth, toDepth, minutes, setpoint))
            if let inspired = CCRInspiredGasModel.inspiredPressures(
                depthMeters: toDepth,
                setpointBar: setpoint,
                diluent: diluent,
                environment: environment
            ) {
                scheduleRows.append(
                    CCRScheduleRow(
                        runtimeMinutes: runtimeMinutes,
                        depthMeters: toDepth,
                        activeSetpointBar: setpoint,
                        diluentLabel: diluent.label,
                        ppO2Bar: inspired.ppO2,
                        ppN2Bar: inspired.ppN2,
                        ppHeBar: inspired.ppHe,
                        ceilingMeters: ceiling,
                        gradientFactor: gf,
                        phase: kind,
                        note: note
                    )
                )
            }
        }

        var state = BuhlmannTissueState.airSaturated(surfacePressureBar: environment.surfacePressureBar)
        var currentDepth = 0.0

        // Descent with setpoint switching at switch depth
        let switchDepth = min(profile.switchDepthMeters, input.maxDepthMeters)
        if switchDepth > 0.5 {
            let lowSP = profile.lowSetpoint
            let descentMinutes = max(0.1, switchDepth / input.descentRateMetersPerMinute)
            state = state.ccrLoadedLinearDepth(
                fromDepthMeters: 0,
                toDepthMeters: switchDepth,
                minutes: descentMinutes,
                diluent: diluent,
                setpointBar: lowSP,
                environment: environment
            )
            recordSegment(kind: .descent, fromDepth: 0, toDepth: switchDepth, minutes: descentMinutes, setpoint: lowSP, note: "CCR descent (low setpoint)")
            currentDepth = switchDepth
            recordSegment(kind: .gasSwitch, fromDepth: switchDepth, toDepth: switchDepth, minutes: BuhlmannConstants.gasSwitchMinutes, setpoint: profile.highSetpoint, note: "Setpoint switch")
            state = state.ccrLoadedConstantDepth(
                depthMeters: switchDepth,
                minutes: BuhlmannConstants.gasSwitchMinutes,
                diluent: diluent,
                setpointBar: profile.highSetpoint,
                environment: environment
            )
            runtimeMinutes += BuhlmannConstants.gasSwitchMinutes
        }

        if currentDepth < input.maxDepthMeters - 0.01 {
            let highSP = profile.highSetpoint
            let remaining = input.maxDepthMeters - currentDepth
            let descentMinutes = max(0.1, remaining / input.descentRateMetersPerMinute)
            state = state.ccrLoadedLinearDepth(
                fromDepthMeters: currentDepth,
                toDepthMeters: input.maxDepthMeters,
                minutes: descentMinutes,
                diluent: diluent,
                setpointBar: highSP,
                environment: environment
            )
            recordSegment(kind: .descent, fromDepth: currentDepth, toDepth: input.maxDepthMeters, minutes: descentMinutes, setpoint: highSP, note: "CCR descent (high setpoint)")
            currentDepth = input.maxDepthMeters
        }

        let bottomSetpoint = activeSetpoint(at: currentDepth)
        state = state.ccrLoadedConstantDepth(
            depthMeters: currentDepth,
            minutes: input.bottomTimeMinutes,
            diluent: diluent,
            setpointBar: bottomSetpoint,
            environment: environment
        )
        recordSegment(kind: .bottom, fromDepth: currentDepth, toDepth: currentDepth, minutes: input.bottomTimeMinutes, setpoint: bottomSetpoint, note: "CCR bottom")

        let deco = decompressionSchedule(
            input: input,
            environment: environment,
            stateAtBottom: state,
            currentDepth: currentDepth,
            runtimeMinutes: &runtimeMinutes,
            runtimeSegments: &runtimeSegments,
            scheduleRows: &scheduleRows,
            exposureSegments: &exposureSegments,
            timeline: &timeline
        )

        let firstStopDepth = deco.stops.first?.depthMeters ?? 0
        let tissueHistory = CCRTissueHistorySampler.sample(
            input: input,
            environment: environment,
            segments: exposureSegments,
            finalState: deco.state,
            firstStopDepthMeters: firstStopDepth
        )

        let decoStops = deco.stops.map {
            DecoStop(
                depthMeters: $0.depthMeters,
                minutes: $0.minutes,
                gas: "CCR \(diluent.label)",
                ppO2: $0.ppO2,
                maxPPO2: $0.maxPPO2
            )
        }

        return EngineOutput(
            segments: runtimeSegments,
            scheduleRows: scheduleRows,
            stops: deco.stops,
            decoStops: decoStops,
            tissueHistory: tissueHistory,
            ttsMinutes: Int(ceil(deco.elapsedMinutes)),
            totalRuntimeMinutes: Int(ceil(runtimeMinutes)),
            timeline: timeline,
            exposureSegments: exposureSegments,
            modelState: .validReference,
            finalTissueState: deco.state
        )
    }

    private struct DecoResult {
        var stops: [BuhlmannDecompressionStop]
        var elapsedMinutes: Double
        var state: BuhlmannTissueState
    }

    private static func decompressionSchedule(
        input: CCRPlanInput,
        environment: PlannerEnvironment,
        stateAtBottom: BuhlmannTissueState,
        currentDepth: Double,
        runtimeMinutes: inout Double,
        runtimeSegments: inout [BuhlmannRuntimeSegment],
        scheduleRows: inout [CCRScheduleRow],
        exposureSegments: inout [(kind: DiveSegmentKind, fromDepth: Double, toDepth: Double, minutes: Double, setpointBar: Double)],
        timeline: inout [CCRTimelineSample]
    ) -> DecoResult {
        let profile = input.setpointProfile
        let diluent = input.diluent
        let gfLow = input.gfLow / 100.0
        let firstCeiling = stateAtBottom.ceiling(gf: gfLow, environment: environment).depthMeters

        func setpoint(at depth: Double, isAscent: Bool = false) -> Double {
            profile.activeSetpointBar(depthMeters: depth, isAscent: isAscent)
        }

        guard firstCeiling > 0.01 else {
            return ascendToSurface(
                input: input,
                environment: environment,
                state: stateAtBottom,
                currentDepth: currentDepth,
                runtimeMinutes: &runtimeMinutes,
                runtimeSegments: &runtimeSegments,
                scheduleRows: &scheduleRows,
                exposureSegments: &exposureSegments,
                timeline: &timeline,
                elapsed: 0
            )
        }

        let firstStopDepth = min(currentDepth, ceilToStop(firstCeiling, interval: BuhlmannConstants.stopIntervalMeters))
        var state = stateAtBottom
        var depth = currentDepth
        var stopDepth = firstStopDepth
        var stops: [BuhlmannDecompressionStop] = []
        var elapsed = 0.0

        while stopDepth > 0.01 {
            if depth > stopDepth {
                let sp = setpoint(at: depth, isAscent: true)
                let minutes = max(0.1, (depth - stopDepth) / input.ascentRateMetersPerMinute)
                state = state.ccrLoadedLinearDepth(
                    fromDepthMeters: depth,
                    toDepthMeters: stopDepth,
                    minutes: minutes,
                    diluent: diluent,
                    setpointBar: sp,
                    environment: environment
                )
                runtimeMinutes += minutes
                elapsed += minutes
                let gas = CCRInspiredGasModel.labelGas(diluent: diluent, setpointBar: sp, depthMeters: stopDepth, environment: environment)
                runtimeSegments.append(BuhlmannRuntimeSegment(kind: .ascent, depthMeters: stopDepth, minutes: minutes, gas: gas, note: "CCR ascent"))
                exposureSegments.append((.ascent, depth, stopDepth, minutes, sp))
                depth = stopDepth
            }

            let nextDepth = max(0, stopDepth - BuhlmannConstants.stopIntervalMeters)
            var stopMinutes = 0
            while true {
                let gf = BuhlmannEngine.gfAtDepth(depthMeters: nextDepth, firstStopDepthMeters: firstStopDepth, gfLow: input.gfLow, gfHigh: input.gfHigh)
                let ceiling = state.ceiling(gf: gf, environment: environment).depthMeters
                if ceiling <= nextDepth + 0.05 { break }
                if stopMinutes >= BuhlmannConstants.maxStopMinutesPerDepth { break }
                let sp = setpoint(at: stopDepth)
                state = state.ccrLoadedConstantDepth(depthMeters: stopDepth, minutes: 1, diluent: diluent, setpointBar: sp, environment: environment)
                stopMinutes += 1
                elapsed += 1
                runtimeMinutes += 1
            }

            if stopMinutes > 0 {
                let sp = setpoint(at: stopDepth)
                let gf = BuhlmannEngine.gfAtDepth(depthMeters: stopDepth, firstStopDepthMeters: firstStopDepth, gfLow: input.gfLow, gfHigh: input.gfHigh)
                let gas = CCRInspiredGasModel.labelGas(diluent: diluent, setpointBar: sp, depthMeters: stopDepth, environment: environment)
                let ppO2 = sp
                stops.append(
                    BuhlmannDecompressionStop(depthMeters: stopDepth, minutes: stopMinutes, gas: gas, ppO2: ppO2, maxPPO2: sp + 0.2, gradientFactor: gf)
                )
                runtimeSegments.append(BuhlmannRuntimeSegment(kind: .stop, depthMeters: stopDepth, minutes: Double(stopMinutes), gas: gas, note: "CCR deco stop"))
                exposureSegments.append((.stop, stopDepth, stopDepth, Double(stopMinutes), sp))
                if let inspired = CCRInspiredGasModel.inspiredPressures(depthMeters: stopDepth, setpointBar: sp, diluent: diluent, environment: environment) {
                    scheduleRows.append(
                        CCRScheduleRow(
                            runtimeMinutes: runtimeMinutes,
                            depthMeters: stopDepth,
                            activeSetpointBar: sp,
                            diluentLabel: diluent.label,
                            ppO2Bar: inspired.ppO2,
                            ppN2Bar: inspired.ppN2,
                            ppHeBar: inspired.ppHe,
                            ceilingMeters: state.ceiling(gf: gf, environment: environment).depthMeters,
                            gradientFactor: gf,
                            phase: .stop,
                            note: "CCR deco stop"
                        )
                    )
                }
            }

            depth = stopDepth
            stopDepth = nextDepth
        }

        return ascendToSurface(
            input: input,
            environment: environment,
            state: state,
            currentDepth: depth,
            runtimeMinutes: &runtimeMinutes,
            runtimeSegments: &runtimeSegments,
            scheduleRows: &scheduleRows,
            exposureSegments: &exposureSegments,
            timeline: &timeline,
            elapsed: elapsed,
            stops: stops
        )
    }

    private static func ascendToSurface(
        input: CCRPlanInput,
        environment: PlannerEnvironment,
        state: BuhlmannTissueState,
        currentDepth: Double,
        runtimeMinutes: inout Double,
        runtimeSegments: inout [BuhlmannRuntimeSegment],
        scheduleRows: inout [CCRScheduleRow],
        exposureSegments: inout [(kind: DiveSegmentKind, fromDepth: Double, toDepth: Double, minutes: Double, setpointBar: Double)],
        timeline: inout [CCRTimelineSample],
        elapsed: Double,
        stops: [BuhlmannDecompressionStop] = []
    ) -> DecoResult {
        var state = state
        let diluent = input.diluent
        let profile = input.setpointProfile
        var elapsed = elapsed
        if currentDepth > 0.01 {
            let sp = profile.activeSetpointBar(depthMeters: currentDepth, isAscent: true)
            let minutes = max(0.1, currentDepth / input.ascentRateMetersPerMinute)
            state = state.ccrLoadedLinearDepth(
                fromDepthMeters: currentDepth,
                toDepthMeters: 0,
                minutes: minutes,
                diluent: diluent,
                setpointBar: sp,
                environment: environment
            )
            runtimeMinutes += minutes
            elapsed += minutes
            let gas = CCRInspiredGasModel.labelGas(diluent: diluent, setpointBar: sp, depthMeters: 0, environment: environment)
            runtimeSegments.append(BuhlmannRuntimeSegment(kind: .ascent, depthMeters: 0, minutes: minutes, gas: gas, note: "CCR ascent to surface"))
            exposureSegments.append((.ascent, currentDepth, 0, minutes, sp))
        }
        return DecoResult(stops: stops, elapsedMinutes: elapsed, state: state)
    }

    private static func ceilToStop(_ depth: Double, interval: Double) -> Double {
        guard interval > 0 else { return depth }
        return ceil(depth / interval) * interval
    }
}
