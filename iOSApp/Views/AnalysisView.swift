import SwiftUI
import Charts

struct AnalysisView: View {
    @EnvironmentObject private var logStore: DiveLogStore
    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        DIRSectionHeader(title: "Analisi", subtitle: "Statistiche aggregate")
                        DIRCard("Overview", icon: "chart.bar.xaxis") {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                DIRMetricTile(title: "Immersioni", value: "\(logStore.sessions.count)", color: DIRTheme.cyan)
                                DIRMetricTile(title: "Max assoluta", value: Formatters.one(logStore.sessions.map(\.maxDepthMeters).max() ?? 0), unit: "m", color: DIRTheme.yellow)
                                DIRMetricTile(title: "Runtime totale", value: Formatters.zero(logStore.sessions.map(\.durationSeconds).reduce(0,+)/60), unit: "min")
                                DIRMetricTile(title: "Temp media", value: Formatters.one(avgTemp), unit: "°C")
                            }
                        }
                        DIRCard("Profondità massima per immersione", icon: "chart.xyaxis.line") {
                            Chart(logStore.sessions) { session in
                                BarMark(x: .value("Data", session.startDate, unit: .day), y: .value("Max", session.maxDepthMeters)).foregroundStyle(DIRTheme.cyan)
                            }.frame(height: 260)
                        }
                    }.padding()
                }
            }.navigationTitle("Analisi").navigationBarTitleDisplayMode(.inline)
        }
    }
    private var avgTemp: Double {
        let values = logStore.sessions.compactMap(\.avgWaterTemperatureCelsius)
        return values.isEmpty ? 0 : values.reduce(0,+)/Double(values.count)
    }
}
