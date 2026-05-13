import SwiftUI

struct ModeSelectionView: View {
    @EnvironmentObject private var exploration: ExplorationStore
    @EnvironmentObject private var navigation: AppNavigationStore

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                header
                ForEach(DIRActivityMode.allCases) { mode in
                    modeCard(mode)
                }
                DivePanel(stroke: DiveUI.yellow) {
                    Text("Seleziona modalita prima di entrare in acqua. Pairing, waypoint e warning vanno preparati in superficie.")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(DiveUI.yellow)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
        }
        .background(Color.black)
    }

    private var header: some View {
        VStack(spacing: 6) {
            HStack {
                DiveOctopusLogo()
                Spacer()
                Text("PRE-DIVE")
                    .font(.caption.bold())
                    .foregroundStyle(DiveUI.green)
            }
            Text("DIR DIVING")
                .font(.headline.bold())
                .foregroundStyle(.white)
            Text("Crown-first underwater workflow")
                .font(.caption2)
                .foregroundStyle(DiveUI.secondaryText)
        }
    }

    private func modeCard(_ mode: DIRActivityMode) -> some View {
        DivePanel(stroke: exploration.selectedMode == mode ? mode.accent : DiveUI.subtleStroke) {
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
                HStack(spacing: 10) {
                    Image(systemName: mode.symbol)
                        .font(.title3.bold())
                        .foregroundStyle(mode.accent)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(mode.rawValue)
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                        Text(modeDescription(mode))
                            .font(.caption2)
                            .foregroundStyle(DiveUI.secondaryText)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(mode.accent)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func modeDescription(_ mode: DIRActivityMode) -> String {
        switch mode {
        case .diving: return "Dive computer premium"
        case .apnea: return "Timer, recovery, depth warnings"
        case .snorkeling: return "GPS route, waypoint, return-to-entry"
        }
    }
}
