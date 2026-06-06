import Foundation

enum TissueAnalyticsService {
    private static var cache: [String: TissueAnalyticsTrace] = [:]

    static func presentationForPlanner(plan: DivePlanResult, input: GasPlanInput, mode: PlannerMode) -> TissueAnalyticsPresentation? {
        let key = plannerCacheKey(plan: plan, input: input, mode: mode)
        if let cached = cache[key] { return TissueAnalyticsPresentation(trace: cached, cacheKey: key) }
        guard let trace = buildFromPlanner(plan: plan, input: input, mode: mode) else { return nil }
        cache[key] = trace
        return TissueAnalyticsPresentation(trace: trace, cacheKey: key)
    }

    static func presentationForSession(_ session: DiveSession) -> TissueAnalyticsPresentation? {
        let key = "session-\(session.id.uuidString)-\(session.samples.count)-\(session.durationSeconds)"
        if let cached = cache[key] { return TissueAnalyticsPresentation(trace: cached, cacheKey: key) }
        guard let trace = buildFromSession(session) else { return nil }
        cache[key] = trace
        return TissueAnalyticsPresentation(trace: trace, cacheKey: key)
    }

    static func invalidateCache() {
        cache.removeAll()
    }

    static func buildFromPlanner(plan: DivePlanResult, input: GasPlanInput, mode: PlannerMode) -> TissueAnalyticsTrace? {
        guard !plan.tissueHistory.isEmpty else { return nil }
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            return nil
        }

        let firstStopDepth = plan.decoStops.first?.depthMeters ?? 0
        let samples = buildSamples(
            tissueHistory: plan.tissueHistory,
            depthProfilePoints: plan.depthProfilePoints,
            segments: plan.segments,
            input: input,
            environment: environment,
            gfLow: input.gfLow,
            gfHigh: input.gfHigh,
            firstStopDepthMeters: firstStopDepth
        )
        guard !samples.isEmpty else { return nil }

        let finalCompartments = finalLoadings(from: plan.tissueHistory)
        let controlling = finalCompartments.max(by: { $0.loadingPercent < $1.loadingPercent })?.compartmentIndex ?? 0
        let maxPPN2 = samples.map(\.ppN2Bar).max() ?? 0
        let endMeters = NarcosisAnalyticsSupport.endMeters(fromPPN2Bar: maxPPN2, environment: environment)

        let summary = TissueAnalyticsSummary(
            maxDepthMeters: input.plannedDepthMeters,
            bottomTimeMinutes: Int(input.plannedBottomMinutes.rounded()),
            ttsMinutes: plan.ttsMinutes,
            gfLow: Int(input.gfLow.rounded()),
            gfHigh: Int(input.gfHigh.rounded()),
            modeTitle: mode.localizedTabTitle,
            totalRuntimeMinutes: plan.totalRuntimeMinutes
        )

        return TissueAnalyticsTrace(
            samples: samples,
            finalCompartments: finalCompartments,
            controllingCompartment: controlling,
            maxPPN2Bar: maxPPN2,
            endEquivalentMeters: endMeters,
            source: .planned,
            summary: summary,
            depthProfilePoints: plan.depthProfilePoints,
            segments: plan.segments,
            decoStops: plan.decoStops.map { TissueAnalyticsTrace.DecoStopSnapshot(depthMeters: $0.depthMeters, minutes: $0.minutes, gas: $0.gas) }
        )
    }

    static func buildFromSession(_ session: DiveSession) -> TissueAnalyticsTrace? {
        guard session.hasDepthProfile, !session.samples.isEmpty else { return nil }
        let environment = PlannerEnvironment.seaLevelSaltWater
        let gas = assumedGas(for: session.gasLabel)
        let sortedSamples = session.samples.sorted { $0.timestamp < $1.timestamp }
        guard let firstTimestamp = sortedSamples.first?.timestamp else { return nil }

        let durationSeconds = max(1, Int(session.durationSeconds.rounded()))
        let totalMinutes = max(1, Int(ceil(Double(durationSeconds) / 60.0)))
        let firstStopDepth = 0.0
        var state = BuhlmannTissueState.airSaturated(surfacePressureBar: environment.surfacePressureBar)
        var analyticsSamples: [TissueAnalyticsSample] = []
        var depthPoints: [DepthProfilePoint] = []

        for minute in 0...totalMinutes {
            let runtimeSeconds = minute * 60
            let targetDate = firstTimestamp.addingTimeInterval(TimeInterval(runtimeSeconds))
            let depth = interpolatedDepth(at: targetDate, samples: sortedSamples, fallback: session.maxDepthMeters)
            depthPoints.append(DepthProfilePoint(elapsedMinutes: Double(minute), depthMeters: depth))

            if minute > 0 {
                state = state.loadedConstantDepth(depthMeters: depth, minutes: 1, gas: gas, environment: environment)
            }

            let gf = 0.85
            var loadings = [Double](repeating: 0, count: BuhlmannConstants.compartmentCount)
            var controlling = 0
            var maxLoad = -1.0
            var controllingMetrics = (
                n2: 0.0, he: 0.0, total: 0.0, tolerated: 0.0, load: 0.0
            )

            for index in 0..<BuhlmannConstants.compartmentCount {
                let metrics = BuhlmannTissueHistorySampler.compartmentMetrics(
                    compartmentIndex: index,
                    state: state,
                    depthMeters: depth,
                    gas: gas,
                    gf: gf,
                    environment: environment
                )
                loadings[index] = metrics.loadPercent
                if metrics.loadPercent > maxLoad {
                    maxLoad = metrics.loadPercent
                    controlling = index
                    controllingMetrics = (metrics.nitrogenPressureBar, metrics.heliumPressureBar, metrics.totalInertPressureBar, metrics.toleratedAmbientPressureBar, metrics.loadPercent)
                }
            }

            let ppN2 = NarcosisAnalyticsSupport.ppN2Bar(depthMeters: depth, gas: gas, environment: environment)
            let ppO2 = NarcosisAnalyticsSupport.ppO2Bar(depthMeters: depth, gas: gas, environment: environment)
            let ceiling = NarcosisAnalyticsSupport.ceilingMeters(from: controllingMetrics.tolerated, environment: environment)

            analyticsSamples.append(
                TissueAnalyticsSample(
                    runtimeSeconds: runtimeSeconds,
                    depthMeters: depth,
                    activeGasName: gas.label,
                    compartmentLoadingsPercent: loadings,
                    controllingCompartment: controlling,
                    ceilingMeters: ceiling,
                    ppN2Bar: ppN2,
                    ppO2Bar: ppO2
                )
            )
        }

        let finalCompartments = analyticsSamples.last.map { sample in
            sample.compartmentLoadingsPercent.enumerated().map { index, loading in
                TissueCompartmentLoading(
                    compartmentIndex: index,
                    loadingPercent: loading,
                    n2Pressure: 0,
                    hePressure: 0,
                    totalInertPressure: 0
                )
            }
        } ?? []

        let controlling = finalCompartments.max(by: { $0.loadingPercent < $1.loadingPercent })?.compartmentIndex ?? 0
        let maxPPN2 = analyticsSamples.map(\.ppN2Bar).max() ?? 0

        let summary = TissueAnalyticsSummary(
            maxDepthMeters: session.maxDepthMeters,
            bottomTimeMinutes: max(1, totalMinutes),
            ttsMinutes: totalMinutes,
            gfLow: 30,
            gfHigh: 85,
            modeTitle: String(localized: "tissue_analytics.mode.logbook"),
            totalRuntimeMinutes: totalMinutes
        )

        return TissueAnalyticsTrace(
            samples: analyticsSamples,
            finalCompartments: finalCompartments,
            controllingCompartment: controlling,
            maxPPN2Bar: maxPPN2,
            endEquivalentMeters: NarcosisAnalyticsSupport.endMeters(fromPPN2Bar: maxPPN2, environment: environment),
            source: .simulated,
            summary: summary,
            depthProfilePoints: depthPoints,
            segments: [],
            decoStops: []
        )
    }

    private static func buildSamples(
        tissueHistory: BuhlmannTissueHistory,
        depthProfilePoints: [DepthProfilePoint],
        segments: [DivePlanSegment],
        input: GasPlanInput,
        environment: PlannerEnvironment,
        gfLow: Double,
        gfHigh: Double,
        firstStopDepthMeters: Double
    ) -> [TissueAnalyticsSample] {
        let timestamps = Set(tissueHistory.samples.map(\.elapsedMinutes)).sorted()
        return timestamps.compactMap { minute in
            let bucket = tissueHistory.samples.filter { $0.elapsedMinutes == minute }
            guard bucket.count == BuhlmannConstants.compartmentCount else { return nil }
            let loadings = (0..<BuhlmannConstants.compartmentCount).map { index in
                bucket.first(where: { $0.compartmentIndex == index })?.loadPercent ?? 0
            }
            let controlling = loadings.enumerated().max(by: { $0.element < $1.element })?.offset ?? 0
            let controllingSample = bucket.first(where: { $0.compartmentIndex == controlling }) ?? bucket[0]
            let elapsed = Double(minute)
            let depth = interpolatedDepth(minutes: elapsed, points: depthProfilePoints)
            let gas = gasAt(elapsedMinutes: elapsed, segments: segments, input: input)
            let gf = BuhlmannEngine.gfAtDepth(
                depthMeters: depth,
                firstStopDepthMeters: firstStopDepthMeters,
                gfLow: gfLow,
                gfHigh: gfHigh
            )
            let ppN2 = NarcosisAnalyticsSupport.ppN2Bar(depthMeters: depth, gas: gas, environment: environment)
            let ppO2 = NarcosisAnalyticsSupport.ppO2Bar(depthMeters: depth, gas: gas, environment: environment)
            let ceiling = NarcosisAnalyticsSupport.ceilingMeters(
                from: controllingSample.toleratedAmbientPressureBar,
                environment: environment
            )
            return TissueAnalyticsSample(
                runtimeSeconds: Int(minute.rounded()) * 60,
                depthMeters: depth,
                activeGasName: gas.label,
                compartmentLoadingsPercent: loadings,
                controllingCompartment: controlling,
                ceilingMeters: ceiling,
                ppN2Bar: ppN2,
                ppO2Bar: ppO2
            )
        }
    }

    private static func finalLoadings(from tissueHistory: BuhlmannTissueHistory) -> [TissueCompartmentLoading] {
        guard let lastMinute = tissueHistory.samples.map(\.elapsedMinutes).max() else { return [] }
        let lastBucket = tissueHistory.samples.filter { abs($0.elapsedMinutes - lastMinute) < 0.001 }
        return (0..<BuhlmannConstants.compartmentCount).compactMap { index in
            guard let sample = lastBucket.first(where: { $0.compartmentIndex == index }) else { return nil }
            return TissueCompartmentLoading(
                compartmentIndex: index,
                loadingPercent: sample.loadPercent,
                n2Pressure: sample.nitrogenPressureBar,
                hePressure: sample.heliumPressureBar,
                totalInertPressure: sample.totalInertPressureBar
            )
        }
    }

    private static func gasAt(elapsedMinutes: Double, segments: [DivePlanSegment], input: GasPlanInput) -> BuhlmannGas {
        var accumulated = 0.0
        var lastGas = BuhlmannGas(gas: input.bottomGas, role: .bottom)
        for segment in segments {
            accumulated += segment.minutes
            if let resolved = resolveGas(name: segment.gas, input: input) {
                lastGas = resolved
            }
            if elapsedMinutes <= accumulated + 0.001 {
                return lastGas
            }
        }
        return lastGas
    }

    private static func resolveGas(name: String, input: GasPlanInput) -> BuhlmannGas? {
        let normalized = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        for entry in input.plannerCylinders {
            let candidates = [
                entry.gas.name.lowercased(),
                entry.gas.mixKind.plannerPickerTitle.lowercased(),
                entry.role.localizedTitle.lowercased()
            ]
            if candidates.contains(where: { normalized.contains($0) || $0.contains(normalized) }) {
                return BuhlmannGas(gas: entry.gas, role: entry.role, switchDepthMeters: entry.switchDepthMeters, cylinderId: entry.id)
            }
        }
        if normalized.contains("air") { return BuhlmannGas(gas: input.bottomGas, role: .bottom) }
        return BuhlmannGas(gas: input.bottomGas, role: .bottom)
    }

    private static func interpolatedDepth(minutes: Double, points: [DepthProfilePoint]) -> Double {
        guard !points.isEmpty else { return 0 }
        if minutes <= points[0].elapsedMinutes { return points[0].depthMeters }
        if minutes >= points.last!.elapsedMinutes { return points.last!.depthMeters }
        for index in 1..<points.count {
            let previous = points[index - 1]
            let next = points[index]
            if minutes <= next.elapsedMinutes {
                let span = next.elapsedMinutes - previous.elapsedMinutes
                guard span > 0 else { return next.depthMeters }
                let progress = (minutes - previous.elapsedMinutes) / span
                return previous.depthMeters + (next.depthMeters - previous.depthMeters) * progress
            }
        }
        return points.last?.depthMeters ?? 0
    }

    private static func interpolatedDepth(at date: Date, samples: [DiveSample], fallback: Double) -> Double {
        guard !samples.isEmpty else { return fallback }
        if date <= samples[0].timestamp { return samples[0].depthMeters }
        if date >= samples.last!.timestamp { return samples.last!.depthMeters }
        for index in 1..<samples.count {
            let previous = samples[index - 1]
            let next = samples[index]
            if date <= next.timestamp {
                let span = next.timestamp.timeIntervalSince(previous.timestamp)
                guard span > 0 else { return next.depthMeters }
                let progress = date.timeIntervalSince(previous.timestamp) / span
                return previous.depthMeters + (next.depthMeters - previous.depthMeters) * progress
            }
        }
        return fallback
    }

    private static func assumedGas(for label: DiveGasLabel) -> BuhlmannGas {
        switch label {
        case .oc:
            return BuhlmannGas(name: "Air", role: .bottom, oxygenFraction: 0.21, heliumFraction: 0, maxPPO2Bar: 1.4, switchDepthMeters: 0)
        case .nitrox:
            return BuhlmannGas(name: "EAN32", role: .bottom, oxygenFraction: 0.32, heliumFraction: 0, maxPPO2Bar: 1.4, switchDepthMeters: 0)
        case .trimix:
            return BuhlmannGas(name: "TX18/45", role: .bottom, oxygenFraction: 0.18, heliumFraction: 0.45, maxPPO2Bar: 1.4, switchDepthMeters: 0)
        }
    }

    private static func plannerCacheKey(plan: DivePlanResult, input: GasPlanInput, mode: PlannerMode) -> String {
        [
            "planner",
            mode.rawValue,
            String(format: "%.1f", input.plannedDepthMeters),
            String(format: "%.1f", input.plannedBottomMinutes),
            String(format: "%.0f", input.gfLow),
            String(format: "%.0f", input.gfHigh),
            String(plan.totalRuntimeMinutes),
            String(plan.tissueHistory.samples.count)
        ].joined(separator: "-")
    }
}
