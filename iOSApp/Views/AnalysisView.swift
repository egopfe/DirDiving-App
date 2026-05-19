import SwiftUI
import Charts
import UniformTypeIdentifiers

struct AnalysisView: View {
    @EnvironmentObject private var logStore: DiveLogStore
    @EnvironmentObject private var watchSync: WatchSyncService
    @EnvironmentObject private var navigation: IOSNavigationStore
    @AppStorage("dirdiving_ios_units") private var units = IOSUnitPreference.metric.rawValue
    @State private var showImporter = false
    @State private var importMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        if logStore.sessions.isEmpty {
                            emptyAnalysisState
                        } else {
                            analysisHero
                            DIRCard("ANALISI AVANZATE", icon: "chart.line.uptrend.xyaxis", accent: DIRTheme.cyan) {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 0) {
                                    DIRMetricTile(title: "Immersioni", value: "\(logStore.sessions.count)", color: DIRTheme.cyan)
                                    DIRMetricTile(title: "Max assoluta", measurement: Formatters.depth(logStore.sessions.map(\.maxDepthMeters).max() ?? 0, units: unitPreference), color: DIRTheme.yellow)
                                    DIRMetricTile(title: "Runtime totale", value: Formatters.zero(logStore.sessions.map(\.durationSeconds).reduce(0, +) / 60), unit: "min")
                                    DIRMetricTile(title: "Temp media", measurement: Formatters.temperature(avgTemp, units: unitPreference))
                                    DIRMetricTile(title: "SAC medio", measurement: Formatters.sac(avgSAC, units: unitPreference), color: DIRTheme.green)
                                    DIRMetricTile(title: "Route GPS", value: "\(RouteSummaryService.summaries(from: logStore.sessions).count)", color: DIRTheme.cyan)
                                }
                            }
                            DIRCard("PROFONDITA MASSIMA PER IMMERSIONE", icon: "chart.xyaxis.line", accent: DIRTheme.cyan) {
                                Chart(logStore.sessions) { session in
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
                Text("Operational Overview")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Text("Logbook trends, gas usage and GPS route summaries from real session data")
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
                    Text("Nessun dato da analizzare")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text("Le statistiche vengono calcolate solo da immersioni reali, importate o sincronizzate dal Watch.")
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Text("Prossima azione: sincronizza Apple Watch o importa un CSV dal Logbook.")
                .font(.caption.weight(.semibold))
                .foregroundStyle(DIRTheme.cyan)
            HStack(spacing: 10) {
                emptyAction("Importa CSV", "square.and.arrow.down") {
                    showImporter = true
                }
                emptyAction("Sync Watch", "applewatch") {
                    watchSync.retryActivation(logStore: logStore)
                    importMessage = "Sync Apple Watch richiesta."
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
        let values = logStore.sessions.compactMap(\.avgWaterTemperatureCelsius)
        return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
    }

    private var avgSAC: Double {
        let values = logStore.sessions.compactMap(\.sacLitersMinute)
        return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
    }

    private var unitPreference: IOSUnitPreference {
        IOSUnitPreference.fromStorage(units)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Analisi")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Operational metrics, profile trends and route summaries from real logbook data")
                .font(.callout)
                .foregroundStyle(DIRTheme.muted)
        }
    }

    private var gasMixSummary: some View {
        DIRCard("GAS MIX SUMMARY", icon: "circle.hexagongrid", accent: DIRTheme.green) {
            VStack(spacing: 8) {
                ForEach(DiveGasLabel.allCases) { gas in
                    let count = logStore.sessions.filter { $0.gasLabel == gas }.count
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
        let routes = RouteSummaryService.summaries(from: logStore.sessions)
        return DIRCard("GPS ROUTE SUMMARY", icon: "map", accent: DIRTheme.cyan) {
            HStack(spacing: 0) {
                DIRMetricTile(title: "Routes", value: "\(routes.count)", color: DIRTheme.cyan)
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: "Distance", measurement: Formatters.distance(routes.map(\.distanceMeters).reduce(0, +), units: unitPreference, prefersLargeUnit: true), color: DIRTheme.green)
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: "Latest", value: routes.first?.bearingDegrees.map { Formatters.zero($0) } ?? "--", unit: routes.first?.bearingDegrees == nil ? nil : "deg", color: DIRTheme.yellow)
            }
        }
    }

}
