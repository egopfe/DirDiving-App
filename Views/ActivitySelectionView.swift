import SwiftUI

struct ActivitySelectionView: View {
    @EnvironmentObject private var activitySelection: DIRActivitySelectionStore

    private let modes: [DIRActivityMode] = [.diving, .apnea, .snorkeling]

    var body: some View {
        ScrollView {
            VStack(spacing: DiveUI.spaceL) {
                DiveScreenHeader(
                    String(localized: "startup.activity.title"),
                    subtitle: nil,
                    accent: DiveUI.cyan,
                    systemImage: "figure.water.fitness"
                )

                ForEach(modes) { mode in
                    activityRow(mode)
                }

                Text(String(localized: "startup.activity.footer"))
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(DiveUI.mutedText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            .padding(.horizontal, DiveUI.screenPadding)
            .padding(.vertical, 10)
        }
    }

    private func activityRow(_ mode: DIRActivityMode) -> some View {
        Button {
            HapticService.shared.confirm()
            activitySelection.selectActivity(mode)
        } label: {
            DivePanel(stroke: accent(for: mode)) {
                HStack(spacing: 10) {
                    modeIcon(mode)
                        .frame(width: 44, height: 44)

                    Text(localizedTitle(for: mode))
                        .font(DiveUI.Typography.rowTitle)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(accent(for: mode))
                }
                .frame(minHeight: DiveUI.Layout.settingsRowInteractiveMinHeight)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(localizedTitle(for: mode))
        .accessibilityHint(accessibilityHint(for: mode))
    }

    @ViewBuilder
    private func modeIcon(_ mode: DIRActivityMode) -> some View {
        let color = accent(for: mode)
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(color.opacity(0.16))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(color.opacity(0.85), lineWidth: 1)
                )
            Image(systemName: symbol(for: mode))
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(color)
        }
    }

    private func accent(for mode: DIRActivityMode) -> Color {
        switch mode {
        case .diving: return DiveUI.green
        case .apnea: return DiveUI.cyan
        case .snorkeling: return DiveUI.cyan
        }
    }

    private func symbol(for mode: DIRActivityMode) -> String {
        switch mode {
        case .diving: return "lungs.fill"
        case .apnea: return "figure.pool.swim"
        case .snorkeling: return "water.waves"
        }
    }

    private func localizedTitle(for mode: DIRActivityMode) -> String {
        switch mode {
        case .diving: return String(localized: "startup.activity.diving")
        case .apnea: return String(localized: "startup.activity.apnea")
        case .snorkeling: return String(localized: "startup.activity.snorkeling")
        }
    }

    private func accessibilityHint(for mode: DIRActivityMode) -> String {
        switch mode {
        case .diving: return String(localized: "startup.activity.diving.hint")
        case .apnea: return String(localized: "startup.activity.apnea.hint")
        case .snorkeling: return String(localized: "startup.activity.snorkeling.hint")
        }
    }
}
