import SwiftUI
import Charts

struct AnalysisView: View {
    @EnvironmentObject private var logStore: DiveLogStore

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
                                    DIRMetricTile(title: "Max assoluta", value: Formatters.one(logStore.sessions.map(\.maxDepthMeters).max() ?? 0), unit: "m", color: DIRTheme.yellow)
                                    DIRMetricTile(title: "Runtime totale", value: Formatters.zero(logStore.sessions.map(\.durationSeconds).reduce(0, +) / 60), unit: "min")
                                    DIRMetricTile(title: "Temp media", value: Formatters.one(avgTemp), unit: "C")
                                    DIRMetricTile(title: "SAC medio", value: Formatters.one(avgSAC), unit: "l/min", color: DIRTheme.green)
                                    DIRMetricTile(title: "Route GPS", value: "\(RouteSummaryService.summaries(from: logStore.sessions).count)", color: DIRTheme.cyan)
                                }
                            }
                            DIRCard("PROFONDITA MASSIMA PER IMMERSIONE", icon: "chart.xyaxis.line", accent: DIRTheme.cyan) {
                                Chart(logStore.sessions) { session in
                                    BarMark(
                                        x: .value("Data", session.startDate, unit: .day),
                                        y: .value("Max", session.maxDepthMeters)
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
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(DIRTheme.surface.opacity(0.86))
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(DIRTheme.cyan.opacity(0.30), lineWidth: 1))
        )
    }

    private var avgTemp: Double {
        let values = logStore.sessions.compactMap(\.avgWaterTemperatureCelsius)
        return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
    }

    private var avgSAC: Double {
        let values = logStore.sessions.compactMap(\.sacLitersMinute)
        return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
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
                DIRMetricTile(title: "Distance", value: Formatters.zero(routes.map(\.distanceMeters).reduce(0, +) / 1000), unit: "km", color: DIRTheme.green)
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: "Latest", value: routes.first?.bearingDegrees.map { Formatters.zero($0) } ?? "--", unit: routes.first?.bearingDegrees == nil ? nil : "deg", color: DIRTheme.yellow)
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
