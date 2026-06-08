import Foundation

/// Classifies logbook sessions for tissue/narcosis analytics and builds recorded-profile Bühlmann replay when safe.
enum TissueAnalyticsLogbookReplay {
    static let minimumSampleCount = 2
    static let defaultGFLow: Double = 30
    static let defaultGFHigh: Double = 85

    /// Resolves analytics source without building a full trace.
    static func resolvedSource(for session: DiveSession) -> TissueAnalyticsSource? {
        guard session.hasDepthProfile, !session.samples.isEmpty else { return nil }
        if session.samples.count < minimumSampleCount { return .insufficientData }
        if session.isManual { return .simulated }
        if requiresSimulatedFallback(for: session) { return .simulated }
        return .recorded
    }

    static func logbookEntrySubtitle(for session: DiveSession) -> String {
        guard let source = resolvedSource(for: session) else {
            return String(localized: "tissue_analytics.logbook.entry.subtitle.insufficient")
        }
        switch source {
        case .planned:
            return String(localized: "tissue_analytics.logbook.entry.subtitle.planned")
        case .recorded:
            return String(localized: "tissue_analytics.logbook.entry.subtitle.recorded")
        case .simulated:
            if session.isManual {
                return String(localized: "tissue_analytics.logbook.entry.subtitle.manual_synthetic")
            }
            return String(localized: "tissue_analytics.logbook.entry.subtitle.simulated")
        case .insufficientData:
            return String(localized: "tissue_analytics.logbook.entry.subtitle.insufficient")
        case .ccrPlanned:
            return String(localized: "tissue_analytics.source.ccr_planned")
        }
    }

    /// Trimix and other multigas profiles without logged switch history cannot be replayed safely.
    static func requiresSimulatedFallback(for session: DiveSession) -> Bool {
        session.gasLabel == .trimix
    }

    static func buildRecordedReplay(from session: DiveSession, environment: PlannerEnvironment) -> TissueAnalyticsTrace? {
        guard resolvedSource(for: session) == .recorded else { return nil }
        let sortedSamples = session.samples.sorted { $0.timestamp < $1.timestamp }
        guard sortedSamples.count >= minimumSampleCount,
              let firstTimestamp = sortedSamples.first?.timestamp else { return nil }

        let gas = assumedGas(for: session.gasLabel)
        var state = BuhlmannTissueState.airSaturated(surfacePressureBar: environment.surfacePressureBar)
        var analyticsSamples: [TissueAnalyticsSample] = []
        var depthPoints: [DepthProfilePoint] = []
        let gfLow = defaultGFLow
        let gfHigh = defaultGFHigh
        let firstStopDepth = 0.0

        func appendSample(at sample: DiveSample, runtimeSeconds: Int) {
            let depth = sample.depthMeters
            let elapsedMinutes = Double(runtimeSeconds) / 60.0
            depthPoints.append(DepthProfilePoint(elapsedMinutes: elapsedMinutes, depthMeters: depth))
            appendAnalyticsSample(
                runtimeSeconds: runtimeSeconds,
                depthMeters: depth,
                state: state,
                gas: gas,
                environment: environment,
                gfLow: gfLow,
                gfHigh: gfHigh,
                firstStopDepthMeters: firstStopDepth,
                into: &analyticsSamples
            )
        }

        appendSample(at: sortedSamples[0], runtimeSeconds: 0)

        for index in 0..<(sortedSamples.count - 1) {
            let previous = sortedSamples[index]
            let next = sortedSamples[index + 1]
            let minutes = next.timestamp.timeIntervalSince(previous.timestamp) / 60.0
            guard minutes.isFinite, minutes > 0 else { continue }
            state = state.loadedLinearDepth(
                fromDepthMeters: previous.depthMeters,
                toDepthMeters: next.depthMeters,
                minutes: minutes,
                gas: gas,
                environment: environment
            )
            let runtimeSeconds = Int(next.timestamp.timeIntervalSince(firstTimestamp).rounded())
            appendSample(at: next, runtimeSeconds: max(0, runtimeSeconds))
        }

        guard !analyticsSamples.isEmpty else { return nil }
        return makeTrace(
            session: session,
            analyticsSamples: analyticsSamples,
            depthPoints: depthPoints,
            environment: environment,
            source: .recorded,
            gfLow: Int(gfLow.rounded()),
            gfHigh: Int(gfHigh.rounded())
        )
    }

    static func buildSimulatedEstimate(from session: DiveSession, environment: PlannerEnvironment) -> TissueAnalyticsTrace? {
        guard session.hasDepthProfile, !session.samples.isEmpty else { return nil }
        let sortedSamples = session.samples.sorted { $0.timestamp < $1.timestamp }
        guard let firstTimestamp = sortedSamples.first?.timestamp else { return nil }

        let gas = assumedGas(for: session.gasLabel)
        let durationSeconds = max(1, Int(session.durationSeconds.rounded()))
        let totalMinutes = max(1, Int(ceil(Double(durationSeconds) / 60.0)))
        var state = BuhlmannTissueState.airSaturated(surfacePressureBar: environment.surfacePressureBar)
        var analyticsSamples: [TissueAnalyticsSample] = []
        var depthPoints: [DepthProfilePoint] = []
        let gfLow = defaultGFLow
        let gfHigh = defaultGFHigh
        let firstStopDepth = 0.0

        for minute in 0...totalMinutes {
            let runtimeSeconds = minute * 60
            let targetDate = firstTimestamp.addingTimeInterval(TimeInterval(runtimeSeconds))
            let depth = interpolatedDepth(at: targetDate, samples: sortedSamples, fallback: session.maxDepthMeters)
            depthPoints.append(DepthProfilePoint(elapsedMinutes: Double(minute), depthMeters: depth))

            if minute > 0 {
                state = state.loadedConstantDepth(depthMeters: depth, minutes: 1, gas: gas, environment: environment)
            }

            appendAnalyticsSample(
                runtimeSeconds: runtimeSeconds,
                depthMeters: depth,
                state: state,
                gas: gas,
                environment: environment,
                gfLow: gfLow,
                gfHigh: gfHigh,
                firstStopDepthMeters: firstStopDepth,
                into: &analyticsSamples
            )
        }

        guard !analyticsSamples.isEmpty else { return nil }
        return makeTrace(
            session: session,
            analyticsSamples: analyticsSamples,
            depthPoints: depthPoints,
            environment: environment,
            source: .simulated,
            gfLow: Int(gfLow.rounded()),
            gfHigh: Int(gfHigh.rounded())
        )
    }

    private static func makeTrace(
        session: DiveSession,
        analyticsSamples: [TissueAnalyticsSample],
        depthPoints: [DepthProfilePoint],
        environment: PlannerEnvironment,
        source: TissueAnalyticsSource,
        gfLow: Int,
        gfHigh: Int
    ) -> TissueAnalyticsTrace {
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
        let totalMinutes = max(1, Int(ceil(Double(max(1, Int(session.durationSeconds.rounded()))) / 60.0)))

        let summary = TissueAnalyticsSummary(
            maxDepthMeters: session.maxDepthMeters,
            bottomTimeMinutes: totalMinutes,
            ttsMinutes: totalMinutes,
            gfLow: gfLow,
            gfHigh: gfHigh,
            modeTitle: String(localized: "tissue_analytics.mode.logbook"),
            totalRuntimeMinutes: totalMinutes
        )

        return TissueAnalyticsTrace(
            samples: analyticsSamples,
            finalCompartments: finalCompartments,
            controllingCompartment: controlling,
            maxPPN2Bar: maxPPN2,
            endEquivalentMeters: NarcosisAnalyticsSupport.endMeters(fromPPN2Bar: maxPPN2, environment: environment),
            source: source,
            summary: summary,
            depthProfilePoints: depthPoints,
            segments: [],
            decoStops: []
        )
    }

    private static func appendAnalyticsSample(
        runtimeSeconds: Int,
        depthMeters: Double,
        state: BuhlmannTissueState,
        gas: BuhlmannGas,
        environment: PlannerEnvironment,
        gfLow: Double,
        gfHigh: Double,
        firstStopDepthMeters: Double,
        into analyticsSamples: inout [TissueAnalyticsSample]
    ) {
        let gf = BuhlmannEngine.gfAtDepth(
            depthMeters: depthMeters,
            firstStopDepthMeters: firstStopDepthMeters,
            gfLow: gfLow,
            gfHigh: gfHigh
        )
        var loadings = [Double](repeating: 0, count: BuhlmannConstants.compartmentCount)
        var controlling = 0
        var maxLoad = -1.0
        var controllingTolerated = 0.0

        for index in 0..<BuhlmannConstants.compartmentCount {
            guard let metrics = BuhlmannTissueHistorySampler.compartmentMetrics(
                compartmentIndex: index,
                state: state,
                depthMeters: depthMeters,
                gas: gas,
                gf: gf,
                environment: environment
            ) else {
                continue
            }
            loadings[index] = metrics.loadPercent
            if metrics.loadPercent > maxLoad {
                maxLoad = metrics.loadPercent
                controlling = index
                controllingTolerated = metrics.toleratedAmbientPressureBar
            }
        }

        let ppN2 = NarcosisAnalyticsSupport.ppN2Bar(depthMeters: depthMeters, gas: gas, environment: environment)
        let ppO2 = NarcosisAnalyticsSupport.ppO2Bar(depthMeters: depthMeters, gas: gas, environment: environment)
        let ceiling = NarcosisAnalyticsSupport.ceilingMeters(from: controllingTolerated, environment: environment)

        analyticsSamples.append(
            TissueAnalyticsSample(
                runtimeSeconds: runtimeSeconds,
                depthMeters: depthMeters,
                activeGasName: gas.label,
                compartmentLoadingsPercent: loadings,
                controllingCompartment: controlling,
                ceilingMeters: ceiling,
                ppN2Bar: ppN2,
                ppO2Bar: ppO2
            )
        )
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
        case .ccr:
            return BuhlmannGas(name: "CCR diluent", role: .bottom, oxygenFraction: 0.21, heliumFraction: 0, maxPPO2Bar: 1.3, switchDepthMeters: 0)
        }
    }
}
