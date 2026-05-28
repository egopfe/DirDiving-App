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
    let stops: [BuhlmannDecompressionStop]
    let segments: [BuhlmannRuntimeSegment]
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
                stops: [],
                segments: [],
                issues: validationIssues,
                modelState: .invalidInput
            )
        }

        let initial = BuhlmannTissueState.airSaturated()
        var runtimeSegments: [BuhlmannRuntimeSegment] = []
        let afterDescent = loadDescent(request, startingState: initial, segments: &runtimeSegments)
        let bottom = loadBottomSegments(request, startingState: afterDescent, segments: &runtimeSegments)

        let ndl = noDecompressionLimit(
            depthMeters: request.maxDepthMeters,
            gas: request.bottomGas,
            gfHigh: request.gfHigh
        )
        let schedule = decompressionSchedule(
            request: request,
            stateAtBottom: bottom.state,
            currentDepthMeters: bottom.depthMeters,
            currentGas: bottom.gas,
            segments: &runtimeSegments
        )

        return BuhlmannEngineResult(
            ndlMinutes: ndl,
            ttsMinutes: schedule.ttsMinutes + Int(ceil(bottom.minutes)),
            stops: schedule.stops,
            segments: runtimeSegments,
            issues: schedule.limitReached ? [.calculationLimitReached] : [],
            modelState: schedule.limitReached ? .modelIncomplete : .validReference
        )
    }

    static func noDecompressionLimit(depthMeters: Double, gas: BuhlmannGas, gfHigh: Double) -> Double? {
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
            gfHigh: gfHigh
        )
        guard validate(request).isEmpty else { return nil }

        func canSurface(afterBottomMinutes minutes: Double) -> Bool {
            let initial = BuhlmannTissueState.airSaturated()
            var segments: [BuhlmannRuntimeSegment] = []
            let descended = loadDescent(request, startingState: initial, segments: &segments)
            let bottom = descended.loadedConstantDepth(depthMeters: depthMeters, minutes: minutes, gas: gas)
            let ascentMinutes = max(0.1, depthMeters / BuhlmannConstants.defaultAscentRateMetersPerMinute)
            let surfaced = bottom.loadedLinearDepth(fromDepthMeters: depthMeters, toDepthMeters: 0, minutes: ascentMinutes, gas: gas)
            return surfaced.ceiling(gf: gfHigh / 100.0).depthMeters <= 0.01
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
            if gas.ppO2(depthMeters: request.maxDepthMeters) > gas.maxPPO2Bar + 0.000_1, gas.role == .bottom {
                issues.append(.ppo2Exceeded(gas.name))
            }
            if let mod = gas.modMeters(), gas.switchDepthMeters > mod + 0.05, gas.role != .bottom {
                issues.append(.gasSwitchTooDeep(gas.name))
            }
            if gas.ppO2(depthMeters: gas.switchDepthMeters) < BuhlmannConstants.minBreathablePPO2Bar, gas.role != .bottom {
                issues.append(.hypoxicGasTooShallow(gas.name))
            }
        }

        let firstGas = firstDescentGas(for: request)
        if firstGas.ppO2(depthMeters: 0) < BuhlmannConstants.minBreathablePPO2Bar {
            issues.append(.hypoxicGasTooShallow(firstGas.name))
        }
        if request.bottomGas.ppO2(depthMeters: request.maxDepthMeters) < BuhlmannConstants.minBreathablePPO2Bar {
            issues.append(.hypoxicGasTooShallow(request.bottomGas.name))
        }
        if let mod = request.bottomGas.modMeters(), request.maxDepthMeters > mod + 0.05 {
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
            if segment.gas.ppO2(depthMeters: segment.depthMeters) < BuhlmannConstants.minBreathablePPO2Bar {
                issues.append(.hypoxicGasTooShallow(segment.gas.name))
            }
            if let mod = segment.gas.modMeters(), segment.depthMeters > mod + 0.05 {
                issues.append(.modExceeded(segment.gas.name))
            }
        }
        if bottomSegmentMinutes > IOSAlgorithmConfiguration.maxBottomTimeMinutes {
            issues.append(.invalidProfile("Bottom segments exceed maximum bottom time."))
        }
        return uniqueIssues(issues)
    }

    private struct ScheduleResult {
        var stops: [BuhlmannDecompressionStop]
        var ttsMinutes: Int
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
        let firstCeiling = stateAtBottom.ceiling(gf: gfLow).depthMeters
        guard firstCeiling > 0.01 else {
            let ascentMinutes = max(0.1, currentDepthMeters / request.ascentRateMetersPerMinute)
            segments.append(
                BuhlmannRuntimeSegment(kind: .ascent, depthMeters: 0, minutes: ascentMinutes, gas: startingGas, note: "Final ascent")
            )
            return ScheduleResult(stops: [], ttsMinutes: Int(ceil(ascentMinutes)), limitReached: false)
        }

        let firstStopDepth = min(currentDepthMeters, ceilToStop(firstCeiling, interval: request.stopIntervalMeters))
        var currentDepth = currentDepthMeters
        var currentGas = startingGas
        var state = stateAtBottom
        var stopDepth = firstStopDepth
        var stops: [BuhlmannDecompressionStop] = []
        var elapsed = 0
        var limitReached = false

        while stopDepth > 0.01 {
            if currentDepth > stopDepth {
                let ascentMinutes = max(0.1, (currentDepth - stopDepth) / request.ascentRateMetersPerMinute)
                state = state.loadedLinearDepth(fromDepthMeters: currentDepth, toDepthMeters: stopDepth, minutes: ascentMinutes, gas: currentGas)
                elapsed += Int(ceil(ascentMinutes))
                segments.append(
                    BuhlmannRuntimeSegment(kind: .ascent, depthMeters: stopDepth, minutes: ascentMinutes, gas: currentGas, note: "Ascent to stop")
                )
                currentDepth = stopDepth
            }

            let nextGas = bestAscentGas(atDepth: stopDepth, currentGas: currentGas, request: request)
            if nextGas != currentGas {
                currentGas = nextGas
                segments.append(
                    BuhlmannRuntimeSegment(kind: .gasSwitch, depthMeters: stopDepth, minutes: 0.5, gas: currentGas, note: "Gas switch")
                )
            }

            let nextDepth = max(0, stopDepth - request.stopIntervalMeters)
            var stopMinutes = 0
            while true {
                let gf = gfAtDepth(depthMeters: nextDepth, firstStopDepthMeters: firstStopDepth, gfLow: request.gfLow, gfHigh: request.gfHigh)
                let ceiling = state.ceiling(gf: gf).depthMeters
                if ceiling <= nextDepth + 0.05 {
                    break
                }
                if stopMinutes >= BuhlmannConstants.maxStopMinutesPerDepth || elapsed >= BuhlmannConstants.maxScheduleMinutes {
                    limitReached = true
                    break
                }
                state = state.loadedConstantDepth(depthMeters: stopDepth, minutes: 1, gas: currentGas)
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
                        ppO2: currentGas.ppO2(depthMeters: stopDepth),
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
            let ascentMinutes = max(0.1, currentDepth / request.ascentRateMetersPerMinute)
            _ = state.loadedLinearDepth(fromDepthMeters: currentDepth, toDepthMeters: 0, minutes: ascentMinutes, gas: currentGas)
            elapsed += Int(ceil(ascentMinutes))
            segments.append(
                BuhlmannRuntimeSegment(kind: .ascent, depthMeters: 0, minutes: ascentMinutes, gas: currentGas, note: "Final ascent")
            )
        }
        return ScheduleResult(stops: stops, ttsMinutes: elapsed, limitReached: limitReached)
    }

    private struct BottomLoadResult {
        var state: BuhlmannTissueState
        var depthMeters: Double
        var gas: BuhlmannGas
        var minutes: Double
    }

    private static func loadBottomSegments(
        _ request: BuhlmannPlanRequest,
        startingState: BuhlmannTissueState,
        segments: inout [BuhlmannRuntimeSegment]
    ) -> BottomLoadResult {
        let plannedSegments = request.bottomSegments.isEmpty
            ? [BuhlmannBottomSegment(depthMeters: request.maxDepthMeters, minutes: request.bottomMinutes, gas: request.bottomGas)]
            : request.bottomSegments

        var state = startingState
        var currentDepth = request.maxDepthMeters
        var currentGas = request.bottomGas
        var totalMinutes = 0.0

        for segment in plannedSegments {
            if abs(segment.depthMeters - currentDepth) > 0.01 {
                let isDescending = segment.depthMeters > currentDepth
                let transitionRate = isDescending ? request.descentRateMetersPerMinute : request.ascentRateMetersPerMinute
                let transitionMinutes = max(0.1, abs(segment.depthMeters - currentDepth) / transitionRate)
                state = state.loadedLinearDepth(fromDepthMeters: currentDepth, toDepthMeters: segment.depthMeters, minutes: transitionMinutes, gas: currentGas)
                segments.append(
                    BuhlmannRuntimeSegment(kind: isDescending ? .descent : .ascent, depthMeters: segment.depthMeters, minutes: transitionMinutes, gas: currentGas, note: "Bottom transition")
                )
                currentDepth = segment.depthMeters
            }
            if segment.gas != currentGas {
                currentGas = segment.gas
                segments.append(
                    BuhlmannRuntimeSegment(kind: .gasSwitch, depthMeters: currentDepth, minutes: 0.5, gas: currentGas, note: "Bottom gas switch")
                )
            }
            state = state.loadedConstantDepth(depthMeters: segment.depthMeters, minutes: segment.minutes, gas: segment.gas)
            totalMinutes += segment.minutes
            segments.append(
                BuhlmannRuntimeSegment(kind: .bottom, depthMeters: segment.depthMeters, minutes: segment.minutes, gas: segment.gas, note: "Bottom segment")
            )
        }

        return BottomLoadResult(state: state, depthMeters: currentDepth, gas: currentGas, minutes: totalMinutes)
    }

    private static func loadDescent(
        _ request: BuhlmannPlanRequest,
        startingState: BuhlmannTissueState,
        segments: inout [BuhlmannRuntimeSegment]
    ) -> BuhlmannTissueState {
        var state = startingState
        var currentDepth = 0.0
        var currentGas = firstDescentGas(for: request)
        let switches = request.travelGases
            .filter { $0.switchDepthMeters > 0.5 && $0.switchDepthMeters < request.maxDepthMeters - 0.5 }
            .sorted { $0.switchDepthMeters < $1.switchDepthMeters }
            + [request.bottomGas]

        for switchGas in switches {
            let targetDepth = switchGas.role == .bottom ? request.maxDepthMeters : switchGas.switchDepthMeters
            guard targetDepth > currentDepth else { continue }
            let minutes = max(0.1, (targetDepth - currentDepth) / request.descentRateMetersPerMinute)
            state = state.loadedLinearDepth(fromDepthMeters: currentDepth, toDepthMeters: targetDepth, minutes: minutes, gas: currentGas)
            segments.append(
                BuhlmannRuntimeSegment(kind: .descent, depthMeters: targetDepth, minutes: minutes, gas: currentGas, note: "Descent segment")
            )
            currentDepth = targetDepth
            if switchGas != currentGas {
                currentGas = switchGas
                segments.append(
                    BuhlmannRuntimeSegment(kind: .gasSwitch, depthMeters: currentDepth, minutes: 0.5, gas: currentGas, note: "Gas switch")
                )
            }
        }
        return state
    }

    private static func firstDescentGas(for request: BuhlmannPlanRequest) -> BuhlmannGas {
        request.travelGases.sorted { $0.switchDepthMeters < $1.switchDepthMeters }.first ?? request.bottomGas
    }

    private static func bestAscentGas(atDepth depth: Double, currentGas: BuhlmannGas, request: BuhlmannPlanRequest) -> BuhlmannGas {
        let candidates = request.decoGases
            .filter { $0.switchDepthMeters + 0.05 >= depth }
            .filter { gas in
                let ppo2 = gas.ppO2(depthMeters: depth)
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
