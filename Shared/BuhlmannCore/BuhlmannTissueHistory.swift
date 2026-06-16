import Foundation

/// One sampled compartment state for visualization. Sampling does not alter decompression math.
struct BuhlmannTissueHistorySample: Hashable, Codable {
    let elapsedMinutes: Double
    let compartmentIndex: Int
    let nitrogenPressureBar: Double
    let heliumPressureBar: Double
    let totalInertPressureBar: Double
    let ambientPressureBar: Double
    let toleratedAmbientPressureBar: Double
    let loadPercent: Double
    let supersaturationPercent: Double
    let compartmentGroup: String
}

/// Aggregated group trace for charting. Uses max `loadPercent` per group at each timestamp.
struct BuhlmannTissueGroupPoint: Hashable, Identifiable, Codable {
    var id: String { "\(elapsedMinutes)-\(compartmentGroup)" }
    let elapsedMinutes: Double
    let compartmentGroup: String
    let loadPercent: Double
    let supersaturationPercent: Double
}

struct BuhlmannTissueHistory: Hashable, Codable {
    let samples: [BuhlmannTissueHistorySample]
    let groupedPoints: [BuhlmannTissueGroupPoint]
    let aggregationMethod: String

    static let empty = BuhlmannTissueHistory(samples: [], groupedPoints: [], aggregationMethod: "max_load_percent")

    var isEmpty: Bool { samples.isEmpty }
}

enum BuhlmannTissueHistorySampler {
    static let sampleIntervalMinutes = 1.0
    static let aggregationMethod = "max_load_percent_per_group"

    static func sample(request: BuhlmannPlanRequest, engineResult: BuhlmannEngineResult) -> BuhlmannTissueHistory {
        guard !engineResult.hasBlockingIssues,
              engineResult.modelState == .validReference,
              !engineResult.segments.isEmpty else {
            return .empty
        }

        let firstStopDepth = engineResult.stops.first?.depthMeters ?? 0
        var samples: [BuhlmannTissueHistorySample] = []
        var state = request.initialTissueState
        var currentDepth = 0.0
        var currentGas = firstDescentGas(for: request)
        var elapsed = 0.0

        recordSamples(
            state: state,
            depthMeters: currentDepth,
            gas: currentGas,
            elapsedMinutes: elapsed,
            request: request,
            firstStopDepthMeters: firstStopDepth,
            into: &samples
        )

        for segment in engineResult.segments {
            let fromDepth = currentDepth
            let toDepth = segment.depthMeters
            let gas = segment.gas

            switch segment.kind {
            case .descent, .ascent:
                loadLinearWithSampling(
                    state: &state,
                    fromDepthMeters: fromDepth,
                    toDepthMeters: toDepth,
                    totalMinutes: segment.minutes,
                    gas: gas,
                    elapsed: &elapsed,
                    request: request,
                    firstStopDepthMeters: firstStopDepth,
                    samples: &samples
                )
            case .bottom, .stop, .gasSwitch:
                loadConstantWithSampling(
                    state: &state,
                    depthMeters: toDepth,
                    totalMinutes: segment.minutes,
                    gas: gas,
                    elapsed: &elapsed,
                    request: request,
                    firstStopDepthMeters: firstStopDepth,
                    samples: &samples
                )
            }

            currentDepth = toDepth
            currentGas = gas
        }

        return BuhlmannTissueHistory(
            samples: samples,
            groupedPoints: groupedPoints(from: samples),
            aggregationMethod: aggregationMethod
        )
    }

    static func groupedPoints(from samples: [BuhlmannTissueHistorySample]) -> [BuhlmannTissueGroupPoint] {
        let groups = ["1-4", "5-8", "9-12", "13-16"]
        let byTime = Dictionary(grouping: samples) { roundElapsed($0.elapsedMinutes) }
        return byTime.keys.sorted().flatMap { time in
            let bucket = byTime[time] ?? []
            return groups.compactMap { group -> BuhlmannTissueGroupPoint? in
                let groupSamples = bucket.filter { $0.compartmentGroup == group }
                guard !groupSamples.isEmpty else { return nil }
                return BuhlmannTissueGroupPoint(
                    elapsedMinutes: time,
                    compartmentGroup: group,
                    loadPercent: groupSamples.map(\.loadPercent).max() ?? 0,
                    supersaturationPercent: groupSamples.map(\.supersaturationPercent).max() ?? 0
                )
            }
        }
    }

    private static func roundElapsed(_ minutes: Double) -> Double {
        (minutes * 1_000).rounded() / 1_000
    }

    private static func loadConstantWithSampling(
        state: inout BuhlmannTissueState,
        depthMeters: Double,
        totalMinutes: Double,
        gas: BuhlmannGas,
        elapsed: inout Double,
        request: BuhlmannPlanRequest,
        firstStopDepthMeters: Double,
        samples: inout [BuhlmannTissueHistorySample]
    ) {
        guard totalMinutes.isFinite, totalMinutes > 0 else { return }
        var remaining = totalMinutes
        while remaining > 0.000_1 {
            let step = min(sampleIntervalMinutes, remaining)
            state = state.loadedConstantDepth(
                depthMeters: depthMeters,
                minutes: step,
                gas: gas,
                environment: request.plannerEnvironment
            )
            elapsed += step
            recordSamples(
                state: state,
                depthMeters: depthMeters,
                gas: gas,
                elapsedMinutes: elapsed,
                request: request,
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
        gas: BuhlmannGas,
        elapsed: inout Double,
        request: BuhlmannPlanRequest,
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
            state = state.loadedLinearDepth(
                fromDepthMeters: segmentStartDepth,
                toDepthMeters: segmentEndDepth,
                minutes: step,
                gas: gas,
                environment: request.plannerEnvironment
            )
            segmentStartDepth = segmentEndDepth
            elapsed += step
            recordSamples(
                state: state,
                depthMeters: segmentEndDepth,
                gas: gas,
                elapsedMinutes: elapsed,
                request: request,
                firstStopDepthMeters: firstStopDepthMeters,
                into: &samples
            )
            remaining -= step
        }
    }

    private static func recordSamples(
        state: BuhlmannTissueState,
        depthMeters: Double,
        gas: BuhlmannGas,
        elapsedMinutes: Double,
        request: BuhlmannPlanRequest,
        firstStopDepthMeters: Double,
        into samples: inout [BuhlmannTissueHistorySample]
    ) {
        guard AmbientPressureModel.ambientPressureBar(depthMeters: depthMeters, environment: request.plannerEnvironment) != nil else {
            return
        }
        let gf = gradientFactor(
            depthMeters: depthMeters,
            firstStopDepthMeters: firstStopDepthMeters,
            request: request
        )
        for index in 0..<BuhlmannConstants.compartmentCount {
            guard let metrics = compartmentMetrics(
                compartmentIndex: index,
                state: state,
                depthMeters: depthMeters,
                gas: gas,
                gf: gf,
                environment: request.plannerEnvironment
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
                compartmentGroup: compartmentGroup(for: index)
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

    static func compartmentGroup(for index: Int) -> String {
        switch index {
        case 0..<4: return "1-4"
        case 4..<8: return "5-8"
        case 8..<12: return "9-12"
        default: return "13-16"
        }
    }

    static func compartmentMetrics(
        compartmentIndex: Int,
        state: BuhlmannTissueState,
        depthMeters: Double,
        gas: BuhlmannGas,
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
        let compartment = state.compartments[compartmentIndex]
        let pn2 = sanitize(compartment.nitrogenPressure)
        let phe = sanitize(compartment.heliumPressure)
        let total = sanitize(pn2 + phe)
        guard let ambientRaw = AmbientPressureModel.ambientPressureBar(depthMeters: depthMeters, environment: environment) else {
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
        let inspiredInert = sanitize(
            gas.inspiredPressure(depthMeters: depthMeters, inert: .nitrogen, environment: environment)
                + gas.inspiredPressure(depthMeters: depthMeters, inert: .helium, environment: environment)
        )

        let loadPercent = displayPercent(numerator: total, denominator: max(mValue, 0.001))
        let superNumerator = total - inspiredInert
        let superDenominator = max(mValue - inspiredInert, 0.001)
        let supersaturationPercent = displayPercent(numerator: superNumerator, denominator: superDenominator)

        return (pn2, phe, total, ambient, toleratedAmbient, loadPercent, supersaturationPercent)
    }

    private static func gradientFactor(
        depthMeters: Double,
        firstStopDepthMeters: Double,
        request: BuhlmannPlanRequest
    ) -> Double {
        if firstStopDepthMeters <= 0.01 {
            return request.gfHigh / 100.0
        }
        return BuhlmannEngine.gfAtDepth(
            depthMeters: depthMeters,
            firstStopDepthMeters: firstStopDepthMeters,
            gfLow: request.gfLow,
            gfHigh: request.gfHigh
        )
    }

    private static func firstDescentGas(for request: BuhlmannPlanRequest) -> BuhlmannGas {
        request.travelGases.sorted { $0.switchDepthMeters < $1.switchDepthMeters }.first ?? request.bottomGas
    }

    private static func sanitize(_ value: Double) -> Double {
        guard value.isFinite else { return 0 }
        return max(0, value)
    }

    /// Display-only clamp documented in IOS_PLANNER_CHART_TRUTHFULNESS.md; algorithm state is not clamped.
    private static func displayPercent(numerator: Double, denominator: Double) -> Double {
        guard denominator.isFinite, denominator > 0, numerator.isFinite else { return 0 }
        let raw = (numerator / denominator) * 100.0
        guard raw.isFinite else { return 0 }
        return min(100, max(0, raw))
    }
}
