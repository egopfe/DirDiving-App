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
    @EnvironmentObject private var settingsStore: IOSSnorkelingSettingsStore

    @State private var mapSelectionMode: MapSelectionMode = .entry
    @State private var mapPosition: MapCameraPosition = .automatic
    @State private var transferMessage: String?
    @State private var mapNotice: String?
    @State private var pendingCenterOnLocation = false
    @State private var isResetMapConfirmationPresented = false
    @State private var isShareSheetPresented = false
    @State private var shareText = ""

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
                    waypointList
                    profilesSection
                    routeTypeSection
                    routeProfileKindSection
                    returnAlertSection
                    checklistSection
                    returnToEntrySection
                    estimatesCard
                    routeSafetySection
                    transferSection
                    exportSection
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
        .onChange(of: locationPermission.lastKnownCoordinate?.latitude) { _, _ in
            guard pendingCenterOnLocation, let coordinate = locationPermission.lastKnownCoordinate else { return }
            applyMapCenter(coordinate)
            pendingCenterOnLocation = false
            mapNotice = nil
        }
        .sheet(isPresented: $isShareSheetPresented) {
            ShareSheetView(activityItems: [shareText])
        }
    }

    private var selectedProfile: SnorkelingCompanionProfile? {
        plannerStore.draft.profileID.flatMap { profileStore.profile(id: $0) }
    }

    private var validation: SnorkelingRouteValidationResult {
        plannerStore.validationResult(profile: selectedProfile)
    }

    private var canSendToWatch: Bool {
        validation.allowsWatchTransfer
    }

    private var mapSection: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.planner.map_title"), icon: "map.fill", accent: DIRTheme.cyan) {
            VStack(alignment: .leading, spacing: 10) {
                permissionBanner
                if let mapNotice {
                    Text(mapNotice)
                        .font(.caption)
                        .foregroundStyle(DIRTheme.orange)
                }
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
                        .mapStyle(IOSSnorkelingMapStyleMapper.mapStyle(for: settingsStore.mapType))
                        .frame(minHeight: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(alignment: .topTrailing) {
                            centerCurrentLocationButton
                        }
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

    private var centerCurrentLocationButton: some View {
        Button(action: centerMapOnCurrentLocation) {
            Image(systemName: "location.north.fill")
                .font(.headline)
                .foregroundStyle(DIRTheme.cyan)
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .padding(12)
        .accessibilityLabel(DIRIOSLocalizer.string("snorkeling.map.center_current_location"))
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

    private var profilesSection: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.planner.profile"), icon: "person.fill", accent: DIRTheme.cyan) {
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
                HStack {
                    Spacer()
                    Button(role: .destructive) {
                        isResetMapConfirmationPresented = true
                    } label: {
                        Label(
                            DIRIOSLocalizer.string("snorkeling.route_points.reset_map"),
                            systemImage: "arrow.counterclockwise"
                        )
                        .font(.subheadline.weight(.semibold))
                    }
                    .disabled(!plannerStore.draft.hasRoutePoints)
                    .accessibilityLabel(DIRIOSLocalizer.string("snorkeling.route_points.reset_map"))
                    .accessibilityHint(
                        plannerStore.draft.hasRoutePoints
                            ? DIRIOSLocalizer.string("snorkeling.route_points.reset_map.confirm_message")
                            : DIRIOSLocalizer.string("snorkeling.route_points.reset_map.disabled_hint")
                    )
                }

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
        .alert(
            DIRIOSLocalizer.string("snorkeling.route_points.reset_map.confirm_title"),
            isPresented: $isResetMapConfirmationPresented
        ) {
            Button(DIRIOSLocalizer.string("common.cancel"), role: .cancel) {}
            Button(DIRIOSLocalizer.string("snorkeling.route_points.reset_map.confirm_action"), role: .destructive) {
                resetCurrentRoutePoints()
            }
        } message: {
            Text(DIRIOSLocalizer.string("snorkeling.route_points.reset_map.confirm_message"))
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
                    Text(IOSSnorkelingRoutePresentation.durationText(seconds: plannerStore.estimatedDurationSeconds(profile: selectedProfile)))
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

    private var routeSafetySection: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.route_safety.title"), icon: "checkmark.shield.fill", accent: safetyAccent) {
            VStack(alignment: .leading, spacing: 8) {
                Text(DIRIOSLocalizer.string(validation.localizationKey))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(safetyAccent)
                ForEach(validation.issues, id: \.self) { issue in
                    Text(DIRIOSLocalizer.string(IOSSnorkelingRoutePresentation.validationText(for: issue)))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.orange)
                }
                ForEach(validation.warnings, id: \.self) { warning in
                    Text(DIRIOSLocalizer.string(IOSSnorkelingRoutePresentation.warningText(for: warning)))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.orange)
                }
            }
        }
    }

    private var safetyAccent: Color {
        switch validation.status {
        case .ready: return DIRTheme.green
        case .warning: return DIRTheme.orange
        case .incomplete, .blocked: return DIRTheme.red
        }
    }

    private var returnToEntrySection: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.route.return_to_entry"), icon: "location.north.line.fill", accent: DIRTheme.cyan) {
            let preview = plannerStore.returnToEntryPreview(
                currentLatitude: locationPermission.currentCoordinate?.latitude,
                currentLongitude: locationPermission.currentCoordinate?.longitude
            )
            VStack(alignment: .leading, spacing: 8) {
                Text(DIRIOSLocalizer.string("snorkeling.route.gps_orientation_aid"))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
                if preview.isAvailable, let distance = preview.distanceMeters {
                    HStack {
                        Text(DIRIOSLocalizer.string("snorkeling.route.return_to_entry"))
                        Spacer()
                        Text(IOSSnorkelingRoutePresentation.distanceText(meters: distance))
                            .font(.headline.monospacedDigit())
                    }
                    if let bearing = preview.bearingDegrees {
                        HStack {
                            Text(DIRIOSLocalizer.string("snorkeling.route.bearing"))
                            Spacer()
                            Text(String(format: "%.0f°", bearing))
                                .font(.headline.monospacedDigit())
                        }
                    }
                } else {
                    Text(DIRIOSLocalizer.string("snorkeling.route.return_unavailable"))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                }
            }
            .foregroundStyle(.white)
        }
    }

    private var routeTypeSection: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.route.type.title"), icon: "arrow.triangle.turn.up.right.diamond.fill", accent: DIRTheme.cyan) {
            Picker(DIRIOSLocalizer.string("snorkeling.route.type.title"), selection: Binding(
                get: { plannerStore.draft.resolvedRouteType },
                set: { plannerStore.setRouteType($0) }
            )) {
                Text(DIRIOSLocalizer.string("snorkeling.route.type.round_trip")).tag(SnorkelingRouteType.roundTrip)
                Text(DIRIOSLocalizer.string("snorkeling.route.type.different_exit")).tag(SnorkelingRouteType.differentExit)
            }
            .pickerStyle(.segmented)
        }
    }

    private var routeProfileKindSection: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.route.profile_kind.title"), icon: "figure.open.water.swim", accent: DIRTheme.cyan) {
            Picker(DIRIOSLocalizer.string("snorkeling.route.profile_kind.title"), selection: Binding(
                get: { plannerStore.draft.routeProfileKind },
                set: { plannerStore.setRouteProfileKind($0) }
            )) {
                Text(DIRIOSLocalizer.string("snorkeling.ios.planner.profile_none")).tag(SnorkelingRouteProfileKind?.none)
                ForEach(SnorkelingRouteProfileKind.allCases) { kind in
                    Text(DIRIOSLocalizer.string(kind.localizationKey)).tag(Optional(kind))
                }
            }
        }
    }

    private var returnAlertSection: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.alert.return.title"), icon: "bell.badge.fill", accent: DIRTheme.cyan) {
            Picker(DIRIOSLocalizer.string("snorkeling.alert.return.title"), selection: Binding(
                get: { plannerStore.draft.resolvedReturnAlertPolicy },
                set: { plannerStore.setReturnAlertPolicy($0) }
            )) {
                Text(DIRIOSLocalizer.string("snorkeling.alert.return.off")).tag(SnorkelingReturnAlertPolicy.off)
                Text(DIRIOSLocalizer.string("snorkeling.alert.return.time_50")).tag(SnorkelingReturnAlertPolicy.halfPlannedTime)
                Text(DIRIOSLocalizer.string("snorkeling.alert.return.distance_50")).tag(SnorkelingReturnAlertPolicy.halfPlannedDistance)
            }
            .pickerStyle(.segmented)
        }
    }

    private var checklistSection: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.checklist.title"), icon: "checklist", accent: DIRTheme.cyan) {
            VStack(alignment: .leading, spacing: 8) {
                checklistToggle("snorkeling.checklist.weather", keyPath: \.weatherChecked)
                checklistToggle("snorkeling.checklist.current", keyPath: \.currentAssessed)
                checklistToggle("snorkeling.checklist.exit", keyPath: \.exitConfirmed)
                checklistToggle("snorkeling.checklist.buddy", keyPath: \.buddyPresent)
                checklistToggle("snorkeling.checklist.buoy", keyPath: \.surfaceMarkerBuoy)
                checklistToggle("snorkeling.checklist.watch_battery", keyPath: \.watchCharged)
            }
        }
    }

    private func checklistToggle(
        _ key: String,
        keyPath: WritableKeyPath<SnorkelingPreSnorkelingChecklist, Bool>
    ) -> some View {
        Toggle(DIRIOSLocalizer.string(key), isOn: Binding(
            get: { plannerStore.draft.resolvedChecklist[keyPath: keyPath] },
            set: { plannerStore.setChecklistValue(keyPath, value: $0) }
        ))
        .toggleStyle(.switch)
        .tint(DIRTheme.cyan)
    }

    private var exportSection: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.export.share_plan"), icon: "square.and.arrow.up", accent: DIRTheme.cyan) {
            Button(action: sharePlan) {
                Label(DIRIOSLocalizer.string("snorkeling.export.share_plan"), systemImage: "square.and.arrow.up")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
            }
            .buttonStyle(.plain)
            .disabled(!canSendToWatch)
        }
    }

    private var transferSection: some View {
        let presentation = SnorkelingRouteSyncStatusPresentationPolicy.make(
            state: transferService.state,
            routeName: {
                let name = plannerStore.draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
                return name.isEmpty ? nil : name
            }(),
            lastSuccessfulSyncAt: transferService.lastSuccessfulSyncAt,
            lastErrorMessage: transferService.lastErrorMessage
        )
        return DIRCard(DIRIOSLocalizer.string("snorkeling.route_sync.status.title"), icon: "applewatch", accent: DIRTheme.cyan) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Image(systemName: transferStatusIcon)
                        .foregroundStyle(transferStatusColor)
                    Text(transferMessage ?? DIRIOSLocalizer.string(presentation.statusSummaryKey))
                        .foregroundStyle(DIRTheme.muted)
                        .font(.caption)
                }
                if let routeName = presentation.routeName {
                    detailLine(DIRIOSLocalizer.string("snorkeling.watch.ready.route_name"), routeName)
                }
                if let revision = presentation.revision {
                    detailLine(DIRIOSLocalizer.string("snorkeling.route_sync.revision"), "r\(revision)")
                }
                if let sentAt = presentation.lastSentAt {
                    let formatter = DateFormatter()
                    let _ = formatter.dateStyle = .short
                    let _ = formatter.timeStyle = .short
                    detailLine(
                        DIRIOSLocalizer.string("snorkeling.route_sync.sent"),
                        formatter.string(from: sentAt)
                    )
                }
                detailLine(
                    DIRIOSLocalizer.string("snorkeling.route_sync.received"),
                    ackStatusText(presentation.ackStatus)
                )
                if presentation.pendingActivation {
                    Text(DIRIOSLocalizer.string("snorkeling.route_sync.pending"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DIRTheme.orange)
                }
            }
        }
    }

    private func detailLine(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(DIRTheme.muted)
            Spacer()
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
        }
    }

    private func ackStatusText(_ status: SnorkelingRouteSyncAckPresentationStatus) -> String {
        switch status {
        case .notAvailable:
            return DIRIOSLocalizer.string("snorkeling.ios.sync.none")
        case .pending:
            return DIRIOSLocalizer.string("snorkeling.route_sync.pending")
        case .delivered:
            return DIRIOSLocalizer.string("snorkeling.route_sync.received")
        case .imported:
            return DIRIOSLocalizer.string("snorkeling.route_sync.activated")
        case .rejected(let key):
            return DIRIOSLocalizer.string(key)
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
            .disabled(!canSendToWatch)

            Button(action: savePlan) {
                Text(DIRIOSLocalizer.string("snorkeling.ios.planner.save_plan"))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(DIRTheme.cyan, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(!canSendToWatch)
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

    private func centerMapOnCurrentLocation() {
        let coordinate = locationPermission.currentCoordinate
        let outcome = SnorkelingRoutePlannerMapCenterPolicy.resolve(
            permissionState: locationPermission.permissionState,
            currentLatitude: coordinate?.latitude,
            currentLongitude: coordinate?.longitude
        )
        switch outcome {
        case .center(let region):
            applyMapCenter(CLLocationCoordinate2D(latitude: region.latitude, longitude: region.longitude), spanDelta: region.latitudeDelta)
            mapNotice = nil
            pendingCenterOnLocation = false
        case .requestPermission:
            locationPermission.requestWhenInUseFromUserAction()
        case .notice(let key):
            mapNotice = DIRIOSLocalizer.string(key)
            if locationPermission.permissionState == .authorized {
                pendingCenterOnLocation = true
                locationPermission.requestCurrentLocationForMapCenter()
            }
        }
    }

    private func applyMapCenter(_ coordinate: CLLocationCoordinate2D, spanDelta: Double = SnorkelingMapCenterRegion.plannerDefaultSpan) {
        withAnimation(.easeInOut(duration: 0.25)) {
            mapPosition = .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
                )
            )
        }
    }

    private func resetCurrentRoutePoints() {
        plannerStore.resetMapPoints()
        mapSelectionMode = .entry
        updateMapPosition()
    }

    private func sendToWatch() {
        let session = WCSession.default
        let profile = selectedProfile
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
        if plannerStore.saveCurrentPlan(profile: selectedProfile) {
            transferMessage = DIRIOSLocalizer.string("snorkeling.ios.planner.saved")
        }
    }

    private func sharePlan() {
        shareText = SnorkelingRoutePlanExportFormatter.shareText(
            draft: plannerStore.draft,
            profile: selectedProfile,
            validation: validation
        )
        isShareSheetPresented = true
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
