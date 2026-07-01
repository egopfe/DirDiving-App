import SwiftUI
import Charts
import MapKit

struct IOSSnorkelingSessionDetailView: View {
    let session: SnorkelingSession
    var isDemoSession: Bool = false
    @EnvironmentObject private var logbook: IOSSnorkelingLogbookStore
    @EnvironmentObject private var photoStore: IOSSnorkelingSessionPhotoStore
    @EnvironmentObject private var equipmentStore: IOSSnorkelingEquipmentStore
    @EnvironmentObject private var locationPermission: IOSLocationPermissionService
    @AppStorage(IOSUnitPreference.storageKey) private var unitsRaw = IOSUnitPreference.metric.rawValue
    @State private var secondaryChart: IOSSnorkelingSecondaryChartKind = .distance

    private enum IOSSnorkelingSecondaryChartKind: String, CaseIterable {
        case distance
        case speed
        case temperature
        case dips
    }

    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(unitsRaw) }
    private var summary: IOSSnorkelingSessionSummaryPresentation {
        IOSSnorkelingLogbookPresentationMapper.sessionSummary(session, units: unitPreference)
    }
    private var charts: SnorkelingSessionChartsModel { logbook.charts(for: session) }
    private var mapModel: SnorkelingSessionMapModel {
        SnorkelingSessionMapPresentation.make(from: session, permission: locationPermission.permissionState)
    }
    private var dipMetrics: [SnorkelingDipMetrics] { logbook.dipMetrics(for: session) }

    var body: some View {
        DIRScreenContainer {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    heroMetrics
                    depthChartSection
                    IOSSnorkelingSessionMapView(model: mapModel, isDemoSession: isDemoSession)
                    secondaryChartsSection
                    dipsSection
                    photosSection
                    markersSection
                    gpsTrackSection
                    runtimeSummarySection
                    equipmentSection
                    buddySection
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
                        IOSSnorkelingSessionExportView(session: session)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel(DIRIOSLocalizer.string("snorkeling.ios.export.title"))
                }
            }
        }
        .onAppear {
            locationPermission.refresh()
        }
    }

    private var header: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.session.detail.title"), icon: "water.waves", accent: DIRTheme.cyan) {
            if isDemoSession {
                DemoLogbookBadge()
                Text(DIRIOSLocalizer.string("settings.demo_logbook.not_saved_real"))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
            }
            Text(summary.dateText)
                .font(.headline)
                .foregroundStyle(.white)
            if let location = summary.locationText {
                Text(location)
                    .font(.subheadline)
                    .foregroundStyle(DIRTheme.muted)
            }
            if let warnings = summary.warningsText {
                Text(warnings)
                    .font(.caption)
                    .foregroundStyle(DIRTheme.orange)
            }
        }
    }

    private var heroMetrics: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            metricTile(DIRIOSLocalizer.string("snorkeling.ios.dashboard.duration"), summary.durationText)
            metricTile(DIRIOSLocalizer.string("snorkeling.ios.dashboard.distance"), summary.distanceText)
            metricTile(DIRIOSLocalizer.string("snorkeling.ios.dashboard.max_depth"), summary.maxDepthText)
            metricTile(DIRIOSLocalizer.string("snorkeling.ios.session.dips"), summary.dipCountText)
        }
    }

    private var depthChartSection: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.charts.depth_m"), icon: "chart.xyaxis.line", accent: DIRTheme.cyan) {
            if charts.hasDepthData {
                Chart(charts.depthPoints.filter { !$0.isSurfaceGap }) { point in
                    LineMark(
                        x: .value("time", point.sessionOffsetSeconds),
                        y: .value("depth", Formatters.depthValue(point.depthMeters, units: unitPreference))
                    )
                    .foregroundStyle(by: .value("dip", point.dipIndex))
                    .interpolationMethod(.catmullRom)
                }
                .chartForegroundStyleScale(range: chartColors)
                .frame(minHeight: 200)
            } else {
                emptyChart(DIRIOSLocalizer.string("snorkeling.ios.charts.depth_empty"))
            }
        }
    }

    private var secondaryChartsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Picker("", selection: $secondaryChart) {
                Text(DIRIOSLocalizer.string("snorkeling.ios.charts.distance")).tag(IOSSnorkelingSecondaryChartKind.distance)
                Text(DIRIOSLocalizer.string("snorkeling.ios.charts.speed")).tag(IOSSnorkelingSecondaryChartKind.speed)
                Text(DIRIOSLocalizer.string("snorkeling.ios.charts.temperature")).tag(IOSSnorkelingSecondaryChartKind.temperature)
                Text(DIRIOSLocalizer.string("snorkeling.ios.charts.dips")).tag(IOSSnorkelingSecondaryChartKind.dips)
            }
            .pickerStyle(.segmented)

            switch secondaryChart {
            case .dips:
                dipDurationChart
            case .distance:
                distanceChart
            case .speed:
                speedChart
            case .temperature:
                temperatureChart
            }
        }
    }

    private var distanceChart: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.charts.distance_m"), icon: "figure.walk", accent: DIRTheme.green) {
            if charts.hasDistanceData {
                Chart(charts.distancePoints.filter { !$0.isInterpolated }) { point in
                    LineMark(
                        x: .value("time", point.sessionOffsetSeconds),
                        y: .value("distance", point.cumulativeDistanceMeters)
                    )
                    .foregroundStyle(DIRTheme.green)
                }
                .frame(minHeight: 160)
            } else {
                emptyChart(DIRIOSLocalizer.string("snorkeling.ios.charts.distance_empty"))
            }
        }
    }

    private var speedChart: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.charts.speed_m"), icon: "speedometer", accent: DIRTheme.cyan) {
            if charts.hasSpeedData {
                Chart(charts.speedPoints.filter(\.isMeasured)) { point in
                    LineMark(
                        x: .value("time", point.sessionOffsetSeconds),
                        y: .value("speed", point.speedMetersPerSecond)
                    )
                    .foregroundStyle(DIRTheme.cyan)
                }
                .frame(minHeight: 160)
            } else {
                emptyChart(DIRIOSLocalizer.string("snorkeling.ios.charts.speed_empty"))
            }
        }
    }

    private var temperatureChart: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.charts.temperature"), icon: "thermometer.medium", accent: DIRTheme.cyan) {
            if charts.hasTemperatureData {
                Chart(charts.temperaturePoints) { point in
                    LineMark(
                        x: .value("time", point.sessionOffsetSeconds),
                        y: .value("temp", Formatters.temperatureValue(point.temperatureCelsius, units: unitPreference))
                    )
                    .foregroundStyle(Color.purple)
                }
                .frame(minHeight: 160)
            } else {
                emptyChart(DIRIOSLocalizer.string("snorkeling.ios.charts.temperature_empty"))
            }
        }
    }

    private var dipDurationChart: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.charts.dips"), icon: "chart.bar.fill", accent: DIRTheme.green) {
            if charts.dipBars.isEmpty {
                emptyChart(DIRIOSLocalizer.string("snorkeling.ios.charts.dips_empty"))
            } else {
                Chart(charts.dipBars) { bar in
                    BarMark(
                        x: .value("dip", bar.dipIndex + 1),
                        y: .value("duration", bar.durationSeconds)
                    )
                    .foregroundStyle(DIRTheme.green)
                }
                .frame(minHeight: 160)
            }
        }
    }

    private var dipsSection: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.session.dips"), icon: "figure.water.fitness", accent: DIRTheme.cyan) {
            if dipMetrics.isEmpty {
                Text(DIRIOSLocalizer.string("snorkeling.ios.session.no_dips"))
                    .foregroundStyle(DIRTheme.muted)
            } else {
                ForEach(dipMetrics) { metrics in
                    NavigationLink {
                        IOSSnorkelingDipDetailView(metrics: metrics)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(format: DIRIOSLocalizer.string("snorkeling.ios.dip.title_format"), metrics.dipIndex + 1))
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

    private var photosSection: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.photos.title"), icon: "photo.on.rectangle", accent: DIRTheme.cyan) {
            let photos = photoStore.attachments(for: session.id)
            if photos.isEmpty {
                NavigationLink {
                    IOSSnorkelingSessionPhotosView(session: session)
                } label: {
                    Text(DIRIOSLocalizer.string("snorkeling.ios.photos.empty"))
                        .foregroundStyle(DIRTheme.muted)
                }
                .buttonStyle(.plain)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(photos.prefix(6)) { attachment in
                            Group {
                                if let image = photoStore.thumbnailImage(for: attachment) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "photo")
                                        .foregroundStyle(DIRTheme.muted)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(DIRTheme.surface)
                                }
                            }
                            .frame(width: 72, height: 72)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                    }
                }
                NavigationLink(DIRIOSLocalizer.string("snorkeling.ios.photos.manage")) {
                    IOSSnorkelingSessionPhotosView(session: session)
                }
                .font(.caption)
                .foregroundStyle(DIRTheme.cyan)
            }
        }
    }

    private var markersSection: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.session.markers"), icon: "mappin.and.ellipse", accent: DIRTheme.cyan) {
            if session.markers.isEmpty {
                Text(DIRIOSLocalizer.string("snorkeling.ios.session.no_markers"))
                    .foregroundStyle(DIRTheme.muted)
            } else {
                ForEach(session.markers) { marker in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(markerLabel(for: marker))
                                .foregroundStyle(.white)
                            if let note = marker.note, !note.isEmpty {
                                Text(note)
                                    .font(.caption)
                                    .foregroundStyle(DIRTheme.muted)
                            }
                        }
                        Spacer()
                        Text(markerTimeText(for: marker))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(DIRTheme.muted)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var gpsTrackSection: some View {
        let counts = ActivityGPSLogbookPresentation.snorkelTrackCounts(session.trackPoints)
        DIRCard(DIRIOSLocalizer.string("snorkeling.logbook.gps.title"), icon: "location.fill", accent: DIRTheme.cyan) {
            detailRow(
                DIRIOSLocalizer.string("gps.track_points"),
                "\(session.trackPoints.count)"
            )
            detailRow(
                DIRIOSLocalizer.string("gps.measured_points"),
                "\(counts.measured)"
            )
            detailRow(
                DIRIOSLocalizer.string("gps.stale_points"),
                "\(counts.stale)"
            )
            detailRow(
                DIRIOSLocalizer.string("gps.unavailable_points"),
                "\(counts.unavailable)"
            )
            if let entry = session.entryPoint {
                detailRow(
                    DIRIOSLocalizer.string("gps.entry"),
                    entry.latitude != nil ? DIRIOSLocalizer.string("gps.status.available") : DIRIOSLocalizer.string("gps.status.unavailable")
                )
            }
        }
    }

    @ViewBuilder
    private var runtimeSummarySection: some View {
        if let summary = session.runtimeSummary {
            DIRCard(DIRIOSLocalizer.string("snorkeling.logbook.runtime_summary"), icon: "waveform.path.ecg", accent: DIRTheme.cyan) {
                VStack(alignment: .leading, spacing: 8) {
                    if let band = summary.gpsQualityBand {
                        detailRow(
                            DIRIOSLocalizer.string("snorkeling.logbook.gps_quality"),
                            DIRIOSLocalizer.string(band.localizationKey)
                        )
                    }
                    detailRow(
                        DIRIOSLocalizer.string("snorkeling.logbook.track_points"),
                        "\(summary.trackPointCount)"
                    )
                    if let average = summary.averageAccuracyMeters {
                        detailRow(
                            DIRIOSLocalizer.string("snorkeling.logbook.average_accuracy"),
                            String(format: "±%.0f m", average)
                        )
                    }
                    detailRow(
                        DIRIOSLocalizer.string("snorkeling.logbook.gaps"),
                        "\(summary.gapsDetected)"
                    )
                    if let completion = summary.routeCompletedPercentage {
                        detailRow(
                            DIRIOSLocalizer.string("snorkeling.logbook.route_completion"),
                            String(format: "%.0f%%", completion)
                        )
                    }
                    if summary.returnAlertTriggered {
                        detailRow(
                            DIRIOSLocalizer.string("snorkeling.logbook.return_alert"),
                            "✓"
                        )
                    }
                    if summary.offRouteEventCount > 0 {
                        detailRow(
                            DIRIOSLocalizer.string("snorkeling.logbook.off_route_events"),
                            "\(summary.offRouteEventCount)"
                        )
                    }
                    if let maxOff = summary.maxOffRouteDistanceMeters {
                        detailRow(
                            DIRIOSLocalizer.string("snorkeling.logbook.max_off_route"),
                            String(format: "%.0f m", maxOff)
                        )
                    }
                    if summary.timeOffRouteSeconds > 0 {
                        detailRow(
                            DIRIOSLocalizer.string("snorkeling.logbook.time_off_route"),
                            Formatters.time(summary.timeOffRouteSeconds)
                        )
                    }
                }
            }
        }
    }

    private var equipmentSection: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.session.equipment"), icon: "backpack.fill", accent: DIRTheme.cyan) {
            let summary = equipmentStore.associationSummary(for: session)
            if !summary.isEmpty {
                Text(summary)
                    .font(.caption)
                    .foregroundStyle(DIRTheme.cyan)
            }
            if let equipment = session.equipment, equipmentHasContent(equipment) {
                if let mask = equipment.maskNotes, !mask.isEmpty {
                    detailRow(DIRIOSLocalizer.string("snorkeling.ios.session.equipment.mask"), mask)
                }
                if let fins = equipment.finsNotes, !fins.isEmpty {
                    detailRow(DIRIOSLocalizer.string("snorkeling.ios.session.equipment.fins"), fins)
                }
                if let suit = equipment.suitNotes, !suit.isEmpty {
                    detailRow(DIRIOSLocalizer.string("snorkeling.ios.session.equipment.suit"), suit)
                }
                if let weight = equipment.weightKilograms {
                    detailRow(
                        DIRIOSLocalizer.string("snorkeling.ios.session.equipment.weight"),
                        String(format: "%.1f kg", weight)
                    )
                }
                if let notes = equipment.notes, !notes.isEmpty {
                    detailRow(DIRIOSLocalizer.string("snorkeling.ios.session.equipment.notes"), notes)
                }
            } else {
                Text(DIRIOSLocalizer.string("snorkeling.ios.session.no_equipment"))
                    .foregroundStyle(DIRTheme.muted)
            }
        }
    }

    private var buddySection: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.session.buddy"), icon: "person.2.fill", accent: DIRTheme.cyan) {
            if let buddy = session.buddy, buddy.isBuddyPresent || buddy.name != nil || buddy.contactNotes != nil {
                if let name = buddy.name, !name.isEmpty {
                    detailRow(DIRIOSLocalizer.string("snorkeling.ios.session.buddy.name"), name)
                }
                if let contact = buddy.contactNotes, !contact.isEmpty {
                    detailRow(DIRIOSLocalizer.string("snorkeling.ios.session.buddy.contact"), contact)
                }
                detailRow(
                    DIRIOSLocalizer.string("snorkeling.ios.session.buddy.present"),
                    buddy.isBuddyPresent
                        ? DIRIOSLocalizer.string("snorkeling.ios.session.buddy.yes")
                        : DIRIOSLocalizer.string("snorkeling.ios.session.buddy.no")
                )
            } else {
                Text(DIRIOSLocalizer.string("snorkeling.ios.session.no_buddy"))
                    .foregroundStyle(DIRTheme.muted)
            }
        }
    }

    private func metricTile(_ title: String, _ value: String) -> some View {
        DIRMetricTile(title: title, value: value, color: .white)
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title).foregroundStyle(DIRTheme.muted)
            Spacer()
            Text(value).foregroundStyle(.white).multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }

    private func emptyChart(_ message: String) -> some View {
        Text(message)
            .font(.callout)
            .foregroundStyle(DIRTheme.muted)
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
    }

    private var chartColors: [Color] {
        [DIRTheme.cyan, DIRTheme.green, DIRTheme.yellow, DIRTheme.orange, Color.purple]
    }

    private func markerLabel(for marker: SnorkelingMarker) -> String {
        if marker.category == .custom, let label = marker.customCategoryLabel, !label.isEmpty {
            return label
        }
        switch marker.category {
        case .marineLife: return DIRIOSLocalizer.string("snorkeling.ios.marker.marine_life")
        case .reef: return DIRIOSLocalizer.string("snorkeling.ios.marker.reef")
        case .wreck: return DIRIOSLocalizer.string("snorkeling.ios.marker.wreck")
        case .photoSpot: return DIRIOSLocalizer.string("snorkeling.ios.marker.photo_spot")
        case .buoy: return DIRIOSLocalizer.string("snorkeling.ios.marker.buoy")
        case .custom: return DIRIOSLocalizer.string("snorkeling.ios.marker.custom")
        }
    }

    private func markerTimeText(for marker: SnorkelingMarker) -> String {
        if let date = marker.wallClockTimestamp {
            return date.formatted(date: .omitted, time: .shortened)
        }
        return Formatters.stopwatch(marker.monotonicRelativeTimestampSeconds)
    }

    private func equipmentHasContent(_ equipment: SnorkelingEquipmentProfile) -> Bool {
        equipment.maskNotes != nil
            || equipment.finsNotes != nil
            || equipment.suitNotes != nil
            || equipment.weightKilograms != nil
            || equipment.notes != nil
    }
}

struct IOSSnorkelingDipDetailView: View {
    let metrics: SnorkelingDipMetrics
    @AppStorage(IOSUnitPreference.storageKey) private var unitsRaw = IOSUnitPreference.metric.rawValue

    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(unitsRaw) }
    private var presentation: IOSSnorkelingDipDetailPresentation {
        IOSSnorkelingLogbookPresentationMapper.dipDetail(metrics, units: unitPreference)
    }

    var body: some View {
        DIRScreenContainer {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    DIRCard(presentation.title, icon: "timer", accent: DIRTheme.cyan) {
                        Text(presentation.timeWindowText)
                            .foregroundStyle(.white)
                    }
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        metricTile(DIRIOSLocalizer.string("snorkeling.ios.dashboard.max_depth"), presentation.maxDepthText)
                        metricTile(DIRIOSLocalizer.string("snorkeling.ios.dip.duration"), presentation.durationText)
                        metricTile(DIRIOSLocalizer.string("snorkeling.ios.dip.descent_speed"), presentation.descentSpeedText)
                        metricTile(DIRIOSLocalizer.string("snorkeling.ios.dip.ascent_speed"), presentation.ascentSpeedText)
                        metricTile(DIRIOSLocalizer.string("snorkeling.ios.dip.temperature"), presentation.temperatureText)
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
                    DIRCard(DIRIOSLocalizer.string("snorkeling.ios.dip.surface_position"), accent: DIRTheme.cyan) {
                        Text(presentation.surfacePositionText)
                            .foregroundStyle(.white)
                        Text(DIRIOSLocalizer.string(presentation.surfaceMethodKey))
                            .font(.caption)
                            .foregroundStyle(DIRTheme.muted)
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
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.charts.depth"), icon: "chart.xyaxis.line", accent: DIRTheme.cyan) {
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
}

struct IOSSnorkelingSessionMapView: View {
    let model: SnorkelingSessionMapModel
    var isDemoSession: Bool = false
    @EnvironmentObject private var settingsStore: IOSSnorkelingSettingsStore

    var body: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.map.session_title"), icon: "map.fill", accent: DIRTheme.cyan) {
            if model.isAvailable {
                ZStack(alignment: .topTrailing) {
                    Map(initialPosition: mapPosition) {
                    ForEach(model.segments) { segment in
                        MapPolyline(
                            coordinates: segment.coordinates.map {
                                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
                            }
                        )
                        .stroke(segment.hasGapBefore ? DIRTheme.orange : DIRTheme.cyan, lineWidth: 3)
                    }
                    if let first = model.segments.first?.coordinates.first {
                        Marker(
                            DIRIOSLocalizer.string("snorkeling.ios.map.start"),
                            coordinate: CLLocationCoordinate2D(latitude: first.latitude, longitude: first.longitude)
                        )
                    }
                }
                .mapStyle(IOSSnorkelingMapStyleMapper.mapStyle(for: settingsStore.mapType))
                .frame(minHeight: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    if isDemoSession {
                        DemoLogbookBadge()
                            .padding(8)
                    }
                }

                HStack {
                    if let start = model.sessionStartText {
                        VStack(alignment: .leading) {
                            Text(DIRIOSLocalizer.string("snorkeling.ios.map.session_start"))
                                .font(.caption)
                                .foregroundStyle(DIRTheme.muted)
                            Text(start).font(.title3.bold()).foregroundStyle(.white)
                        }
                    }
                    Spacer()
                    if let end = model.sessionEndText {
                        VStack(alignment: .trailing) {
                            Text(DIRIOSLocalizer.string("snorkeling.ios.map.session_end"))
                                .font(.caption)
                                .foregroundStyle(DIRTheme.muted)
                            Text(end).font(.title3.bold()).foregroundStyle(.white)
                        }
                    }
                }

                if model.gapCount > 0 {
                    Text(String(format: DIRIOSLocalizer.string("snorkeling.ios.map.gap_format"), model.gapCount))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.orange)
                }
                if model.showsSparseTrackWarning {
                    Text(DIRIOSLocalizer.string("snorkeling.ios.session.warning.sparse_track"))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.orange)
                }
                if let accuracy = model.accuracyMeters {
                    Text(String(format: DIRIOSLocalizer.string("snorkeling.ios.map.accuracy_format"), Int(accuracy.rounded())))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                }
                Text(DIRIOSLocalizer.string("snorkeling.ios.map.privacy_notice"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                fixQualityBadge
            } else {
                Text(DIRIOSLocalizer.string(model.unavailableReasonKey ?? "snorkeling.ios.map.unavailable"))
                    .font(.callout)
                    .foregroundStyle(DIRTheme.muted)
                    .frame(maxWidth: .infinity, minHeight: 160, alignment: .center)
            }
        }
        .accessibilityIdentifier("snorkeling.ios.map_summary")
    }

    private var fixQualityBadge: some View {
        let key = model.fixQualityKey ?? "snorkeling.ios.map.fix.fair"
        let color: Color = switch key {
        case "snorkeling.ios.map.fix.good": DIRTheme.green
        case "snorkeling.ios.map.fix.fair": DIRTheme.cyan
        case "snorkeling.ios.map.fix.poor": DIRTheme.orange
        default: DIRTheme.muted
        }
        return Text(DIRIOSLocalizer.string(key))
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
    }

    private var mapPosition: MapCameraPosition {
        guard let first = model.segments.first?.coordinates.first else { return .automatic }
        return .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: first.latitude, longitude: first.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }
}
