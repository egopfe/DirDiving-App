import Foundation

/// Samples CCR tissue history using the same `ccrLoaded*` path as `CCRPlannerEngine` (not OC `labelGas` replay).
enum CCRTissueHistorySampler {
    static let sampleIntervalMinutes = BuhlmannTissueHistorySampler.sampleIntervalMinutes

    static func sample(
        input: CCRPlanInput,
        environment: PlannerEnvironment,
        segments: [(kind: DiveSegmentKind, fromDepth: Double, toDepth: Double, minutes: Double, setpointBar: Double)],
        finalState: BuhlmannTissueState,
        firstStopDepthMeters: Double
    ) -> BuhlmannTissueHistory {
        guard !segments.isEmpty else { return .empty }

        var samples: [BuhlmannTissueHistorySample] = []
        var state = BuhlmannTissueState.airSaturated(surfacePressureBar: environment.surfacePressureBar)
        var elapsed = 0.0
        let diluent = input.diluent

        recordSamples(
            state: state,
            depthMeters: 0,
            setpointBar: input.setpointProfile.lowSetpoint,
            diluent: diluent,
            elapsedMinutes: elapsed,
            input: input,
            environment: environment,
            firstStopDepthMeters: firstStopDepthMeters,
            into: &samples
        )

        for segment in segments {
            switch segment.kind {
            case .descent, .ascent:
                loadLinearWithSampling(
                    state: &state,
                    fromDepthMeters: segment.fromDepth,
                    toDepthMeters: segment.toDepth,
                    totalMinutes: segment.minutes,
                    setpointBar: segment.setpointBar,
                    diluent: diluent,
                    elapsed: &elapsed,
                    input: input,
                    environment: environment,
                    firstStopDepthMeters: firstStopDepthMeters,
                    samples: &samples
                )
            case .bottom, .stop, .gasSwitch:
                loadConstantWithSampling(
                    state: &state,
                    depthMeters: segment.toDepth,
                    totalMinutes: segment.minutes,
                    setpointBar: segment.setpointBar,
                    diluent: diluent,
                    elapsed: &elapsed,
                    input: input,
                    environment: environment,
                    firstStopDepthMeters: firstStopDepthMeters,
                    samples: &samples
                )
            }
        }

        _ = finalState

        return BuhlmannTissueHistory(
            samples: samples,
            groupedPoints: BuhlmannTissueHistorySampler.groupedPoints(from: samples),
            aggregationMethod: BuhlmannTissueHistorySampler.aggregationMethod
        )
    }

    /// Replays CCR exposure segments without sampling — used by tests to verify trace alignment.
    static func replayFinalState(
        input: CCRPlanInput,
        environment: PlannerEnvironment,
        segments: [(kind: DiveSegmentKind, fromDepth: Double, toDepth: Double, minutes: Double, setpointBar: Double)]
    ) -> BuhlmannTissueState {
        var state = BuhlmannTissueState.airSaturated(surfacePressureBar: environment.surfacePressureBar)
        let diluent = input.diluent
        for segment in segments {
            switch segment.kind {
            case .descent, .ascent:
                state = state.ccrLoadedLinearDepth(
                    fromDepthMeters: segment.fromDepth,
                    toDepthMeters: segment.toDepth,
                    minutes: segment.minutes,
                    diluent: diluent,
                    setpointBar: segment.setpointBar,
                    environment: environment
                )
            case .bottom, .stop, .gasSwitch:
                state = state.ccrLoadedConstantDepth(
                    depthMeters: segment.toDepth,
                    minutes: segment.minutes,
                    diluent: diluent,
                    setpointBar: segment.setpointBar,
                    environment: environment
                )
            }
        }
        return state
    }

    private static func loadConstantWithSampling(
        state: inout BuhlmannTissueState,
        depthMeters: Double,
        totalMinutes: Double,
        setpointBar: Double,
        diluent: CCRDiluent,
        elapsed: inout Double,
        input: CCRPlanInput,
        environment: PlannerEnvironment,
        firstStopDepthMeters: Double,
        samples: inout [BuhlmannTissueHistorySample]
    ) {
        guard totalMinutes.isFinite, totalMinutes > 0 else { return }
        var remaining = totalMinutes
        while remaining > 0.000_1 {
            let step = min(sampleIntervalMinutes, remaining)
            state = state.ccrLoadedConstantDepth(
                depthMeters: depthMeters,
                minutes: step,
                diluent: diluent,
                setpointBar: setpointBar,
                environment: environment
            )
            elapsed += step
            recordSamples(
                state: state,
                depthMeters: depthMeters,
                setpointBar: setpointBar,
                diluent: diluent,
                elapsedMinutes: elapsed,
                input: input,
                environment: environment,
                firstStopDepthMeters: firstStopDepthMeters,
                into: &samples
            )
            remaining -= step
        }
    }

    private static func loadLinearWithSampling(
        state: inout BuhlmannTissueState,
        fromDepthMeters: Double,
        toDepthMeters: Double,
        totalMinutes: Double,
        setpointBar: Double,
        diluent: CCRDiluent,
        elapsed: inout Double,
        input: CCRPlanInput,
        environment: PlannerEnvironment,
        firstStopDepthMeters: Double,
        samples: inout [BuhlmannTissueHistorySample]
    ) {
        guard totalMinutes.isFinite, totalMinutes > 0 else { return }
        var remaining = totalMinutes
        var segmentStartDepth = fromDepthMeters
        while remaining > 0.000_1 {
            let step = min(sampleIntervalMinutes, remaining)
            let progressEnd = (totalMinutes - remaining + step) / totalMinutes
            let segmentEndDepth = fromDepthMeters + (toDepthMeters - fromDepthMeters) * progressEnd
            state = state.ccrLoadedLinearDepth(
                fromDepthMeters: segmentStartDepth,
                toDepthMeters: segmentEndDepth,
                minutes: step,
                diluent: diluent,
                setpointBar: setpointBar,
                environment: environment
            )
            segmentStartDepth = segmentEndDepth
            elapsed += step
            recordSamples(
                state: state,
                depthMeters: segmentEndDepth,
                setpointBar: setpointBar,
                diluent: diluent,
                elapsedMinutes: elapsed,
                input: input,
                environment: environment,
                firstStopDepthMeters: firstStopDepthMeters,
                into: &samples
            )
            remaining -= step
        }
    }

    private static func recordSamples(
        state: BuhlmannTissueState,
        depthMeters: Double,
        setpointBar: Double,
        diluent: CCRDiluent,
        elapsedMinutes: Double,
        input: CCRPlanInput,
        environment: PlannerEnvironment,
        firstStopDepthMeters: Double,
        into samples: inout [BuhlmannTissueHistorySample]
    ) {
        guard CCRInspiredGasModel.inspiredPressures(
            depthMeters: depthMeters,
            setpointBar: setpointBar,
            diluent: diluent,
            environment: environment
        ) != nil else {
            return
        }
        let gf = gradientFactor(
            depthMeters: depthMeters,
            firstStopDepthMeters: firstStopDepthMeters,
            input: input
        )
        for index in 0..<BuhlmannConstants.compartmentCount {
            guard let metrics = compartmentMetrics(
                compartmentIndex: index,
                state: state,
                depthMeters: depthMeters,
                setpointBar: setpointBar,
                diluent: diluent,
                gf: gf,
                environment: environment
            ) else {
                return
            }
            let sample = BuhlmannTissueHistorySample(
                elapsedMinutes: roundElapsed(elapsedMinutes),
                compartmentIndex: index,
                nitrogenPressureBar: metrics.nitrogenPressureBar,
                heliumPressureBar: metrics.heliumPressureBar,
                totalInertPressureBar: metrics.totalInertPressureBar,
                ambientPressureBar: metrics.ambientPressureBar,
                toleratedAmbientPressureBar: metrics.toleratedAmbientPressureBar,
                loadPercent: metrics.loadPercent,
                supersaturationPercent: metrics.supersaturationPercent,
                compartmentGroup: BuhlmannTissueHistorySampler.compartmentGroup(for: index)
            )
            if let existingIndex = samples.lastIndex(where: {
                $0.elapsedMinutes == sample.elapsedMinutes && $0.compartmentIndex == sample.compartmentIndex
            }) {
                samples[existingIndex] = sample
            } else {
                samples.append(sample)
            }
        }
    }

    static func compartmentMetrics(
        compartmentIndex: Int,
        state: BuhlmannTissueState,
        depthMeters: Double,
        setpointBar: Double,
        diluent: CCRDiluent,
        gf: Double,
        environment: PlannerEnvironment
    ) -> (
        nitrogenPressureBar: Double,
        heliumPressureBar: Double,
        totalInertPressureBar: Double,
        ambientPressureBar: Double,
        toleratedAmbientPressureBar: Double,
        loadPercent: Double,
        supersaturationPercent: Double
    )? {
        guard let inspired = CCRInspiredGasModel.inspiredPressures(
            depthMeters: depthMeters,
            setpointBar: setpointBar,
            diluent: diluent,
            environment: environment
        ) else {
            return nil
        }
        let compartment = state.compartments[compartmentIndex]
        let pn2 = sanitize(compartment.nitrogenPressure)
        let phe = sanitize(compartment.heliumPressure)
        let total = sanitize(pn2 + phe)
        guard let ambientRaw = IOSUnitConversions.ambientPressureBar(depthMeters: depthMeters, environment: environment) else {
            return nil
        }
        let ambient = sanitize(ambientRaw)
        let a = BuhlmannConstants.coefficientA(index: compartmentIndex, pn2: pn2, phe: phe)
        let b = BuhlmannConstants.coefficientB(index: compartmentIndex, pn2: pn2, phe: phe)
        let fraction = max(0, min(1, gf))
        let denominator = 1.0 + fraction * ((1.0 / b) - 1.0)
        let toleratedAmbient = denominator.isFinite && denominator > 0
            ? sanitize((total - fraction * a) / denominator)
            : ambient

        let mValue = sanitize(a + b * ambient)
        let inspiredInert = sanitize(inspired.ppN2 + inspired.ppHe)

        let loadPercent = displayPercent(numerator: total, denominator: max(mValue, 0.001))
        let superNumerator = total - inspiredInert
        let superDenominator = max(mValue - inspiredInert, 0.001)
        let supersaturationPercent = displayPercent(numerator: superNumerator, denominator: superDenominator)

        return (pn2, phe, total, ambient, toleratedAmbient, loadPercent, supersaturationPercent)
    }

    private static func gradientFactor(
        depthMeters: Double,
        firstStopDepthMeters: Double,
        input: CCRPlanInput
    ) -> Double {
        if firstStopDepthMeters <= 0.01 {
            return input.gfHigh / 100.0
        }
        return BuhlmannEngine.gfAtDepth(
            depthMeters: depthMeters,
            firstStopDepthMeters: firstStopDepthMeters,
            gfLow: input.gfLow,
            gfHigh: input.gfHigh
        )
    }

    private static func roundElapsed(_ minutes: Double) -> Double {
        (minutes * 1_000).rounded() / 1_000
    }

    private static func sanitize(_ value: Double) -> Double {
        guard value.isFinite else { return 0 }
        return max(0, value)
    }

    private static func displayPercent(numerator: Double, denominator: Double) -> Double {
        guard denominator.isFinite, denominator > 0, numerator.isFinite else { return 0 }
        let raw = (numerator / denominator) * 100.0
        guard raw.isFinite else { return 0 }
        return min(100, max(0, raw))
    }
}
