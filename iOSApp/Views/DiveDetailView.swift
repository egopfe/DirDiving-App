import SwiftUI
import Charts

enum DiveDetailTab: String, CaseIterable, Identifiable {
    case summary = "Riepilogo"
    case charts = "Grafici"
    case details = "Dettagli"
    var id: String { rawValue }
}
struct DiveDetailView: View {
    let session: DiveSession
    @State private var tab: DiveDetailTab = .summary
    @State private var csvURL: URL?
    var body: some View {
        ZStack {
            DIRBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    Picker("Tab", selection: $tab) {
                        ForEach(DiveDetailTab.allCases) { Text($0.rawValue).tag($0) }
                    }.pickerStyle(.segmented)
                    switch tab {
                    case .summary: summary
                    case .charts: charts
                    case .details: details
                    }
                    exportBlock
                }.padding()
            }
        }.navigationTitle(session.startDate.formatted(date: .abbreviated, time: .shortened)).navigationBarTitleDisplayMode(.inline)
    }
    private var header: some View {
        DIRCard {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(LinearGradient(colors: [DIRTheme.cyan.opacity(0.55), DIRTheme.surface2], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Image(systemName: "water.waves").font(.largeTitle).foregroundStyle(.white)
                }.frame(width: 88, height: 88)
                VStack(alignment: .leading, spacing: 6) {
                    Text(session.siteName ?? "Immersione").font(.title3.bold()).foregroundStyle(.white)
                    Text(session.gasLabel.rawValue).font(.caption.bold()).foregroundStyle(DIRTheme.yellow)
                    if let buddy = session.buddy { Text("Buddy: \(buddy)").font(.caption).foregroundStyle(DIRTheme.muted) }
                }
                Spacer()
            }
        }
    }
    private var summary: some View {
        VStack(spacing: 14) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                DIRMetricTile(title: "Tempo", value: Formatters.time(session.durationSeconds), unit: "min")
                DIRMetricTile(title: "Max", value: Formatters.one(session.maxDepthMeters), unit: "m", color: DIRTheme.cyan)
                DIRMetricTile(title: "Media", value: Formatters.one(session.avgDepthMeters), unit: "m")
                DIRMetricTile(title: "TTR", value: Formatters.one(session.ttv), unit: "min", color: DIRTheme.yellow)
                DIRMetricTile(title: "SAC", value: Formatters.one(session.sacLitersMinute ?? 0), unit: "l/min")
                DIRMetricTile(title: "Temp", value: Formatters.one(session.avgWaterTemperatureCelsius ?? 0), unit: "°C")
            }
            DIRCard("Gas utilizzato", icon: "gauge.with.dots.needle.67percent") {
                HStack {
                    VStack(alignment: .leading) { Text("Inizio").foregroundStyle(DIRTheme.muted); Text("200 bar").font(.title3.bold()) }
                    Spacer(); Image(systemName: "arrow.right").foregroundStyle(DIRTheme.muted); Spacer()
                    VStack(alignment: .leading) { Text("Fine").foregroundStyle(DIRTheme.muted); Text("50 bar").font(.title3.bold()) }
                    Spacer()
                    VStack(alignment: .leading) { Text("Consumo").foregroundStyle(DIRTheme.yellow); Text("150 bar").font(.title3.bold()).foregroundStyle(DIRTheme.yellow) }
                }
            }
        }
    }
    private var charts: some View {
        DIRCard("Profondità", icon: "chart.xyaxis.line") {
            Chart(session.samples) { sample in
                LineMark(x: .value("Tempo", sample.timestamp), y: .value("Profondità", sample.depthMeters)).foregroundStyle(DIRTheme.cyan).lineStyle(StrokeStyle(lineWidth: 3))
            }.chartYScale(domain: [(session.maxDepthMeters + 2), 0]).frame(height: 280)
        }
    }
    private var details: some View {
        VStack(spacing: 14) {
            DIRCard("GPS", icon: "location.fill") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Start: \(session.entryGPS?.coordinateText ?? "n/d")")
                    Text("End: \(session.exitGPS?.coordinateText ?? "n/d")")
                }.font(.callout.monospacedDigit())
            }
            DIRCard("Note", icon: "note.text") { Text(session.notes ?? "Nessuna nota").foregroundStyle(DIRTheme.muted) }
        }
    }
    private var exportBlock: some View {
        DIRCard("Export", icon: "square.and.arrow.up") {
            Button("Genera CSV Subsurface") { csvURL = SubsurfaceExportService.writeCSV(for: session) }.buttonStyle(.borderedProminent).tint(DIRTheme.cyan)
            if let csvURL { ShareLink(item: csvURL) { Label("Condividi CSV", systemImage: "doc") }.foregroundStyle(DIRTheme.yellow) }
        }
    }
}
