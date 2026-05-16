import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LogbookView().tabItem { Label("Logbook", systemImage: "list.bullet.rectangle") }
            AnalysisView().tabItem { Label("Analisi", systemImage: "chart.line.uptrend.xyaxis") }
            ExploreView().tabItem { Label("Explore", systemImage: "map") }
            PlannerView().tabItem { Label("Planner", systemImage: "chart.line.uptrend.xyaxis") }
            EquipmentView().tabItem { Label("Attrezzatura", systemImage: "shippingbox") }
            MoreView().tabItem { Label("Altro", systemImage: "ellipsis") }
        }
        .tint(DIRTheme.cyan)
        .toolbarBackground(DIRTheme.background, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
