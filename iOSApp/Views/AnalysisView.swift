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
                        DIRCard("ANALISI AVANZATE", icon: "chart.line.uptrend.xyaxis", accent: DIRTheme.cyan) {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 0) {
                                DIRMetricTile(title: "Immersioni", value: "\(logStore.sessions.count)", color: DIRTheme.cyan)
                                DIRMetricTile(title: "Max assoluta", value: Formatters.one(logStore.sessions.map(\.maxDepthMeters).max() ?? 0), unit: "m", color: DIRTheme.yellow)
                                DIRMetricTile(title: "Runtime totale", value: Formatters.zero(logStore.sessions.map(\.durationSeconds).reduce(0, +) / 60), unit: "min")
                                DIRMetricTile(title: "Temp media", value: Formatters.one(avgTemp), unit: "C")
                            }
                        }
                        DIRCard("PROFONDITA MASSIMA PER IMMERSIONE", icon: "chart.xyaxis.line", accent: DIRTheme.cyan) {
                            Chart(logStore.sessions) { session in
                                BarMark(
                                    x: .value("Data", session.startDate, unit: .day),
                                    y: .value("Max", session.maxDepthMeters)
                                )
                                .foregroundStyle(LinearGradient(colors: [DIRTheme.cyan, DIRTheme.green], startPoint: .top, endPoint: .bottom))
                            }
                            .chartXAxis { AxisMarks { AxisGridLine().foregroundStyle(DIRTheme.faint); AxisValueLabel().foregroundStyle(DIRTheme.muted) } }
                            .chartYAxis { AxisMarks { AxisGridLine().foregroundStyle(DIRTheme.faint); AxisValueLabel().foregroundStyle(DIRTheme.muted) } }
                            .chartPlotStyle { plot in
                                plot
                                    .background(.black.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .frame(height: 240)
                        }
                        adaptiveAnalyticsConcept
                    }
                    .padding(16)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var avgTemp: Double {
        let values = logStore.sessions.compactMap(\.avgWaterTemperatureCelsius)
        return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Analisi")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Operational trends plus experimental visual-only readiness and fatigue concepts")
                .font(.callout)
                .foregroundStyle(DIRTheme.muted)
        }
    }

    private var adaptiveAnalyticsConcept: some View {
        DIRCard("EXPERIMENTAL ANALYTICS CONCEPTS", icon: "sparkles", accent: DIRTheme.yellow) {
            // TODO: Static UI only. Do not implement analytics engines, AI scoring or persistence here.
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    analyticsTile("Readiness", "--%", DIRTheme.yellow, "bolt.heart")
                    analyticsTile("Fatigue", "N/A", DIRTheme.red, "waveform.path.ecg")
                    analyticsTile("Adaptivity", "Mock", DIRTheme.cyan, "slider.horizontal.3")
                }
                Text("Future adaptive apnea and exploration analytics are represented here as visual concepts only.")
                    .font(.footnote)
                    .foregroundStyle(DIRTheme.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func analyticsTile(_ title: String, _ value: String, _ color: Color, _ icon: String) -> some View {
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
}
