import SwiftUI

enum FullComputerLivePanelStyle {
    static func accentColor(_ accent: FullComputerNDLAccent?) -> Color {
        switch accent {
        case .green, .none: return DiveUI.green
        case .yellow: return DiveUI.yellow
        case .red: return DiveUI.red
        }
    }

    static func stopPanelColor(_ accent: FullComputerDecoStopPanelAccent) -> Color {
        switch accent {
        case .green: return DiveUI.green
        case .yellow: return DiveUI.yellow
        case .orange: return DiveUI.orange
        case .red: return DiveUI.red
        }
    }

    static func immersionColor(_ accent: FullComputerImmersionAccent) -> Color {
        switch accent {
        case .diving: return DiveUI.green
        case .decompression: return DiveUI.green
        case .ceilingViolation: return DiveUI.red
        }
    }

    static func panelStroke(_ presentation: FullComputerDecoPresentation) -> Color {
        switch presentation.mode {
        case .noDecompression:
            return accentColor(presentation.ndlAccent)
        case .decompression:
            if presentation.ceilingViolation { return DiveUI.red }
            if presentation.stopState == .decoCompleted { return DiveUI.green }
            return stopPanelColor(presentation.stopPanelAccent)
        }
    }
}

struct FullComputerActiveGasBadge: View {
    let gasLabel: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "aqi.medium")
                .font(.system(size: 11, weight: .black))
            Text(gasLabel)
                .font(DiveUI.Typography.secondaryLabel)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(DiveUI.cyan)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule(style: .continuous)
                .fill(DiveUI.cyan.opacity(0.12))
                .overlay(Capsule(style: .continuous).stroke(DiveUI.cyan.opacity(0.55), lineWidth: 1))
        )
        .accessibilityLabel(String(format: String(localized: "live.fc.gas.a11y"), gasLabel))
    }
}

struct FullComputerTopMetricsPanel: View {
    let presentation: FullComputerDecoPresentation

    var body: some View {
        Group {
            switch presentation.mode {
            case .noDecompression:
                noDecoPanel
            case .decompression:
                decoPanel
            }
        }
        .frame(maxWidth: .infinity, minHeight: 70)
        .background(panelBackground)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
    }

    private var noDecoPanel: some View {
        HStack(spacing: 0) {
            metricColumn(
                title: String(localized: "live.fc.metric.ndl"),
                value: ndlValueText,
                unit: "min",
                valueColor: FullComputerLivePanelStyle.accentColor(presentation.ndlAccent),
                footer: String(localized: "live.fc.metric.ndl.footer")
            )
            divider
            metricColumn(
                title: String(localized: "live.metric.runtime"),
                value: "\(presentation.runtimeMinutes)",
                unit: "min",
                valueColor: .white,
                footer: nil
            )
        }
    }

    private var decoPanel: some View {
        HStack(spacing: 0) {
            metricColumn(
                title: String(localized: "live.fc.metric.tts"),
                value: "\(presentation.ttsMinutes)",
                unit: "min",
                valueColor: presentation.ceilingViolation ? DiveUI.red : .white,
                footer: String(localized: "live.fc.metric.tts.footer")
            )
            divider
            metricColumn(
                title: String(localized: "live.fc.metric.ceiling"),
                value: ceilingValueText,
                unit: "m",
                valueColor: presentation.stopState == .decoCompleted ? DiveUI.green : DiveUI.blue,
                footer: presentation.stopState == .decoCompleted
                    ? String(localized: "live.fc.metric.ceiling.completed.footer")
                    : nil
            )
            divider
            metricColumn(
                title: String(localized: "live.metric.runtime"),
                value: "\(presentation.runtimeMinutes)",
                unit: "min",
                valueColor: .white,
                footer: nil
            )
        }
    }

    private var ndlValueText: String {
        guard let ndl = presentation.ndlDisplayMinutes else { return "—" }
        return "\(ndl)"
    }

    private var ceilingValueText: String {
        Formatters.one(presentation.ceilingMetersRounded)
    }

    private var divider: some View {
        Rectangle()
            .fill(.white.opacity(0.34))
            .frame(width: 1, height: 54)
    }

    private func metricColumn(
        title: String,
        value: String,
        unit: String?,
        valueColor: Color,
        footer: String?
    ) -> some View {
        VStack(spacing: 3) {
            Text(title)
                .font(DiveUI.Typography.dashboardLabel)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(DiveUI.Typography.dashboardValue)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .monospacedDigit()
                    .foregroundStyle(valueColor)
                if let unit {
                    Text(unit)
                        .font(DiveUI.Typography.dashboardUnit)
                        .foregroundStyle(valueColor)
                        .padding(.bottom, 4)
                }
            }
            if let footer {
                Text(footer)
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(DiveUI.secondaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }

    private var panelBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.black.opacity(0.42))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(FullComputerLivePanelStyle.panelStroke(presentation).opacity(0.86), lineWidth: 1.4)
            )
    }

    private var accessibilitySummary: String {
        switch presentation.mode {
        case .noDecompression:
            return String(
                format: String(localized: "live.fc.a11y.ndl_runtime"),
                ndlValueText,
                presentation.runtimeMinutes
            )
        case .decompression:
            return String(
                format: String(localized: "live.fc.a11y.tts_ceiling_runtime"),
                presentation.ttsMinutes,
                ceilingValueText,
                presentation.runtimeMinutes
            )
        }
    }
}

struct FullComputerDecoStopStatePanel: View {
    let presentation: FullComputerDecoPresentation
    let units: DIRUnitPreference

    private var accent: Color {
        FullComputerLivePanelStyle.stopPanelColor(presentation.stopPanelAccent)
    }

    var body: some View {
        VStack(spacing: 8) {
            if !presentation.stopPanelTitleKey.isEmpty {
                Text(String(localized: String.LocalizationValue(presentation.stopPanelTitleKey)))
                    .font(DiveUI.Typography.warningTitle)
                    .foregroundStyle(accent)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
            }

            if presentation.stopState == .decoCompleted {
                completedBody
            } else {
                activeStopBody
            }

            bottomStatusRow
        }
        .padding(10)
        .background(panelBackground)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var completedBody: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(DiveUI.green)
            if let instructionKey = presentation.stopInstructionKey {
                Text(String(localized: String.LocalizationValue(instructionKey)))
                    .font(DiveUI.Typography.warningBody)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var activeStopBody: some View {
        VStack(spacing: 6) {
            HStack(alignment: .center, spacing: 8) {
                directionalIndicator
                    .frame(width: 34)
                if let depth = presentation.nextStopDepthMeters {
                    stopMetric(
                        title: String(localized: "live.fc.deco.stop_depth"),
                        value: depthDisplay(depth),
                        unit: units.depthUnitLabel
                    )
                }
                if let seconds = presentation.stopRemainingSeconds {
                    stopMetric(
                        title: String(localized: "live.fc.deco_stop.time"),
                        value: stopTimeText(seconds),
                        unit: "min"
                    )
                }
            }
            if let instructionKey = presentation.stopInstructionKey {
                instructionText(instructionKey)
            }
        }
    }

    @ViewBuilder
    private var directionalIndicator: some View {
        switch presentation.stopDirection {
        case .hold:
            HStack(spacing: 0) {
                Capsule()
                    .fill(accent)
                    .frame(width: 18, height: 4)
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(accent)
            }
        case .ascend:
            Image(systemName: "arrow.up")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(accent)
        case .descend:
            Image(systemName: "arrow.down")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(accent)
        case .none:
            Color.clear.frame(width: 22, height: 22)
        }
    }

    private func instructionText(_ key: String) -> some View {
        Text(instructionFormatted(key))
            .font(DiveUI.Typography.hintCaptionBold)
            .foregroundStyle(accent)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity)
    }

    private func instructionFormatted(_ key: String) -> String {
        guard let depth = presentation.nextStopDepthMeters else {
            return String(localized: String.LocalizationValue(key))
        }
        let depthText = depthDisplay(depth) + " " + units.depthUnitLabel
        return String(format: String(localized: String.LocalizationValue(key)), depthText)
    }

    private var bottomStatusRow: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "live.fc.deco_stop.remaining"))
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(.white)
                Text("\(presentation.remainingStopCount)")
                    .font(DiveUI.Typography.statusValue)
                    .foregroundStyle(
                        presentation.stopState == .decoCompleted ? DiveUI.green : accent
                    )
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(.white.opacity(0.34))
                .frame(width: 1, height: 34)

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(localized: "live.fc.deco_stop.ascent_allowed"))
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                Text(presentation.ascentAllowedBetweenStops
                    ? String(localized: "live.fc.deco_stop.yes")
                    : String(localized: "live.fc.deco_stop.no"))
                    .font(DiveUI.Typography.statusValue)
                    .foregroundStyle(presentation.ascentAllowedBetweenStops ? DiveUI.green : DiveUI.red)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.top, 4)
    }

    private func stopMetric(title: String, value: String, unit: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(DiveUI.Typography.secondaryLabel)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(unit)
                    .font(DiveUI.Typography.unitLabel)
                    .foregroundStyle(accent)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var panelBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.black.opacity(0.42))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(accent.opacity(0.86), lineWidth: 1.2)
            )
    }

    private func depthDisplay(_ meters: Double) -> String {
        WatchDepthFormatting.display(meters: meters, units: units).valueText
    }

    private func stopTimeText(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainder = seconds % 60
        return String(format: "%d:%02d", minutes, remainder)
    }

    private var accessibilitySummary: String {
        var parts: [String] = []
        if !presentation.stopPanelTitleKey.isEmpty {
            parts.append(String(localized: String.LocalizationValue(presentation.stopPanelTitleKey)))
        }
        if let depth = presentation.nextStopDepthMeters {
            parts.append(
                String(
                    format: String(localized: "live.fc.a11y.stop_depth"),
                    depthDisplay(depth),
                    units.depthUnitLabel
                )
            )
        }
        if let seconds = presentation.stopRemainingSeconds {
            parts.append(
                String(
                    format: String(localized: "live.fc.a11y.stop_time"),
                    stopTimeText(seconds)
                )
            )
        }
        switch presentation.stopDirection {
        case .ascend:
            parts.append(String(localized: "live.fc.a11y.direction.ascend"))
        case .descend:
            parts.append(String(localized: "live.fc.a11y.direction.descend"))
        case .hold:
            parts.append(String(localized: "live.fc.a11y.direction.hold"))
        case .none:
            break
        }
        return parts.joined(separator: ". ")
    }
}

struct FullComputerCeilingViolationBanner: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16, weight: .black))
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "live.fc.ceiling_violation.title"))
                    .font(DiveUI.Typography.bannerTitle)
                Text(String(localized: "live.fc.ceiling_violation.subtitle"))
                    .font(DiveUI.Typography.bannerSubtitle)
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(DiveUI.red)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(DiveUI.red.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(DiveUI.red.opacity(0.72), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(localized: "live.fc.ceiling_violation.a11y"))
    }
}
