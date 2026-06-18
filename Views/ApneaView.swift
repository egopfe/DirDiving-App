import SwiftUI

struct ApneaView: View {
    @EnvironmentObject private var runtime: ApneaWatchRuntimeStore
    @EnvironmentObject private var apneaLogbook: ApneaLogbookStore
    @EnvironmentObject private var watchSync: WatchSyncService
    @ObservedObject private var importedPlan = ApneaImportedPlanStore.shared
    @AppStorage(HapticService.hapticsEnabledKey) private var hapticsEnabled = true

    @State private var recoveryCompleteHapticFired = false
    @State private var savedConfirmationVisible = false

    private var input: ApneaWatchPresentationInput { runtime.presentationInput }

    private var ui: ApneaWatchPresentationOutput {
        ApneaWatchPresentation.make(input)
    }

    var body: some View {
        ZStack {
            DiveScreenBackground()
            ScrollView {
                VStack(spacing: 8) {
                    header
                    content
                    footerBadges
                }
                .padding(.horizontal, DiveUI.screenPadding)
                .padding(.vertical, 9)
            }
            .scrollIndicators(.hidden)

            if let overlay = ui.activeOverlay {
                eventOverlay(overlay)
            }

            if savedConfirmationVisible {
                savedConfirmationBanner
            }
        }
        .dynamicTypeSize(.xSmall ... .accessibility2)
        .onAppear {
            runtime.configureRuntimePreferences(
                hapticsEnabled: hapticsEnabled,
                missionModeEnabled: importedPlan.readyPresentation.missionModeEnabled
            )
            watchSync.isApneaSessionInProgress = runtime.isSessionActive
        }
        .onChange(of: hapticsEnabled) { _, enabled in
            runtime.configureRuntimePreferences(
                hapticsEnabled: enabled,
                missionModeEnabled: importedPlan.readyPresentation.missionModeEnabled
            )
        }
        .onChange(of: runtime.isSessionActive) { _, active in
            watchSync.isApneaSessionInProgress = active
            if !active {
                importedPlan.activatePendingIfNeeded(sessionInProgress: false)
            }
        }
        .onChange(of: ui.recoveryCompleteHapticEligible) { _, eligible in
            guard eligible, !recoveryCompleteHapticFired else { return }
            recoveryCompleteHapticFired = true
            HapticService.shared.confirm()
        }
        .onChange(of: ui.recoveryState) { _, state in
            if state != .completed {
                recoveryCompleteHapticFired = false
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Apnea")
                .font(DiveUI.Typography.brandTitle)
                .foregroundStyle(DiveUI.cyan)
            Spacer()
            DiveClockText(size: 14)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch ui.stage {
        case .ready:
            readyPanel
        case .dive:
            activeDivePanel(title: String(localized: "apnea.stage.dive"), ascentAccent: false)
        case .ascent:
            activeDivePanel(title: String(localized: "apnea.stage.ascent"), ascentAccent: true)
        case .surfaceRecovery:
            surfaceRecoveryPanel
        case .sessionSummary:
            sessionSummaryPanel
        }
    }

    private var readyPanel: some View {
        DivePanel(stroke: DiveUI.blue) {
            VStack(spacing: 8) {
                Text(String(localized: "apnea.ready.title"))
                    .font(DiveUI.Typography.readyTitle)
                    .foregroundStyle(.white)

                metricRow(label: String(localized: "apnea.ready.target"), value: "\(Int(input.targetDepthMeters)) m", valueColor: DiveUI.blue)
                metricRow(label: String(localized: "apnea.ready.recovery"), value: input.recoveryPolicyLabel, valueColor: DiveUI.blue)
                metricRow(label: String(localized: "apnea.ready.alarms"), value: ui.alarmLabel, valueColor: DiveUI.green)

                if let revision = importedPlan.readyPresentation.packageRevision {
                    metricRow(
                        label: String(localized: "apnea.ready.revision"),
                        value: "r\(revision)",
                        valueColor: importedPlan.readyPresentation.isPendingWhileSessionActive ? DiveUI.yellow : DiveUI.cyan
                    )
                }

                if importedPlan.readyPresentation.isPendingWhileSessionActive {
                    Text(String(localized: "apnea.ready.pending_plan"))
                        .font(DiveUI.Typography.hintCaption)
                        .foregroundStyle(DiveUI.yellow)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if !ui.configuredAlarms.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(ui.configuredAlarms, id: \.self) { alarm in
                            Text(alarm)
                                .font(DiveUI.Typography.hintCaption)
                                .foregroundStyle(DiveUI.secondaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                metricRow(label: String(localized: "apnea.ready.sensor"), value: ui.sensorLabel, valueColor: input.sensorDegraded ? DiveUI.red : DiveUI.green)
                metricRow(label: String(localized: "apnea.ready.buddy"), value: input.buddyReminderEnabled ? String(localized: "apnea.buddy.on") : String(localized: "apnea.buddy.off"), valueColor: DiveUI.yellow)

                if input.sensorDegraded {
                    DiveCommandButton(String(localized: "apnea.manual.fallback"), systemImage: "hand.tap.fill", color: DiveUI.yellow) {
                        runtime.startManualFallback()
                    }
                }

                DiveCommandButton(String(localized: "apnea.ready.start"), systemImage: "play.fill", color: ui.startEnabled ? DiveUI.green : DiveUI.red) {
                    if ui.startEnabled {
                        runtime.armSession()
                    }
                }
                .disabled(!ui.startEnabled)
                .accessibilityHint(ui.startEnabled ? String(localized: "apnea.a11y.start_hint") : (ui.startDisabledReason ?? ""))

                if let reason = ui.startDisabledReason {
                    Text(reason)
                        .font(DiveUI.Typography.warningBody)
                        .foregroundStyle(DiveUI.red)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    private var surfaceRecoveryPanel: some View {
        DivePanel(stroke: recoveryAccentColor) {
            VStack(spacing: 8) {
                Text(String(localized: "apnea.surface.title"))
                    .font(DiveUI.Typography.statusTitle)
                    .foregroundStyle(.white)

                Text(ui.surfaceElapsedText)
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundStyle(recoveryAccentColor)
                    .monospacedDigit()
                    .minimumScaleFactor(0.55)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(String(localized: "apnea.surface.a11y.elapsed"))
                    .accessibilityValue(ui.surfaceElapsedText)

                Text(String(localized: "apnea.surface.last_dive"))
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(DiveUI.secondaryText)

                HStack {
                    Text(ui.lastDiveMaxDepthText)
                        .font(DiveUI.Typography.statusValue)
                        .foregroundStyle(.white)
                        .monospacedDigit()
                    Spacer()
                    Text(ui.lastDiveDurationText)
                        .font(DiveUI.Typography.statusValue)
                        .foregroundStyle(.white)
                        .monospacedDigit()
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(String(localized: "apnea.surface.a11y.last_dive"))
                .accessibilityValue("\(ui.lastDiveMaxDepthText), \(ui.lastDiveDurationText)")

                Text(String(localized: "apnea.surface.recovery_required"))
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(DiveUI.secondaryText)

                if let remaining = ui.recoveryRemainingText {
                    Text(remaining)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(recoveryAccentColor)
                        .monospacedDigit()
                        .accessibilityLabel(String(localized: "apnea.surface.a11y.recovery_remaining"))
                        .accessibilityValue(remaining)
                } else {
                    Text(ui.recoveryRequiredText)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(recoveryAccentColor)
                        .monospacedDigit()
                }

                Text(ui.recoveryStateText)
                    .font(DiveUI.Typography.rowTitle)
                    .foregroundStyle(recoveryAccentColor)
                    .accessibilityLabel(String(localized: "apnea.surface.a11y.recovery_state"))
                    .accessibilityValue(ui.recoveryStateText)

                if runtime.isSessionActive {
                    DiveCommandButton(String(localized: "apnea.summary.open"), systemImage: "list.bullet", color: DiveUI.blue) {
                        runtime.requestSessionSummary()
                    }
                }
            }
        }
    }

    private var sessionSummaryPanel: some View {
        DivePanel(stroke: DiveUI.blue) {
            VStack(spacing: 6) {
                Text(String(localized: "apnea.summary.title"))
                    .font(DiveUI.Typography.readyTitle)
                    .foregroundStyle(.white)

                metricRow(label: String(localized: "apnea.summary.dives"), value: ui.summaryDiveCountText, valueColor: .white)
                metricRow(label: String(localized: "apnea.summary.max_depth"), value: ui.summaryMaxDepthText, valueColor: .white)
                metricRow(label: String(localized: "apnea.summary.best_time"), value: ui.summaryBestTimeText, valueColor: .white)
                metricRow(label: String(localized: "apnea.summary.average_time"), value: ui.summaryAverageTimeText, valueColor: .white)
                metricRow(label: String(localized: "apnea.summary.total_underwater"), value: ui.summaryTotalUnderwaterText, valueColor: .white)
                metricRow(label: String(localized: "apnea.summary.session_duration"), value: ui.summarySessionDurationText, valueColor: .white)

                if let warnings = ui.summaryWarningsText {
                    Text(warnings)
                        .font(DiveUI.Typography.warningBody)
                        .foregroundStyle(DiveUI.orange)
                        .multilineTextAlignment(.center)
                        .accessibilityLabel(String(localized: "apnea.summary.a11y.warnings"))
                        .accessibilityValue(warnings)
                }

                DiveCommandButton(String(localized: "apnea.summary.save_end"), systemImage: "checkmark", color: DiveUI.green) {
                    saveCurrentSessionToLogbook()
                }
                DiveCommandButton(String(localized: "apnea.summary.return"), systemImage: "arrow.uturn.backward", color: .white.opacity(0.78)) {
                    runtime.showSessionSummary = false
                    runtime.endSession()
                }
            }
        }
    }

    private var savedConfirmationBanner: some View {
        VStack {
            Text(String(localized: "apnea.logbook.saved"))
                .font(DiveUI.Typography.rowTitle)
                .foregroundStyle(DiveUI.green)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.88))
                        .overlay(Capsule().stroke(DiveUI.green.opacity(0.8), lineWidth: 1))
                )
                .accessibilityLabel(String(localized: "apnea.logbook.saved.a11y"))
            Spacer()
        }
        .padding(.top, 8)
        .transition(.opacity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                savedConfirmationVisible = false
            }
        }
    }

    private func saveCurrentSessionToLogbook() {
        runtime.saveCompletedSession(to: apneaLogbook)
        runtime.resetAfterSave()
        savedConfirmationVisible = true
        HapticService.shared.confirm()
    }

    private func eventOverlay(_ overlay: ApneaWatchOverlayPresentation) -> some View {
        let accent = overlayAccentColor(for: overlay.kind)
        return ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
            VStack(spacing: 8) {
                Text(overlay.title)
                    .font(DiveUI.Typography.statusTitle)
                    .foregroundStyle(.white)
                if let depth = overlay.depthMeters {
                    Text("\(Formatters.one(depth)) m")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(accent)
                        .monospacedDigit()
                }
                Text(overlay.subtitle)
                    .font(DiveUI.Typography.rowTitle)
                    .foregroundStyle(accent)
                overlayIcon(for: overlay.kind, color: accent)

                if overlay.dismissSafe {
                    DiveCommandButton(String(localized: "apnea.overlay.dismiss"), systemImage: "xmark", color: .white.opacity(0.78)) {
                        runtime.dismissOperationalOverlay(eventID: runtime.operationalOverlay?.eventID ?? UUID())
                    }
                    .accessibilityHint(String(localized: "apnea.overlay.a11y.dismiss_hint"))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.black.opacity(0.92))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(accent.opacity(0.8), lineWidth: 1))
            )
            .padding(.horizontal, 10)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(overlayAccessibilityLabel(for: overlay))
    }

    private func activeDivePanel(title: String, ascentAccent: Bool) -> some View {
        DivePanel(stroke: ascentAccent ? ascentColor : DiveUI.blue) {
            VStack(spacing: 8) {
                Text(title)
                    .font(DiveUI.Typography.statusTitle)
                    .foregroundStyle(ascentAccent ? ascentColor : .white)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(Formatters.one(input.currentDepthMeters))
                        .font(.system(size: 62, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                        .minimumScaleFactor(0.55)
                    Text("m")
                        .font(DiveUI.Typography.metricUnitHero)
                        .foregroundStyle(DiveUI.blue)
                        .padding(.bottom, 8)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(String(localized: "live.depth.a11y"))
                .accessibilityValue("\(Formatters.one(input.currentDepthMeters)) m")

                metricRow(label: String(localized: "apnea.active.duration"), value: Formatters.time(input.diveElapsedSeconds), valueColor: .white)
                metricRow(label: String(localized: "apnea.active.max"), value: "\(Formatters.one(input.maxDepthMeters)) m", valueColor: DiveUI.blue)

                VStack(spacing: 2) {
                    Text(ui.verticalSpeedText)
                        .font(.system(size: 29, weight: .bold, design: .rounded))
                        .foregroundStyle(ascentAccent ? ascentColor : .white)
                        .monospacedDigit()
                    Text(ui.verticalDirectionText)
                        .font(DiveUI.Typography.hintCaption)
                        .foregroundStyle(DiveUI.secondaryText)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(String(localized: "apnea.a11y.vertical_speed"))
                .accessibilityValue("\(ui.verticalDirectionText), \(ui.verticalSpeedText)")

                HStack(spacing: 8) {
                    badge(systemImage: "thermometer", text: temperatureText, color: DiveUI.cyan)
                    badge(systemImage: "number", text: "#\(input.diveCount)", color: DiveUI.blue)
                    badge(systemImage: "dot.radiowaves.left.and.right", text: ui.sensorLabel, color: input.sensorDegraded ? DiveUI.red : DiveUI.green)
                }

                if ui.stage == .ascent {
                    HStack(spacing: 6) {
                        badge(systemImage: "water.waves", text: String(localized: "apnea.marker.indicator"), color: DiveUI.yellow)
                        badge(systemImage: "checkmark.circle", text: String(localized: "apnea.target.indicator"), color: DiveUI.green)
                    }
                }

                if runtime.isSessionActive && ui.stage != .dive {
                    DiveCommandButton(String(localized: "apnea.summary.open"), systemImage: "list.bullet", color: DiveUI.blue) {
                        runtime.requestSessionSummary()
                    }
                }

                if runtime.lifecyclePhase == .sensorDegraded || input.sensorDegraded {
                    HStack(spacing: 6) {
                        DiveCommandButton(String(localized: "apnea.manual.descent"), systemImage: "arrow.down", color: DiveUI.cyan) {
                            runtime.triggerManualDescent()
                        }
                        DiveCommandButton(String(localized: "apnea.manual.surface"), systemImage: "arrow.up", color: DiveUI.yellow) {
                            runtime.triggerManualSurface()
                        }
                    }
                }
            }
        }
    }

    private var footerBadges: some View {
        HStack(spacing: 6) {
            if !hapticsEnabled {
                badge(systemImage: "bell.slash.fill", text: String(localized: "live.haptics.off"), color: DiveUI.yellow)
                    .accessibilityLabel(String(localized: "a11y.watch.haptics_off_badge.label"))
                    .accessibilityHint(String(localized: "a11y.watch.haptics_off_badge.hint"))
            }
            badge(systemImage: "bolt.fill", text: ui.missionLabel, color: input.missionModeEnabled ? DiveUI.cyan : DiveUI.secondaryText)
            Spacer(minLength: 0)
        }
    }

    private func metricRow(label: String, value: String, valueColor: Color) -> some View {
        HStack {
            Text(label)
                .font(DiveUI.Typography.rowTitle)
                .foregroundStyle(.white)
            Spacer()
            Text(value)
                .font(DiveUI.Typography.statusValue)
                .foregroundStyle(valueColor)
                .monospacedDigit()
        }
    }

    private func badge(systemImage: String, text: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Image(systemName: systemImage)
            Text(text)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .font(DiveUI.Typography.hintCaptionBold)
        .foregroundStyle(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.12))
                .overlay(Capsule().stroke(color.opacity(0.72), lineWidth: 1))
        )
    }

    @ViewBuilder
    private func overlayIcon(for kind: ApneaOperationalOverlay.Kind, color: Color) -> some View {
        switch kind {
        case .markerReached:
            Image(systemName: "water.waves")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(color)
        case .targetReached:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(color)
        case .alarm:
            Image(systemName: "bell.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(color)
        }
    }

    private func overlayAccentColor(for kind: ApneaOperationalOverlay.Kind) -> Color {
        switch kind {
        case .markerReached: DiveUI.yellow
        case .targetReached: DiveUI.green
        case .alarm: DiveUI.orange
        }
    }

    private func overlayAccessibilityLabel(for overlay: ApneaWatchOverlayPresentation) -> String {
        switch overlay.kind {
        case .markerReached:
            return String(localized: "apnea.overlay.a11y.marker")
        case .targetReached:
            return String(localized: "apnea.overlay.a11y.target")
        case .alarm:
            return String(localized: "apnea.overlay.a11y.alarm")
        }
    }

    private var temperatureText: String {
        guard let temperatureCelsius = input.temperatureCelsius else { return "--.-°C" }
        return "\(Formatters.one(temperatureCelsius))°C"
    }

    private var ascentColor: Color {
        abs(input.verticalSpeedMetersPerSecond) > 1.5 ? DiveUI.yellow : DiveUI.blue
    }

    private var recoveryAccentColor: Color {
        switch ui.recoveryState {
        case .completed: DiveUI.green
        case .inProgress: DiveUI.yellow
        case .insufficient: DiveUI.orange
        }
    }
}
