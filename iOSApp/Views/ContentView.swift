import SwiftUI

enum IOSTab: Hashable {
    case logbook
    case explore
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
            LogbookView().tabItem { Label("Logbook", systemImage: "list.bullet.rectangle.portrait.fill") }
                .tag(IOSTab.logbook)
            ExploreView().tabItem { Label("Explore", systemImage: "map.fill") }
                .tag(IOSTab.explore)
            AnalysisView().tabItem { Label("Analysis", systemImage: "chart.xyaxis.line") }
                .tag(IOSTab.analysis)
            PlannerView().tabItem { Label("Planner", systemImage: "point.topleft.down.curvedto.point.bottomright.up") }
                .tag(IOSTab.planner)
            EquipmentView().tabItem { Label("Gear", systemImage: "shippingbox.fill") }
                .tag(IOSTab.gear)
            MoreView().tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(IOSTab.settings)
        }
        .tint(DIRTheme.cyan)
        .toolbarBackground(DIRTheme.background, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}
