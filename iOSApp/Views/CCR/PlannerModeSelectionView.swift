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
                    .accessibilityElement(children: .combine)
                    .accessibilitySortPriority(100)

                    DIRWarningBox(text: String(localized: "planner.reference_only.warning"))
                        .accessibilityHint(String(localized: "planner.mode_selection.safety.a11y"))

                    ForEach(PlannerMode.allCases) { mode in
                        modeCard(mode)
                            .accessibilitySortPriority(Double(90 - PlannerMode.allCases.firstIndex(of: mode)!))
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
        let isCurrentMode = store.mode == mode
        return Button {
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
            .overlay {
                if isCurrentMode {
                    RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                        .stroke(DIRTheme.cyan, lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mode.localizedTabTitle)
        .accessibilityHint(modeAccessibilityHint(mode))
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(
            isCurrentMode
                ? String(format: String(localized: "planner.mode.a11y.active"), mode.localizedTabTitle)
                : ""
        )
    }

    private func modeAccessibilityHint(_ mode: PlannerMode) -> String {
        if mode.isCCR {
            return String(
                format: String(localized: "planner.mode_selection.card.a11y.hint"),
                mode.localizedTabTitle
            ) + ". " + String(localized: "ccr.safety.disclaimer")
        }
        return String(
            format: String(localized: "planner.mode_selection.card.a11y.hint"),
            mode.localizedTabTitle
        )
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
        case .technical: return Self.technicalAmber
        case .ccr: return DIRTheme.orange
        }
    }

    private static let technicalAmber = Color(red: 1.00, green: 0.68, blue: 0.18)
}
