import SwiftUI
import MapKit
import WatchConnectivity

struct IOSSnorkelingRoutePlannerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var plannerStore: IOSSnorkelingRoutePlannerStore
    @EnvironmentObject private var profileStore: IOSSnorkelingProfileStore
    @EnvironmentObject private var transferService: IOSSnorkelingWatchTransferService
    @EnvironmentObject private var watchSync: WatchSyncService
    @EnvironmentObject private var locationPermission: IOSLocationPermissionService

    @State private var mapSelectionMode: MapSelectionMode = .entry
    @State private var mapPosition: MapCameraPosition = .automatic
    @State private var transferMessage: String?

    private enum MapSelectionMode: String, CaseIterable, Identifiable {
        case entry, waypoint, exit
        var id: String { rawValue }
    }

    var body: some View {
        DIRScreenContainer {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(DIRIOSLocalizer.string("snorkeling.ios.planner.title"))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    mapSection
                    planFields
                    waypointList
                    estimatesCard
                    validationSection
                    transferSection
                    actionButtons
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
            }
            .dirCompanionScrollSurface()
        }
        .accessibilityIdentifier("snorkeling.ios.route_planner")
        .onAppear {
            locationPermission.refresh()
            updateMapPosition()
        }
    }

    private var mapSection: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.planner.map_title"), icon: "map.fill", accent: DIRTheme.cyan) {
            VStack(alignment: .leading, spacing: 10) {
                permissionBanner
                Picker(DIRIOSLocalizer.string("snorkeling.ios.planner.map_mode"), selection: $mapSelectionMode) {
                    Text(DIRIOSLocalizer.string("snorkeling.ios.planner.entry")).tag(MapSelectionMode.entry)
                    Text(DIRIOSLocalizer.string("snorkeling.ios.planner.waypoint")).tag(MapSelectionMode.waypoint)
                    Text(DIRIOSLocalizer.string("snorkeling.ios.planner.exit")).tag(MapSelectionMode.exit)
                }
                .pickerStyle(.segmented)

                if locationPermission.permissionState == .authorized {
                    MapReader { proxy in
                        Map(position: $mapPosition, interactionModes: [.pan, .zoom]) {
                            routeAnnotations
                            if !routeCoordinates.isEmpty {
                                MapPolyline(coordinates: routeCoordinates)
                                    .stroke(DIRTheme.cyan, lineWidth: 3)
                            }
                        }
                        .frame(minHeight: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .onTapGesture { location in
                            guard let coordinate = proxy.convert(location, from: .local) else { return }
                            applyCoordinate(coordinate)
                        }
                    }
                } else {
                    mapPermissionPlaceholder
                }
            }
        }
    }

    @MapContentBuilder
    private var routeAnnotations: some MapContent {
        if let entry = plannerStore.draft.entryPoint {
            Marker(DIRIOSLocalizer.string("snorkeling.ios.planner.entry"), coordinate: coordinate(for: entry))
                .tint(.green)
        }
        ForEach(Array(plannerStore.draft.waypoints.enumerated()), id: \.element.id) { index, point in
            Marker("\(index + 1)", coordinate: coordinate(for: point))
                .tint(DIRTheme.cyan)
        }
        if let exit = plannerStore.draft.exitPoint {
            Marker(DIRIOSLocalizer.string("snorkeling.ios.planner.exit"), coordinate: coordinate(for: exit))
                .tint(.orange)
        }
    }

    private var planFields: some View {
        DIRCard(accent: DIRTheme.cyan) {
            VStack(alignment: .leading, spacing: 12) {
                TextField(DIRIOSLocalizer.string("snorkeling.ios.planner.name"), text: $plannerStore.draft.name)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: plannerStore.draft.name) { _, _ in plannerStore.persistDraft() }

                Picker(DIRIOSLocalizer.string("snorkeling.ios.planner.profile"), selection: Binding(
                    get: { plannerStore.draft.profileID },
                    set: { plannerStore.setProfileID($0) }
                )) {
                    Text(DIRIOSLocalizer.string("snorkeling.ios.planner.profile_none")).tag(UUID?.none)
                    ForEach(profileStore.allProfiles()) { profile in
                        Text(profile.isPreset ? DIRIOSLocalizer.string(profile.displayName) : profile.displayName)
                            .tag(Optional(profile.id))
                    }
                }
            }
        }
    }

    private var waypointList: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.planner.waypoints"), icon: "point.3.connected.trianglepath.dotted", accent: DIRTheme.cyan) {
            VStack(alignment: .leading, spacing: 8) {
                pointRow(
                    title: DIRIOSLocalizer.string("snorkeling.ios.planner.entry"),
                    point: plannerStore.draft.entryPoint,
                    color: DIRTheme.green
                )
                ForEach(plannerStore.draft.waypoints.sorted { $0.routeOrder < $1.routeOrder }) { point in
                    HStack {
                        pointRow(
                            title: String(format: DIRIOSLocalizer.string("snorkeling.ios.planner.waypoint_number_format"), point.routeOrder + 1),
                            point: point,
                            color: DIRTheme.cyan
                        )
                        Button(role: .destructive) {
                            plannerStore.removeWaypoint(id: point.id)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
                pointRow(
                    title: DIRIOSLocalizer.string("snorkeling.ios.planner.exit"),
                    point: plannerStore.draft.exitPoint,
                    color: DIRTheme.orange
                )
            }
        }
    }

    private func pointRow(title: String, point: SnorkelingRoutePlannerPoint?, color: Color) -> some View {
        HStack(spacing: 8) {
            Circle().fill(color).frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                if let point {
                    Text(String(format: "%.5f, %.5f", point.latitude, point.longitude))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(DIRTheme.muted)
                } else {
                    Text(DIRIOSLocalizer.string("snorkeling.ios.planner.not_set"))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                }
            }
            Spacer()
        }
    }

    private var estimatesCard: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.planner.estimates"), icon: "ruler", accent: DIRTheme.cyan) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(DIRIOSLocalizer.string("snorkeling.ios.planner.distance"))
                    Spacer()
                    Text(IOSSnorkelingRoutePresentation.distanceText(meters: plannerStore.estimatedDistanceMeters))
                        .font(.headline.monospacedDigit())
                }
                HStack {
                    Text(DIRIOSLocalizer.string("snorkeling.ios.planner.duration"))
                    Spacer()
                    Text(IOSSnorkelingRoutePresentation.durationText(seconds: plannerStore.estimatedDurationSeconds))
                        .font(.headline.monospacedDigit())
                }
                if let limit = plannerStore.draft.maxDistanceLimitMeters, limit > 0 {
                    HStack {
                        Text(DIRIOSLocalizer.string("snorkeling.ios.planner.distance_limit"))
                        Spacer()
                        Text(IOSSnorkelingRoutePresentation.distanceText(meters: limit))
                            .foregroundStyle(plannerStore.estimatedDistanceMeters > limit ? DIRTheme.orange : DIRTheme.muted)
                    }
                    if plannerStore.estimatedDistanceMeters > limit {
                        Text(DIRIOSLocalizer.string("snorkeling.ios.planner.distance_limit_warning"))
                            .font(.caption)
                            .foregroundStyle(DIRTheme.orange)
                    }
                }
            }
            .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    private var validationSection: some View {
        if !plannerStore.validationIssues.isEmpty {
            DIRCard(DIRIOSLocalizer.string("snorkeling.ios.planner.validation"), icon: "exclamationmark.triangle.fill", accent: DIRTheme.orange) {
                ForEach(plannerStore.validationIssues, id: \.self) { issue in
                    Text(DIRIOSLocalizer.string(IOSSnorkelingRoutePresentation.validationText(for: issue)))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.orange)
                }
            }
        }
    }

    private var transferSection: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.planner.watch_transfer"), icon: "applewatch", accent: DIRTheme.cyan) {
            HStack(spacing: 10) {
                Image(systemName: transferStatusIcon)
                    .foregroundStyle(transferStatusColor)
                Text(transferMessage ?? transferStatusText(transferService.state))
                    .foregroundStyle(DIRTheme.muted)
                    .font(.caption)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button(action: sendToWatch) {
                Text(DIRIOSLocalizer.string("snorkeling.ios.planner.send_watch"))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).fill(DIRTheme.cyan))
            }
            .buttonStyle(.plain)
            .disabled(!plannerStore.validationIssues.isEmpty)

            Button(action: savePlan) {
                Text(DIRIOSLocalizer.string("snorkeling.ios.planner.save_plan"))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(DIRTheme.cyan, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(!plannerStore.validationIssues.isEmpty)
        }
    }

    private var permissionBanner: some View {
        Group {
            switch locationPermission.permissionState {
            case .authorized:
                EmptyView()
            case .denied, .restricted:
                VStack(alignment: .leading, spacing: 8) {
                    Text(DIRIOSLocalizer.string("ios.location.permission.denied.body"))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.orange)
                    Button(DIRIOSLocalizer.string("ios.location.permission.open_settings")) {
                        IOSLocationSettingsOpener.openAppSettings()
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
                }
            case .notDetermined:
                VStack(alignment: .leading, spacing: 8) {
                    Text(DIRIOSLocalizer.string("ios.location.permission.required.body"))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                    Button(DIRIOSLocalizer.string("ios.location.permission.enable")) {
                        locationPermission.requestWhenInUseFromUserAction()
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
                }
            }
        }
    }

    private var mapPermissionPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(DIRTheme.surface)
            .frame(minHeight: 220)
            .overlay {
                Text(DIRIOSLocalizer.string("snorkeling.ios.map.unavailable"))
                    .font(.callout)
                    .foregroundStyle(DIRTheme.muted)
                    .multilineTextAlignment(.center)
                    .padding()
            }
    }

    private var routeCoordinates: [CLLocationCoordinate2D] {
        plannerStore.draft.orderedPoints.map { coordinate(for: $0) }
    }

    private func coordinate(for point: SnorkelingRoutePlannerPoint) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
    }

    private func applyCoordinate(_ coordinate: CLLocationCoordinate2D) {
        switch mapSelectionMode {
        case .entry:
            plannerStore.setEntry(latitude: coordinate.latitude, longitude: coordinate.longitude)
        case .waypoint:
            plannerStore.addWaypoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
        case .exit:
            plannerStore.setExit(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        updateMapPosition()
    }

    private func updateMapPosition() {
        let coords = routeCoordinates
        guard let first = coords.first else { return }
        if coords.count == 1 {
            mapPosition = .region(MKCoordinateRegion(center: first, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
            return
        }
        let lats = coords.map(\.latitude)
        let lons = coords.map(\.longitude)
        let center = CLLocationCoordinate2D(latitude: (lats.min()! + lats.max()!) / 2, longitude: (lons.min()! + lons.max()!) / 2)
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.01, (lats.max()! - lats.min()!) * 1.5),
            longitudeDelta: max(0.01, (lons.max()! - lons.min()!) * 1.5)
        )
        mapPosition = .region(MKCoordinateRegion(center: center, span: span))
    }

    private func sendToWatch() {
        let session = WCSession.default
        let profile = plannerStore.draft.profileID.flatMap { profileStore.profile(id: $0) }
        let sent = transferService.send(
            draft: plannerStore.draft,
            profile: profile,
            connectivity: SnorkelingWatchTransferConnectivityContext(
                isSupported: watchSync.isSupported,
                activationState: watchSync.activationState,
                isPaired: session.isPaired,
                isWatchAppInstalled: session.isWatchAppInstalled,
                isReachable: session.isReachable
            )
        )
        transferMessage = sent
            ? DIRIOSLocalizer.string("snorkeling.ios.planner.transfer_sent")
            : DIRIOSLocalizer.string(transferService.lastErrorMessage ?? "snorkeling.ios.planner.transfer_failed")
    }

    private func savePlan() {
        if plannerStore.saveCurrentPlan() {
            transferMessage = DIRIOSLocalizer.string("snorkeling.ios.planner.saved")
        }
    }

    private var transferStatusIcon: String {
        switch transferService.state {
        case .acknowledged: return "checkmark.circle.fill"
        case .failed: return "xmark.octagon.fill"
        case .awaitingAck, .sending, .queued: return "arrow.triangle.2.circlepath"
        default: return "circle"
        }
    }

    private var transferStatusColor: Color {
        switch transferService.state {
        case .acknowledged: return DIRTheme.green
        case .failed: return DIRTheme.red
        case .awaitingAck, .sending, .queued: return DIRTheme.orange
        default: return DIRTheme.muted
        }
    }

    private func transferStatusText(_ state: IOSSnorkelingWatchSyncState) -> String {
        switch state {
        case .draft: return DIRIOSLocalizer.string("snorkeling.ios.planner.transfer_idle")
        case .validated: return DIRIOSLocalizer.string("snorkeling.ios.planner.transfer_ready")
        case .sending: return DIRIOSLocalizer.string("snorkeling.ios.planner.transfer_sending")
        case .queued: return DIRIOSLocalizer.string("snorkeling.ios.planner.transfer_queued")
        case .awaitingAck: return DIRIOSLocalizer.string("snorkeling.ios.planner.transfer_awaiting_ack")
        case .acknowledged: return DIRIOSLocalizer.string("snorkeling.ios.planner.transfer_acknowledged")
        case .failed(let key): return DIRIOSLocalizer.string(key)
        }
    }
}
