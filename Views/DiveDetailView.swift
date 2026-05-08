import SwiftUI
import Charts

struct DiveDetailView: View {
    let session: DiveSession
    @State private var exportURL: URL?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Immersione").font(.headline)
                row("Durata", Formatters.time(session.durationSeconds))
                row("Max", "\(Formatters.one(session.maxDepthMeters)) m")
                row("Media", "\(Formatters.one(session.avgDepthMeters)) m")
                row("TTV", Formatters.one(session.ttv))
                if let temp = session.avgWaterTemperatureCelsius { row("Temp media", "\(Formatters.one(temp))°C") }
                if let entry = session.entryGPS { row("GPS Start", entry.coordinateText) }
                if let exit = session.exitGPS { row("GPS End", exit.coordinateText) }

                Chart(session.samples) { sample in
                    LineMark(x: .value("Tempo", sample.timestamp), y: .value("Profondità", sample.depthMeters))
                }
                .chartYScale(domain: [(session.maxDepthMeters + 1), 0])
                .frame(height: 160)

                Button("Genera CSV Subsurface") { exportURL = SubsurfaceExportService.writeCSV(for: session) }
                if let exportURL {
                    ShareLink(item: exportURL) { Label("Condividi CSV", systemImage: "square.and.arrow.up") }
                }
            }.padding()
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title); Spacer(); Text(value).multilineTextAlignment(.trailing).monospacedDigit()
        }.font(.caption)
    }
}
