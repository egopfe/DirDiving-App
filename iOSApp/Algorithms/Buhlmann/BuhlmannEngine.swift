import Foundation

struct BuhlmannPlanRequest: Hashable {
    var maxDepthMeters: Double
    var bottomMinutes: Double
    var bottomGas: BuhlmannGas
    var bottomSegments: [BuhlmannBottomSegment] = []
    var travelGases: [BuhlmannGas]
    var decoGases: [BuhlmannGas]
    var gfLow: Double
    var gfHigh: Double
    var descentRateMetersPerMinute: Double = BuhlmannConstants.defaultDescentRateMetersPerMinute
    var ascentRateMetersPerMinute: Double = BuhlmannConstants.defaultAscentRateMetersPerMinute
    var stopIntervalMeters: Double = BuhlmannConstants.stopIntervalMeters
    var initialTissueState: BuhlmannTissueState = .airSaturated()
    var plannerEnvironment: PlannerEnvironment = .seaLevelSaltWater
}

struct BuhlmannBottomSegment: Hashable {
    let depthMeters: Double
    let minutes: Double
    let gas: BuhlmannGas
}

struct BuhlmannDecompressionStop: Hashable {
    let depthMeters: Double
    let minutes: Int
    let gas: BuhlmannGas
    let ppO2: Double
    let maxPPO2: Double
    let gradientFactor: Double
}

struct BuhlmannRuntimeSegment: Hashable {
    let kind: DiveSegmentKind
    let depthMeters: Double
    let minutes: Double
    let gas: BuhlmannGas
    let note: String
}

struct BuhlmannEngineResult: Hashable {
    let ndlMinutes: Double?
    let ttsMinutes: Int
    let totalRuntimeMinutes: Int
    let descentMinutes: Double
    let bottomMinutes: Double
    let gasSwitchMinutes: Double
    let finalTissueState: BuhlmannTissueState?
    let stops: [BuhlmannDecompressionStop]
    let segments: [BuhlmannRuntimeSegment]
    let tissueHistory: BuhlmannTissueHistory
    let issues: [BuhlmannPlanIssue]
    let modelState: BuhlmannModelState

    var hasBlockingIssues: Bool {
        issues.contains { $0.isBlocking }
    }
}

enum BuhlmannEngine {
    static func plan(_ request: BuhlmannPlanRequest) -> BuhlmannEngineResult {
        let validationIssues = validate(request)
        guard validationIssues.isEmpty else {
            return BuhlmannEngineResult(
                ndlMinutes: nil,
                ttsMinutes: 0,
                totalRuntimeMinutes: 0,
                descentMinutes: 0,
                bottomMinutes: 0,
                gasSwitchMinutes: 0,
                finalTissueState: nil,
                stops: [],
                segments: [],
                tissueHistory: .empty,
                issues: validationIssues,
                modelState: .invalidInput
            )
        }

        var runtimeSegments: [BuhlmannRuntimeSegment] = []
        let descent = loadDescent(request, startingState: request.initialTissueState, segments: &runtimeSegments)
        let bottom = loadBottomSegments(
            request,
            startingState: descent.state,
            startingGas: descent.gas,
            startingDepthMeters: descent.depthMeters,
            segments: &runtimeSegments
        )

        let ndl = noDecompressionLimit(
            depthMeters: request.maxDepthMeters,
            gas: request.bottomGas,
            gfHigh: request.gfHigh,
            initialTissueState: request.initialTissueState,
            plannerEnvironment: request.plannerEnvironment
        )
        let schedule = decompressionSchedule(
            request: request,
            stateAtBottom: bottom.state,
            currentDepthMeters: bottom.depthMeters,
            currentGas: bottom.gas,
            segments: &runtimeSegments
        )

        let engineResult = BuhlmannEngineResult(
            ndlMinutes: ndl,
            ttsMinutes: Int(ceil(schedule.elapsedMinutes)),
            totalRuntimeMinutes: Int(ceil(descent.elapsedMinutes + bottom.elapsedMinutes + schedule.elapsedMinutes)),
            descentMinutes: descent.elapsedMinutes,
            bottomMinutes: bottom.bottomMinutes,
            gasSwitchMinutes: descent.gasSwitchMinutes + bottom.gasSwitchMinutes + schedule.gasSwitchMinutes,
            finalTissueState: schedule.state,
            stops: schedule.stops,
            segments: runtimeSegments,
            tissueHistory: .empty,
            issues: schedule.issues,
            modelState: schedule.issues.isEmpty ? .validReference : .modelIncomplete
        )
        let tissueHistory = BuhlmannTissueHistorySampler.sample(request: request, engineResult: engineResult)
        return BuhlmannEngineResult(
            ndlMinutes: engineResult.ndlMinutes,
            ttsMinutes: engineResult.ttsMinutes,
            totalRuntimeMinutes: engineResult.totalRuntimeMinutes,
            descentMinutes: engineResult.descentMinutes,
            bottomMinutes: engineResult.bottomMinutes,
            gasSwitchMinutes: engineResult.gasSwitchMinutes,
            finalTissueState: engineResult.finalTissueState,
            stops: engineResult.stops,
            segments: engineResult.segments,
            tissueHistory: tissueHistory,
            issues: engineResult.issues,
            modelState: engineResult.modelState
        )
    }

    static func noDecompressionLimit(
        depthMeters: Double,
        gas: BuhlmannGas,
        gfHigh: Double,
        initialTissueState: BuhlmannTissueState = .airSaturated(),
        plannerEnvironment: PlannerEnvironment = .seaLevelSaltWater
    ) -> Double? {
        guard depthMeters.isFinite,
              depthMeters >= IOSAlgorithmConfiguration.minPlannerDepthMeters,
              depthMeters <= IOSAlgorithmConfiguration.maxPlannerDepthMeters,
              gas.isCompositionValid else {
            return nil
        }
        let request = BuhlmannPlanRequest(
            maxDepthMeters: depthMeters,
            bottomMinutes: 0,
            bottomGas: gas,
            travelGases: [],
            decoGases: [],
            gfLow: min(gfHigh, 30),
            gfHigh: gfHigh,
            initialTissueState: initialTissueState,
            plannerEnvironment: plannerEnvironment
        )
        guard validate(request).isEmpty else { return nil }

        func canSurface(afterBottomMinutes minutes: Double) -> Bool {
            var segments: [BuhlmannRuntimeSegment] = []
            let descended = loadDescent(request, startingState: initialTissueState, segments: &segments)
            let bottom = descended.state.loadedConstantDepth(depthMeters: depthMeters, minutes: minutes, gas: gas, environment: plannerEnvironment)
            let ascentMinutes = max(0.1, depthMeters / BuhlmannConstants.defaultAscentRateMetersPerMinute)
            let surfaced = bottom.loadedLinearDepth(fromDepthMeters: depthMeters, toDepthMeters: 0, minutes: ascentMinutes, gas: gas, environment: plannerEnvironment)
            return surfaced.ceiling(gf: gfHigh / 100.0, environment: plannerEnvironment).depthMeters <= 0.01
        }

        if !canSurface(afterBottomMinutes: 0) {
            return 0
        }
        if canSurface(afterBottomMinutes: IOSAlgorithmConfiguration.maxBottomTimeMinutes) {
            return IOSAlgorithmConfiguration.maxBottomTimeMinutes
        }

        var low = 0.0
        var high = IOSAlgorithmConfiguration.maxBottomTimeMinutes
        for _ in 0..<32 {
            let mid = (low + high) / 2.0
            if canSurface(afterBottomMinutes: mid) {
                low = mid
            } else {
                high = mid
            }
        }
        return floor(low * 10) / 10
    }

    static func gfAtDepth(depthMeters: Double, firstStopDepthMeters: Double, gfLow: Double, gfHigh: Double) -> Double {
        guard firstStopDepthMeters > 0 else {
            return max(0, min(1, gfHigh / 100.0))
        }
        let low = max(0, min(1, gfLow / 100.0))
        let high = max(0, min(1, gfHigh / 100.0))
        let ratio = max(0, min(1, depthMeters / firstStopDepthMeters))
        return high - (high - low) * ratio
    }

    static func validate(_ request: BuhlmannPlanRequest) -> [BuhlmannPlanIssue] {
        var issues: [BuhlmannPlanIssue] = []
        guard request.maxDepthMeters.isFinite,
              request.maxDepthMeters >= IOSAlgorithmConfiguration.minPlannerDepthMeters,
              request.maxDepthMeters <= IOSAlgorithmConfiguration.maxPlannerDepthMeters,
              request.bottomMinutes.isFinite,
              request.bottomMinutes >= 0,
              request.bottomMinutes <= IOSAlgorithmConfiguration.maxBottomTimeMinutes,
              request.gfLow.isFinite,
              request.gfHigh.isFinite,
              request.gfLow >= IOSAlgorithmConfiguration.minGradientFactor,
              request.gfLow <= IOSAlgorithmConfiguration.maxGradientFactor,
              request.gfHigh >= IOSAlgorithmConfiguration.minGradientFactor,
              request.gfHigh <= IOSAlgorithmConfiguration.maxGradientFactor,
              request.gfLow < request.gfHigh,
              request.descentRateMetersPerMinute.isFinite,
              request.descentRateMetersPerMinute > 0,
              request.ascentRateMetersPerMinute.isFinite,
              request.ascentRateMetersPerMinute > 0,
              request.stopIntervalMeters.isFinite,
              request.stopIntervalMeters > 0 else {
            return [.invalidProfile("Invalid depth, time, or gradient factors.")]
        }

        let allGases = [request.bottomGas] + request.travelGases + request.decoGases
        for gas in allGases {
            if !gas.isCompositionValid {
                issues.append(.invalidGas(gas.name))
                continue
            }
            if gas.ppO2(depthMeters: request.maxDepthMeters, environment: request.plannerEnvironment) > gas.maxPPO2Bar + 0.000_1, gas.role == .bottom {
                issues.append(.ppo2Exceeded(gas.name))
            }
            if gas.role != .bottom {
                let switchPPO2 = gas.ppO2(depthMeters: gas.switchDepthMeters, environment: request.plannerEnvironment)
                // Standard recreational switch depths (e.g. 6 m O2) may sit marginally above ISA MOD at 1.6 bar.
                if switchPPO2 > gas.maxPPO2Bar + BuhlmannConstants.decoGasSwitchPPO2ToleranceBar {
                    issues.append(.gasSwitchTooDeep(gas.name))
                }
            }
            if gas.ppO2(depthMeters: gas.switchDepthMeters, environment: request.plannerEnvironment) < BuhlmannConstants.minBreathablePPO2Bar, gas.role != .bottom {
                issues.append(.hypoxicGasTooShallow(gas.name))
            }
        }

        let firstGas = firstDescentGas(for: request)
        if firstGas.ppO2(depthMeters: 0, environment: request.plannerEnvironment) < BuhlmannConstants.minBreathablePPO2Bar {
            issues.append(.hypoxicGasTooShallow(firstGas.name))
        }
        let bottomSwitchDepth = request.bottomGas.switchDepthMeters
        if request.bottomGas.ppO2(depthMeters: bottomSwitchDepth, environment: request.plannerEnvironment) < BuhlmannConstants.minBreathablePPO2Bar {
            issues.append(.hypoxicGasTooShallow(request.bottomGas.name))
        }
        if request.bottomGas.ppO2(depthMeters: bottomSwitchDepth, environment: request.plannerEnvironment)
            > request.bottomGas.maxPPO2Bar + 0.000_1 {
            issues.append(.modExceeded(request.bottomGas.name))
        }
        var bottomSegmentMinutes = 0.0
        for segment in request.bottomSegments {
            if !segment.depthMeters.isFinite || segment.depthMeters < 0 || segment.depthMeters > request.maxDepthMeters || !segment.minutes.isFinite || segment.minutes <= 0 {
                issues.append(.invalidProfile("Invalid bottom segment."))
                continue
            }
            bottomSegmentMinutes += segment.minutes
            if !segment.gas.isCompositionValid {
                issues.append(.invalidGas(segment.gas.name))
                continue
            }
            if segment.gas.ppO2(depthMeters: segment.depthMeters, environment: request.plannerEnvironment) < BuhlmannConstants.minBreathablePPO2Bar {
                issues.append(.hypoxicGasTooShallow(segment.gas.name))
            }
            if segment.gas.ppO2(depthMeters: segment.depthMeters, environment: request.plannerEnvironment)
                > segment.gas.maxPPO2Bar + 0.000_1 {
                issues.append(.modExceeded(segment.gas.name))
            }
        }
        if bottomSegmentMinutes > IOSAlgorithmConfiguration.maxBottomTimeMinutes {
            issues.append(.invalidProfile("Bottom segments exceed maximum bottom time."))
        }
        issues.append(contentsOf: validateGasUseRanges(request))
        return uniqueIssues(issues)
    }

    private struct ScheduleResult {
        var stops: [BuhlmannDecompressionStop]
        var elapsedMinutes: Double
        var gasSwitchMinutes: Double
        var state: BuhlmannTissueState
        var issues: [BuhlmannPlanIssue]
        var limitReached: Bool
    }

    private static func decompressionSchedule(
        request: BuhlmannPlanRequest,
        stateAtBottom: BuhlmannTissueState,
        currentDepthMeters: Double,
        currentGas startingGas: BuhlmannGas,
        segments: inout [BuhlmannRuntimeSegment]
    ) -> ScheduleResult {
        let gfLow = request.gfLow / 100.0
        let firstCeiling = stateAtBottom.ceiling(gf: gfLow, environment: request.plannerEnvironment).depthMeters
        guard firstCeiling > 0.01 else {
            let ascent = loadAscentToSurface(
                request: request,
                startingState: stateAtBottom,
                startingDepth: currentDepthMeters,
                startingGas: startingGas,
                segments: &segments
            )
            return ScheduleResult(
                stops: [],
                elapsedMinutes: ascent.elapsedMinutes,
                gasSwitchMinutes: ascent.gasSwitchMinutes,
                state: ascent.state,
                issues: uniqueIssues(ascent.issues),
                limitReached: !ascent.issues.isEmpty
            )
        }

        let firstStopDepth = min(currentDepthMeters, ceilToStop(firstCeiling, interval: request.stopIntervalMeters))
        var currentDepth = currentDepthMeters
        var currentGas = startingGas
        var state = stateAtBottom
        var stopDepth = firstStopDepth
        var stops: [BuhlmannDecompressionStop] = []
        var elapsed = 0.0
        var gasSwitchElapsed = 0.0
        var issues: [BuhlmannPlanIssue] = []
        var limitReached = false

        while stopDepth > 0.01 {
            if currentDepth > stopDepth {
                guard ascendSegment(
                    request: request,
                    currentDepth: &currentDepth,
                    to: stopDepth,
                    state: &state,
                    currentGas: &currentGas,
                    elapsed: &elapsed,
                    gasSwitchElapsed: &gasSwitchElapsed,
                    segments: &segments,
                    issues: &issues,
                    gasSwitchNote: "Gas switch"
                ) else {
                    limitReached = true
                    break
                }
            }

            let nextDepth = max(0, stopDepth - request.stopIntervalMeters)
            var stopMinutes = 0
            while true {
                let gf = gfAtDepth(depthMeters: nextDepth, firstStopDepthMeters: firstStopDepth, gfLow: request.gfLow, gfHigh: request.gfHigh)
                let ceiling = state.ceiling(gf: gf, environment: request.plannerEnvironment).depthMeters
                if ceiling <= nextDepth + 0.05 {
                    break
                }
                if stopMinutes >= BuhlmannConstants.maxStopMinutesPerDepth || elapsed >= Double(BuhlmannConstants.maxScheduleMinutes) {
                    issues.append(.calculationLimitReached)
                    limitReached = true
                    break
                }
                state = state.loadedConstantDepth(depthMeters: stopDepth, minutes: 1, gas: currentGas, environment: request.plannerEnvironment)
                stopMinutes += 1
                elapsed += 1
            }

            if stopMinutes > 0 {
                let gf = gfAtDepth(depthMeters: stopDepth, firstStopDepthMeters: firstStopDepth, gfLow: request.gfLow, gfHigh: request.gfHigh)
                stops.append(
                    BuhlmannDecompressionStop(
                        depthMeters: stopDepth,
                        minutes: stopMinutes,
                        gas: currentGas,
                        ppO2: currentGas.ppO2(depthMeters: stopDepth, environment: request.plannerEnvironment),
                        maxPPO2: currentGas.maxPPO2Bar,
                        gradientFactor: gf
                    )
                )
                segments.append(
                    BuhlmannRuntimeSegment(kind: .stop, depthMeters: stopDepth, minutes: Double(stopMinutes), gas: currentGas, note: "Buhlmann stop")
                )
            }

            if limitReached {
                break
            }
            currentDepth = stopDepth
            stopDepth = nextDepth
        }

        if !limitReached, currentDepth > 0 {
            let ascent = loadAscentToSurface(
                request: request,
                startingState: state,
                startingDepth: currentDepth,
                startingGas: currentGas,
                segments: &segments
            )
            state = ascent.state
            elapsed += ascent.elapsedMinutes
            gasSwitchElapsed += ascent.gasSwitchMinutes
            issues.append(contentsOf: ascent.issues)
            limitReached = limitReached || !ascent.issues.isEmpty
        }
        return ScheduleResult(stops: stops, elapsedMinutes: elapsed, gasSwitchMinutes: gasSwitchElapsed, state: state, issues: uniqueIssues(issues), limitReached: limitReached)
    }

    private struct AscentLoadResult {
        var state: BuhlmannTissueState
        var gas: BuhlmannGas
        var elapsedMinutes: Double
        var gasSwitchMinutes: Double
        var issues: [BuhlmannPlanIssue]
    }

    private struct BottomLoadResult {
        var state: BuhlmannTissueState
        var depthMeters: Double
        var gas: BuhlmannGas
        var bottomMinutes: Double
        var elapsedMinutes: Double
        var gasSwitchMinutes: Double
    }

    private struct DescentLoadResult {
        var state: BuhlmannTissueState
        var depthMeters: Double
        var gas: BuhlmannGas
        var elapsedMinutes: Double
        var gasSwitchMinutes: Double
    }

    private static func loadBottomSegments(
        _ request: BuhlmannPlanRequest,
        startingState: BuhlmannTissueState,
        startingGas: BuhlmannGas,
        startingDepthMeters: Double,
        segments: inout [BuhlmannRuntimeSegment]
    ) -> BottomLoadResult {
        let plannedSegments = request.bottomSegments.isEmpty
            ? [BuhlmannBottomSegment(depthMeters: startingDepthMeters, minutes: request.bottomMinutes, gas: request.bottomGas)]
            : request.bottomSegments

        var state = startingState
        var currentDepth = startingDepthMeters
        var currentGas = startingGas
        var totalMinutes = 0.0
        var elapsedMinutes = 0.0
        var gasSwitchMinutes = 0.0

        for segment in plannedSegments {
            if abs(segment.depthMeters - currentDepth) > 0.01 {
                let isDescending = segment.depthMeters > currentDepth
                let transitionRate = isDescending ? request.descentRateMetersPerMinute : request.ascentRateMetersPerMinute
                let transitionMinutes = max(0.1, abs(segment.depthMeters - currentDepth) / transitionRate)
                state = state.loadedLinearDepth(fromDepthMeters: currentDepth, toDepthMeters: segment.depthMeters, minutes: transitionMinutes, gas: currentGas, environment: request.plannerEnvironment)
                elapsedMinutes += transitionMinutes
                segments.append(
                    BuhlmannRuntimeSegment(kind: isDescending ? .descent : .ascent, depthMeters: segment.depthMeters, minutes: transitionMinutes, gas: currentGas, note: "Bottom transition")
                )
                currentDepth = segment.depthMeters
            }
            if segment.gas != currentGas {
                currentGas = segment.gas
                state = state.loadedConstantDepth(depthMeters: currentDepth, minutes: BuhlmannConstants.gasSwitchMinutes, gas: currentGas, environment: request.plannerEnvironment)
                elapsedMinutes += BuhlmannConstants.gasSwitchMinutes
                gasSwitchMinutes += BuhlmannConstants.gasSwitchMinutes
                segments.append(
                    BuhlmannRuntimeSegment(kind: .gasSwitch, depthMeters: currentDepth, minutes: BuhlmannConstants.gasSwitchMinutes, gas: currentGas, note: "Bottom gas switch")
                )
            }
            state = state.loadedConstantDepth(depthMeters: segment.depthMeters, minutes: segment.minutes, gas: segment.gas, environment: request.plannerEnvironment)
            totalMinutes += segment.minutes
            elapsedMinutes += segment.minutes
            segments.append(
                BuhlmannRuntimeSegment(kind: .bottom, depthMeters: segment.depthMeters, minutes: segment.minutes, gas: segment.gas, note: "Bottom segment")
            )
        }

        return BottomLoadResult(
            state: state,
            depthMeters: currentDepth,
            gas: currentGas,
            bottomMinutes: totalMinutes,
            elapsedMinutes: elapsedMinutes,
            gasSwitchMinutes: gasSwitchMinutes
        )
    }

    private static func loadDescent(
        _ request: BuhlmannPlanRequest,
        startingState: BuhlmannTissueState,
        segments: inout [BuhlmannRuntimeSegment]
    ) -> DescentLoadResult {
        var state = startingState
        var currentDepth = 0.0
        var currentGas = firstDescentGas(for: request)
        var elapsedMinutes = 0.0
        var gasSwitchMinutes = 0.0
        let switches = request.travelGases
            .filter { $0.switchDepthMeters > 0.5 && $0.switchDepthMeters < request.maxDepthMeters - 0.5 }
            .sorted { $0.switchDepthMeters < $1.switchDepthMeters }
            + [request.bottomGas]

        for switchGas in switches {
            let targetDepth = switchGas.switchDepthMeters
            guard targetDepth > currentDepth else { continue }
            let minutes = max(0.1, (targetDepth - currentDepth) / request.descentRateMetersPerMinute)
            state = state.loadedLinearDepth(fromDepthMeters: currentDepth, toDepthMeters: targetDepth, minutes: minutes, gas: currentGas, environment: request.plannerEnvironment)
            elapsedMinutes += minutes
            segments.append(
                BuhlmannRuntimeSegment(kind: .descent, depthMeters: targetDepth, minutes: minutes, gas: currentGas, note: "Descent segment")
            )
            currentDepth = targetDepth
            if switchGas != currentGas {
                currentGas = switchGas
                state = state.loadedConstantDepth(depthMeters: currentDepth, minutes: BuhlmannConstants.gasSwitchMinutes, gas: currentGas, environment: request.plannerEnvironment)
                elapsedMinutes += BuhlmannConstants.gasSwitchMinutes
                gasSwitchMinutes += BuhlmannConstants.gasSwitchMinutes
                segments.append(
                    BuhlmannRuntimeSegment(kind: .gasSwitch, depthMeters: currentDepth, minutes: BuhlmannConstants.gasSwitchMinutes, gas: currentGas, note: "Gas switch")
                )
            }
        }

        if currentDepth < request.maxDepthMeters - 0.01 {
            let targetDepth = request.maxDepthMeters
            let minutes = max(0.1, (targetDepth - currentDepth) / request.descentRateMetersPerMinute)
            state = state.loadedLinearDepth(
                fromDepthMeters: currentDepth,
                toDepthMeters: targetDepth,
                minutes: minutes,
                gas: currentGas,
                environment: request.plannerEnvironment
            )
            elapsedMinutes += minutes
            segments.append(
                BuhlmannRuntimeSegment(kind: .descent, depthMeters: targetDepth, minutes: minutes, gas: currentGas, note: "Descent segment")
            )
            currentDepth = targetDepth
        }

        return DescentLoadResult(
            state: state,
            depthMeters: currentDepth,
            gas: currentGas,
            elapsedMinutes: elapsedMinutes,
            gasSwitchMinutes: gasSwitchMinutes
        )
    }

    private static func loadAscentToSurface(
        request: BuhlmannPlanRequest,
        startingState: BuhlmannTissueState,
        startingDepth: Double,
        startingGas: BuhlmannGas,
        segments: inout [BuhlmannRuntimeSegment]
    ) -> AscentLoadResult {
        var state = startingState
        var currentDepth = max(0, startingDepth)
        var currentGas = startingGas
        var elapsedMinutes = 0.0
        var gasSwitchMinutes = 0.0
        var issues: [BuhlmannPlanIssue] = []

        _ = ascendSegment(
            request: request,
            currentDepth: &currentDepth,
            to: 0,
            state: &state,
            currentGas: &currentGas,
            elapsed: &elapsedMinutes,
            gasSwitchElapsed: &gasSwitchMinutes,
            segments: &segments,
            issues: &issues,
            gasSwitchNote: "Ascent gas switch"
        )

        return AscentLoadResult(
            state: state,
            gas: currentGas,
            elapsedMinutes: elapsedMinutes,
            gasSwitchMinutes: gasSwitchMinutes,
            issues: uniqueIssues(issues)
        )
    }

    private static func firstDescentGas(for request: BuhlmannPlanRequest) -> BuhlmannGas {
        request.travelGases.sorted { $0.switchDepthMeters < $1.switchDepthMeters }.first ?? request.bottomGas
    }

    private static func ascentSwitchDepths(fromDepthMeters depth: Double, request: BuhlmannPlanRequest) -> [Double] {
        let depths = (request.travelGases + request.decoGases)
            .map(\.switchDepthMeters)
            .filter { $0.isFinite && $0 > 0.05 && $0 < depth - 0.05 }
        return Array(Set(depths)).sorted(by: >)
    }

    private static func ascentWaypoints(from startDepth: Double, to endDepth: Double, request: BuhlmannPlanRequest) -> [Double] {
        guard startDepth > endDepth + 0.01 else { return [] }
        let switches = ascentSwitchDepths(fromDepthMeters: startDepth, request: request)
            .filter { $0 > endDepth + 0.01 }
        return switches + [max(0, endDepth)]
    }

    private static func ascendSegment(
        request: BuhlmannPlanRequest,
        currentDepth: inout Double,
        to endDepth: Double,
        state: inout BuhlmannTissueState,
        currentGas: inout BuhlmannGas,
        elapsed: inout Double,
        gasSwitchElapsed: inout Double,
        segments: inout [BuhlmannRuntimeSegment],
        issues: inout [BuhlmannPlanIssue],
        gasSwitchNote: String
    ) -> Bool {
        switchGasIfNeeded(
            request: request,
            at: currentDepth,
            state: &state,
            currentGas: &currentGas,
            elapsed: &elapsed,
            gasSwitchElapsed: &gasSwitchElapsed,
            segments: &segments,
            note: gasSwitchNote
        )
        for targetDepth in ascentWaypoints(from: currentDepth, to: endDepth, request: request) {
            guard currentDepth > targetDepth + 0.01 else {
                switchGasIfNeeded(
                    request: request,
                    at: currentDepth,
                    state: &state,
                    currentGas: &currentGas,
                    elapsed: &elapsed,
                    gasSwitchElapsed: &gasSwitchElapsed,
                    segments: &segments,
                    note: gasSwitchNote
                )
                continue
            }
            guard currentGas.isOperational(fromDepthMeters: currentDepth, toDepthMeters: targetDepth, environment: request.plannerEnvironment) else {
                issues.append(.gasNotOperationalInSegment(currentGas.name))
                return false
            }
            let ascentMinutes = max(0.1, (currentDepth - targetDepth) / request.ascentRateMetersPerMinute)
            state = state.loadedLinearDepth(
                fromDepthMeters: currentDepth,
                toDepthMeters: targetDepth,
                minutes: ascentMinutes,
                gas: currentGas,
                environment: request.plannerEnvironment
            )
            elapsed += ascentMinutes
            segments.append(
                BuhlmannRuntimeSegment(
                    kind: .ascent,
                    depthMeters: targetDepth,
                    minutes: ascentMinutes,
                    gas: currentGas,
                    note: targetDepth <= 0.01 ? "Final ascent" : "Ascent segment"
                )
            )
            currentDepth = targetDepth
            switchGasIfNeeded(
                request: request,
                at: currentDepth,
                state: &state,
                currentGas: &currentGas,
                elapsed: &elapsed,
                gasSwitchElapsed: &gasSwitchElapsed,
                segments: &segments,
                note: gasSwitchNote
            )
        }
        return true
    }

    private static func switchGasIfNeeded(
        request: BuhlmannPlanRequest,
        at depth: Double,
        state: inout BuhlmannTissueState,
        currentGas: inout BuhlmannGas,
        elapsed: inout Double,
        gasSwitchElapsed: inout Double,
        segments: inout [BuhlmannRuntimeSegment],
        note: String
    ) {
        let nextGas = bestAscentGas(atDepth: depth, currentGas: currentGas, request: request)
        guard nextGas != currentGas else { return }
        currentGas = nextGas
        state = state.loadedConstantDepth(
            depthMeters: depth,
            minutes: BuhlmannConstants.gasSwitchMinutes,
            gas: currentGas,
            environment: request.plannerEnvironment
        )
        elapsed += BuhlmannConstants.gasSwitchMinutes
        gasSwitchElapsed += BuhlmannConstants.gasSwitchMinutes
        segments.append(
            BuhlmannRuntimeSegment(
                kind: .gasSwitch,
                depthMeters: depth,
                minutes: BuhlmannConstants.gasSwitchMinutes,
                gas: currentGas,
                note: note
            )
        )
    }

    private static func validateGasUseRanges(_ request: BuhlmannPlanRequest) -> [BuhlmannPlanIssue] {
        var issues: [BuhlmannPlanIssue] = []
        var currentDepth = 0.0
        var currentGas = firstDescentGas(for: request)
        let descentSwitches = request.travelGases
            .filter { $0.switchDepthMeters > 0.5 && $0.switchDepthMeters < request.maxDepthMeters - 0.5 }
            .sorted { $0.switchDepthMeters < $1.switchDepthMeters }
            + [request.bottomGas]

        for switchGas in descentSwitches {
            let targetDepth = switchGas.switchDepthMeters
            if targetDepth > currentDepth {
                issues.append(contentsOf: operationalIssues(for: currentGas, fromDepth: currentDepth, toDepth: targetDepth, environment: request.plannerEnvironment))
                currentDepth = targetDepth
            }
            currentGas = switchGas
        }

        let bottomSegments = request.bottomSegments.isEmpty
            ? [BuhlmannBottomSegment(depthMeters: request.maxDepthMeters, minutes: request.bottomMinutes, gas: request.bottomGas)]
            : request.bottomSegments
        for segment in bottomSegments {
            if abs(segment.depthMeters - currentDepth) > 0.01 {
                issues.append(contentsOf: operationalIssues(for: currentGas, fromDepth: currentDepth, toDepth: segment.depthMeters, environment: request.plannerEnvironment))
                currentDepth = segment.depthMeters
            }
            issues.append(contentsOf: operationalIssues(for: segment.gas, fromDepth: segment.depthMeters, toDepth: segment.depthMeters, environment: request.plannerEnvironment))
            currentGas = segment.gas
        }

        return issues
    }

    private static func operationalIssues(for gas: BuhlmannGas, fromDepth: Double, toDepth: Double, environment: PlannerEnvironment) -> [BuhlmannPlanIssue] {
        guard gas.isCompositionValid, fromDepth.isFinite, toDepth.isFinite else {
            return [.invalidGas(gas.name)]
        }
        let shallow = max(0, min(fromDepth, toDepth))
        let deep = max(fromDepth, toDepth)
        var issues: [BuhlmannPlanIssue] = []
        if gas.ppO2(depthMeters: shallow, environment: environment) < BuhlmannConstants.minBreathablePPO2Bar {
            issues.append(.hypoxicGasTooShallow(gas.name))
        }
        if gas.ppO2(depthMeters: deep, environment: environment) > gas.maxPPO2Bar + 0.000_1 {
            issues.append(.ppo2Exceeded(gas.name))
        }
        if issues.isEmpty, !gas.isOperational(fromDepthMeters: fromDepth, toDepthMeters: toDepth, environment: environment) {
            issues.append(.gasNotOperationalInSegment(gas.name))
        }
        return issues
    }

    private static func bestAscentGas(atDepth depth: Double, currentGas: BuhlmannGas, request: BuhlmannPlanRequest) -> BuhlmannGas {
        let candidates = (request.decoGases + request.travelGases)
            .filter { $0.switchDepthMeters + 0.05 >= depth }
            .filter { gas in
                let ppo2 = gas.ppO2(depthMeters: depth, environment: request.plannerEnvironment)
                return ppo2 >= BuhlmannConstants.minBreathablePPO2Bar
                    && ppo2 <= gas.maxPPO2Bar + 0.000_1
            }
            .sorted { $0.oxygenFraction > $1.oxygenFraction }
        return candidates.first ?? currentGas
    }

    private static func ceilToStop(_ depth: Double, interval: Double) -> Double {
        guard interval > 0 else { return depth }
        return ceil(depth / interval) * interval
    }

    private static func uniqueIssues(_ issues: [BuhlmannPlanIssue]) -> [BuhlmannPlanIssue] {
        var seen = Set<BuhlmannPlanIssue>()
        var result: [BuhlmannPlanIssue] = []
        for issue in issues where seen.insert(issue).inserted {
            result.append(issue)
        }
        return result
    }
}
