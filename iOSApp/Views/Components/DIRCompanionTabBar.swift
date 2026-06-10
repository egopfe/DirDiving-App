import SwiftUI

/// Custom bottom tab bar for the iOS Companion.
/// UITabBar shows at most five items on iPhone; a sixth `TabView` item is hidden behind the system "More" tab.
/// This bar keeps all six product tabs visible: Planner, LogBook, Analysis, Equipment, Checklist, Settings.
struct DIRCompanionTabBar: View {
    @Binding var selection: IOSTab
    let settingsBadge: String?

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(DIRTheme.hairline)
                .frame(height: 1)

            HStack(spacing: 0) {
                ForEach(IOSTab.companionOrder) { tab in
                    tabButton(tab)
                }
            }
            .padding(.horizontal, 2)
            .padding(.top, 6)
            .padding(.bottom, 4)
        }
        .background(DIRTheme.background.ignoresSafeArea(edges: .bottom))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(String(localized: "a11y.companion.tab_bar"))
    }

    private func tabButton(_ tab: IOSTab) -> some View {
        let isSelected = selection == tab

        return Button {
            selection = tab
        } label: {
            VStack(spacing: 3) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: tab.systemImage)
                        .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                        .symbolRenderingMode(.monochrome)

                    if tab == .settings, let settingsBadge, !settingsBadge.isEmpty {
                        Text(settingsBadge)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(DIRTheme.background)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Capsule().fill(DIRTheme.orange))
                            .offset(x: 10, y: -6)
                            .accessibilityHidden(true)
                    }
                }
                .frame(height: 22)

                Text(String(localized: String.LocalizationValue(tab.labelKey)))
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
            }
            .foregroundStyle(isSelected ? DIRTheme.cyan : DIRTheme.muted)
            .frame(maxWidth: .infinity)
            .frame(minHeight: DIRTheme.buttonMinHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String(localized: String.LocalizationValue(tab.labelKey)))
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
        .accessibilityHint(
            tab == .settings && settingsBadge != nil
                ? String(localized: "a11y.companion.settings_tab_badge_hint")
                : ""
        )
    }
}

extension IOSTab: Identifiable {
    var id: Self { self }

    static let companionOrder: [IOSTab] = [
        .planner, .explore, .logbook, .analysis, .gear, .buddy, .checklist, .settings
    ]

    var labelKey: String {
        switch self {
        case .planner: "tab.planner"
        case .explore: "Explore"
        case .logbook: "tab.logbook"
        case .analysis: "tab.analysis"
        case .gear: "tab.gear"
        case .buddy: "Buddy"
        case .checklist: "tab.checklist"
        case .settings: "tab.settings"
        }
    }

    var systemImage: String {
        switch self {
        case .planner: "point.topleft.down.curvedto.point.bottomright.up"
        case .explore: "map.fill"
        case .logbook: "list.bullet.rectangle.portrait.fill"
        case .analysis: "chart.xyaxis.line"
        case .gear: "shippingbox.fill"
        case .buddy: "person.2.wave.2.fill"
        case .checklist: "checklist"
        case .settings: "gearshape.fill"
        }
    }
}
