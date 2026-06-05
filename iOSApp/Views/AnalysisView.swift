import SwiftUI
import Charts

struct AnalysisView: View {
    @EnvironmentObject private var logStore: DiveLogStore
    @EnvironmentObject private var watchSync: WatchSyncService
    @EnvironmentObject private var navigation: IOSNavigationStore
    @AppStorage("dirdiving_ios_units") private var units = IOSUnitPreference.metric.rawValue
    @AppStorage("dirdiving_ios_analysis_include_demo") private var includeDemoInAnalysis = false
    @State private var syncStatusMessage: String?

    private var analysisSessions: [DiveSession] {
        AnalysisDashboardMath.sessionsForAnalysis(all: logStore.sessions, includeDemo: includeDemoInAnalysis)
    }

    private var analysisSummary: AnalysisDashboardMath.Summary {
        AnalysisDashboardMath.summary(from: analysisSessions)
    }

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        if !logStore.sessions.isEmpty {
                            CSVImportPanel()
                        }
                        if analysisSessions.isEmpty {
                            emptyAnalysisState
                        } else {
                            analysisHero
                            demoAnalysisToggle
                            DIRCard(String(localized: "analysis.card.advanced"), icon: "chart.line.uptrend.xyaxis", accent: DIRTheme.cyan) {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 0) {
                                    DIRMetricTile(title: String(localized: "analysis.metric.dives"), value: "\(analysisSummary.diveCount)", color: DIRTheme.cyan)
                                    DIRMetricTile(title: String(localized: "analysis.metric.max_depth"), measurement: Formatters.depth(analysisSummary.maxDepthMeters, units: unitPreference), color: DIRTheme.yellow)
                                    DIRMetricTile(title: String(localized: "analysis.metric.total_runtime"), value: Formatters.zero(analysisSummary.totalRuntimeMinutes), unit: "min")
                                    avgTemperatureTile
                                    avgSACTile
                                    DIRMetricTile(title: String(localized: "analysis.metric.gps_routes"), value: "\(RouteSummaryService.summaries(from: analysisSessions).count)", color: DIRTheme.cyan)
                                }
                            }
                            DIRCard(String(localized: "analysis.card.max_depth"), icon: "chart.xyaxis.line", accent: DIRTheme.cyan) {
                                Chart(analysisSessions) { session in
                                    BarMark(
                                        x: .value("Data", session.startDate, unit: .day),
                                        y: .value("Max", Formatters.depthValue(session.maxDepthMeters, units: unitPreference))
                                    )
                                    .foregroundStyle(
                                        LinearGradient(colors: [DIRTheme.cyan, DIRTheme.green], startPoint: .top, endPoint: .bottom)
                                    )
                                }
                                .chartXAxis { AxisMarks { AxisGridLine().foregroundStyle(DIRTheme.faint); AxisValueLabel().foregroundStyle(DIRTheme.muted) } }
                                .chartYAxis { AxisMarks { AxisGridLine().foregroundStyle(DIRTheme.faint); AxisValueLabel().foregroundStyle(DIRTheme.muted) } }
                                .chartPlotStyle { plot in
                                    plot
                                        .background(
                                            LinearGradient(
                                                colors: [.black.opacity(0.32), DIRTheme.surface.opacity(0.32)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: DIRTheme.compactRadius))
                                        .overlay(RoundedRectangle(cornerRadius: DIRTheme.compactRadius).stroke(DIRTheme.hairline, lineWidth: 1))
                                }
                                .frame(height: 240)
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel(String(localized: "analysis.chart.max_depth_a11y"))
                                .accessibilityValue(
                                    String(
                                        format: String(localized: "analysis.chart.max_depth_a11y_value"),
                                        analysisSessions.count,
                                        Formatters.depth(analysisSessions.map(\.maxDepthMeters).max() ?? 0, units: unitPreference).text
                                    )
                                )
                            }
                            gasMixSummary
                            routeSummary
                        }
                    }
                    .padding(16)
                }
                .dirCompanionScrollSurface()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var analysisHero: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(String(localized: "analysis.hero.title"))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(String(localized: "analysis.hero.subtitle"))
                    .font(.footnote)
                    .foregroundStyle(DIRTheme.muted)
            }
            Spacer()
            Image(systemName: "waveform.path.ecg.rectangle")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(DIRTheme.cyan)
                .frame(width: 54, height: 54)
                .background(RoundedRectangle(cornerRadius: 16).fill(DIRTheme.cyan.opacity(0.12)))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(LinearGradient(colors: [DIRTheme.cyan.opacity(0.14), DIRTheme.surface.opacity(0.86)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(DIRTheme.cyan.opacity(0.36), lineWidth: 1))
        )
    }

    private var emptyAnalysisState: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 11) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(DIRTheme.cyan)
                    .frame(width: 46, height: 46)
                    .background(RoundedRectangle(cornerRadius: 12).fill(DIRTheme.cyan.opacity(0.12)))
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "analysis.empty.title"))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text(String(localized: "analysis.empty.body"))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Text(String(localized: "analysis.empty.next_action"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(DIRTheme.cyan)
            CSVImportPanel()
            HStack(spacing: 10) {
                emptyAction(String(localized: "analysis.empty.sync_watch"), "applewatch") {
                    watchSync.retryActivation(logStore: logStore)
                    syncStatusMessage = String(localized: "analysis.empty.sync_requested")
                }
                emptyAction(String(localized: "analysis.empty.open_logbook"), "list.bullet.rectangle.portrait.fill") {
                    navigation.selectedTab = .logbook
                }
            }
            if let syncStatusMessage {
                Text(syncStatusMessage)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(DIRTheme.yellow)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(DIRTheme.surface.opacity(0.86))
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(DIRTheme.cyan.opacity(0.30), lineWidth: 1))
        )
    }

    private func emptyAction(_ title: String, _ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(DIRTheme.cyan)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan.opacity(0.68), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var avgTemperatureTile: some View {
        if let avg = analysisSummary.averageWaterTemperatureCelsius {
            DIRMetricTile(title: String(localized: "analysis.metric.avg_temp"), measurement: Formatters.temperature(avg, units: unitPreference))
        } else {
            DIRMetricTile(title: String(localized: "analysis.metric.avg_temp"), value: "—", color: DIRTheme.yellow)
        }
    }

    @ViewBuilder
    private var avgSACTile: some View {
        if let avg = analysisSummary.averageSACLitersPerMinute {
            DIRMetricTile(title: String(localized: "analysis.metric.avg_sac"), measurement: Formatters.sac(avg, units: unitPreference), color: DIRTheme.green)
        } else {
            DIRMetricTile(title: String(localized: "analysis.metric.avg_sac"), value: "—", color: DIRTheme.yellow)
        }
    }

    private var unitPreference: IOSUnitPreference {
        IOSUnitPreference.fromStorage(units)
    }

    private var demoAnalysisToggle: some View {
        Toggle(isOn: $includeDemoInAnalysis) {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "analysis.demo.include_toggle"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                Text(String(localized: "analysis.demo.include_hint"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
            }
        }
        .tint(DIRTheme.cyan)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.compactRadius)
                .fill(DIRTheme.surface.opacity(0.72))
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.compactRadius).stroke(DIRTheme.hairline, lineWidth: 1))
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(String(localized: "analysis.title"))
                .dirScreenTitleStyle()
            Text(String(localized: "analysis.subtitle"))
                .dirScreenSubtitleStyle()
        }
    }

    private var gasMixSummary: some View {
        DIRCard(String(localized: "analysis.card.gas_summary"), icon: "circle.hexagongrid", accent: DIRTheme.green) {
            VStack(spacing: 8) {
                ForEach(DiveGasLabel.allCases) { gas in
                    let count = analysisSessions.filter { $0.gasLabel == gas }.count
                    HStack {
                        Text(gas.rawValue).foregroundStyle(.white)
                        Spacer()
                        Text("\(count)").foregroundStyle(DIRTheme.cyan).monospacedDigit()
                    }
                    .font(.callout.weight(.semibold))
                }
            }
        }
    }

    private var routeSummary: some View {
        let aggregate = RouteSummaryAggregation.aggregate(from: analysisSessions)
        let bearingTitle: String = {
            switch aggregate.bearingScope {
            case .none:
                return String(localized: "analysis.metric.bearing")
            case .singleRoute:
                return String(localized: "analysis.metric.bearing")
            case .firstOfMany(let count):
                return String(format: String(localized: "analysis.metric.bearing_first_of_many"), count)
            }
        }()
        return DIRCard(String(localized: "analysis.card.route_summary"), icon: "map", accent: DIRTheme.cyan) {
            HStack(spacing: 0) {
                DIRMetricTile(title: String(localized: "analysis.metric.routes"), value: "\(aggregate.routeCount)", color: DIRTheme.cyan)
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: String(localized: "analysis.metric.distance"), measurement: Formatters.distance(aggregate.totalDistanceMeters, units: unitPreference, prefersLargeUnit: true), color: DIRTheme.green)
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(
                    title: bearingTitle,
                    value: aggregate.bearingDegrees.map { Formatters.zero($0) } ?? "--",
                    unit: aggregate.bearingDegrees == nil ? nil : "°",
                    color: DIRTheme.yellow
                )
            }
        }
    }

    private func analysisPill(_ title: String, _ value: String, _ color: Color, _ icon: String) -> some View {
        VStack(spacing: 7) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.monospacedDigit().weight(.bold))
                .foregroundStyle(.white)
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(DIRTheme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.surface2.opacity(0.6)))
    }

    private func trendCard(_ title: String, _ value: String, _ color: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.muted)
                Text(value.uppercased())
                    .font(.callout.weight(.bold))
                    .foregroundStyle(.white)
            }
            Spacer()
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.surface2.opacity(0.6)))
    }
}

private struct AnalysisDepthTrendPreview: View {
    var body: some View {
        Canvas { context, size in
            let gridColor = Color.white.opacity(0.08)
            for y in stride(from: 0.0, through: size.height, by: 24) {
                var grid = Path()
                grid.move(to: CGPoint(x: 0, y: y))
                grid.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(grid, with: .color(gridColor), lineWidth: 1)
            }

            var path = Path()
            path.move(to: CGPoint(x: 0, y: size.height * 0.18))
            path.addCurve(to: CGPoint(x: size.width * 0.26, y: size.height * 0.82), control1: CGPoint(x: 30, y: 18), control2: CGPoint(x: 48, y: size.height * 0.82))
            path.addLine(to: CGPoint(x: size.width * 0.52, y: size.height * 0.76))
            path.addCurve(to: CGPoint(x: size.width, y: size.height * 0.2), control1: CGPoint(x: size.width * 0.68, y: size.height * 0.7), control2: CGPoint(x: size.width * 0.78, y: size.height * 0.24))
            context.stroke(path, with: .color(DIRTheme.cyan), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        }
        .background(RoundedRectangle(cornerRadius: DIRTheme.compactRadius).fill(.black.opacity(0.22)))
    }
}
