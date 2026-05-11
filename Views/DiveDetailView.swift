import SwiftUI
import Charts

struct DiveDetailView: View {
    let session: DiveSession
    @State private var exportURL: URL?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 8) {
                    header
                    summaryGrid
                    gpsPanel
                    chartPanel
                    exportPanel
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 2) {
            Text("IMMERSIONE")
                .font(.headline.bold())
                .foregroundStyle(DiveUI.blue)
            Text(session.startDate.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundStyle(DiveUI.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var summaryGrid: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                DivePanel { DiveMetric("MAX", value: Formatters.one(session.maxDepthMeters), unit: "m") }
                DivePanel { DiveMetric("MEDIA", value: Formatters.one(session.avgDepthMeters), unit: "m") }
            }
            HStack(spacing: 8) {
                DivePanel(stroke: DiveUI.yellow) { DiveMetric("DURATA", value: Formatters.time(session.durationSeconds), color: DiveUI.yellow) }
                DivePanel(stroke: DiveUI.green) { DiveMetric("TTV", value: Formatters.one(session.ttv), color: DiveUI.green) }
            }
            if let temp = session.avgWaterTemperatureCelsius {
                DivePanel(stroke: DiveUI.blue) {
                    DiveMetric("TEMP MEDIA", value: Formatters.one(temp), unit: "\u{00B0}C", color: DiveUI.blue)
                }
            }
        }
    }

    private var gpsPanel: some View {
        DivePanel(stroke: DiveUI.subtleStroke) {
            VStack(spacing: 5) {
                row("GPS START", session.entryGPS?.coordinateText ?? "--")
                row("GPS END", session.exitGPS?.coordinateText ?? "--")
            }
        }
    }

    private var chartPanel: some View {
        DivePanel(stroke: DiveUI.blue) {
            VStack(alignment: .leading, spacing: 6) {
                Text("PROFILO")
                    .font(.caption.bold())
                    .foregroundStyle(DiveUI.blue)
                Chart(session.samples) { sample in
                    LineMark(
                        x: .value("Tempo", sample.timestamp),
                        y: .value("Profondita", sample.depthMeters)
                    )
                    .foregroundStyle(DiveUI.blue)
                }
                .chartYScale(domain: [(session.maxDepthMeters + 1), 0])
                .frame(height: 150)
            }
        }
    }

    private var exportPanel: some View {
        VStack(spacing: 8) {
            DiveCommandButton("CSV", systemImage: "doc.badge.arrow.up", color: DiveUI.green) {
                exportURL = SubsurfaceExportService.writeCSV(for: session)
            }
            if let exportURL {
                ShareLink(item: exportURL) {
                    HStack {
                        Text("CONDIVIDI CSV")
                            .font(.caption.bold())
                        Image(systemName: "square.and.arrow.up")
                    }
                    .foregroundStyle(DiveUI.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 9)
                            .stroke(DiveUI.blue, lineWidth: 1)
                    )
                }
            }
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(.white)
            Spacer()
            Text(value)
                .foregroundStyle(DiveUI.blue)
                .multilineTextAlignment(.trailing)
                .monospacedDigit()
        }
        .font(.caption2.bold())
    }
}

