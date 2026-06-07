import SwiftUI
import Charts

struct TissueDiveProfileChart: View {
    let points: [DepthProfilePoint]
    let segments: [DivePlanSegment]
    let decoStops: [TissueAnalyticsTrace.DecoStopSnapshot]
    let unitPreference: IOSUnitPreference

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer()
                legendItem(color: TissueAnalyticsTheme.accentBlue, label: String(localized: "tissue_analytics.legend.depth"))
                legendItem(color: TissueAnalyticsTheme.green, label: String(localized: "tissue_analytics.legend.active_gas"))
            }
            .font(.system(size: 11))
            .foregroundStyle(TissueAnalyticsTheme.labelSecondary)

            Chart {
                ForEach(points) { point in
                    AreaMark(
                        x: .value("Time", point.elapsedMinutes),
                        y: .value("Depth", -displayDepth(point.depthMeters))
                    )
                    .foregroundStyle(TissueAnalyticsTheme.accentBlue.opacity(0.22))
                    LineMark(
                        x: .value("Time", point.elapsedMinutes),
                        y: .value("Depth", -displayDepth(point.depthMeters))
                    )
                    .foregroundStyle(TissueAnalyticsTheme.accentBlue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                ForEach(decoStops) { stop in
                    if let minute = ascentMinute(for: stop.depthMeters) {
                        PointMark(
                            x: .value("Stop time", minute),
                            y: .value("Stop depth", -displayDepth(stop.depthMeters))
                        )
                        .symbolSize(0)
                        .annotation(position: .top, spacing: 4) {
                            Text(Formatters.depth(stop.depthMeters, units: unitPreference).text)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(TissueAnalyticsTheme.accentBlue))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(TissueAnalyticsTheme.grid)
                    AxisValueLabel().foregroundStyle(TissueAnalyticsTheme.labelSecondary)
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(TissueAnalyticsTheme.grid)
                    AxisValueLabel {
                        if let minutes = value.as(Double.self) {
                            Text("\(Int(minutes))’")
                                .foregroundStyle(TissueAnalyticsTheme.labelSecondary)
                        }
                    }
                }
            }

            gasTimeline
        }
    }

    private var gasTimeline: some View {
        GeometryReader { geometry in
            let total = max(points.last?.elapsedMinutes ?? 1, 1)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(TissueAnalyticsTheme.grid.opacity(0.35))
                HStack(spacing: 0) {
                    ForEach(Array(gasSpans.enumerated()), id: \.offset) { _, span in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(span.color)
                            .frame(width: max(8, geometry.size.width * span.fraction))
                            .overlay(
                                Text(span.label)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(span.textColor)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .padding(.horizontal, 2)
                            )
                    }
                }
            }
        }
        .frame(height: 24)
    }

    private var gasSpans: [(label: String, fraction: CGFloat, color: Color, textColor: Color)] {
        guard !segments.isEmpty else {
            return [(String(localized: "tissue_analytics.gas.bottom"), 1, Color.gray.opacity(0.45), .white)]
        }
        let total = segments.reduce(0) { $0 + $1.minutes }
        guard total > 0 else { return [] }
        return segments.map { segment in
            let label = segment.gas
            let color: Color
            let text: Color
            if label.uppercased().contains("O2") || label.contains("100") {
                color = TissueAnalyticsTheme.green.opacity(0.85)
                text = .black
            } else if segment.kind == .gasSwitch || segment.kind == .stop {
                color = TissueAnalyticsTheme.yellow.opacity(0.85)
                text = .black
            } else {
                color = Color.gray.opacity(0.45)
                text = .white
            }
            return (label, CGFloat(segment.minutes / total), color, text)
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 14, height: 3)
            Text(label)
        }
    }

    private func displayDepth(_ meters: Double) -> Double {
        Formatters.depthValue(meters, units: unitPreference)
    }

    private func ascentMinute(for stopDepthMeters: Double) -> Double? {
        guard points.count > 1 else { return nil }
        let maxDepth = points.map(\.depthMeters).max() ?? 0
        let bottomEndIndex = points.lastIndex(where: { abs($0.depthMeters - maxDepth) < 0.5 }) ?? 0
        let ascentPoints = points[bottomEndIndex...]
        return ascentPoints
            .filter { abs($0.depthMeters - stopDepthMeters) < 1.5 }
            .map(\.elapsedMinutes)
            .first
    }
}

struct TissueCompartmentBarChart: View {
    let compartments: [TissueCompartmentLoading]
    let controllingCompartment: Int

    var body: some View {
        VStack(spacing: 8) {
            Chart {
                ForEach(compartments) { compartment in
                    BarMark(
                        x: .value("Compartment", "C\(compartment.compartmentIndex + 1)"),
                        y: .value("Load", compartment.loadingPercent)
                    )
                    .foregroundStyle(barColor(for: compartment))
                    .cornerRadius(3)
                }
                RuleMark(y: .value("M-value", 100))
                    .foregroundStyle(TissueAnalyticsTheme.warningRed)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [6, 4]))
            }
            .chartYScale(domain: 0...150)
            .chartYAxis {
                AxisMarks(values: [0, 50, 100, 150]) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(TissueAnalyticsTheme.grid)
                    AxisValueLabel {
                        if let number = value.as(Int.self) {
                            Text("\(number)%").foregroundStyle(TissueAnalyticsTheme.labelSecondary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel().foregroundStyle(TissueAnalyticsTheme.labelSecondary)
                }
            }
            .overlay(alignment: .top) {
                if let controlling = compartments.first(where: { $0.compartmentIndex == controllingCompartment }) {
                    Text("\(Int(controlling.loadingPercent.rounded()))%")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(TissueAnalyticsTheme.yellow)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(RoundedRectangle(cornerRadius: 6).fill(TissueAnalyticsTheme.badgeBrown))
                        .offset(x: barOffset(for: controllingCompartment), y: -8)
                }
            }

            HStack {
                legendDot(TissueAnalyticsTheme.green, "< 70%")
                legendDot(TissueAnalyticsTheme.yellow, "70 - 90%")
                legendDot(TissueAnalyticsTheme.orangeRed, "> 90%")
                Spacer()
                Text(String(localized: "tissue_analytics.legend.mvalue_gf"))
                    .font(.system(size: 11))
                    .foregroundStyle(TissueAnalyticsTheme.labelMuted)
            }
        }
    }

    private func barColor(for compartment: TissueCompartmentLoading) -> Color {
        if compartment.compartmentIndex == controllingCompartment {
            return TissueAnalyticsTheme.orangeRed
        }
        return TissueAnalyticsTheme.loadingColor(for: compartment.loadingPercent)
    }

    private func barOffset(for index: Int) -> CGFloat {
        CGFloat(index - 7) * 8
    }

    private func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(.system(size: 11)).foregroundStyle(TissueAnalyticsTheme.labelSecondary)
        }
    }
}

struct TissueTrendChart: View {
    let samples: [TissueAnalyticsSample]
    let controllingCompartment: Int
    @Binding var selectedRuntimeSeconds: Int?
    let unitPreference: IOSUnitPreference

    private var trendPoints: [(minutes: Double, load: Double)] {
        samples.map { (Double($0.runtimeSeconds) / 60.0, $0.compartmentLoadingsPercent[safe: $0.controllingCompartment] ?? 0) }
    }

    private var selectedSample: TissueAnalyticsSample? {
        guard let selectedRuntimeSeconds else { return samples.last }
        return samples.min(by: { abs($0.runtimeSeconds - selectedRuntimeSeconds) < abs($1.runtimeSeconds - selectedRuntimeSeconds) })
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Chart {
                ForEach(Array(trendPoints.enumerated()), id: \.offset) { _, point in
                    LineMark(
                        x: .value("Time", point.minutes),
                        y: .value("Load", point.load)
                    )
                    .foregroundStyle(TissueAnalyticsTheme.orange)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    AreaMark(
                        x: .value("Time", point.minutes),
                        y: .value("Load", point.load)
                    )
                    .foregroundStyle(TissueAnalyticsTheme.orange.opacity(0.12))
                }
                RuleMark(y: .value("M-value", 100))
                    .foregroundStyle(TissueAnalyticsTheme.warningRed)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [6, 4]))
                if let selected = selectedSample {
                    RuleMark(x: .value("Selected", Double(selected.runtimeSeconds) / 60.0))
                        .foregroundStyle(TissueAnalyticsTheme.accentBlue)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    PointMark(
                        x: .value("Selected", Double(selected.runtimeSeconds) / 60.0),
                        y: .value("Load", selected.compartmentLoadingsPercent[safe: selected.controllingCompartment] ?? 0)
                    )
                    .foregroundStyle(TissueAnalyticsTheme.accentBlue)
                    .symbolSize(70)
                }
            }
            .chartYScale(domain: 0...120)
            .chartXScale(domain: 0...(trendPoints.last?.minutes ?? 1))
            .chartYAxis {
                AxisMarks(values: [0, 40, 60, 80, 100, 120]) { value in
                    AxisGridLine().foregroundStyle(TissueAnalyticsTheme.grid)
                    AxisValueLabel {
                        if let number = value.as(Int.self) {
                            Text("\(number)%").foregroundStyle(TissueAnalyticsTheme.labelSecondary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine().foregroundStyle(TissueAnalyticsTheme.grid)
                    AxisValueLabel {
                        if let minutes = value.as(Double.self) {
                            Text("\(Int(minutes))’").foregroundStyle(TissueAnalyticsTheme.labelSecondary)
                        }
                    }
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    guard let plotFrame = proxy.plotFrame else { return }
                                    let origin = geometry[plotFrame].origin
                                    let x = value.location.x - origin.x
                                    if let minutes: Double = proxy.value(atX: x) {
                                        let seconds = Int(minutes * 60)
                                        selectedRuntimeSeconds = samples.min(by: { abs($0.runtimeSeconds - seconds) < abs($1.runtimeSeconds - seconds) })?.runtimeSeconds
                                    }
                                }
                        )
                }
            }

            if let sample = selectedSample {
                tooltip(for: sample)
            }
        }
    }

    private func tooltip(for sample: TissueAnalyticsSample) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(TissueAnalyticsTheme.runtimeLabel(seconds: sample.runtimeSeconds))
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
            tooltipRow(String(localized: "tissue_analytics.tooltip.depth"), Formatters.depth(sample.depthMeters, units: unitPreference).text, TissueAnalyticsTheme.yellow)
            tooltipRow(String(localized: "tissue_analytics.tooltip.active_gas"), sample.activeGasName, TissueAnalyticsTheme.yellow)
            tooltipRow(
                String(localized: "tissue_analytics.tooltip.controlling"),
                TissueAnalyticsTheme.controllingCompartmentLabel(index: sample.controllingCompartment),
                .white,
                badge: true
            )
            tooltipRow(
                String(localized: "tissue_analytics.tooltip.tissue_load"),
                "\(Int((sample.compartmentLoadingsPercent[safe: sample.controllingCompartment] ?? 0).rounded()))%",
                TissueAnalyticsTheme.orange
            )
            tooltipRow(String(localized: "tissue_analytics.tooltip.ceiling"), Formatters.depth(sample.ceilingMeters, units: unitPreference).text, TissueAnalyticsTheme.cyan)
            tooltipRow(String(localized: "tissue_analytics.tooltip.ppn2"), Formatters.one(sample.ppN2Bar) + " bar", TissueAnalyticsTheme.green)
            tooltipRow(String(localized: "tissue_analytics.tooltip.ppo2"), Formatters.one(sample.ppO2Bar) + " bar", TissueAnalyticsTheme.orange)
        }
        .font(.system(size: 12))
        .padding(10)
        .frame(width: 180, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(red: 0.11, green: 0.11, blue: 0.12).opacity(0.95))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(TissueAnalyticsTheme.cardBorder, lineWidth: 1))
        )
    }

    private func tooltipRow(_ title: String, _ value: String, _ color: Color, badge: Bool = false) -> some View {
        HStack {
            Text(title).foregroundStyle(TissueAnalyticsTheme.labelSecondary)
            Spacer()
            if badge {
                Text(value)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(TissueAnalyticsTheme.orangeRed))
            } else {
                Text(value).foregroundStyle(color)
            }
        }
    }
}

struct TissueNarcoticLoadChart: View {
    let samples: [TissueAnalyticsSample]
    let maxPPN2Bar: Double
    let endEquivalentMeters: Double
    let unitPreference: IOSUnitPreference

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Chart {
                ForEach(samples) { sample in
                    LineMark(
                        x: .value("Time", Double(sample.runtimeSeconds) / 60.0),
                        y: .value("PPN2", sample.ppN2Bar)
                    )
                    .foregroundStyle(TissueAnalyticsTheme.purple)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    AreaMark(
                        x: .value("Time", Double(sample.runtimeSeconds) / 60.0),
                        y: .value("PPN2", sample.ppN2Bar)
                    )
                    .foregroundStyle(TissueAnalyticsTheme.purple.opacity(0.15))
                }
                RuleMark(y: .value("Threshold", 3.0))
                    .foregroundStyle(TissueAnalyticsTheme.warningRed)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [6, 4]))
            }
            .chartYScale(domain: 0...4)
            .chartYAxis {
                AxisMarks(values: [0, 1, 2, 3, 4]) { value in
                    AxisGridLine().foregroundStyle(TissueAnalyticsTheme.grid)
                    AxisValueLabel {
                        if let number = value.as(Double.self) {
                            Text(String(format: "%.1f", number)).foregroundStyle(TissueAnalyticsTheme.labelSecondary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine().foregroundStyle(TissueAnalyticsTheme.grid)
                    AxisValueLabel {
                        if let minutes = value.as(Double.self) {
                            Text("\(Int(minutes))’").foregroundStyle(TissueAnalyticsTheme.labelSecondary)
                        }
                    }
                }
            }

            VStack(spacing: 8) {
                statBox(title: String(localized: "tissue_analytics.stat.ppn2_max"), value: "\(Formatters.one(maxPPN2Bar)) bar")
                statBox(
                    title: String(localized: "tissue_analytics.stat.end"),
                    value: Formatters.depth(endEquivalentMeters, units: unitPreference).text
                )
            }
            .frame(width: 110)
        }
    }

    private func statBox(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(TissueAnalyticsTheme.labelMuted)
            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(TissueAnalyticsTheme.purple)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 62, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(red: 0.11, green: 0.11, blue: 0.12))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(TissueAnalyticsTheme.cardBorder, lineWidth: 1))
        )
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
