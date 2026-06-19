import SwiftUI
import MapKit

struct IOSSnorkelingDashboardView: View {
    @EnvironmentObject private var logbook: IOSSnorkelingLogbookStore
    @EnvironmentObject private var watchSync: WatchSyncService
    @EnvironmentObject private var snorkelingNavigation: IOSSnorkelingNavigationStore
    @EnvironmentObject private var transferService: IOSSnorkelingWatchTransferService
    @EnvironmentObject private var sessionSyncService: IOSSnorkelingSessionSyncService

    private var presentation: IOSSnorkelingDashboardPresentation {
        IOSSnorkelingDashboardPresentationMapper.make(
            lastSession: logbook.lastSession,
            sessions: logbook.sessions,
            statistics: logbook.statistics(),
            watchConnectivityText: watchConnectivityText,
            watchConnectivityIsPositive: watchConnectivityIsPositive,
            syncStatusText: syncStatusText,
            syncStatusIsPositive: syncStatusIsPositive
        )
    }

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        if presentation.hasLastSession, let session = logbook.lastSession {
                            lastSessionCard(session: session)
                        } else if let empty = presentation.emptyStateText {
                            Text(DIRIOSLocalizer.string(empty))
                                .font(.callout)
                                .foregroundStyle(DIRTheme.muted)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                        metricsGrid
                        if presentation.mapPreviewAvailable {
                            mapPreviewCard
                        }
                        syncStatusCard
                        watchStatusCard
                        newSessionButton
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                }
                .dirCompanionScrollSurface()
            }
        }
        .accessibilityIdentifier("snorkeling.ios.dashboard")
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(DIRIOSLocalizer.string("snorkeling.ios.dashboard.title"))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(DIRIOSLocalizer.string("snorkeling.ios.dashboard.subtitle"))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
            }
            Spacer()
            Button {
                snorkelingNavigation.showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundStyle(DIRTheme.cyan)
            }
            .accessibilityLabel(DIRIOSLocalizer.string("snorkeling.ios.settings.title"))
        }
    }

    private func lastSessionCard(session: SnorkelingSession) -> some View {
        NavigationLink {
            IOSSnorkelingSessionDetailView(session: session)
        } label: {
            DIRCard(DIRIOSLocalizer.string("snorkeling.ios.dashboard.last_session"), icon: "clock.fill", accent: DIRTheme.cyan) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(presentation.lastSessionDateText)
                        .font(.headline)
                        .foregroundStyle(.white)
                    HStack(spacing: 12) {
                        metricInline(DIRIOSLocalizer.string("snorkeling.ios.dashboard.duration"), presentation.lastSessionDurationText)
                        metricInline(DIRIOSLocalizer.string("snorkeling.ios.dashboard.max_depth"), presentation.lastSessionMaxDepthText)
                        metricInline(DIRIOSLocalizer.string("snorkeling.ios.dashboard.distance"), presentation.lastSessionDistanceText)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(DIRIOSLocalizer.string("snorkeling.ios.dashboard.last_session.a11y"))
        .accessibilityHint(DIRIOSLocalizer.string("snorkeling.ios.dashboard.last_session.hint"))
    }

    private func metricInline(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2).foregroundStyle(DIRTheme.muted)
            Text(value).font(.subheadline.weight(.semibold)).foregroundStyle(.white)
        }
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            metricTile(DIRIOSLocalizer.string("snorkeling.ios.dashboard.total_distance"), presentation.totalDistanceText)
            metricTile(DIRIOSLocalizer.string("snorkeling.ios.dashboard.max_depth"), presentation.maxDepthText)
            metricTile(DIRIOSLocalizer.string("snorkeling.ios.dashboard.sessions"), presentation.sessionCountText)
            metricTile(DIRIOSLocalizer.string("snorkeling.ios.dashboard.water_time"), presentation.totalWaterTimeText)
            metricTile(DIRIOSLocalizer.string("snorkeling.ios.dashboard.sessions_month"), presentation.sessionsThisMonthText)
            metricTile(DIRIOSLocalizer.string("snorkeling.ios.dashboard.avg_max_depth"), presentation.averageMaxDepthText)
        }
    }

    private func metricTile(_ title: String, _ value: String) -> some View {
        DIRMetricTile(title: title, value: value, color: .white)
    }

    private var mapPreviewCard: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.dashboard.map_preview"), icon: "map.fill", accent: DIRTheme.cyan) {
            if let model = presentation.mapPreviewModel, model.isAvailable {
                Map(initialPosition: .region(previewRegion(for: model))) {
                    ForEach(model.segments) { segment in
                        MapPolyline(
                            coordinates: segment.coordinates.map {
                                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
                            }
                        )
                        .stroke(segment.hasGapBefore ? DIRTheme.orange : DIRTheme.cyan, lineWidth: 2)
                    }
                }
                .frame(minHeight: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                if model.gapCount > 0 {
                    Text(String(format: DIRIOSLocalizer.string("snorkeling.ios.map.gap_format"), model.gapCount))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.orange)
                }
                Text(mapPreviewAccessibilityLabel(for: model))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(mapPreviewAccessibilityLabel(for: presentation.mapPreviewModel))
    }

    private func mapPreviewAccessibilityLabel(for model: SnorkelingSessionMapModel?) -> String {
        guard let model, model.isAvailable else {
            return DIRIOSLocalizer.string("snorkeling.ios.map.unavailable")
        }
        if model.gapCount > 0 {
            return String(
                format: DIRIOSLocalizer.string("snorkeling.ios.dashboard.map_preview.a11y_gaps_format"),
                model.segments.count,
                model.gapCount
            )
        }
        return String(
            format: DIRIOSLocalizer.string("snorkeling.ios.dashboard.map_preview.a11y_segments_format"),
            model.segments.count
        )
    }

    private func previewRegion(for model: SnorkelingSessionMapModel) -> MKCoordinateRegion {
        let coords = model.segments.flatMap(\.coordinates)
        guard let first = coords.first else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        }
        let lats = coords.map(\.latitude)
        let lons = coords.map(\.longitude)
        let center = CLLocationCoordinate2D(
            latitude: (lats.min()! + lats.max()!) / 2,
            longitude: (lons.min()! + lons.max()!) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.005, (lats.max()! - lats.min()!) * 1.4),
            longitudeDelta: max(0.005, (lons.max()! - lons.min()!) * 1.4)
        )
        return MKCoordinateRegion(center: center, span: span)
    }

    private var syncStatusCard: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.dashboard.sync_status"), icon: "arrow.triangle.2.circlepath", accent: presentation.syncStatusIsPositive ? DIRTheme.green : DIRTheme.orange) {
            VStack(alignment: .leading, spacing: 8) {
                Text(presentation.syncStatusText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(presentation.syncStatusIsPositive ? DIRTheme.green : DIRTheme.orange)
                Text(sessionSyncStatusText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(sessionSyncIsPositive ? DIRTheme.green : DIRTheme.orange)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var watchStatusCard: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.dashboard.watch_status"), icon: "applewatch", accent: presentation.watchConnectivityIsPositive ? DIRTheme.green : DIRTheme.orange) {
            Text(presentation.watchConnectivityText)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(presentation.watchConnectivityIsPositive ? DIRTheme.green : DIRTheme.orange)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var newSessionButton: some View {
        Button {
            snorkelingNavigation.selectedTab = .routePlanner
        } label: {
            Text(DIRIOSLocalizer.string("snorkeling.ios.dashboard.new_session"))
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                        .fill(LinearGradient(colors: [DIRTheme.cyan, DIRTheme.cyan.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                )
        }
        .buttonStyle(.plain)
        .accessibilityHint(DIRIOSLocalizer.string("snorkeling.ios.dashboard.new_session.hint"))
    }

    private var watchConnectivityText: String {
        if !watchSync.isSupported { return DIRIOSLocalizer.string("snorkeling.ios.watch.unsupported") }
        if watchSync.activationState != .activated { return DIRIOSLocalizer.string("snorkeling.ios.watch.not_active") }
        return watchSync.userVisibleState
    }

    private var watchConnectivityIsPositive: Bool {
        watchSync.isSupported && watchSync.activationState == .activated
    }

    private var syncStatusText: String {
        let routePrefix = DIRIOSLocalizer.string("snorkeling.ios.sync.route_label")
        switch transferService.state {
        case .acknowledged(_, _, let syncedAt):
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return "\(routePrefix) \(String(format: DIRIOSLocalizer.string("snorkeling.ios.sync.up_to_date_format"), formatter.string(from: syncedAt)))"
        case .awaitingAck, .sending, .queued:
            return "\(routePrefix) \(DIRIOSLocalizer.string("snorkeling.ios.sync.pending"))"
        case .failed:
            return "\(routePrefix) \(DIRIOSLocalizer.string(transferService.lastErrorMessage ?? "snorkeling.ios.sync.failed"))"
        case .draft, .validated:
            if let syncedAt = transferService.lastSuccessfulSyncAt {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                return "\(routePrefix) \(String(format: DIRIOSLocalizer.string("snorkeling.ios.sync.up_to_date_format"), formatter.string(from: syncedAt)))"
            }
            return "\(routePrefix) \(DIRIOSLocalizer.string("snorkeling.ios.sync.none"))"
        }
    }

    private var sessionSyncStatusText: String {
        let sessionPrefix = DIRIOSLocalizer.string("snorkeling.ios.sync.session_label")
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return "\(sessionPrefix) \(sessionSyncService.statusText(dateFormatter: formatter))"
    }

    private var sessionSyncIsPositive: Bool {
        sessionSyncService.isPositive
    }

    private var syncStatusIsPositive: Bool {
        let routePositive: Bool
        switch transferService.state {
        case .acknowledged:
            routePositive = true
        case .failed, .awaitingAck, .sending, .queued:
            routePositive = false
        case .draft, .validated:
            routePositive = transferService.lastSuccessfulSyncAt != nil
        }
        return routePositive && sessionSyncIsPositive
    }
}
