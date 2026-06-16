import SwiftUI

enum FullComputerLivePanelStyle {
    static func accentColor(_ accent: FullComputerNDLAccent?) -> Color {
        switch accent {
        case .green, .none: return DiveUI.green
        case .yellow: return DiveUI.yellow
        case .red: return DiveUI.red
        }
    }

    static func immersionColor(_ accent: FullComputerImmersionAccent) -> Color {
        switch accent {
        case .diving: return DiveUI.green
        case .decompression: return DiveUI.orange
        case .ceilingViolation: return DiveUI.red
        }
    }

    static func panelStroke(_ presentation: FullComputerDecoPresentation) -> Color {
        switch presentation.mode {
        case .noDecompression:
            return accentColor(presentation.ndlAccent)
        case .decompression:
            return presentation.ceilingViolation ? DiveUI.red : DiveUI.orange
        }
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
                valueColor: DiveUI.blue,
                footer: nil
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

struct FullComputerDecoStopPanel: View {
    let presentation: FullComputerDecoPresentation
    let units: DIRUnitPreference

    var body: some View {
        VStack(spacing: 8) {
            Text(String(localized: "live.fc.deco_stop.title"))
                .font(DiveUI.Typography.warningTitle)
                .foregroundStyle(DiveUI.yellow)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 8) {
                Image(systemName: "arrow.down.to.line")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(DiveUI.yellow)
                if let depth = presentation.nextStopDepthMeters {
                    stopMetric(
                        title: String(localized: "live.fc.deco_stop.depth"),
                        value: depthDisplay(depth),
                        unit: units.depthUnitLabel
                    )
                }
                if let minutes = presentation.nextStopMinutes {
                    stopMetric(
                        title: String(localized: "live.fc.deco_stop.time"),
                        value: stopTimeText(minutes),
                        unit: "min"
                    )
                }
            }

            HStack {
                Text(String(localized: "live.fc.deco_stop.remaining"))
                    .font(DiveUI.Typography.secondaryLabel)
                    .foregroundStyle(.white)
                Spacer()
                Text("\(presentation.remainingStopCount)")
                    .font(DiveUI.Typography.statusValue)
                    .foregroundStyle(DiveUI.orange)
            }

            HStack {
                Text(String(localized: "live.fc.deco_stop.ascent_allowed"))
                    .font(DiveUI.Typography.secondaryLabel)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Spacer()
                Text(presentation.ascentAllowedBetweenStops
                    ? String(localized: "live.fc.deco_stop.yes")
                    : String(localized: "live.fc.deco_stop.no"))
                    .font(DiveUI.Typography.statusValue)
                    .foregroundStyle(presentation.ascentAllowedBetweenStops ? DiveUI.green : DiveUI.red)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.42))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(DiveUI.yellow.opacity(0.86), lineWidth: 1.2)
                )
        )
        .accessibilityElement(children: .combine)
    }

    private func stopMetric(title: String, value: String, unit: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(DiveUI.Typography.secondaryLabel)
                .foregroundStyle(.white)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(DiveUI.yellow)
                Text(unit)
                    .font(DiveUI.Typography.unitLabel)
                    .foregroundStyle(DiveUI.yellow)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func depthDisplay(_ meters: Double) -> String {
        WatchDepthFormatting.display(meters: meters, units: units).valueText
    }

    private func stopTimeText(_ minutes: Int) -> String {
        String(format: "%d:%02d", minutes, 0)
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
