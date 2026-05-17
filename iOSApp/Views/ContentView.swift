import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LogbookView().tabItem { Label("Logbook", systemImage: "list.bullet.rectangle.portrait.fill") }
            ExploreView().tabItem { Label("Explore", systemImage: "map.fill") }
            AnalysisView().tabItem { Label("Analysis", systemImage: "chart.xyaxis.line") }
            PlannerView().tabItem { Label("Planner", systemImage: "point.topleft.down.curvedto.point.bottomright.up") }
            EquipmentView().tabItem { Label("Gear", systemImage: "shippingbox.fill") }
            MoreView().tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(DIRTheme.cyan)
        .toolbarBackground(DIRTheme.background, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}
