import Foundation

enum TissueAnalyticsService {
    private static let maxCacheEntries = 32
    private static var cache: [String: TissueAnalyticsTrace] = [:]
    private static var cacheOrder: [String] = []

    static func presentationForCCRPlan(plan: CCRPlanResult, input: CCRPlanInput) -> TissueAnalyticsPresentation? {
        let key = ccrPlannerCacheKey(plan: plan, input: input)
        if let cached = cachedTrace(for: key) { return TissueAnalyticsPresentation(trace: cached, cacheKey: key) }
        guard let trace = buildFromCCRPlan(plan: plan, input: input) else { return nil }
        storeTrace(trace, for: key)
        return TissueAnalyticsPresentation(trace: trace, cacheKey: key)
    }

    static func presentationForPlanner(plan: DivePlanResult, input: GasPlanInput, mode: PlannerMode) -> TissueAnalyticsPresentation? {
        let key = plannerCacheKey(plan: plan, input: input, mode: mode)
        if let cached = cachedTrace(for: key) { return TissueAnalyticsPresentation(trace: cached, cacheKey: key) }
        guard let trace = buildFromPlanner(plan: plan, input: input, mode: mode) else { return nil }
        storeTrace(trace, for: key)
        return TissueAnalyticsPresentation(trace: trace, cacheKey: key)
    }

    static func presentationForSession(_ session: DiveSession) -> TissueAnalyticsPresentation? {
        let key = "session-\(session.id.uuidString)-\(session.samples.count)-\(session.durationSeconds)"
        if let cached = cachedTrace(for: key) { return TissueAnalyticsPresentation(trace: cached, cacheKey: key) }
        guard let trace = buildFromSession(session) else { return nil }
        storeTrace(trace, for: key)
        return TissueAnalyticsPresentation(trace: trace, cacheKey: key)
    }

    static func invalidateCache() {
        cache.removeAll()
        cacheOrder.removeAll()
    }

    #if DEBUG
    static func testHook_cacheEntryCount() -> Int {
        cacheOrder.count
    }
    #endif

    private static func cachedTrace(for key: String) -> TissueAnalyticsTrace? {
        cache[key]
    }

    private static func storeTrace(_ trace: TissueAnalyticsTrace, for key: String) {
        if cache[key] != nil {
            cacheOrder.removeAll { $0 == key }
        } else if cacheOrder.count >= maxCacheEntries, let evicted = cacheOrder.first {
            cache.removeValue(forKey: evicted)
            cacheOrder.removeFirst()
        }
        cache[key] = trace
        cacheOrder.append(key)
    }

    static func buildFromCCRPlan(plan: CCRPlanResult, input: CCRPlanInput) -> TissueAnalyticsTrace? {
        guard !plan.tissueTrace.isEmpty else { return nil }
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            return nil
        }
        let firstStopDepth = plan.decoStops.first?.depthMeters ?? 0
        let segments = plan.engineSegments.map {
            DivePlanSegment(kind: $0.kind, depthMeters: $0.depthMeters, minutes: $0.minutes, gas: $0.gas.label, note: $0.note)
        }
        let samples = buildCCRSamples(
            tissueHistory: plan.tissueTrace,
            depthProfilePoints: plan.depthProfilePoints,
            ppO2Timeline: plan.ppO2Timeline,
            ppN2Timeline: plan.ppN2Timeline,
            environment: environment,
            gfLow: input.gfLow,
            gfHigh: input.gfHigh,
            firstStopDepthMeters: firstStopDepth,
            diluentLabel: input.diluent.label
        )
        guard !samples.isEmpty else { return nil }

        let finalCompartments = finalLoadings(from: plan.tissueTrace)
        let controlling = finalCompartments.max(by: { $0.loadingPercent < $1.loadingPercent })?.compartmentIndex ?? 0
        let maxPPN2 = plan.ppN2Timeline.map(\.ppN2Bar).max() ?? 0
        let endMeters = NarcosisAnalyticsSupport.endMeters(fromPPN2Bar: maxPPN2, environment: environment)

        let summary = TissueAnalyticsSummary(
            maxDepthMeters: input.maxDepthMeters,
            bottomTimeMinutes: Int(input.bottomTimeMinutes.rounded()),
            ttsMinutes: plan.ttsMinutes,
            gfLow: Int(input.gfLow.rounded()),
            gfHigh: Int(input.gfHigh.rounded()),
            modeTitle: DIRIOSLocalizer.string("planner.mode.ccr"),
            totalRuntimeMinutes: plan.totalRuntimeMinutes
        )

        return TissueAnalyticsTrace(
            samples: samples,
            finalCompartments: finalCompartments,
            controllingCompartment: controlling,
            maxPPN2Bar: maxPPN2,
            endEquivalentMeters: endMeters,
            source: .ccrPlanned,
            summary: summary,
            depthProfilePoints: plan.depthProfilePoints,
            segments: segments,
            decoStops: plan.decoStops.map { TissueAnalyticsTrace.DecoStopSnapshot(depthMeters: $0.depthMeters, minutes: $0.minutes, gas: $0.gas) }
        )
    }

    static func buildFromPlanner(plan: DivePlanResult, input: GasPlanInput, mode: PlannerMode) -> TissueAnalyticsTrace? {
        let signpost = DIRPerformanceSignpost.begin(.tissueAnalyticsGeneration)
        defer { signpost.end() }

        guard !plan.tissueHistory.isEmpty else { return nil }
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            return nil
        }
        guard environment.surfacePressureBar.isFinite, environment.surfacePressureBar > 0 else { return nil }

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
            samples: downsampledSamples(samples),
            finalCompartments: finalCompartments,
            controllingCompartment: controlling,
            maxPPN2Bar: maxPPN2,
            endEquivalentMeters: endMeters,
            source: .planned,
            summary: summary,
            depthProfilePoints: downsampledDepthPoints(plan.depthProfilePoints),
            segments: plan.segments,
            decoStops: plan.decoStops.map { TissueAnalyticsTrace.DecoStopSnapshot(depthMeters: $0.depthMeters, minutes: $0.minutes, gas: $0.gas) }
        )
    }

    private static func downsampledSamples(_ samples: [TissueAnalyticsSample]) -> [TissueAnalyticsSample] {
        let cap = PresentationSeriesDownsampler.defaultMaxPresentationPoints
        guard samples.count > cap else { return samples }
        return PresentationSeriesDownsampler.downsampleUniform(samples, maxPoints: cap)
    }

    private static func downsampledDepthPoints(_ points: [DepthProfilePoint]) -> [DepthProfilePoint] {
        let cap = PresentationSeriesDownsampler.defaultMaxPresentationPoints
        guard points.count > cap else { return points }
        return PresentationSeriesDownsampler.downsampleUniform(points, maxPoints: cap)
    }

    static func logbookEntrySubtitle(for session: DiveSession) -> String {
        TissueAnalyticsLogbookReplay.logbookEntrySubtitle(for: session)
    }

    static func buildFromSession(_ session: DiveSession) -> TissueAnalyticsTrace? {
        guard let source = TissueAnalyticsLogbookReplay.resolvedSource(for: session) else { return nil }
        let environment = PlannerEnvironment.seaLevelSaltWater

        switch source {
        case .recorded:
            return TissueAnalyticsLogbookReplay.buildRecordedReplay(from: session, environment: environment)
        case .simulated:
            return TissueAnalyticsLogbookReplay.buildSimulatedEstimate(from: session, environment: environment)
        case .planned, .ccrPlanned, .insufficientData:
            return nil
        }
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

    private static func buildCCRSamples(
        tissueHistory: BuhlmannTissueHistory,
        depthProfilePoints: [DepthProfilePoint],
        ppO2Timeline: [CCRTimelineSample],
        ppN2Timeline: [CCRTimelineSample],
        environment: PlannerEnvironment,
        gfLow: Double,
        gfHigh: Double,
        firstStopDepthMeters: Double,
        diluentLabel: String
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
            let ppO2Sample = ppO2Timeline.min(by: { abs($0.runtimeMinutes - elapsed) < abs($1.runtimeMinutes - elapsed) })
            let ppN2Sample = ppN2Timeline.min(by: { abs($0.runtimeMinutes - elapsed) < abs($1.runtimeMinutes - elapsed) })
            let ppN2 = ppN2Sample?.ppN2Bar ?? 0
            let ppO2 = ppO2Sample?.ppO2Bar ?? 0
            let gf = BuhlmannEngine.gfAtDepth(
                depthMeters: depth,
                firstStopDepthMeters: firstStopDepthMeters,
                gfLow: gfLow,
                gfHigh: gfHigh
            )
            let ceiling = NarcosisAnalyticsSupport.ceilingMeters(
                from: controllingSample.toleratedAmbientPressureBar,
                environment: environment
            )
            return TissueAnalyticsSample(
                runtimeSeconds: Int(minute.rounded()) * 60,
                depthMeters: depth,
                activeGasName: "CCR \(diluentLabel)",
                compartmentLoadingsPercent: loadings,
                controllingCompartment: controlling,
                ceilingMeters: ceiling,
                ppN2Bar: ppN2,
                ppO2Bar: ppO2
            )
        }
    }

    private static func ccrPlannerCacheKey(plan: CCRPlanResult, input: CCRPlanInput) -> String {
        [
            "ccr-planner",
            String(format: "%.1f", input.maxDepthMeters),
            String(format: "%.1f", input.bottomTimeMinutes),
            String(format: "%.0f", input.gfLow),
            String(format: "%.0f", input.gfHigh),
            String(plan.totalRuntimeMinutes),
            String(plan.tissueTrace.samples.count)
        ].joined(separator: "-")
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
