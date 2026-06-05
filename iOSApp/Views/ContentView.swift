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
    @State private var mountedTabs: Set<IOSTab> = [.planner]

    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            mountedTab(.planner) {
                PlannerView()
            }
            .tabItem { Label("tab.planner", systemImage: "point.topleft.down.curvedto.point.bottomright.up") }

            mountedTab(.logbook) {
                LogbookView()
            }
            .tabItem { Label("tab.logbook", systemImage: "list.bullet.rectangle.portrait.fill") }

            mountedTab(.analysis) {
                AnalysisView()
            }
            .tabItem { Label("tab.analysis", systemImage: "chart.xyaxis.line") }

            mountedTab(.gear) {
                EquipmentView()
            }
            .tabItem { Label("tab.gear", systemImage: "shippingbox.fill") }

            mountedTab(.settings) {
                MoreView()
            }
            .tabItem { Label("tab.more", systemImage: "gearshape.fill") }
        }
        .dirCompanionTabSlot()
        .tint(DIRTheme.cyan)
        .toolbarColorScheme(.dark, for: .tabBar)
        .launchCompanionDisclaimer(isPresented: $showLaunchDisclaimer)
        .onAppear {
            mountedTabs.insert(navigation.selectedTab)
        }
        .onChange(of: navigation.selectedTab) { _, tab in
            mountedTabs.insert(tab)
        }
    }

    /// Mount tab roots lazily so PhotosPicker / fileImporter / ShareLink are not created at cold launch.
    @ViewBuilder
    private func mountedTab<Content: View>(_ tab: IOSTab, @ViewBuilder content: () -> Content) -> some View {
        Group {
            if mountedTabs.contains(tab) {
                content()
            } else {
                Color.clear
            }
        }
        .dirCompanionTabRoot()
        .tag(tab)
    }
}
