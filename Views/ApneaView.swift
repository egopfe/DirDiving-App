import SwiftUI

struct ApneaView: View {
    @EnvironmentObject private var exploration: ExplorationStore
    @EnvironmentObject private var dive: DiveManager
    @AppStorage(HapticService.hapticsEnabledKey) private var hapticsEnabled = true

    private var input: ApneaWatchPresentationInput {
        ApneaWatchPresentationInput(
            isSessionStarted: exploration.apneaState != .idle,
            currentDepthMeters: dive.currentDepthMeters,
            maxDepthMeters: dive.maxDepthMeters,
            temperatureCelsius: dive.currentTemperatureCelsius,
            diveElapsedSeconds: exploration.currentApneaSeconds,
            diveCount: exploration.apneaCount,
            verticalSpeedMetersPerSecond: dive.ascentStatus.currentRateMetersPerMinute / 60,
            targetDepthMeters: 25,
            recoveryPolicyLabel: "1:1",
            activeAlarmCount: 1,
            buddyReminderEnabled: true,
            sensorDegraded: dive.isDepthDataStale,
            hapticsEnabled: hapticsEnabled,
            missionModeEnabled: dive.isMissionModeActive,
            markerIndicatorActive: false,
            targetIndicatorActive: false
        )
    }

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
        }
        .dynamicTypeSize(.xSmall ... .accessibility2)
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
                metricRow(label: String(localized: "apnea.ready.sensor"), value: ui.sensorLabel, valueColor: input.sensorDegraded ? DiveUI.red : DiveUI.green)
                metricRow(label: String(localized: "apnea.ready.buddy"), value: input.buddyReminderEnabled ? String(localized: "apnea.buddy.on") : String(localized: "apnea.buddy.off"), valueColor: DiveUI.yellow)

                DiveCommandButton(String(localized: "apnea.ready.start"), systemImage: "play.fill", color: ui.startEnabled ? DiveUI.green : DiveUI.red) {
                    if ui.startEnabled {
                        exploration.startApneaSession()
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
            badge(systemImage: "bolt.fill", text: ui.missionLabel, color: dive.isMissionModeActive ? DiveUI.cyan : DiveUI.secondaryText)
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

    private var temperatureText: String {
        guard let temperatureCelsius = input.temperatureCelsius else { return "--.-°C" }
        return "\(Formatters.one(temperatureCelsius))°C"
    }

    private var ascentColor: Color {
        abs(input.verticalSpeedMetersPerSecond) > 1.5 ? DiveUI.yellow : DiveUI.blue
    }
}
