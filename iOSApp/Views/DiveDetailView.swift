import SwiftUI
import Charts

enum DiveDetailTab: String, CaseIterable, Identifiable {
    case summary
    case charts
    case details

    var id: String { rawValue }

    var title: String {
        switch self {
        case .summary: String(localized: "RIEPILOGO")
        case .charts: String(localized: "GRAFICI")
        case .details: String(localized: "DETTAGLI")
        }
    }
}

struct DiveDetailView: View {
    let session: DiveSession
    @State private var tab: DiveDetailTab = .summary
    @State private var csvURL: URL?
    @State private var exportErrorMessage: String?
    @AppStorage("dirdiving_ios_units") private var units = IOSUnitPreference.metric.rawValue

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    segmentedTabs
                    switch tab {
                    case .summary:
                        metricGrid
                        if session.exceededSupportedDepthRange {
                            exceededDepthLogBanner
                        }
                        ttvSafetyNote
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
                .padding(.top, 10)
                .padding(.bottom, 22)
            }
        }
        .navigationTitle(Formatters.detailTitle(session.startDate))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var segmentedTabs: some View {
        HStack(spacing: 0) {
            ForEach(DiveDetailTab.allCases) { item in
                Button {
                    tab = item
                } label: {
                    VStack(spacing: 9) {
                        Text(item.title)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .tracking(0.5)
                            .foregroundStyle(tab == item ? DIRTheme.cyan : DIRTheme.muted)
                        Rectangle()
                            .fill(tab == item ? DIRTheme.cyan : .clear)
                            .frame(height: 2.5)
                            .shadow(color: tab == item ? DIRTheme.cyan.opacity(0.55) : .clear, radius: 5, x: 0, y: 0)
                    }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 2)
    }

    private var header: some View {
        HStack(spacing: 12) {
            DiveThumbnail(index: 0)
                .frame(width: 82, height: 82)
            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 6) {
                    Text(session.siteName ?? "Immersione")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                    if session.buddy != nil {
                        Text("BUDDY")
                            .font(.system(size: 8, weight: .bold, design: .rounded))
                            .foregroundStyle(DIRTheme.yellow)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(DIRTheme.yellow, lineWidth: 1))
                    }
                }
                HStack(spacing: 6) {
                    Image(systemName: "circle")
                        .font(.system(size: 7, weight: .bold))
                    Text(session.gasLabel.rawValue)
                }
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(DIRTheme.muted)
                HStack(spacing: 14) {
                    Label("Acqua Salata", systemImage: "drop")
                    Label(temperatureText, systemImage: "thermometer")
                }
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(DIRTheme.muted)
            }
            Spacer()
        }
        .padding(.top, 2)
    }

    private var metricGrid: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                detailMetric("Tempo", value: Formatters.time(session.durationSeconds), unit: "min")
                Divider().overlay(DIRTheme.hairline)
                detailMetric("Max Profondita", measurement: Formatters.depth(session.maxDepthMeters, units: unitPreference))
                Divider().overlay(DIRTheme.hairline)
                detailMetric("Prof. Media", measurement: Formatters.depth(session.avgDepthMeters, units: unitPreference))
            }
            Divider().overlay(DIRTheme.hairline)
            HStack(spacing: 0) {
                detailMetric("TTV", value: Formatters.zero(session.ttv))
                Divider().overlay(DIRTheme.hairline)
                sacMetric
                Divider().overlay(DIRTheme.hairline)
                temperatureMetric
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(red: 0.030, green: 0.043, blue: 0.060).opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private var exceededDepthLogBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.octagon.fill")
            Text(String(localized: "Outside supported operating range"))
                .font(.system(size: 13, weight: .bold, design: .rounded))
        }
        .foregroundStyle(DIRTheme.red)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(DIRTheme.red.opacity(0.12))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(DIRTheme.red.opacity(0.7), lineWidth: 1))
        )
    }

    private var ttvSafetyNote: some View {
        Text("TTV: metrica informativa derivata da profondita media e durata. Non e NDL, TTS o guida decompressiva certificata.")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(DIRTheme.yellow)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.surface2.opacity(0.56)))
    }

    private var depthChart: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text("PROFONDITA")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(0.7)
                    .foregroundStyle(DIRTheme.cyan)
                Spacer()
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DIRTheme.cyan)
            }
            Chart(session.samples) { sample in
                LineMark(
                    x: .value("Tempo", sample.timestamp),
                    y: .value("Profondita", Formatters.depthValue(sample.depthMeters, units: unitPreference))
                )
                .foregroundStyle(DIRTheme.cyan)
                .lineStyle(StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
            }
            .chartYScale(domain: [(Formatters.depthValue(session.maxDepthMeters + 8, units: unitPreference)), 0])
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) {
                    AxisGridLine().foregroundStyle(DIRTheme.cyan.opacity(0.08))
                    AxisValueLabel().foregroundStyle(DIRTheme.muted)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine().foregroundStyle(DIRTheme.cyan.opacity(0.08))
                    AxisValueLabel().foregroundStyle(DIRTheme.muted)
                }
            }
            .frame(height: 210)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(red: 0.020, green: 0.035, blue: 0.048).opacity(0.94))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(DIRTheme.cyan.opacity(0.16), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Grafico profilo profondita")
        .accessibilityValue("Profondita massima \(Formatters.depth(session.maxDepthMeters, units: unitPreference).text), durata \(Formatters.time(session.durationSeconds)) minuti")
    }

    private var gasBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GAS UTILIZZATO")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(0.7)
                .foregroundStyle(DIRTheme.cyan)
            HStack(spacing: 10) {
                gasMetric("Miscela", session.gasLabel.rawValue, nil, color: .white)
                gasMetric("Pressioni", "Non disponibile", nil, color: DIRTheme.yellow)
            }
            Text("Pressioni iniziale/finale e consumo gas non sono presenti nel record sincronizzato.")
                .font(.caption.weight(.semibold))
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(red: 0.020, green: 0.035, blue: 0.048).opacity(0.94))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(DIRTheme.cyan.opacity(0.14), lineWidth: 1)
                )
        )
    }

    private func gasMetric(_ title: String, _ value: String, _ unit: String?, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(title == "Pressioni" ? DIRTheme.yellow : DIRTheme.muted)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: title == "Pressioni" ? 14 : 20, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(color)
                if let unit {
                    Text(unit)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(DIRTheme.muted)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var temperatureText: String {
        Formatters.optionalTemperature(session.avgWaterTemperatureCelsius, units: unitPreference)
    }

    private var unitPreference: IOSUnitPreference {
        IOSUnitPreference.fromStorage(units)
    }

    @ViewBuilder
    private var sacMetric: some View {
        if let sac = session.sacLitersMinute {
            detailMetric("SAC", measurement: Formatters.sac(sac, units: unitPreference))
        } else {
            detailMetric("SAC", value: "—", valueColor: DIRTheme.yellow)
        }
    }

    @ViewBuilder
    private var temperatureMetric: some View {
        if let temperature = session.avgWaterTemperatureCelsius {
            detailMetric("Temperatura", measurement: Formatters.temperature(temperature, units: unitPreference))
        } else {
            detailMetric("Temperatura", value: "—", valueColor: DIRTheme.yellow)
        }
    }

    private func detailMetric(_ title: String, value: String, unit: String? = nil, valueColor: Color = .white) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(DIRTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(valueColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                if let unit {
                    Text(unit)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(DIRTheme.muted)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 70)
        .padding(.horizontal, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title) \(value) \(unit ?? "")")
    }

    private func detailMetric(_ title: String, measurement: DisplayMeasurement) -> some View {
        detailMetric(title, value: measurement.value, unit: measurement.unit)
    }

    private var details: some View {
        VStack(spacing: 12) {
            darkPanel(title: "GPS", icon: "location.fill") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Start: \(session.entryGPS?.coordinateText ?? "n/d") · \(fixSourceText(session.entryGPSFixSource))")
                    Text("End: \(session.exitGPS?.coordinateText ?? "n/d") · \(fixSourceText(session.exitGPSFixSource))")
                    Text("Accuratezza start: \(accuracyText(session.entryGPS))")
                    Text("Accuratezza end: \(accuracyText(session.exitGPS))")
                }
                .font(.system(size: 13, weight: .medium, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
            }
            darkPanel(title: "Note", icon: "note.text") {
                Text(session.notes ?? "Nessuna nota")
                    .foregroundStyle(DIRTheme.muted)
            }
        }
    }

    private func darkPanel<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                Text(title.uppercased())
            }
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .tracking(0.6)
            .foregroundStyle(DIRTheme.cyan)
            content()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(red: 0.020, green: 0.035, blue: 0.048).opacity(0.94))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(DIRTheme.cyan.opacity(0.14), lineWidth: 1)
                )
        )
    }

    private func fixSourceText(_ source: GPSFixSource) -> String {
        switch source {
        case .fix: return "fix superficie"
        case .fallback: return "ultimo punto noto"
        case .noFix: return "no-fix"
        }
    }

    private func accuracyText(_ point: GPSPoint?) -> String {
        guard let point, point.horizontalAccuracy >= 0 else { return "Non disponibile" }
        return "\(Formatters.zero(point.horizontalAccuracy)) m"
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
                Text("Genera CSV Subsurface")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(DIRTheme.cyan.opacity(0.75), lineWidth: 1))
            }
            Spacer()
            if let csvURL {
                ShareLink(item: csvURL) {
                    Text("Condividi CSV")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(DIRTheme.cyan)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(DIRTheme.cyan.opacity(0.75), lineWidth: 1))
                }
            } else if let exportErrorMessage {
                Text(exportErrorMessage)
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.orange)
                    .multilineTextAlignment(.trailing)
            } else {
                Text("CSV non generato")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.muted)
            }
        }
        .padding(.top, 4)
    }
}
