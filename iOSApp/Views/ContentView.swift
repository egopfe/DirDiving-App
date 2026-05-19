import SwiftUI

/// Main iOS tab bar: five companion surfaces (Logbook, analysis, planner, equipment, settings).
/// Intent: match stable reference layout — no experimental Lab targets.
enum IOSTab: Hashable {
    case logbook
    case analysis
    case planner
    case gear
    case settings
}

@MainActor
final class IOSNavigationStore: ObservableObject {
    @Published var selectedTab: IOSTab = .logbook
}

struct ContentView: View {
    @EnvironmentObject private var navigation: IOSNavigationStore

    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            LogbookView()
                .tabItem { Label("tab.logbook", systemImage: "list.bullet.rectangle.portrait.fill") }
                .tag(IOSTab.logbook)
            AnalysisView()
                .tabItem { Label("tab.analysis", systemImage: "chart.xyaxis.line") }
                .tag(IOSTab.analysis)
            PlannerView()
                .tabItem { Label("tab.planner", systemImage: "point.topleft.down.curvedto.point.bottomright.up") }
                .tag(IOSTab.planner)
            EquipmentView()
                .tabItem { Label("tab.gear", systemImage: "shippingbox.fill") }
                .tag(IOSTab.gear)
            MoreView()
                .tabItem { Label("tab.more", systemImage: "gearshape.fill") }
                .tag(IOSTab.settings)
        }
        .tint(DIRTheme.cyan)
        .toolbarBackground(DIRTheme.background, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}
