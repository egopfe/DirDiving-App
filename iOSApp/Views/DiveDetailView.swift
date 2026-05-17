import SwiftUI
import Charts

enum DiveDetailTab: String, CaseIterable, Identifiable {
    case summary = "RIEPILOGO"
    case charts = "GRAFICI"
    case details = "DETTAGLI"
    var id: String { rawValue }
}

struct DiveDetailView: View {
    let session: DiveSession
    @State private var tab: DiveDetailTab = .summary
    @State private var csvURL: URL?
    @State private var exportErrorMessage: String?

    var body: some View {
        ZStack {
            DIRBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    segmentedTabs
                    header
                    switch tab {
                    case .summary:
                        metricGrid
                        depthChart
                        gasBlock
                    case .charts:
                        depthChart
                        gasBlock
                    case .details:
                        details
                    }
                    exportBlock
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 18)
            }
        }
        .navigationTitle(Formatters.detailTitle(session.startDate))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("CSV")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(DIRTheme.cyan)
            }
        }
    }

    private var segmentedTabs: some View {
        HStack(spacing: 0) {
            ForEach(DiveDetailTab.allCases) { item in
                Button {
                    tab = item
                } label: {
                    VStack(spacing: 10) {
                        Text(item.rawValue)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(tab == item ? DIRTheme.cyan : .white.opacity(0.72))
                        Rectangle()
                            .fill(tab == item ? DIRTheme.cyan : .clear)
                            .frame(height: 2)
                    }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 10)
    }

    private var header: some View {
        HStack(spacing: 14) {
            DiveThumbnail(index: 0)
                .frame(width: 86, height: 86)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text(session.siteName ?? "Immersione")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("BUDDY")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .foregroundStyle(DIRTheme.yellow)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .overlay(RoundedRectangle(cornerRadius: 3).stroke(DIRTheme.yellow, lineWidth: 1))
                }
                Label(session.gasLabel.rawValue, systemImage: "circle")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.78))
                HStack(spacing: 16) {
                    Label("Acqua Salata", systemImage: "drop")
                    Label("\(Formatters.one(session.avgWaterTemperatureCelsius ?? 0)) C", systemImage: "thermometer")
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.78))
            }
            Spacer()
        }
    }

    private var metricGrid: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                DIRMetricTile(title: "Tempo", value: Formatters.time(session.durationSeconds), unit: "min")
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: "Max Profondita", value: Formatters.one(session.maxDepthMeters), unit: "m")
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: "Prof. Media", value: Formatters.one(session.avgDepthMeters), unit: "m")
            }
            Divider().overlay(DIRTheme.hairline)
            HStack(spacing: 0) {
                DIRMetricTile(title: "TTR", value: Formatters.zero(session.ttv), unit: "min")
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: "SAC", value: Formatters.one(session.sacLitersMinute ?? 0), unit: "l/min")
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: "Temperatura", value: Formatters.one(session.avgWaterTemperatureCelsius ?? 0), unit: "C")
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(DIRTheme.surface.opacity(0.72))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(DIRTheme.hairline, lineWidth: 1))
        )
    }

    private var depthChart: some View {
        DIRCard("PROFONDITA", icon: nil) {
            Chart(session.samples) { sample in
                LineMark(
                    x: .value("Tempo", sample.timestamp),
                    y: .value("Profondita", sample.depthMeters)
                )
                .foregroundStyle(DIRTheme.cyan)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            }
            .chartYScale(domain: [(session.maxDepthMeters + 8), 0])
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) {
                    AxisGridLine().foregroundStyle(DIRTheme.faint)
                    AxisValueLabel().foregroundStyle(DIRTheme.muted)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine().foregroundStyle(DIRTheme.faint)
                    AxisValueLabel().foregroundStyle(DIRTheme.muted)
                }
            }
            .frame(height: 220)
        }
    }

    private var gasBlock: some View {
        DIRCard("GAS UTILIZZATO", icon: nil) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    gasMetric("Gas", session.gasLabel.rawValue, "", color: .white)
                    Spacer()
                    gasMetric("Pressioni", "--", "bar", color: DIRTheme.yellow)
                }
                Text("Pressioni iniziale/finale non disponibili nel record sincronizzato; valori placeholder rimossi.")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(DIRTheme.yellow)
            }
        }
    }

    private func gasMetric(_ title: String, _ value: String, _ unit: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundStyle(title == "Consumo" ? DIRTheme.yellow : DIRTheme.muted)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.title3.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(color)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
            }
        }
    }

    private var details: some View {
        VStack(spacing: 14) {
            DIRCard("GPS", icon: "location.fill") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Start: \(session.entryGPS?.coordinateText ?? "n/d")")
                    Text("End: \(session.exitGPS?.coordinateText ?? "n/d")")
                }
                .font(.callout.monospacedDigit())
                .foregroundStyle(.white)
            }
            DIRCard("Note", icon: "note.text") {
                Text(session.notes ?? "Nessuna nota")
                    .foregroundStyle(DIRTheme.muted)
            }
        }
    }

    private var exportBlock: some View {
        HStack {
            Button {
                switch SubsurfaceExportService.writeCSV(for: session) {
                case .success(let url):
                    csvURL = url
                    exportErrorMessage = nil
                case .failure(let error):
                    csvURL = nil
                    exportErrorMessage = error.localizedDescription
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
                    .foregroundStyle(DIRTheme.cyan)
            }
            Spacer()
            if let csvURL {
                ShareLink(item: csvURL) {
                    Text("Condividi CSV")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(DIRTheme.cyan)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(DIRTheme.cyan, lineWidth: 1))
                }
            } else if let exportErrorMessage {
                Text(exportErrorMessage)
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.orange)
                    .multilineTextAlignment(.trailing)
            } else {
                Text("Genera CSV per condividere")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(DIRTheme.muted)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
            }
        }
        .padding(.top, 4)
    }
}
