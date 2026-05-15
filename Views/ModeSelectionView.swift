import SwiftUI

struct ModeSelectionView: View {
    @EnvironmentObject private var exploration: ExplorationStore
    @EnvironmentObject private var navigation: AppNavigationStore

    var body: some View {
        ZStack {
            DiveScreenBackground()

            ScrollView {
                VStack(spacing: 11) {
                    DiveScreenHeader(
                        "DIR DIVING",
                        subtitle: "PRE-DIVE MODE SELECTOR",
                        accent: DiveUI.cyan,
                        systemImage: "water.waves"
                    )

                    selectorHero

                    ForEach(DIRActivityMode.allCases) { mode in
                        modeCard(mode)
                    }

                    DivePanel(stroke: DiveUI.yellow) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption.bold())
                            Text("Seleziona modalita prima di entrare in acqua. Pairing, waypoint e warning vanno preparati in superficie.")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .foregroundStyle(DiveUI.yellow)
                    }
                }
                .padding(.horizontal, DiveUI.screenPadding)
                .padding(.vertical, 10)
            }
        }
    }

    private var selectorHero: some View {
        DivePanel(stroke: exploration.selectedMode.accent) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(exploration.selectedMode.accent.opacity(0.14))
                    Circle()
                        .stroke(exploration.selectedMode.accent.opacity(0.8), lineWidth: 1)
                    Image(systemName: exploration.selectedMode.symbol)
                        .font(.system(size: 27, weight: .black))
                        .foregroundStyle(exploration.selectedMode.accent)
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 4) {
                    Text(exploration.selectedMode.rawValue.uppercased())
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Text(modeDescription(exploration.selectedMode))
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(DiveUI.secondaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                    DiveStatusPill("ACTIVE", color: exploration.selectedMode.accent, systemImage: "checkmark.circle.fill")
                }

                Spacer(minLength: 0)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: exploration.selectedMode)
    }

    private func modeCard(_ mode: DIRActivityMode) -> some View {
        let isSelected = exploration.selectedMode == mode

        return Button {
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
            DivePanel(stroke: isSelected ? mode.accent : DiveUI.hairline) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(mode.accent.opacity(isSelected ? 0.18 : 0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(mode.accent.opacity(isSelected ? 0.9 : 0.45), lineWidth: 1)
                            )
                        Image(systemName: mode.symbol)
                            .font(.system(size: 21, weight: .black))
                            .foregroundStyle(mode.accent)
                    }
                    .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(mode.rawValue)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Text(modeDescription(mode))
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(DiveUI.secondaryText)
                            .lineLimit(2)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(mode.accent)
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.015 : 1)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }

    private func modeDescription(_ mode: DIRActivityMode) -> String {
        switch mode {
        case .diving: return "Dive computer premium"
        case .apnea: return "Timer, recovery, depth warnings"
        case .snorkeling: return "GPS route, waypoint, return-to-entry"
        }
    }
}
