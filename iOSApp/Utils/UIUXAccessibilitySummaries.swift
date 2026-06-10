import Foundation

enum UIUXAccessibilitySummaries {
    static func ratioDecoOverlayChart(
        buhlmannTTS: Int,
        ratioTTS: Int,
        maxDepthMeters: Double,
        validation: RatioDecoValidationResult,
        unitPreference: IOSUnitPreference
    ) -> String {
        let depth = Formatters.depth(maxDepthMeters, units: unitPreference).text
        if validation.isBuhlmannCompatible {
            return String(
                format: String(localized: "planner.ratio_deco.overlay.a11y.compatible"),
                buhlmannTTS,
                ratioTTS,
                depth
            )
        }
        return String(
            format: String(localized: "planner.ratio_deco.overlay.a11y.incompatible"),
            buhlmannTTS,
            ratioTTS,
            depth,
            validation.localizedStatusTitle
        )
    }

    static func maxDepth(from points: [DepthProfilePoint]) -> Double {
        points.map(\.depthMeters).max() ?? 0
    }

    static func tissueTrend(trace: TissueAnalyticsTrace, unitPreference: IOSUnitPreference) -> String {
        let peak = peakControllingLoad(in: trace)
        let controlling = TissueAnalyticsTheme.controllingCompartmentLabel(index: trace.controllingCompartment)
        return String(
            format: String(localized: "tissue_analytics.a11y.trend"),
            trace.source.localizedTitle,
            controlling,
            Int(peak.rounded())
        )
    }

    static func tissueCompartments(trace: TissueAnalyticsTrace) -> String {
        let peak = trace.finalCompartments.map(\.loadingPercent).max() ?? 0
        let controlling = TissueAnalyticsTheme.controllingCompartmentLabel(index: trace.controllingCompartment)
        return String(
            format: String(localized: "tissue_analytics.a11y.compartment_bars"),
            trace.source.localizedTitle,
            controlling,
            Int(peak.rounded())
        )
    }

    static func tissueNarcosis(trace: TissueAnalyticsTrace, unitPreference: IOSUnitPreference) -> String {
        let endDepth = Formatters.depth(trace.endEquivalentMeters, units: unitPreference).text
        return String(
            format: String(localized: "tissue_analytics.a11y.narcotic_chart"),
            trace.source.localizedTitle,
            Formatters.one(trace.maxPPN2Bar),
            endDepth
        )
    }

    private static func peakControllingLoad(in trace: TissueAnalyticsTrace) -> Double {
        trace.samples.map { sample in
            guard trace.controllingCompartment >= 0,
                  trace.controllingCompartment < sample.compartmentLoadingsPercent.count else { return 0 }
            return sample.compartmentLoadingsPercent[trace.controllingCompartment]
        }.max() ?? 0
    }

    static func ccrPPO2Timeline(samples: [CCRTimelineSample], setpointHigh: Double) -> String {
        guard let first = samples.first, let last = samples.last, !samples.isEmpty else {
            return String(localized: "ccr.a11y.ppo2.empty")
        }
        let values = samples.map(\.ppO2Bar)
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 0
        let average = values.reduce(0, +) / Double(values.count)
        let warning = maxValue > setpointHigh + 0.05
            ? String(localized: "ccr.a11y.ppo2.warning_high")
            : String(localized: "ccr.a11y.ppo2.within_range")
        return String(
            format: String(localized: "ccr.a11y.ppo2.summary"),
            Formatters.one(minValue),
            Formatters.one(maxValue),
            Formatters.one(average),
            Int(first.runtimeMinutes.rounded()),
            Int(last.runtimeMinutes.rounded()),
            warning
        )
    }

    static func ccrPPN2Timeline(samples: [CCRTimelineSample]) -> String {
        guard let first = samples.first, let last = samples.last, !samples.isEmpty else {
            return String(localized: "ccr.a11y.ppn2.empty")
        }
        let values = samples.map(\.ppN2Bar)
        return String(
            format: String(localized: "ccr.a11y.ppn2.summary"),
            Formatters.one(values.min() ?? 0),
            Formatters.one(values.max() ?? 0),
            Formatters.one(values.reduce(0, +) / Double(values.count)),
            Int(first.runtimeMinutes.rounded()),
            Int(last.runtimeMinutes.rounded())
        )
    }

    static func ccrENDTimeline(samples: [CCRTimelineSample], unitPreference: IOSUnitPreference) -> String {
        guard let first = samples.first, let last = samples.last, !samples.isEmpty else {
            return String(localized: "ccr.a11y.end.empty")
        }
        let values = samples.map(\.endMeters)
        let maxEND = Formatters.depth(values.max() ?? 0, units: unitPreference).text
        return String(
            format: String(localized: "ccr.a11y.end.summary"),
            maxEND,
            Int(first.runtimeMinutes.rounded()),
            Int(last.runtimeMinutes.rounded()),
            String(localized: "ccr.a11y.reference_estimate_note")
        )
    }

    static func ccrGasDensityTimeline(
        samples: [(runtimeMinutes: Double, density: Double)]
    ) -> String {
        guard let first = samples.first, let last = samples.last, !samples.isEmpty else {
            return String(localized: "ccr.a11y.density.empty")
        }
        let values = samples.map(\.density)
        return String(
            format: String(localized: "ccr.a11y.density.summary"),
            Formatters.one(values.min() ?? 0),
            Formatters.one(values.max() ?? 0),
            Int(first.runtimeMinutes.rounded()),
            Int(last.runtimeMinutes.rounded()),
            String(localized: "ccr.a11y.reference_estimate_note")
        )
    }
}
