import SwiftUI

struct ModeSelectionView: View {
    @EnvironmentObject private var exploration: ExplorationStore
    @EnvironmentObject private var navigation: AppNavigationStore

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 8) {
                    header
                    apneaModeCard
                    modeCard(.diving)
                    modeCard(.snorkeling)
                    buddyCard
                    ascentLimitsCard
                    settingsCard
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 8) {
            DiveOctopusLogo(accent: DiveUI.blue)
                .frame(width: 38, height: 34)

            Text("DIR DIVING")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(DiveUI.yellow)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Spacer(minLength: 0)

            // TODO: Wire to a shared watch clock if one is introduced.
            Text("10:09")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
        .padding(.bottom, 6)
    }

    private var apneaModeCard: some View {
        Button {
            exploration.select(.apnea)
            navigation.selectedPage = .apnea
        } label: {
            modeRow(
                title: "Apnea",
                systemImage: DIRActivityMode.apnea.symbol,
                accent: DiveUI.blue,
                isHighlighted: true,
                isSelected: exploration.selectedMode == .apnea
            )
        }
        .buttonStyle(.plain)
    }

    private func modeCard(_ mode: DIRActivityMode) -> some View {
        Button {
            exploration.select(mode)
            switch mode {
            case .diving:
                navigation.selectedPage = .live
            case .apnea:
                navigation.selectedPage = .apnea
            case .snorkeling:
                navigation.selectedPage = .snorkeling
            }
        } label: {
            modeRow(
                title: mode.title,
                systemImage: mode.symbol,
                accent: mode == .diving ? DiveUI.blue : DiveUI.cyan,
                isHighlighted: false,
                isSelected: exploration.selectedMode == mode
            )
        }
        .buttonStyle(.plain)
    }

    private var settingsCard: some View {
        Button {
            navigation.selectedPage = .settings
        } label: {
            modeRow(
                title: "Impostazioni",
                systemImage: "gearshape",
                accent: DiveUI.secondaryText,
                isHighlighted: false,
                isSelected: false
            )
        }
        .buttonStyle(.plain)
    }

    private var ascentLimitsCard: some View {
        Button {
            navigation.selectedPage = .ascentSettings
        } label: {
            modeRow(
                title: "Limiti Risalita",
                systemImage: "arrow.up.right.circle",
                accent: DiveUI.blue,
                isHighlighted: false,
                isSelected: navigation.selectedPage == .ascentSettings
            )
        }
        .buttonStyle(.plain)
    }

    private var buddyCard: some View {
        Button {
            navigation.selectedPage = .buddyAssist
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                modeRow(
                    title: "Buddy Assist",
                    systemImage: "person.2.wave.2.fill",
                    accent: DiveUI.yellow,
                    isHighlighted: false,
                    isSelected: navigation.selectedPage == .buddyAssist
                )
                Text("Sperimentale pre-dive: pairing e messaggi preset, non safety certificata.")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 11)
            }
        }
        .buttonStyle(.plain)
    }

    private func modeRow(
        title: String,
        systemImage: String,
        accent: Color,
        isHighlighted: Bool,
        isSelected: Bool
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(accent.opacity(isHighlighted ? 0.26 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(accent.opacity(isHighlighted ? 0.85 : 0.42), lineWidth: isHighlighted ? 1.5 : 1)
                    )

                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(isHighlighted ? .white : accent)
            }
            .frame(width: 38, height: 38)

            Text(title)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .foregroundStyle(isHighlighted ? .white : DiveUI.secondaryText)

            Spacer(minLength: 0)

            if isSelected {
                Circle()
                    .fill(accent)
                    .frame(width: 7, height: 7)
                    .shadow(color: accent.opacity(0.65), radius: 4, x: 0, y: 0)
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            isHighlighted ? DiveUI.blue.opacity(0.22) : DiveUI.panelFillRaised.opacity(0.88),
                            DiveUI.panelFill.opacity(0.98)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isHighlighted ? DiveUI.blue.opacity(0.95) : DiveUI.hairline, lineWidth: isHighlighted ? 1.6 : 1)
                )
                .shadow(color: isHighlighted ? DiveUI.blue.opacity(0.25) : .clear, radius: 5, x: 0, y: 0)
        )
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
