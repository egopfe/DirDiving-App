import SwiftUI
import Charts

enum DiveDetailTab: String, CaseIterable, Identifiable {
    case summary
    case charts
    case details

    var id: String { rawValue }

    var title: String {
        switch self {
        case .summary: String(localized: "detail.tab.summary")
        case .charts: String(localized: "detail.tab.charts")
        case .details: String(localized: "detail.tab.details")
        }
    }
}

struct DiveDetailView: View {
    let sessionID: UUID
    @EnvironmentObject private var logStore: DiveLogStore
    @State private var session: DiveSession
    @State private var tab: DiveDetailTab = .summary
    @State private var csvURL: URL?
    @State private var exportErrorMessage: String?
    @State private var showManualEditor = false
    @AppStorage("dirdiving_ios_units") private var units = IOSUnitPreference.metric.rawValue

    init(session: DiveSession) {
        sessionID = session.id
        _session = State(initialValue: session)
    }

    var body: some View {
        DIRScreenContainer {
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
                        if session.isManual, !session.hasDepthProfile {
                            watchManualNoDepthBanner
                        }
                        ttvSafetyNote
                        tissueAnalyticsEntry
                        depthProfileSection
                        gasBlock
                    case .charts:
                        depthProfileSection
                        gasBlock
                    case .details:
                        details
                    }
                    if session.isManual && !session.isDemoDive {
                        Button {
                            showManualEditor = true
                        } label: {
                            Text(String(localized: "manual_dive.edit.title"))
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(DIRTheme.cyan)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(DIRTheme.cyan.opacity(0.75), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint(Text(String(localized: "manual_dive.edit.a11y")))
                    }
                    exportBlock
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 22)
            }
            .dirCompanionScrollSurface()
        }
        .navigationTitle(Formatters.detailTitle(session.startDate))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showManualEditor) {
            ManualDiveEditorView(existing: session)
        }
        .onChange(of: logStore.sessions) { _, _ in
            guard let updated = logStore.session(id: sessionID), updated != session else { return }
            session = updated
        }
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
                .accessibilityLabel(detailTabAccessibilityLabel(for: item))
                .accessibilityAddTraits(tab == item ? .isSelected : [])
            }
        }
        .padding(.top, 2)
    }

    private func detailTabAccessibilityLabel(for item: DiveDetailTab) -> String {
        if tab == item {
            return String(format: String(localized: "detail.tab.a11y.selected"), item.title)
        }
        return String(format: String(localized: "detail.tab.a11y.unselected"), item.title)
    }

    private var header: some View {
        HStack(spacing: 12) {
            DiveThumbnail(index: 0)
                .frame(width: 82, height: 82)
            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 6) {
                    Text(session.siteName ?? String(localized: "detail.default_site"))
                        .font(DIRTypography.cardHeading)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                    if session.buddy != nil {
                        Text(String(localized: "detail.buddy.badge"))
                            .font(DIRTypography.microBadge)
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
                .font(DIRTypography.metadata)
                .foregroundStyle(DIRTheme.muted)
                HStack(spacing: 14) {
                    Label(salinityText, systemImage: "drop")
                    Label(temperatureText, systemImage: "thermometer")
                }
                .font(DIRTypography.metadata)
                .foregroundStyle(DIRTheme.muted)
            }
            Spacer()
        }
        .padding(.top, 2)
    }

    private var metricGrid: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                detailMetric(String(localized: "detail.metric.duration"), value: Formatters.time(session.durationSeconds), unit: String(localized: "common.unit.min"))
                Divider().overlay(DIRTheme.hairline)
                detailMetric(String(localized: "detail.metric.max_depth"), measurement: Formatters.depth(session.maxDepthMeters, units: unitPreference))
                Divider().overlay(DIRTheme.hairline)
                detailMetric(String(localized: "detail.metric.avg_depth"), measurement: Formatters.depth(session.avgDepthMeters, units: unitPreference))
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
            Text(String(localized: "depth.safety.log.outside_range"))
                .font(DIRTypography.warning)
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
        Text(String(localized: "detail.ttv.note"))
            .font(.caption2.weight(.semibold))
            .foregroundStyle(DIRTheme.yellow)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.surface2.opacity(0.56)))
    }

    @ViewBuilder
    private var depthProfileSection: some View {
        if session.hasDepthProfile {
            depthChart
        } else {
            noDepthProfilePlaceholder
        }
    }

    private var watchManualNoDepthBanner: some View {
        Text(String(localized: "detail.manual.nodepth.banner"))
            .font(.caption.weight(.semibold))
            .foregroundStyle(DIRTheme.cyan)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(DIRTheme.cyan.opacity(0.10))
                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(DIRTheme.cyan.opacity(0.55), lineWidth: 1))
            )
    }

    private var noDepthProfilePlaceholder: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "detail.chart.no_profile_title"))
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(DIRTheme.cyan)
            Text(String(localized: "detail.chart.no_profile_body"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(red: 0.020, green: 0.035, blue: 0.048).opacity(0.94))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(DIRTheme.cyan.opacity(0.16), lineWidth: 1))
        )
    }

    private var depthChart: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text(String(localized: "detail.chart.depth_title"))
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
                    x: .value(String(localized: "chart.axis.time"), sample.timestamp),
                    y: .value(String(localized: "chart.axis.depth"), Formatters.depthValue(sample.depthMeters, units: unitPreference))
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
            .frame(minHeight: 180, maxHeight: 280)
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
        .accessibilityLabel(String(localized: "detail.chart.depth_a11y"))
        .accessibilityValue(
            String(
                format: String(localized: "detail.chart.depth_a11y_value"),
                Formatters.depth(session.maxDepthMeters, units: unitPreference).text,
                Formatters.time(session.durationSeconds)
            )
        )
    }

    private var gasBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "detail.gas.title"))
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(0.7)
                .foregroundStyle(DIRTheme.cyan)
            HStack(spacing: 10) {
                gasMetric(String(localized: "detail.gas.mix"), session.gasLabel.rawValue, nil, color: .white)
                if let pressureSummary {
                    gasMetric(String(localized: "detail.gas.pressures"), pressureSummary.value, pressureSummary.unit, color: DIRTheme.yellow)
                }
            }
            if let pressureFootnote {
                Text(pressureFootnote)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            } else if !session.isManual {
                Text(String(localized: "detail.gas.pressures_unavailable"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
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
                .foregroundStyle(title == String(localized: "detail.gas.pressures") ? DIRTheme.yellow : DIRTheme.muted)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: title == String(localized: "detail.gas.pressures") ? 14 : 20, weight: .semibold, design: .rounded))
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

    private var pressureSummary: (value: String, unit: String?)? {
        if let entryBar = session.entryPressureBar, let exitBar = session.exitPressureBar {
            let entry = PressureDisplayMath.formatPressureValue(entryBar, units: unitPreference)
            let exit = PressureDisplayMath.formatPressureValue(exitBar, units: unitPreference)
            return ("\(entry) → \(exit)", nil)
        }
        let entry = session.entryPressureText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let exit = session.exitPressureText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !entry.isEmpty || !exit.isEmpty else { return nil }
        if !entry.isEmpty, !exit.isEmpty {
            return ("\(entry) → \(exit)", nil)
        }
        return (entry.isEmpty ? exit : entry, nil)
    }

    private var pressureFootnote: String? {
        PressureDisplayMath.consumedDisplay(
            entryText: session.entryPressureText ?? "",
            exitText: session.exitPressureText ?? "",
            entryBar: session.entryPressureBar,
            exitBar: session.exitPressureBar,
            units: unitPreference
        )
    }

    private var temperatureText: String {
        Formatters.optionalTemperature(session.avgWaterTemperatureCelsius, units: unitPreference)
    }

    private var salinityText: String {
        String(localized: "detail.salinity.not_recorded")
    }

    private var unitPreference: IOSUnitPreference {
        IOSUnitPreference.fromStorage(units)
    }

    @ViewBuilder
    private var sacMetric: some View {
        if let sac = session.sacLitersMinute {
            detailMetric(String(localized: "detail.metric.sac"), measurement: Formatters.sac(sac, units: unitPreference))
        } else {
            detailMetric(String(localized: "detail.metric.sac"), value: "—", valueColor: DIRTheme.yellow)
        }
    }

    @ViewBuilder
    private var temperatureMetric: some View {
        if let temperature = session.avgWaterTemperatureCelsius {
            detailMetric(String(localized: "detail.metric.temperature"), measurement: Formatters.temperature(temperature, units: unitPreference))
        } else {
            detailMetric(String(localized: "detail.metric.temperature"), value: "—", valueColor: DIRTheme.yellow)
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
            if let ccr = session.ccrLogbookMetadata {
                darkPanel(title: String(localized: "manual_dive.ccr.header"), icon: "lungs.fill") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "manual_dive.ccr.logbook_disclosure"))
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.muted)
                        if !ccr.rebreatherModel.isEmpty {
                            Text("\(String(localized: "ccr.rebreather_model")): \(ccr.rebreatherModel)")
                        }
                        Text("\(String(localized: "ccr.setpoint.low")) / \(String(localized: "ccr.setpoint.high")): \(Formatters.one(ccr.lowSetpoint)) / \(Formatters.one(ccr.highSetpoint)) bar")
                        Text("\(String(localized: "ccr.setpoint.switch_depth")): \(Formatters.depth(ccr.setpointSwitchDepthMeters, units: IOSUnitPreference.fromStorage(units)).text)")
                        Text("\(String(localized: "ccr.diluent")): \(ccr.diluentLabel)")
                        if !ccr.bailoutLabels.isEmpty {
                            Text("\(String(localized: "ccr.bailout")): \(ccr.bailoutLabels.joined(separator: ", "))")
                        }
                    }
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                }
            }
            darkPanel(title: String(localized: "detail.panel.gps"), icon: "location.fill") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(String(localized: "detail.gps.start")): \(session.entryGPS?.coordinateText ?? String(localized: "detail.not_available")) · \(fixSourceText(session.entryGPSFixSource))")
                    Text("\(String(localized: "detail.gps.end")): \(session.exitGPS?.coordinateText ?? String(localized: "detail.not_available")) · \(fixSourceText(session.exitGPSFixSource))")
                    Text("\(String(localized: "detail.gps.accuracy_start")): \(accuracyText(session.entryGPS))")
                    Text("\(String(localized: "detail.gps.accuracy_end")): \(accuracyText(session.exitGPS))")
                }
                .font(.system(size: 13, weight: .medium, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
            }
            darkPanel(title: String(localized: "detail.panel.notes"), icon: "note.text") {
                Text(session.notes ?? String(localized: "detail.notes.empty"))
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
        case .fix: return String(localized: "detail.gps.fix_surface")
        case .fallback: return String(localized: "detail.gps.fix_fallback")
        case .noFix: return String(localized: "detail.gps.fix_none")
        }
    }

    private func accuracyText(_ point: GPSPoint?) -> String {
        guard let point, point.horizontalAccuracy >= 0 else { return String(localized: "detail.not_available") }
        return "\(Formatters.zero(point.horizontalAccuracy)) m"
    }

    private var exportBlock: some View {
        HStack {
            Button {
                guard session.hasDepthProfile else {
                    csvURL = nil
                    exportErrorMessage = String(localized: "detail.export.no_profile")
                    return
                }
                switch SubsurfaceExportService.writeCSV(for: session) {
                case .success(let url):
                    csvURL = url
                    exportErrorMessage = nil
                case .failure(let error):
                    csvURL = nil
                    exportErrorMessage = error.localizedDescription
                }
            } label: {
                Text(String(localized: "detail.export.generate_csv"))
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(DIRTheme.cyan.opacity(0.75), lineWidth: 1))
            }
            Spacer()
            if let csvURL {
                ShareLink(
                    item: csvURL,
                    preview: SharePreview(
                        String(localized: "detail.export.share_csv"),
                        icon: Image(systemName: "tablecells")
                    )
                ) {
                    Text(String(localized: "detail.export.share_csv"))
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
                Text(String(localized: "detail.export.csv_not_generated"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.muted)
            }
        }
        .padding(.top, 4)
    }

    @ViewBuilder
    private var tissueAnalyticsEntry: some View {
        if session.hasDepthProfile, !session.samples.isEmpty {
            NavigationLink {
                if let presentation = TissueAnalyticsService.presentationForSession(session) {
                    TissueNarcosisAnalyticsView(presentation: presentation, initialTab: .tissues)
                } else {
                    TissueAnalyticsUnavailableView()
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(TissueAnalyticsTheme.accentBlue)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "tissue_analytics.logbook.entry.title"))
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(TissueAnalyticsService.logbookEntrySubtitle(for: session))
                            .font(.caption)
                            .foregroundStyle(TissueAnalyticsTheme.labelSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(TissueAnalyticsTheme.labelMuted)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(TissueAnalyticsTheme.cardBackground)
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(TissueAnalyticsTheme.cardBorder, lineWidth: 1))
                )
            }
            .buttonStyle(.plain)
        }
    }
}
