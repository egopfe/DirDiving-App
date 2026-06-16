import SwiftUI

struct DivingModeSelectionView: View {
    @EnvironmentObject private var activitySelection: DIRActivitySelectionStore

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
                    subtitle: String(localized: "startup.diving_mode.gauge.subtitle"),
                    accent: DiveUI.cyan,
                    symbol: "gauge.with.dots.needle.67percent"
                )

                divingModeRow(
                    mode: .fullComputer,
                    title: String(localized: "startup.diving_mode.full_computer.title"),
                    subtitle: String(localized: "startup.diving_mode.full_computer.subtitle"),
                    accent: DiveUI.green,
                    symbol: "applewatch"
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

    private func divingModeRow(
        mode: DIRDivingMode,
        title: String,
        subtitle: String,
        accent: Color,
        symbol: String
    ) -> some View {
        Button {
            HapticService.shared.confirm()
            activitySelection.selectDivingMode(mode)
        } label: {
            DivePanel(stroke: accent) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(accent.opacity(0.14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(accent.opacity(0.85), lineWidth: 1)
                            )
                        Image(systemName: symbol)
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(accent)
                    }
                    .frame(width: 48, height: 48)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(DiveUI.Typography.rowTitle)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                        Text(subtitle)
                            .font(DiveUI.Typography.hintCaption)
                            .foregroundStyle(DiveUI.cyan)
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(accent)
                }
                .frame(minHeight: 56)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityValue(subtitle)
        .accessibilityHint(accessibilityHint(for: mode))
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
