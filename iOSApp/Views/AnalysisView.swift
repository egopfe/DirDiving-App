import SwiftUI
import Charts
import UniformTypeIdentifiers

struct AnalysisView: View {
    @EnvironmentObject private var logStore: DiveLogStore
    @EnvironmentObject private var watchSync: WatchSyncService
    @EnvironmentObject private var navigation: IOSNavigationStore
    @AppStorage("dirdiving_ios_units") private var units = IOSUnitPreference.metric.rawValue
    @AppStorage("dirdiving_ios_analysis_include_demo") private var includeDemoInAnalysis = false
    @State private var showImporter = false
    @State private var importMessage: String?

    private var analysisSessions: [DiveSession] {
        includeDemoInAnalysis ? logStore.sessions : logStore.sessions.filter { !$0.isDemoDive }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
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
                                    DIRMetricTile(title: String(localized: "analysis.metric.dives"), value: "\(analysisSessions.count)", color: DIRTheme.cyan)
                                    DIRMetricTile(title: String(localized: "analysis.metric.max_depth"), measurement: Formatters.depth(analysisSessions.map(\.maxDepthMeters).max() ?? 0, units: unitPreference), color: DIRTheme.yellow)
                                    DIRMetricTile(title: String(localized: "analysis.metric.total_runtime"), value: Formatters.zero(analysisSessions.map(\.durationSeconds).reduce(0, +) / 60), unit: "min")
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
            }
            .toolbar(.hidden, for: .navigationBar)
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.commaSeparatedText, .plainText]) { result in
                switch result {
                case .success(let url):
                    switch DiveImportService.importCSV(from: url) {
                    case .success(let summary):
                        let alreadyImported = logStore.session(id: summary.session.id) != nil
                        logStore.add(summary.session)
                        importMessage = summary.message(alreadyImported: alreadyImported)
                    case .failure(let error):
                        importMessage = error.localizedDescription
                    }
                case .failure(let error):
                    importMessage = error.localizedDescription
                }
            }
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
            HStack(spacing: 10) {
                emptyAction("Importa CSV", "square.and.arrow.down") {
                    showImporter = true
                }
                emptyAction("Sync Watch", "applewatch") {
                    watchSync.retryActivation(logStore: logStore)
                    importMessage = String(localized: "Sync Apple Watch richiesta.")
                }
            }
            emptyAction("Apri Logbook", "list.bullet.rectangle.portrait.fill") {
                navigation.selectedTab = .logbook
            }
            if let importMessage {
                Text(importMessage)
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

    private var avgTemp: Double {
        let values = analysisSessions.compactMap(\.avgWaterTemperatureCelsius)
        return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
    }

    @ViewBuilder
    private var avgTemperatureTile: some View {
        let values = analysisSessions.compactMap(\.avgWaterTemperatureCelsius)
        if values.isEmpty {
            DIRMetricTile(title: String(localized: "analysis.metric.avg_temp"), value: "—", color: DIRTheme.yellow)
        } else {
            DIRMetricTile(title: String(localized: "analysis.metric.avg_temp"), measurement: Formatters.temperature(avgTemp, units: unitPreference))
        }
    }

    private var avgSAC: Double {
        let values = analysisSessions.compactMap(\.sacLitersMinute)
        return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
    }

    @ViewBuilder
    private var avgSACTile: some View {
        let values = analysisSessions.compactMap(\.sacLitersMinute)
        if values.isEmpty {
            DIRMetricTile(title: String(localized: "analysis.metric.avg_sac"), value: "—", color: DIRTheme.yellow)
        } else {
            DIRMetricTile(title: String(localized: "analysis.metric.avg_sac"), measurement: Formatters.sac(avgSAC, units: unitPreference), color: DIRTheme.green)
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
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(String(localized: "analysis.subtitle"))
                .font(.callout)
                .foregroundStyle(DIRTheme.muted)
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
        let routes = RouteSummaryService.summaries(from: analysisSessions)
        return DIRCard(String(localized: "analysis.card.route_summary"), icon: "map", accent: DIRTheme.cyan) {
            HStack(spacing: 0) {
                DIRMetricTile(title: String(localized: "analysis.metric.routes"), value: "\(routes.count)", color: DIRTheme.cyan)
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: String(localized: "analysis.metric.distance"), measurement: Formatters.distance(routes.map(\.distanceMeters).reduce(0, +), units: unitPreference, prefersLargeUnit: true), color: DIRTheme.green)
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: String(localized: "analysis.metric.bearing"), value: routes.first?.bearingDegrees.map { Formatters.zero($0) } ?? "--", unit: routes.first?.bearingDegrees == nil ? nil : "°", color: DIRTheme.yellow)
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
