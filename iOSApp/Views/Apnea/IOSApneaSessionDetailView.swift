import SwiftUI
import Charts
import MapKit

enum IOSApneaSessionDetailTab: String, CaseIterable, Identifiable {
    case summary
    case charts
    case map

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .summary: return "apnea.ios.session.tab.summary"
        case .charts: return "apnea.ios.session.tab.charts"
        case .map: return "apnea.ios.session.tab.map"
        }
    }
}

struct IOSApneaSessionDetailView: View {
    let session: ApneaSession
    var isDemoSession: Bool = false
    @EnvironmentObject private var logbook: IOSApneaLogbookStore
    @EnvironmentObject private var locationPermission: IOSLocationPermissionService
    @AppStorage(IOSUnitPreference.storageKey) private var unitsRaw = IOSUnitPreference.metric.rawValue
    @State private var tab: IOSApneaSessionDetailTab = .summary

    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(unitsRaw) }
    private var summary: IOSApneaSessionSummaryPresentation {
        IOSApneaLogbookPresentationMapper.sessionSummary(session, units: unitPreference)
    }
    private var charts: ApneaSessionChartsModel { logbook.charts(for: session) }
    private var mapModel: ApneaSessionMapModel {
        ApneaSessionMapPresentation.make(from: session, permission: locationPermission.permissionState)
    }
    private var diveMetrics: [ApneaDiveMetrics] { logbook.diveMetrics(for: session) }

    var body: some View {
        DIRScreenContainer {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    segmentedTabs
                    switch tab {
                    case .summary:
                        summarySection
                        divesSection
                    case .charts:
                        IOSApneaSessionChartsView(charts: charts, units: unitPreference)
                    case .map:
                        IOSApneaSessionMapView(model: mapModel)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
            }
            .dirCompanionScrollSurface()
        }
        .navigationTitle(summary.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isDemoSession {
                ToolbarItem(placement: .topBarTrailing) {
                    DemoLogbookBadge()
                }
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        IOSApneaSessionExportView(session: session)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel(DIRIOSLocalizer.string("apnea.ios.export.title"))
                }
            }
        }
        .onAppear {
            locationPermission.refresh()
        }
    }

    private var header: some View {
        DIRCard(DIRIOSLocalizer.string("apnea.ios.session.detail.title"), icon: "clock.fill", accent: DIRTheme.cyan) {
            if isDemoSession {
                DemoLogbookBadge()
                Text(DIRIOSLocalizer.string("settings.demo_logbook.not_saved_real"))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
            }
            Text(summary.dateText)
                .font(.headline)
                .foregroundStyle(.white)
            if let warnings = summary.warningsText {
                Text(warnings)
                    .font(.caption)
                    .foregroundStyle(DIRTheme.orange)
            }
        }
    }

    private var segmentedTabs: some View {
        Picker("", selection: $tab) {
            ForEach(IOSApneaSessionDetailTab.allCases) { item in
                Text(DIRIOSLocalizer.string(item.titleKey)).tag(item)
            }
        }
        .pickerStyle(.segmented)
    }

    private var summarySection: some View {
        VStack(spacing: 10) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                metricTile(DIRIOSLocalizer.string("apnea.ios.dashboard.max_depth"), summary.maxDepthText)
                metricTile(DIRIOSLocalizer.string("apnea.ios.dashboard.dives"), summary.diveCountText)
                metricTile(DIRIOSLocalizer.string("apnea.ios.dashboard.total_time"), summary.durationText)
                metricTile(DIRIOSLocalizer.string("apnea.ios.dashboard.total_recovery"), summary.recoveryText)
            }
        }
    }

    private var divesSection: some View {
        DIRCard(DIRIOSLocalizer.string("apnea.ios.session.dives"), icon: "figure.water.fitness", accent: DIRTheme.cyan) {
            if diveMetrics.isEmpty {
                Text(DIRIOSLocalizer.string("apnea.ios.session.no_dives"))
                    .foregroundStyle(DIRTheme.muted)
            } else {
                ForEach(diveMetrics, id: \.diveID) { metrics in
                    NavigationLink {
                        IOSApneaDiveDetailView(metrics: metrics)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(format: DIRIOSLocalizer.string("apnea.ios.dive.title_format"), metrics.diveIndex + 1))
                                    .foregroundStyle(.white)
                                Text(Formatters.depth(metrics.maxDepthMeters, units: unitPreference).text)
                                    .font(.caption)
                                    .foregroundStyle(DIRTheme.muted)
                            }
                            Spacer()
                            Text(Formatters.stopwatch(metrics.durationSeconds))
                                .monospacedDigit()
                                .foregroundStyle(DIRTheme.cyan)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(DIRTheme.muted)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func metricTile(_ title: String, _ value: String) -> some View {
        DIRMetricTile(title: title, value: value, color: .white)
    }
}

struct IOSApneaDiveDetailView: View {
    let metrics: ApneaDiveMetrics
    @AppStorage(IOSUnitPreference.storageKey) private var unitsRaw = IOSUnitPreference.metric.rawValue

    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(unitsRaw) }
    private var presentation: IOSApneaDiveDetailPresentation {
        IOSApneaLogbookPresentationMapper.diveDetail(metrics, units: unitPreference)
    }

    var body: some View {
        DIRScreenContainer {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    DIRCard(presentation.title, icon: "timer", accent: DIRTheme.cyan) {
                        Text(presentation.dateText)
                            .foregroundStyle(.white)
                    }
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        metricTile(DIRIOSLocalizer.string("apnea.ios.dashboard.max_depth"), presentation.maxDepthText)
                        metricTile(DIRIOSLocalizer.string("apnea.ios.dive.duration"), presentation.durationText)
                        metricTile(DIRIOSLocalizer.string("apnea.ios.dive.descent_speed"), presentation.descentSpeedText)
                        metricTile(DIRIOSLocalizer.string("apnea.ios.dive.ascent_speed"), presentation.ascentSpeedText)
                        metricTile(DIRIOSLocalizer.string("apnea.ios.dive.bottom_time"), presentation.bottomTimeText)
                        metricTile(DIRIOSLocalizer.string("apnea.ios.dive.temperature"), presentation.temperatureText)
                    }
                    if presentation.hasDepthProfile {
                        depthChart
                    } else if let key = presentation.emptyProfileKey {
                        Text(DIRIOSLocalizer.string(key))
                            .font(.callout)
                            .foregroundStyle(DIRTheme.muted)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 20)
                    }
                    DIRCard(DIRIOSLocalizer.string("apnea.ios.dive.details"), accent: DIRTheme.cyan) {
                        detailRow(DIRIOSLocalizer.string("apnea.ios.dive.markers"), presentation.markersText)
                        detailRow(DIRIOSLocalizer.string("apnea.ios.dive.alarms"), presentation.alarmsText)
                        detailRow(DIRIOSLocalizer.string("apnea.ios.dive.recovery_before"), presentation.recoveryBeforeText)
                        detailRow(DIRIOSLocalizer.string("apnea.ios.dive.recovery_after"), presentation.recoveryAfterText)
                    }
                }
                .padding(18)
            }
            .dirCompanionScrollSurface()
        }
        .navigationTitle(presentation.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var depthChart: some View {
        DIRCard(DIRIOSLocalizer.string("apnea.ios.charts.depth"), icon: "chart.xyaxis.line", accent: DIRTheme.cyan) {
            Chart(metrics.depthPoints) { point in
                LineMark(
                    x: .value("time", point.sessionOffsetSeconds),
                    y: .value("depth", Formatters.depthValue(point.depthMeters, units: unitPreference))
                )
                .foregroundStyle(DIRTheme.cyan)
                .interpolationMethod(.catmullRom)
                AreaMark(
                    x: .value("time", point.sessionOffsetSeconds),
                    y: .value("depth", Formatters.depthValue(point.depthMeters, units: unitPreference))
                )
                .foregroundStyle(DIRTheme.cyan.opacity(0.18))
            }
            .chartYScale(domain: .automatic(includesZero: true))
            .frame(minHeight: 180)
        }
    }

    private func metricTile(_ title: String, _ value: String) -> some View {
        DIRMetricTile(title: title, value: value, color: .white)
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(DIRTheme.muted)
            Spacer()
            Text(value).foregroundStyle(.white)
        }
        .font(.subheadline)
    }
}

struct IOSApneaSessionChartsView: View {
    let charts: ApneaSessionChartsModel
    let units: IOSUnitPreference
    @State private var kind: ApneaSessionChartKind = .depth

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Picker("", selection: $kind) {
                Text(DIRIOSLocalizer.string("apnea.ios.charts.depth")).tag(ApneaSessionChartKind.depth)
                Text(DIRIOSLocalizer.string("apnea.ios.charts.time")).tag(ApneaSessionChartKind.time)
                Text(DIRIOSLocalizer.string("apnea.ios.charts.recovery")).tag(ApneaSessionChartKind.recovery)
            }
            .pickerStyle(.segmented)

            switch kind {
            case .depth:
                depthChartCard
            case .time:
                diveDurationChartCard
                if charts.hasTemperatureData {
                    temperatureChartCard
                }
            case .recovery:
                recoveryChartCard
            }
        }
    }

    private var depthChartCard: some View {
        DIRCard(DIRIOSLocalizer.string("apnea.ios.charts.depth_m"), icon: "water.waves", accent: DIRTheme.cyan) {
            if charts.hasDepthData {
                Chart(charts.depthPoints.filter { !$0.isSurfaceGap }) { point in
                    LineMark(
                        x: .value("time", point.sessionOffsetSeconds),
                        y: .value("depth", Formatters.depthValue(point.depthMeters, units: units))
                    )
                    .foregroundStyle(by: .value("dive", point.diveIndex))
                    .interpolationMethod(.catmullRom)
                }
                .chartForegroundStyleScale(range: chartColors)
                .frame(minHeight: 200)
            } else {
                emptyChart(DIRIOSLocalizer.string("apnea.ios.charts.depth_empty"))
            }
        }
    }

    private var diveDurationChartCard: some View {
        DIRCard(DIRIOSLocalizer.string("apnea.ios.charts.dives"), icon: "chart.bar.fill", accent: DIRTheme.green) {
            if charts.diveBars.isEmpty {
                emptyChart(DIRIOSLocalizer.string("apnea.ios.charts.dives_empty"))
            } else {
                Chart(charts.diveBars) { bar in
                    BarMark(
                        x: .value("dive", bar.diveIndex + 1),
                        y: .value("duration", bar.durationSeconds)
                    )
                    .foregroundStyle(DIRTheme.green)
                }
                .frame(minHeight: 180)
            }
        }
    }

    private var temperatureChartCard: some View {
        DIRCard(DIRIOSLocalizer.string("apnea.ios.charts.temperature"), icon: "thermometer.medium", accent: DIRTheme.cyan) {
            Chart(charts.temperaturePoints) { point in
                LineMark(
                    x: .value("time", point.sessionOffsetSeconds),
                    y: .value("temp", Formatters.temperatureValue(point.temperatureCelsius, units: units))
                )
                .foregroundStyle(Color.purple)
                AreaMark(
                    x: .value("time", point.sessionOffsetSeconds),
                    y: .value("temp", Formatters.temperatureValue(point.temperatureCelsius, units: units))
                )
                .foregroundStyle(Color.purple.opacity(0.15))
            }
            .frame(minHeight: 160)
        }
    }

    private var recoveryChartCard: some View {
        DIRCard(DIRIOSLocalizer.string("apnea.ios.charts.recovery"), icon: "heart.text.square", accent: DIRTheme.orange) {
            if charts.hasRecoveryData {
                Chart(charts.recoveryBars) { bar in
                    BarMark(
                        x: .value("dive", bar.diveIndex + 1),
                        y: .value("recovery", bar.seconds)
                    )
                    .foregroundStyle(DIRTheme.orange)
                }
                .frame(minHeight: 180)
            } else {
                emptyChart(DIRIOSLocalizer.string("apnea.ios.charts.recovery_empty"))
            }
        }
    }

    private var chartColors: [Color] {
        [DIRTheme.cyan, DIRTheme.green, DIRTheme.yellow, DIRTheme.orange, Color.purple]
    }

    private func emptyChart(_ message: String) -> some View {
        Text(message)
            .font(.callout)
            .foregroundStyle(DIRTheme.muted)
            .frame(maxWidth: .infinity, minHeight: 140, alignment: .center)
    }
}

struct IOSApneaSessionMapView: View {
    let model: ApneaSessionMapModel

    var body: some View {
        DIRCard(DIRIOSLocalizer.string("apnea.ios.map.title"), icon: "map.fill", accent: DIRTheme.cyan) {
            if model.isAvailable {
                Map(initialPosition: mapPosition) {
                    MapPolyline(coordinates: model.coordinates.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) })
                        .stroke(DIRTheme.cyan, lineWidth: 3)
                    if let first = model.coordinates.first {
                        Marker(DIRIOSLocalizer.string("apnea.ios.map.start"), coordinate: CLLocationCoordinate2D(latitude: first.latitude, longitude: first.longitude))
                    }
                }
                .frame(minHeight: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                HStack {
                    if let start = model.sessionStartText {
                        VStack(alignment: .leading) {
                            Text(DIRIOSLocalizer.string("apnea.ios.map.session_start"))
                                .font(.caption)
                                .foregroundStyle(DIRTheme.muted)
                            Text(start).font(.title3.bold()).foregroundStyle(.white)
                        }
                    }
                    Spacer()
                    if let end = model.sessionEndText {
                        VStack(alignment: .trailing) {
                            Text(DIRIOSLocalizer.string("apnea.ios.map.session_end"))
                                .font(.caption)
                                .foregroundStyle(DIRTheme.muted)
                            Text(end).font(.title3.bold()).foregroundStyle(.white)
                        }
                    }
                }

                if let accuracy = model.accuracyMeters {
                    Text(String(format: DIRIOSLocalizer.string("apnea.ios.map.accuracy_format"), Int(accuracy.rounded())))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                }
                Text(DIRIOSLocalizer.string(model.privacyNoticeKey))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                fixQualityBadge
            } else {
                Text(DIRIOSLocalizer.string(model.unavailableReasonKey ?? "apnea.ios.map.unavailable"))
                    .font(.callout)
                    .foregroundStyle(DIRTheme.muted)
                    .frame(maxWidth: .infinity, minHeight: 160, alignment: .center)
            }
        }
    }

    private var fixQualityBadge: some View {
        let (text, color): (String, Color) = switch model.fixQuality {
        case .good: (DIRIOSLocalizer.string("apnea.ios.map.fix.good"), DIRTheme.green)
        case .fair: (DIRIOSLocalizer.string("apnea.ios.map.fix.fair"), DIRTheme.cyan)
        case .poor: (DIRIOSLocalizer.string("apnea.ios.map.fix.poor"), DIRTheme.orange)
        case .none: (DIRIOSLocalizer.string("apnea.ios.map.fix.none"), DIRTheme.muted)
        }
        return Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
    }

    private var mapPosition: MapCameraPosition {
        guard let first = model.coordinates.first else { return .automatic }
        return .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: first.latitude, longitude: first.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }
}

struct IOSApneaPersonalRecordsView: View {
    @EnvironmentObject private var logbook: IOSApneaLogbookStore
    @AppStorage(IOSUnitPreference.storageKey) private var unitsRaw = IOSUnitPreference.metric.rawValue
    @State private var includeDegraded = false
    @State private var includeSimulated = false

    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(unitsRaw) }
    private var summary: ApneaPersonalRecordsSummary {
        logbook.personalRecords(
            options: ApneaRecordEligibilityOptions(
                includeSimulatedSessions: includeSimulated,
                includeDegradedData: includeDegraded
            )
        )
    }
    private var records: [IOSApneaPersonalRecordPresentation] {
        IOSApneaLogbookPresentationMapper.personalRecords(summary, units: unitPreference)
    }

    var body: some View {
        DIRScreenContainer {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    filterCard
                    if records.isEmpty {
                        Text(DIRIOSLocalizer.string("apnea.ios.records.empty"))
                            .foregroundStyle(DIRTheme.muted)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                    } else {
                        ForEach(records) { record in
                            DIRCard(record.title, accent: DIRTheme.green) {
                                Text(record.valueText)
                                    .font(.title2.bold())
                                    .foregroundStyle(.white)
                                Text(record.dateText)
                                    .font(.caption)
                                    .foregroundStyle(DIRTheme.muted)
                                Text(record.contextText)
                                    .font(.subheadline)
                                    .foregroundStyle(DIRTheme.cyan)
                                if let tie = record.tieText {
                                    Text(tie)
                                        .font(.caption)
                                        .foregroundStyle(DIRTheme.orange)
                                }
                            }
                        }
                    }
                }
                .padding(18)
            }
            .dirCompanionScrollSurface()
        }
        .navigationTitle(DIRIOSLocalizer.string("apnea.ios.records.title"))
    }

    private var filterCard: some View {
        DIRCard(DIRIOSLocalizer.string("apnea.ios.records.filters"), accent: DIRTheme.cyan) {
            Toggle(DIRIOSLocalizer.string("apnea.ios.records.include_degraded"), isOn: $includeDegraded)
                .tint(DIRTheme.cyan)
            Toggle(DIRIOSLocalizer.string("apnea.ios.records.include_simulated"), isOn: $includeSimulated)
                .tint(DIRTheme.cyan)
            Text(
                String(
                    format: DIRIOSLocalizer.string("apnea.ios.records.eligible_format"),
                    summary.eligibleSessionCount,
                    summary.excludedSessionCount
                )
            )
            .font(.caption)
            .foregroundStyle(DIRTheme.muted)
        }
    }
}
