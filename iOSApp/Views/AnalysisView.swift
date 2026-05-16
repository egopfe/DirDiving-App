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
                                .foregroundStyle(
                                    LinearGradient(colors: [DIRTheme.cyan, DIRTheme.green], startPoint: .top, endPoint: .bottom)
                                )
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
                        apneaPresentation
                        snorkelingSummary
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
            Text("Clean operational metrics, trends and visual-only experimental summaries")
                .font(.callout)
                .foregroundStyle(DIRTheme.muted)
        }
    }

    private var apneaPresentation: some View {
        DIRCard("APNEA READINESS", icon: "lungs.fill", accent: DIRTheme.yellow) {
            // TODO: Static presentation only; connect readiness, recovery and fatigue analytics after product approval.
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    analysisPill("Readiness", "--%", DIRTheme.yellow, "heart.fill")
                    analysisPill("Recovery", "2.4x", DIRTheme.green, "timer")
                    analysisPill("Fatigue", "N/A", DIRTheme.red, "waveform.path.ecg")
                }
                HStack(spacing: 12) {
                    trendCard("Depth trend", "stable", DIRTheme.cyan)
                    trendCard("Surface interval", "visual", DIRTheme.green)
                }
            }
        }
    }

    private var snorkelingSummary: some View {
        DIRCard("SNORKELING SESSION SUMMARY", icon: "figure.pool.swim", accent: DIRTheme.green) {
            // TODO: Placeholder presentation only; do not implement route analytics here.
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    DIRMetricTile(title: "Routes", value: "--", color: DIRTheme.cyan)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Entry/Exit", value: "UI", color: DIRTheme.green)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Waypoints", value: "--", color: DIRTheme.yellow)
                }
                Divider().overlay(DIRTheme.hairline)
                Text("Route overview, waypoint lists and entry/exit hierarchy are presented in Explore as UI-only concepts.")
                    .font(.footnote)
                    .foregroundStyle(DIRTheme.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
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
