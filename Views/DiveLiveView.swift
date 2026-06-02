import SwiftUI

/// **Screen intent (Watch MAIN):** in-water dashboard — depth hero, TTV/RunTime summary, ascent gauge, stopwatch, lifecycle controls.
/// Visual target: black canvas, neon accents, rounded panels (`Docs/ReferenceUI/Watch_LIVE_reference.png`).
struct DiveLiveView: View {
    @EnvironmentObject private var dive: DiveManager
    @EnvironmentObject private var watchSync: WatchSyncService
    @AppStorage(HapticService.hapticsEnabledKey) private var hapticsEnabled = true
    @AppStorage(DIRUnitPreference.storageKey) private var watchUnits = DIRUnitPreference.metric.rawValue
    @State private var showResetStopwatchConfirmation = false

    private var unitPreference: DIRUnitPreference { DIRUnitPreference.fromStorage(watchUnits) }

    private var showAscentAlarmBanner: Bool {
        dive.isDiveActive && dive.ascentStatus.isOverLimit
    }

    private var depthSafetyState: DepthSafetyState {
        dive.depthSafetyState
    }

    private var depthReadoutStyle: DepthSafetyReadoutStyle {
        DepthSafetyReadoutStyle.forState(depthSafetyState, redWarningBlink: dive.redWarningBlink)
    }

    private var missionModeProfile: MissionModeRuntimeProfile {
        dive.missionModeRuntimeProfile
    }

    private var showsMissionModeControl: Bool {
        dive.isDiveActive
    }

    private var activeDiveTransition: AnyTransition {
        missionModeProfile.animationsEnabled
            ? .opacity.combined(with: .move(edge: .top))
            : .identity
    }

    var body: some View {
        ZStack {
            DiveScreenBackground()

            GeometryReader { geometry in
                let contentWidth = geometry.size.width - 18
                let gaugeWidth = min(58, contentWidth * 0.24)
                let leftWidth = contentWidth - gaugeWidth - 8

                VStack(spacing: 7) {
                    if watchSync.pendingTransferCount > 0 || watchSync.failedTransferCount > 0 {
                        syncStatusStrip
                    }
                    if dive.isDiveActive {
                        activeDiveContent(leftWidth: leftWidth, gaugeWidth: gaugeWidth)
                    } else {
                        preDiveWaitingContent
                    }
                    if let confirmation = dive.gpsConfirmation {
                        gpsConfirmationBanner(confirmation)
                    }
                    if let alarm = dive.alarmWarningMessage {
                        warningBanner(alarm, showAcknowledge: true) {
                            dive.dismissAlarmWarning()
                        }
                    }
                    if let error = dive.lastErrorMessage {
                        warningBanner(error, showAcknowledge: false) {}
                    }
                }
                .padding(.horizontal, 9)
                .padding(.top, 9)
                .padding(.bottom, 7)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            }
        }
        .animation(missionModeProfile.animationsEnabled ? .easeInOut(duration: 0.18) : nil, value: dive.redWarningBlink)
        .onChange(of: hapticsEnabled) { _, _ in
            dive.resyncHapticsAfterPreferenceChange()
        }
        .confirmationDialog(String(localized: "live.stopwatch.reset.confirm.title"), isPresented: $showResetStopwatchConfirmation, titleVisibility: .visible) {
            Button(String(localized: "live.stopwatch.reset.confirm.action"), role: .destructive) {
                dive.resetStopwatch()
            }
            Button(String(localized: "log.delete.cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "live.stopwatch.reset.confirm.message"))
        }
    }

    private var syncStatusStrip: some View {
        HStack(spacing: 6) {
            Image(systemName: watchSync.failedTransferCount > 0 ? "exclamationmark.triangle.fill" : "arrow.triangle.2.circlepath")
            Text(watchSync.lastSyncStatus)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
            if watchSync.pendingTransferCount > 0 {
                Text("\(watchSync.pendingTransferCount)")
                    .font(.caption2.bold())
                    .foregroundStyle(DiveUI.cyan)
            }
        }
        .font(.caption2.bold())
        .foregroundStyle(watchSync.failedTransferCount > 0 ? DiveUI.yellow : DiveUI.cyan)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill((watchSync.failedTransferCount > 0 ? DiveUI.yellow : DiveUI.cyan).opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke((watchSync.failedTransferCount > 0 ? DiveUI.yellow : DiveUI.cyan).opacity(0.65), lineWidth: 1)
                )
        )
    }

    private func gpsConfirmationBanner(_ confirmation: DiveGPSConfirmation) -> some View {
        HStack(spacing: 7) {
            Image(systemName: gpsConfirmationIcon(confirmation))
                .font(.system(size: 14, weight: .black))
            VStack(alignment: .leading, spacing: 1) {
                Text(gpsConfirmationTitle(confirmation))
                    .font(.system(size: 10, weight: .black, design: .rounded))
                Text(gpsConfirmationDetail(confirmation))
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.66)
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(gpsConfirmationColor(confirmation))
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(gpsConfirmationColor(confirmation).opacity(0.11))
                .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous).stroke(gpsConfirmationColor(confirmation).opacity(0.72), lineWidth: 1))
        )
    }

    private func gpsConfirmationIcon(_ confirmation: DiveGPSConfirmation) -> String {
        switch confirmation.presentation {
        case .fix: return "checkmark.circle.fill"
        case .fallback: return "location.fill.viewfinder"
        case .noFix: return "location.slash.fill"
        }
    }

    private func gpsConfirmationTitle(_ confirmation: DiveGPSConfirmation) -> String {
        let key: String
        switch (confirmation.isStart, confirmation.presentation) {
        case (true, .fix): key = "gps.banner.start.fix.title"
        case (true, .fallback): key = "gps.banner.start.fallback.title"
        case (true, .noFix): key = "gps.banner.start.nofix.title"
        case (false, .fix): key = "gps.banner.end.fix.title"
        case (false, .fallback): key = "gps.banner.end.fallback.title"
        case (false, .noFix): key = "gps.banner.end.nofix.title"
        }
        return String(localized: String.LocalizationValue(key))
    }

    private func gpsConfirmationDetail(_ confirmation: DiveGPSConfirmation) -> String {
        switch confirmation {
        case .start(let point, _), .end(let point, _):
            if let point {
                return String(format: String(localized: "gps.banner.coords"), point.latitude, point.longitude)
            }
            return String(localized: "gps.banner.unavailable")
        }
    }

    private func gpsConfirmationColor(_ confirmation: DiveGPSConfirmation) -> Color {
        switch confirmation.presentation {
        case .fix: return DiveUI.green
        case .fallback: return DiveUI.yellow
        case .noFix: return DiveUI.red
        }
    }

    private var depthStaleBanner: some View {
        DiveInlineStatusBanner(
            systemImage: "waveform.path.ecg.rectangle",
            title: String(localized: "live.depth.stale.title"),
            detail: dive.depthDataUsesLastKnownReading
                ? String(localized: "live.depth.stale.last_known")
                : String(localized: "live.depth.stale.body"),
            color: DiveUI.yellow
        )
    }

    private var manualNoDepthBanner: some View {
        DiveInlineStatusBanner(
            systemImage: "hand.tap.fill",
            title: String(localized: "live.manual.nodepth.title"),
            detail: String(localized: "live.manual.nodepth.body"),
            color: DiveUI.cyan
        )
    }

    private func activeDiveContent(leftWidth: CGFloat, gaugeWidth: CGFloat) -> some View {
        ScrollView {
            VStack(spacing: activeDiveSpacing) {
                topBar
                immersionStatus
                if dive.isDepthAutomationAvailable && !dive.isManualLifecycleActive {
                    Text(String(localized: "live.auto_dive.active.hint"))
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(DiveUI.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if !hapticsEnabled {
                    hapticsOffBadge
                }
                ttvRuntimePanel
                    .layoutPriority(2)
                if showAscentAlarmBanner {
                    AscentWarningBannerView(
                        rateMetersPerMinute: dive.ascentStatus.currentRateMetersPerMinute,
                        isActive: true,
                        units: unitPreference
                    )
                    .transition(activeDiveTransition)
                }
                if dive.isDepthDataStale {
                    depthStaleBanner
                        .transition(activeDiveTransition)
                } else if dive.isManualNoDepthSession {
                    manualNoDepthBanner
                        .transition(activeDiveTransition)
                }
                if depthSafetyState != .normal {
                    DepthSafetyBannerView(state: depthSafetyState)
                        .transition(activeDiveTransition)
                }
                if dive.exceededSupportedDepthRange {
                    Text(String(localized: "depth.safety.exceeded.readings"))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(DiveUI.red)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                depthSection(leftWidth: leftWidth, gaugeWidth: gaugeWidth)
                    .layoutPriority(2)
                stopwatchPanel
                controls
                    .layoutPriority(1)
            }
        }
        .scrollIndicators(.hidden)
        .animation(missionModeProfile.animationsEnabled ? .easeInOut(duration: 0.3) : nil, value: showAscentAlarmBanner)
        .animation(missionModeProfile.animationsEnabled ? .easeInOut(duration: 0.22) : nil, value: depthSafetyState)
    }

    private var activeBannerCount: Int {
        var count = 0
        if showAscentAlarmBanner { count += 1 }
        if dive.isDepthDataStale || dive.isManualNoDepthSession { count += 1 }
        if depthSafetyState != .normal { count += 1 }
        if dive.exceededSupportedDepthRange { count += 1 }
        if !hapticsEnabled { count += 1 }
        if dive.isDepthAutomationAvailable && !dive.isManualLifecycleActive { count += 1 }
        return count
    }

    private var activeDiveSpacing: CGFloat {
        switch activeBannerCount {
        case 0...1: return 7
        case 2...3: return 4
        default: return 3
        }
    }

    private var preDiveWaitingContent: some View {
        VStack(spacing: 0) {
            preDiveHeader

            if !hapticsEnabled {
                hapticsOffBadge
                    .padding(.top, 6)
            }

            Spacer(minLength: 28)

            Text(String(localized: "live.ready.title"))
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.blue)
                .multilineTextAlignment(.center)
                .lineSpacing(1)

            Spacer(minLength: 24)

            if dive.isDepthAutomationAvailable {
                autoDiveStatusPanel
                Spacer(minLength: 16)
                surfaceManualStartPanel
                Spacer(minLength: 8)
            } else {
                HStack(spacing: 9) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 25, weight: .black))
                        .foregroundStyle(DiveUI.blue)
                        .symbolRenderingMode(.hierarchical)
                    Text(String(localized: "live.waiting.start"))
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 9)

                Spacer(minLength: 20)

                Text(String(localized: "live.gps.start.hint"))
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                Spacer(minLength: 16)

                manualFallbackPanel
                Spacer(minLength: 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var preDiveHeader: some View {
        HStack(alignment: .center) {
            HStack(spacing: 5) {
                DiveOctopusLogo(accent: DiveUI.yellow)
                    .frame(width: 23, height: 22, alignment: .leading)
                    .scaleEffect(0.68)
                Text("DIR DIVING")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .lineLimit(1)
            }

            Spacer()

            DiveClockText(size: 14)
        }
    }

    private var missionModeLiveToggle: some View {
        Button {
            if dive.isMissionModeActive {
                dive.disableMissionModeManually()
            } else {
                dive.enableMissionModeManually()
            }
        } label: {
            MissionModeIndicatorView(isActive: dive.isMissionModeActive)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
    }

    private var topBar: some View {
        HStack(alignment: .center) {
            HStack(spacing: 5) {
                DiveOctopusLogo(accent: DiveUI.blue)
                    .frame(width: 29, height: 26, alignment: .leading)
                    .scaleEffect(0.8)
                    .overlay(alignment: .topTrailing) {
                        if showsMissionModeControl {
                            missionModeLiveToggle
                                .offset(x: 2, y: -1)
                        }
                    }
                Text("DIR DIVING")
                    .font(DiveUI.Typography.brandTitle)
                    .foregroundStyle(DiveUI.yellow)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                DiveClockText(size: 20)
                HStack(spacing: 3) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text(temperatureText)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }
                .foregroundStyle(DiveUI.blue)
            }
        }
    }

    private var autoDiveStatusPanel: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(DiveUI.cyan)
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "live.auto_dive.waiting.title"))
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.cyan)
                    Text(String(localized: "live.auto_dive.waiting.subtitle"))
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(DiveUI.cyan.opacity(0.12))
                    .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous).stroke(DiveUI.cyan.opacity(0.55), lineWidth: 1))
            )

            Text(String(localized: "live.gps.start.hint"))
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(DiveUI.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .padding(.horizontal, 4)
    }

    private var surfaceManualStartPanel: some View {
        VStack(spacing: 8) {
            Text(String(localized: "live.manual_start.title"))
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.yellow)
                .multilineTextAlignment(.center)
            Text(String(localized: "live.manual_start.body"))
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            DiveCommandButton(String(localized: "live.manual.start.button"), systemImage: "play.circle.fill", color: DiveUI.green) {
                dive.startManualDive()
            }
        }
        .padding(9)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(DiveUI.yellow.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(DiveUI.yellow.opacity(0.7), lineWidth: 1)
                )
        )
    }

    private var immersionStatus: some View {
        HStack(spacing: 8) {
            Image(systemName: "water.waves")
                .font(.system(size: 18, weight: .black))
            Text(dive.isManualLifecycleActive ? String(localized: "live.status.manual_dive") : String(localized: "live.status.in_dive"))
                .font(DiveUI.Typography.statusTitle)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
        }
        .foregroundStyle(DiveUI.green)
    }

    private var hapticsOffBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "bell.slash.fill")
                .font(.system(size: 12, weight: .black))
            Text(String(localized: "live.haptics.off"))
                .font(.system(size: 10, weight: .black, design: .rounded))
            Spacer(minLength: 0)
            Text(String(localized: "live.haptics.visual_only"))
                .font(.system(size: 9, weight: .black, design: .rounded))
        }
        .foregroundStyle(DiveUI.yellow)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(DiveUI.yellow.opacity(0.10))
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(DiveUI.yellow.opacity(0.55), lineWidth: 1))
        )
    }

    private var ttvRuntimePanel: some View {
        HStack(spacing: 0) {
            dashboardValue(title: "TTV", value: ttvText, unit: nil, color: DiveUI.green)
            Rectangle()
                .fill(.white.opacity(0.34))
                .frame(width: 1, height: 54)
            dashboardValue(title: "RunTime", value: runtimeMinutes, unit: "min", color: .white)
        }
        .frame(maxWidth: .infinity, minHeight: 70)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.42))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(DiveUI.green.opacity(0.86), lineWidth: 1.4)
                )
                .shadow(
                    color: missionModeProfile.decorativeEffectsEnabled ? DiveUI.green.opacity(0.16) : .clear,
                    radius: missionModeProfile.decorativeEffectsEnabled ? 5 : 0,
                    x: 0,
                    y: 0
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("TTV sessione \(ttvText), runtime \(runtimeMinutes)")
        .accessibilityHint(String(localized: "TTV informativo derivato da profondita media e durata; non e un valore decompressivo o time to surface."))
    }

    private func dashboardValue(title: String, value: String, unit: String?, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(DiveUI.Typography.dashboardLabel)
                .foregroundStyle(.white)
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(DiveUI.Typography.dashboardValue)
                    .minimumScaleFactor(0.54)
                    .lineLimit(1)
                    .monospacedDigit()
                    .foregroundStyle(color)
                if let unit {
                    Text(unit)
                        .font(DiveUI.Typography.dashboardUnit)
                        .foregroundStyle(color)
                        .padding(.bottom, 5)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func depthSection(leftWidth: CGFloat, gaugeWidth: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 7) {
                depthReadout
                depthSummary
            }
            .frame(width: leftWidth, alignment: .leading)

            AscentGaugeView(status: dive.ascentStatus, units: unitPreference)
                .frame(width: gaugeWidth, height: 154)
        }
        .frame(maxWidth: .infinity)
    }

    private var depthReadout: some View {
        let style = depthReadoutStyle
        let depthDisplay = WatchDepthFormatting.display(meters: dive.currentDepthMeters, units: unitPreference)
        let depthOpacity = dive.isDepthDataStale ? 0.72 : 1.0
        return VStack(spacing: 0) {
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(depthDisplay.valueText)
                    .font(DiveUI.Typography.metricValueHero)
                    .minimumScaleFactor(0.42)
                    .lineLimit(1)
                    .monospacedDigit()
                    .foregroundStyle(style.depthColor)
                    .opacity(depthOpacity)
                    .shadow(
                        color: missionModeProfile.decorativeEffectsEnabled ? style.depthShadow : .clear,
                        radius: missionModeProfile.decorativeEffectsEnabled ? 8 : 0,
                        x: 0,
                        y: 0
                    )
                    .layoutPriority(1)
                Text(depthDisplay.unitLabel)
                    .font(DiveUI.Typography.metricUnitHero)
                    .foregroundStyle(style.labelColor)
                    .opacity(depthOpacity)
                    .padding(.bottom, 9)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(String(localized: "live.depth.a11y"))
            .accessibilityValue("\(depthDisplay.valueText) \(depthDisplay.unitLabel)")

            Text(dive.isDepthDataStale ? String(localized: "live.depth.stale.label") : String(localized: "live.depth.current.label"))
                .font(DiveUI.Typography.depthCaption)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
                .foregroundStyle(dive.isDepthDataStale ? DiveUI.yellow : style.labelColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(depthSafetyState == .normal ? Color.clear : Color.black.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(style.panelStroke, lineWidth: depthSafetyState == .normal ? 0 : 1.2)
                )
        )
    }

    private var depthSummary: some View {
        Group {
            if depthSafetyState.suppressesPositiveDepthReinforcement {
                EmptyView()
            } else {
                HStack(spacing: 7) {
                    depthCard(title: "PROF. MASSIMA", value: dive.maxDepthMeters, emphasize: false)
                    depthCard(title: "PROF. MEDIA", value: dive.averageDepthMeters, emphasize: false)
                }
            }
        }
    }

    private func depthCard(title: String, value: Double, emphasize: Bool) -> some View {
        let depthDisplay = WatchDepthFormatting.display(meters: value, units: unitPreference)
        return VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(emphasize ? DiveUI.yellow : DiveUI.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(depthDisplay.valueText)
                    .font(.system(size: 25, weight: .black, design: .rounded))
                    .foregroundStyle(emphasize ? DiveUI.yellow : DiveUI.blue)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
                Text(depthDisplay.unitLabel)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.blue)
                    .padding(.bottom, 2)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue("\(depthDisplay.valueText) \(depthDisplay.unitLabel)")
        .frame(maxWidth: .infinity, minHeight: 55)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.black.opacity(0.45))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(0.34), lineWidth: 1.1)
                )
        )
    }

    private var stopwatchPanel: some View {
        HStack(spacing: 15) {
            Image(systemName: "stopwatch")
                .font(.system(size: 35, weight: .black))
                .foregroundStyle(DiveUI.yellow)

            VStack(spacing: 0) {
                Text(Formatters.time(dive.stopwatchTime))
                    .font(.system(size: 39, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.66)
                Text(String(localized: "live.stopwatch.title"))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, minHeight: 63)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.black.opacity(0.44))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(DiveUI.yellow.opacity(0.9), lineWidth: 1.4)
                )
                .shadow(
                    color: missionModeProfile.decorativeEffectsEnabled ? DiveUI.yellow.opacity(0.16) : .clear,
                    radius: missionModeProfile.decorativeEffectsEnabled ? 5 : 0,
                    x: 0,
                    y: 0
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "live.stopwatch.a11y"))
        .accessibilityValue(Formatters.time(dive.stopwatchTime))
    }

    private var controls: some View {
        VStack(spacing: 7) {
            HStack(spacing: 7) {
                DiveCommandButton("START", systemImage: "play.fill", color: DiveUI.green) {
                    dive.startStopwatch()
                }
                .accessibilityLabel(String(localized: "live.stopwatch.start.a11y"))
                DiveCommandButton("STOP", systemImage: "stop.fill", color: DiveUI.red) {
                    dive.stopStopwatch()
                }
                .accessibilityLabel(String(localized: "live.stopwatch.stop.a11y"))
                DiveCommandButton("RESET", systemImage: "arrow.clockwise", color: .white.opacity(0.78)) {
                    if dive.stopwatchTime > 0 {
                        showResetStopwatchConfirmation = true
                    } else {
                        dive.resetStopwatch()
                    }
                }
                .accessibilityLabel(String(localized: "live.stopwatch.reset.a11y"))
                .accessibilityHint(String(localized: "live.stopwatch.reset.hint"))
            }
            if dive.isManualLifecycleActive {
                DiveCommandButton(String(localized: "live.manual.end.button"), systemImage: "stop.circle.fill", color: DiveUI.red) {
                    dive.endManualDive()
                }
            }
        }
    }

    private var manualFallbackPanel: some View {
        VStack(spacing: 8) {
            Text(String(localized: "live.depth.automation.unavailable.title"))
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.yellow)
                .multilineTextAlignment(.center)
            Text(String(localized: "live.depth.automation.unavailable.body"))
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Text(String(localized: "live.depth.automation.limited"))
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(DiveUI.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            DiveCommandButton(String(localized: "live.manual.start.button"), systemImage: "play.circle.fill", color: DiveUI.green) {
                dive.startManualDive()
            }
        }
        .padding(9)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(DiveUI.yellow.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(DiveUI.yellow.opacity(0.7), lineWidth: 1)
                )
        )
    }

    private func warningBanner(_ message: String, showAcknowledge: Bool, acknowledge: @escaping () -> Void) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
            if showAcknowledge {
                Button(String(localized: "alarm.acknowledge"), action: acknowledge)
                    .font(.caption2.bold())
                    .foregroundStyle(DiveUI.cyan)
            }
        }
        .font(.caption2.bold())
        .foregroundStyle(DiveUI.yellow)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(DiveUI.yellow.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(DiveUI.yellow.opacity(0.7), lineWidth: 1)
                )
        )
    }

    private var temperatureText: String {
        guard let temp = dive.currentTemperatureCelsius else {
            return "--.- \(unitPreference.temperatureUnitLabel)"
        }
        let display = unitPreference.temperatureDisplay(celsius: temp)
        return "\(Formatters.one(display.value)) \(display.unit)"
    }

    private var ttvText: String {
        Formatters.one(dive.ttv).replacingOccurrences(of: ".", with: ",")
    }

    private var runtimeMinutes: String {
        Formatters.time(dive.runtime)
    }
}
