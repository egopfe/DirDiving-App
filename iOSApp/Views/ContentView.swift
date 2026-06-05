import SwiftUI

/// Main iOS tab bar: Planner first, then logbook, analysis, equipment, settings.
enum IOSTab: Hashable {
    case planner
    case logbook
    case analysis
    case gear
    case settings
}

@MainActor
final class IOSNavigationStore: ObservableObject {
    @Published var selectedTab: IOSTab = .planner
}

struct ContentView: View {
    @EnvironmentObject private var navigation: IOSNavigationStore
    @State private var showLaunchDisclaimer = CompanionDisclaimerAcceptance.requiresDisplay

    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            PlannerView()
                .tabItem { Label("tab.planner", systemImage: "point.topleft.down.curvedto.point.bottomright.up") }
                .tag(IOSTab.planner)
            LogbookView()
                .tabItem { Label("tab.logbook", systemImage: "list.bullet.rectangle.portrait.fill") }
                .tag(IOSTab.logbook)
            AnalysisView()
                .tabItem { Label("tab.analysis", systemImage: "chart.xyaxis.line") }
                .tag(IOSTab.analysis)
            EquipmentView()
                .tabItem { Label("tab.gear", systemImage: "shippingbox.fill") }
                .tag(IOSTab.gear)
            MoreView()
                .tabItem { Label("tab.more", systemImage: "gearshape.fill") }
                .tag(IOSTab.settings)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .tint(DIRTheme.cyan)
        .toolbarBackground(DIRTheme.background, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
        .launchCompanionDisclaimer(isPresented: $showLaunchDisclaimer)
    }
}
