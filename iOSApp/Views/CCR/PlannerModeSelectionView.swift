import SwiftUI

struct PlannerModeSelectionView: View {
    @EnvironmentObject private var store: PlannerStore

    var body: some View {
        DIRScreenContainer {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(String(localized: "Planner"))
                            .dirScreenTitleStyle()
                        Text(String(localized: "planner.mode_selection.subtitle"))
                            .dirScreenSubtitleStyle()
                    }
                    DIRWarningBox(text: String(localized: "planner.reference_only.warning"))

                    ForEach(PlannerMode.allCases) { mode in
                        modeCard(mode)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 18)
            }
            .dirCompanionScrollSurface()
        }
        .dirCompanionTabRoot()
    }

    private func modeCard(_ mode: PlannerMode) -> some View {
        Button {
            store.selectPlannerMode(mode)
        } label: {
            DIRCard(mode.localizedTabTitle, icon: modeIcon(mode), accent: modeAccent(mode)) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(mode.localizedDescription)
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                        .multilineTextAlignment(.leading)
                    if mode.isCCR {
                        Text(String(localized: "ccr.safety.disclaimer"))
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.yellow)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mode.localizedTabTitle)
        .accessibilityHint(mode.localizedDescription)
    }

    private func modeIcon(_ mode: PlannerMode) -> String {
        switch mode {
        case .base: return "water.waves"
        case .deco: return "arrow.down.circle"
        case .technical: return "gearshape.2"
        case .ccr: return "lungs"
        }
    }

    private func modeAccent(_ mode: PlannerMode) -> Color {
        switch mode {
        case .base: return DIRTheme.cyan
        case .deco: return DIRTheme.yellow
        case .technical: return DIRTheme.yellow
        case .ccr: return DIRTheme.orange
        }
    }
}
