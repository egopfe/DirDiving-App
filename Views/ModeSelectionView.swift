import SwiftUI

struct ModeSelectionView: View {
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

                    ForEach(stableModes) { mode in
                        modeCard(mode)
                    }

                    DivePanel(stroke: DiveUI.yellow) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption.bold())
                            Text("Modalita stabile: Diving. Le funzioni sperimentali restano isolate dai rami experimental.")
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
        DivePanel(stroke: DiveUI.cyan) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(DiveUI.cyan.opacity(0.14))
                    Circle()
                        .stroke(DiveUI.cyan.opacity(0.8), lineWidth: 1)
                    Image(systemName: "water.waves")
                        .font(.system(size: 27, weight: .black))
                        .foregroundStyle(DiveUI.cyan)
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 4) {
                    Text("DIVING")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Text("Dive computer premium")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(DiveUI.secondaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                    DiveStatusPill("ACTIVE", color: DiveUI.cyan, systemImage: "checkmark.circle.fill")
                }

                Spacer(minLength: 0)
            }
        }
    }

    private var stableModes: [StableMode] {
        [StableMode(title: "Diving", symbol: "water.waves", accent: DiveUI.cyan, description: "Dive computer premium")]
    }

    private func modeCard(_ mode: StableMode) -> some View {
        Button {
            navigation.selectedPage = .live
        } label: {
            DivePanel(stroke: mode.accent) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(mode.accent.opacity(0.18))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(mode.accent.opacity(0.9), lineWidth: 1)
                            )
                        Image(systemName: mode.symbol)
                            .font(.system(size: 21, weight: .black))
                            .foregroundStyle(mode.accent)
                    }
                    .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(mode.title)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Text(mode.description)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(DiveUI.secondaryText)
                            .lineLimit(2)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(mode.accent)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct StableMode: Identifiable {
    let id = UUID()
    let title: String
    let symbol: String
    let accent: Color
    let description: String
}
