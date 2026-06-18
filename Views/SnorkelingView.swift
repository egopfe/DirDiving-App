import SwiftUI

struct SnorkelingView: View {
    @EnvironmentObject private var runtime: SnorkelingWatchRuntimeStore
    @EnvironmentObject private var snorkelingLogbook: SnorkelingLogbookStore
    @EnvironmentObject private var watchSync: WatchSyncService
    @ObservedObject private var importedRoute = SnorkelingImportedRouteStore.shared
    @EnvironmentObject private var gps: GPSManager
    @EnvironmentObject private var compass: CompassManager
    @AppStorage(HapticService.hapticsEnabledKey) private var hapticsEnabled = true
    @AppStorage(MissionModeSettings.autoEnableOnDiveStartKey) private var missionModeEnabled = false

    @State private var savedBannerVisible = false

    private var input: SnorkelingWatchPresentationInput { runtime.presentationInput }

    private var ui: SnorkelingWatchPresentationOutput {
        SnorkelingWatchPresentation.make(input)
    }

    var body: some View {
        ZStack {
            DiveScreenBackground()
            ScrollView {
                VStack(spacing: DiveUI.spaceM) {
                    header
                    if let recovered = ui.recoveredSessionBannerText {
                        recoveredBanner(recovered, warning: ui.recoveryWarningText)
                    }
                    content
                    if input.isSessionStarted, ui.stage != .ready, ui.stage != .sessionSummary {
                        actionRow
                    }
                    footerBadges
                }
                .padding(.horizontal, DiveUI.screenPadding)
                .padding(.vertical, 9)
            }
            .scrollIndicators(.hidden)

            if let overlay = ui.overlay {
                warningOverlay(overlay)
            }

            if savedBannerVisible, let message = runtime.lastMarkerSavedConfirmation {
                savedConfirmationBanner(message)
            }
        }
        .dynamicTypeSize(.xSmall ... .accessibility2)
        .onAppear {
            runtime.attachSensorManagers(gps: gps, compass: compass)
            runtime.configureRuntimePreferences(
                hapticsEnabled: hapticsEnabled,
                missionModeEnabled: missionModeEnabled,
                buddyReminderEnabled: input.buddyReminderEnabled
            )
            watchSync.isSnorkelingSessionInProgress = runtime.isSessionActive
        }
        .onChange(of: runtime.isSessionActive) { _, active in
            watchSync.isSnorkelingSessionInProgress = active
            if !active {
                importedRoute.activatePendingIfNeeded()
            }
        }
        .onChange(of: hapticsEnabled) { _, enabled in
            runtime.configureRuntimePreferences(
                hapticsEnabled: enabled,
                missionModeEnabled: missionModeEnabled,
                buddyReminderEnabled: input.buddyReminderEnabled
            )
        }
        .onChange(of: missionModeEnabled) { _, enabled in
            runtime.configureRuntimePreferences(
                hapticsEnabled: hapticsEnabled,
                missionModeEnabled: enabled,
                buddyReminderEnabled: input.buddyReminderEnabled
            )
        }
        .onChange(of: runtime.lastMarkerSavedConfirmation) { _, message in
            guard message != nil else { return }
            savedBannerVisible = true
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                savedBannerVisible = false
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(ui.headerTitle)
                    .font(DiveUI.Typography.screenTitle)
                    .foregroundStyle(DiveUI.cyan)
                    .accessibilityAddTraits(.isHeader)
                Text(ui.headerSubtitle)
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(DiveUI.secondaryText)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 4) {
                DiveClockText(size: 14)
                gpsPill
            }
        }
    }

    private var gpsPill: some View {
        DiveStatusPill(ui.gpsStatusText, color: color(for: ui.gpsStatusColorToken), systemImage: "location.fill")
            .accessibilityLabel(String(localized: "snorkeling.a11y.gps_status"))
            .accessibilityValue(ui.gpsStatusText)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch ui.stage {
        case .ready:
            readyPanel
        case .surfaceDashboard:
            surfaceDashboardPanel
        case .dipInProgress:
            dipPanel
        case .navigation:
            navigationPanel
        case .returnToEntry:
            returnPanel
        case .saveMarker:
            saveMarkerPanel
        case .sessionSummary:
            sessionSummaryPanel
        }
    }

    private var readyPanel: some View {
        DivePanel(stroke: DiveUI.blue) {
            VStack(spacing: DiveUI.spaceM) {
                Text(String(localized: "snorkeling.ready.title"))
                    .font(DiveUI.Typography.readyTitle)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                readyGrid

                Text(ui.buddyText)
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(DiveUI.yellow)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel(String(localized: "snorkeling.buddy.label"))
                    .accessibilityValue(ui.buddyText)

                if input.sensorHealth == .manualFallback || input.phase == .sensorDegraded {
                    DiveCommandButton(String(localized: "snorkeling.manual.fallback"), systemImage: "hand.tap.fill", color: DiveUI.yellow) {
                        runtime.enableManualFallback()
                    }
                }

                DiveCommandButton(
                    String(localized: "snorkeling.ready.start"),
                    systemImage: "play.fill",
                    color: ui.startEnabled ? DiveUI.green : DiveUI.red
                ) {
                    runtime.startSession()
                }
                .disabled(!ui.startEnabled)
                .accessibilityHint(ui.startDisabledReason ?? "")
            }
        }
    }

    private var readyGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DiveUI.spaceS) {
            readyCell(String(localized: "snorkeling.ready.gps"), ui.gpsStatusText, color(for: ui.gpsStatusColorToken))
            readyCell(String(localized: "snorkeling.ready.depth_sensor"), ui.depthSensorText, DiveUI.green)
            readyCell(String(localized: "snorkeling.ready.entry"), ui.entryPointText, DiveUI.blue)
            readyCell(String(localized: "snorkeling.ready.duration"), ui.targetDurationText, DiveUI.blue)
            readyCell(String(localized: "snorkeling.ready.distance"), ui.maxDistanceText, DiveUI.blue)
            readyCell(String(localized: "snorkeling.ready.mission"), ui.missionModeText, DiveUI.yellow)
        }
    }

    private func readyCell(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(DiveUI.Typography.hintCaption)
                .foregroundStyle(DiveUI.secondaryText)
            Text(value)
                .font(DiveUI.Typography.statusValue)
                .foregroundStyle(color)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var surfaceDashboardPanel: some View {
        DivePanel(stroke: DiveUI.green) {
            VStack(spacing: DiveUI.spaceM) {
                heroRow(value: ui.runtimeText, unit: String(localized: "snorkeling.metric.runtime"), color: DiveUI.green)

                HStack(spacing: 0) {
                    metricTile(String(localized: "snorkeling.metric.distance"), ui.distanceText, DiveUI.blue)
                    divider
                    metricTile(String(localized: "snorkeling.metric.speed"), ui.surfaceSpeedText, DiveUI.yellow)
                }
                HStack(spacing: 0) {
                    metricTile(String(localized: "snorkeling.metric.temperature"), ui.waterTemperatureText, DiveUI.cyan)
                    divider
                    metricTile(String(localized: "snorkeling.metric.dips"), ui.dipCountText, .white)
                }

                entryDistanceRow
            }
        }
    }

    private var dipPanel: some View {
        DivePanel(stroke: DiveUI.cyan) {
            HStack(alignment: .top, spacing: DiveUI.spaceS) {
                VStack(alignment: .leading, spacing: DiveUI.spaceS) {
                    heroRow(
                        value: ui.heroValue,
                        unit: ui.heroUnit,
                        color: DiveUI.cyan,
                        accessibility: ui.heroAccessibilityLabel
                    )
                    HStack(spacing: DiveUI.spaceM) {
                        metricTile(String(localized: "snorkeling.dip.duration"), ui.dipDurationText, DiveUI.green)
                        metricTile(String(localized: "snorkeling.dip.max"), ui.dipMaxDepthText, DiveUI.yellow)
                    }
                    HStack(spacing: DiveUI.spaceM) {
                        Text(ui.dipNumberText)
                            .font(DiveUI.Typography.hintCaption)
                            .foregroundStyle(DiveUI.secondaryText)
                        Text(ui.waterTemperatureText)
                            .font(DiveUI.Typography.hintCaption)
                            .foregroundStyle(DiveUI.cyan)
                    }
                }
                verticalSpeedGauge
            }
        }
    }

    private var verticalSpeedGauge: some View {
        VStack(spacing: 4) {
            Text(String(localized: "snorkeling.metric.vertical_speed"))
                .font(DiveUI.Typography.hintCaption)
                .foregroundStyle(DiveUI.secondaryText)
            Text(ui.verticalSpeedText)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(DiveUI.orange)
                .accessibilityLabel(String(localized: "snorkeling.a11y.vertical_speed"))
                .accessibilityValue(ui.verticalSpeedText)
        }
        .frame(width: 54)
        .padding(.vertical, 6)
        .background(DiveUI.panelFillRaised)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var navigationPanel: some View {
        DivePanel(stroke: color(for: ui.navigationAccentToken)) {
            HStack(spacing: DiveUI.spaceM) {
                DiveBearingRing(
                    headingDegrees: ui.headingDegrees ?? 0,
                    bearingDelta: ui.bearingDeltaDegrees ?? 0,
                    accent: color(for: ui.navigationAccentToken),
                    size: 100
                )
                .accessibilityLabel(ui.turnInstructionAccessibility)

                VStack(alignment: .leading, spacing: 6) {
                    Text(ui.waypointNameText)
                        .font(DiveUI.Typography.sectionHeading)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                    DiveStatusPill(ui.waypointDistanceText + " m", color: DiveUI.blue, systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                    DiveStatusPill(ui.turnInstructionText, color: color(for: ui.navigationAccentToken), systemImage: turnIcon)
                        .accessibilityLabel(ui.turnInstructionAccessibility)
                }
                Spacer(minLength: 0)
            }

            HStack {
                gpsPill
                Spacer()
                Text(ui.surfaceSpeedText)
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(DiveUI.secondaryText)
            }
            .padding(.top, 4)
        }
    }

    private var returnPanel: some View {
        DivePanel(stroke: ui.showReturnAdvisor ? DiveUI.yellow : DiveUI.green) {
            VStack(spacing: DiveUI.spaceM) {
                HStack(spacing: DiveUI.spaceM) {
                    if ui.turnInstructionText == String(localized: "snorkeling.nav.gps_unavailable") {
                        Image(systemName: "location.slash")
                            .font(.title2)
                            .foregroundStyle(DiveUI.orange)
                            .accessibilityLabel(String(localized: "snorkeling.nav.gps_unavailable"))
                    } else {
                        DiveBearingRing(
                            headingDegrees: ui.headingDegrees ?? 0,
                            bearingDelta: ui.bearingDeltaDegrees ?? 0,
                            accent: DiveUI.yellow,
                            size: 88
                        )
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(ui.returnDistanceText + " m")
                            .font(DiveUI.Typography.dashboardValue)
                            .monospacedDigit()
                            .foregroundStyle(DiveUI.green)
                            .accessibilityLabel(ui.heroAccessibilityLabel)
                        Text(ui.returnBearingText)
                            .font(DiveUI.Typography.hintCaption)
                            .foregroundStyle(DiveUI.secondaryText)
                    }
                    Spacer(minLength: 0)
                }

                if let advisor = ui.returnAdvisorText {
                    Text(advisor)
                        .font(DiveUI.Typography.warningTitle)
                        .foregroundStyle(DiveUI.yellow)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                HStack {
                    Text(ui.runtimeText)
                        .font(DiveUI.Typography.hintCaption)
                        .foregroundStyle(DiveUI.secondaryText)
                    Spacer()
                    Text(ui.entryDistanceText)
                        .font(DiveUI.Typography.hintCaption)
                        .foregroundStyle(DiveUI.blue)
                }
            }
        }
    }

    private var saveMarkerPanel: some View {
        DivePanel(stroke: DiveUI.yellow) {
            VStack(spacing: DiveUI.spaceM) {
                Picker(String(localized: "snorkeling.marker.category"), selection: $runtime.selectedMarkerCategory) {
                    ForEach(SnorkelingMarkerCategory.allCases, id: \.self) { category in
                        Text(markerLabel(category)).tag(category)
                    }
                }
                .labelsHidden()

                VStack(alignment: .leading, spacing: 4) {
                    Text(input.markerPositionQualityLabel)
                        .font(DiveUI.Typography.statusValue)
                        .foregroundStyle(DiveUI.yellow)
                    if let distance = input.markerDistanceFromEntryText {
                        Text(distance)
                            .font(DiveUI.Typography.hintCaption)
                            .foregroundStyle(DiveUI.blue)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                DiveCommandButton(String(localized: "snorkeling.marker.save"), systemImage: "mappin.and.ellipse", color: DiveUI.yellow) {
                    runtime.saveMarker()
                }
                .disabled(!ui.saveMarkerEnabled)

                DiveCommandButton(String(localized: "snorkeling.marker.cancel"), systemImage: "xmark", color: DiveUI.secondaryText) {
                    runtime.dismissSaveMarker()
                }
            }
        }
    }

    private var sessionSummaryPanel: some View {
        DivePanel(stroke: DiveUI.blue) {
            VStack(spacing: DiveUI.spaceM) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DiveUI.spaceS) {
                    summaryCell(String(localized: "snorkeling.summary.total_time"), ui.summaryTotalTimeText)
                    summaryCell(String(localized: "snorkeling.summary.distance"), ui.summaryDistanceText)
                    summaryCell(String(localized: "snorkeling.summary.max_depth"), ui.summaryMaxDepthText)
                    summaryCell(String(localized: "snorkeling.summary.underwater"), ui.summaryUnderwaterTimeText)
                    summaryCell(String(localized: "snorkeling.summary.dips"), ui.summaryDipCountText)
                    summaryCell(String(localized: "snorkeling.summary.markers"), ui.summaryMarkerCountText)
                    summaryCell(String(localized: "snorkeling.summary.avg_speed"), ui.summaryAverageSpeedText)
                    summaryCell(String(localized: "snorkeling.summary.min_temp"), ui.summaryMinTemperatureText)
                }

                Text(ui.summaryFooterText)
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(summaryFooterColor)
                    .frame(maxWidth: .infinity, alignment: .leading)

                DiveCommandButton(String(localized: "snorkeling.summary.done"), systemImage: "checkmark", color: DiveUI.green) {
                    if runtime.saveCompletedSession(to: snorkelingLogbook) {
                        runtime.resetAfterSave()
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private var actionRow: some View {
        HStack(spacing: 6) {
            if input.phase == .paused {
                DiveCommandButton(String(localized: "snorkeling.action.resume"), systemImage: "play.fill", color: DiveUI.green) {
                    runtime.resumeSession()
                }
            } else if input.isSessionStarted {
                DiveCommandButton(String(localized: "snorkeling.action.pause"), systemImage: "pause.fill", color: DiveUI.yellow) {
                    runtime.pauseSession()
                }
            }
            DiveCommandButton(String(localized: "snorkeling.action.nav"), systemImage: "location.north.fill", color: DiveUI.blue) {
                runtime.enterNavigation()
            }
            DiveCommandButton(String(localized: "snorkeling.action.return"), systemImage: "arrow.uturn.backward", color: DiveUI.yellow) {
                runtime.enterReturnMode()
            }
            DiveCommandButton(String(localized: "snorkeling.action.marker"), systemImage: "mappin", color: DiveUI.yellow) {
                runtime.presentSaveMarker()
            }
        }
    }

    private var footerBadges: some View {
        HStack {
            DiveStatusPill(ui.gpsStatusText, color: color(for: ui.gpsStatusColorToken), systemImage: "location")
            Spacer()
            if input.isSessionStarted, ui.stage != .sessionSummary {
                DiveCommandButton(String(localized: "snorkeling.action.end"), systemImage: "stop.fill", color: DiveUI.red) {
                    runtime.endSession()
                }
            }
        }
    }

    // MARK: - Overlays

    private func recoveredBanner(_ title: String, warning: String?) -> some View {
        DivePanel(stroke: DiveUI.yellow) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DiveUI.Typography.warningTitle)
                    .foregroundStyle(DiveUI.yellow)
                if let warning {
                    Text(warning)
                        .font(DiveUI.Typography.hintCaption)
                        .foregroundStyle(DiveUI.secondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func warningOverlay(_ overlay: SnorkelingWatchOverlayPresentation) -> some View {
        switch overlay {
        case .sensorDegraded:
            inlineBanner(
                title: String(localized: "snorkeling.overlay.sensor_degraded"),
                subtitle: String(localized: "snorkeling.overlay.sensor_degraded.hint"),
                color: DiveUI.red
            )
        case .gpsDegradedUnderwater:
            inlineBanner(
                title: String(localized: "snorkeling.overlay.gps_underwater"),
                subtitle: String(localized: "snorkeling.overlay.gps_underwater.hint"),
                color: DiveUI.secondaryText
            )
        case .operational(let item):
            inlineBanner(
                title: item.subtitle,
                subtitle: item.titleKey,
                color: operationalColor(item.severity)
            )
        }
    }

    private func inlineBanner(title: String, subtitle: String, color: Color) -> some View {
        VStack {
            DiveInlineStatusBanner(
                systemImage: "exclamationmark.triangle.fill",
                title: title,
                detail: subtitle,
                color: color
            )
                .padding(.horizontal, DiveUI.screenPadding)
                .padding(.top, 8)
            Spacer()
        }
        .transition(ui.animationsEnabled ? .opacity : .identity)
        .accessibilityElement(children: .combine)
    }

    private func savedConfirmationBanner(_ message: String) -> some View {
        VStack {
            Spacer()
            DiveInlineStatusBanner(
                systemImage: "checkmark.circle.fill",
                title: message,
                detail: String(localized: "snorkeling.marker.saved.hint"),
                color: DiveUI.yellow
            )
            .padding(.horizontal, DiveUI.screenPadding)
            .padding(.bottom, 8)
        }
        .transition(ui.animationsEnabled ? .move(edge: .bottom).combined(with: .opacity) : .identity)
    }

    // MARK: - Helpers

    private var entryDistanceRow: some View {
        HStack {
            Text(String(localized: "snorkeling.metric.entry_distance"))
                .font(DiveUI.Typography.metricLabel)
                .foregroundStyle(DiveUI.secondaryText)
            Spacer()
            Text(ui.entryDistanceText)
                .font(DiveUI.Typography.statusValue)
                .foregroundStyle(DiveUI.blue)
        }
        .padding(.top, 4)
    }

    private var divider: some View {
        Rectangle().fill(DiveUI.hairline).frame(width: 1, height: 34)
    }

    private func heroRow(value: String, unit: String?, color: Color, accessibility: String? = nil) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 6) {
            Text(value)
                .font(.system(size: 40, weight: .black, design: .rounded))
                .minimumScaleFactor(0.65)
                .lineLimit(1)
                .monospacedDigit()
                .foregroundStyle(color)
            if let unit {
                Text(unit)
                    .font(DiveUI.Typography.unitLabel)
                    .foregroundStyle(DiveUI.blue)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibility ?? value)
    }

    private func metricTile(_ label: String, _ value: String, _ color: Color) -> some View {
        DiveMetric(label, value: value, color: color, valueSize: 22)
            .frame(maxWidth: .infinity)
    }

    private func summaryCell(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(DiveUI.Typography.hintCaption)
                .foregroundStyle(DiveUI.secondaryText)
            Text(value)
                .font(DiveUI.Typography.statusValue)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var turnIcon: String {
        switch ui.turnInstructionText {
        case String(localized: "snorkeling.nav.turn_left"): return "arrow.turn.up.left"
        case String(localized: "snorkeling.nav.turn_right"): return "arrow.turn.up.right"
        case String(localized: "snorkeling.nav.on_line"): return "checkmark"
        default: return "location.slash"
        }
    }

    private var summaryFooterColor: Color {
        switch input.sessionSaveState {
        case .saved: return DiveUI.green
        case .syncPending: return DiveUI.yellow
        case .failed: return DiveUI.red
        case .notSaved: return DiveUI.secondaryText
        }
    }

    private func color(for token: SnorkelingWatchColorToken) -> Color {
        switch token {
        case .primary: return .white
        case .blue: return DiveUI.blue
        case .green: return DiveUI.green
        case .yellow: return DiveUI.yellow
        case .orange: return DiveUI.orange
        case .red: return DiveUI.red
        case .secondary: return DiveUI.secondaryText
        }
    }

    private func operationalColor(_ severity: SnorkelingOperationalSeverity) -> Color {
        switch severity {
        case .info: return DiveUI.blue
        case .caution: return DiveUI.yellow
        case .warning: return DiveUI.orange
        case .critical: return DiveUI.red
        }
    }

    private func markerLabel(_ category: SnorkelingMarkerCategory) -> String {
        switch category {
        case .marineLife: return String(localized: "snorkeling.marker.marine_life")
        case .reef: return String(localized: "snorkeling.marker.reef")
        case .wreck: return String(localized: "snorkeling.marker.wreck")
        case .photoSpot: return String(localized: "snorkeling.marker.photo")
        case .buoy: return String(localized: "snorkeling.marker.buoy")
        case .custom: return String(localized: "snorkeling.marker.custom")
        }
    }
}
