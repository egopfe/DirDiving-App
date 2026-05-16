import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LogbookView().tabItem { Label("Logbook", systemImage: "list.bullet.rectangle.portrait.fill") }
            AnalysisView().tabItem { Label("Analysis", systemImage: "chart.line.uptrend.xyaxis") }
            ExplorationCenterView().tabItem { Label("Explore Lab", systemImage: "map.fill") }
            PlannerView().tabItem { Label("Planner", systemImage: "point.topleft.down.curvedto.point.bottomright.up") }
            BuddyExperimentalView().tabItem { Label("Buddy Lab", systemImage: "dot.radiowaves.left.and.right") }
            EquipmentView().tabItem { Label("Equipment", systemImage: "shippingbox.fill") }
            MoreView().tabItem { Label("More", systemImage: "ellipsis.circle.fill") }
        }
        .tint(DIRTheme.cyan)
        .toolbarBackground(DIRTheme.background, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}
