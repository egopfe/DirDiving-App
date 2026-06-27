import SwiftUI

struct DivingModeSelectionView: View {
    @EnvironmentObject private var activitySelection: DIRActivitySelectionStore

    private var capabilityPolicy: DepthCapabilityPolicy {
        DepthCapabilityPolicy.current
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DiveUI.spaceL) {
                DiveScreenHeader(
                    String(localized: "startup.diving_mode.title"),
                    subtitle: nil,
                    accent: DiveUI.cyan,
                    systemImage: "water.waves"
                )

                divingModeRow(
                    mode: .gauge,
                    title: String(localized: "startup.diving_mode.gauge.title"),
                    subtitle: gaugeSubtitle,
                    accent: DiveUI.cyan,
                    symbol: "gauge.with.dots.needle.67percent",
                    disabled: !capabilityPolicy.supportsDivingGaugeRuntime,
                    disabledReason: capabilityPolicy.gaugeDisabledReason
                )

                divingModeRow(
                    mode: .fullComputer,
                    title: String(localized: "startup.diving_mode.full_computer.title"),
                    subtitle: fullComputerSubtitle,
                    accent: DiveUI.green,
                    symbol: "applewatch",
                    disabled: !capabilityPolicy.supportsFullComputerRuntime,
                    disabledReason: capabilityPolicy.fullComputerDisabledReason
                )

                Text(String(localized: "startup.diving_mode.footer"))
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(DiveUI.mutedText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            .padding(.horizontal, DiveUI.screenPadding)
            .padding(.vertical, 10)
        }
    }

    private var gaugeSubtitle: String {
        if capabilityPolicy.supportsDivingGaugeRuntime {
            return String(localized: "startup.diving_mode.gauge.subtitle")
        }
        return capabilityPolicy.gaugeDisabledReason ?? String(localized: "startup.diving_mode.gauge.subtitle")
    }

    private var fullComputerSubtitle: String {
        if capabilityPolicy.supportsFullComputerRuntime {
            return String(localized: "startup.diving_mode.full_computer.subtitle")
        }
        return capabilityPolicy.fullComputerDisabledReason ?? String(localized: "startup.diving_mode.full_computer.subtitle")
    }

    private func divingModeRow(
        mode: DIRDivingMode,
        title: String,
        subtitle: String,
        accent: Color,
        symbol: String,
        disabled: Bool,
        disabledReason: String?
    ) -> some View {
        Button {
            guard !disabled else { return }
            HapticService.shared.confirm()
            activitySelection.selectDivingMode(mode)
        } label: {
            DivePanel(stroke: disabled ? DiveUI.mutedText : accent) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(accent.opacity(disabled ? 0.06 : 0.14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(accent.opacity(disabled ? 0.35 : 0.85), lineWidth: 1)
                            )
                        Image(systemName: symbol)
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(disabled ? DiveUI.mutedText : accent)
                    }
                    .frame(width: 48, height: 48)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(DiveUI.Typography.rowTitle)
                            .foregroundStyle(disabled ? DiveUI.mutedText : .white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                        Text(subtitle)
                            .font(DiveUI.Typography.hintCaption)
                            .foregroundStyle(disabled ? DiveUI.mutedText : DiveUI.cyan)
                            .lineLimit(3)
                            .minimumScaleFactor(0.72)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: disabled ? "lock.fill" : "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(disabled ? DiveUI.mutedText : accent)
                }
                .frame(minHeight: 56)
            }
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .accessibilityLabel(title)
        .accessibilityValue(subtitle)
        .accessibilityHint(disabled ? (disabledReason ?? subtitle) : accessibilityHint(for: mode))
    }

    private func accessibilityHint(for mode: DIRDivingMode) -> String {
        switch mode {
        case .gauge:
            return String(localized: "startup.diving_mode.gauge.a11y")
        case .fullComputer:
            return String(localized: "startup.diving_mode.full_computer.a11y")
        }
    }
}
