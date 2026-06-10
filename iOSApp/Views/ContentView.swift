import SwiftUI

/// Main iOS tab bar: Planner, Explore, Logbook, Analisi, Attrezzatura, Buddy, Checklist, Settings.
enum IOSTab: Hashable {
    case planner
    case explore
    case logbook
    case analysis
    case gear
    case buddy
    case checklist
    case settings
}

@MainActor
final class IOSNavigationStore: ObservableObject {
    @Published var selectedTab: IOSTab = .planner
}

struct ContentView: View {
    @EnvironmentObject private var navigation: IOSNavigationStore
    @EnvironmentObject private var plannerStore: PlannerStore
    @EnvironmentObject private var watchSync: WatchSyncService
    @EnvironmentObject private var cloudSync: CloudSyncStore
    @EnvironmentObject private var logStore: DiveLogStore
    @State private var showLaunchDisclaimer = CompanionDisclaimerAcceptance.requiresDisplay
    @State private var mountedTabs: Set<IOSTab> = [.planner]

    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            mountedTab(.planner) {
                PlannerRootView()
            }
            .tabItem { Label("tab.planner", systemImage: "point.topleft.down.curvedto.point.bottomright.up") }

            mountedTab(.explore) {
                ExplorationCenterView()
            }
            .tabItem { Label("Explore", systemImage: "map.fill") }

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

            mountedTab(.buddy) {
                BuddyExperimentalView()
            }
            .tabItem { Label("Buddy", systemImage: "person.2.wave.2.fill") }

            mountedTab(.checklist) {
                ChecklistView()
            }
            .tabItem { Label("tab.checklist", systemImage: "checklist") }

            mountedTab(.settings) {
                MoreView()
            }
            .tabItem { Label("tab.settings", systemImage: "gearshape.fill") }
            .badge(settingsTabBadge)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            DIRBackground()
                .ignoresSafeArea()
        }
        .dirCompanionTabSlot()
        .tint(DIRTheme.cyan)
        .toolbarBackground(DIRTheme.background, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
        .launchCompanionDisclaimer(isPresented: $showLaunchDisclaimer)
        .onAppear {
            applyPostLegalPlannerLandingIfNeeded()
            mountedTabs.insert(navigation.selectedTab)
        }
        .onChange(of: navigation.selectedTab) { _, tab in
            mountedTabs.insert(tab)
        }
    }

    private func applyPostLegalPlannerLandingIfNeeded() {
        guard IOSCompanionPostLegalEntry.consumePendingPlannerLanding() else { return }
        navigation.selectedTab = .planner
        mountedTabs.insert(.planner)
        Task { @MainActor in
            plannerStore.preparePostLegalOnboardingEntry()
        }
    }

    private var settingsTabBadge: String? {
        let conflictCount = watchSync.conflicts.count + logStore.sessionMergeConflicts.count
        if conflictCount > 0 {
            return conflictCount > 99 ? "99+" : "\(conflictCount)"
        }
        if watchSync.pendingWatchQueueCount > 0 || cloudSync.lastDecodeError != nil {
            return "!"
        }
        return nil
    }

    /// Mount tab roots lazily so PhotosPicker / fileImporter / ShareLink are not created at cold launch.
    @ViewBuilder
    private func mountedTab<Content: View>(_ tab: IOSTab, @ViewBuilder content: () -> Content) -> some View {
        Group {
            if mountedTabs.contains(tab) {
                content()
            } else {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background {
                        DIRBackground()
                            .ignoresSafeArea()
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .dirCompanionTabRoot()
        .tag(tab)
    }
}
