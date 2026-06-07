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
}
