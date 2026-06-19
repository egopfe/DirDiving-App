import SwiftUI

/// Main iOS tab bar: Planner (Diving home), Explore, Logbook, Analisi, Attrezzatura, Buddy, Checklist, Settings.
enum IOSTab: Hashable, CaseIterable {
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
        VStack(spacing: 0) {
            ZStack {
                mountedTab(.planner) {
                    PlannerRootView()
                }
                mountedTab(.explore) {
                    ExplorationCenterView()
                }
                mountedTab(.logbook) {
                    LogbookView()
                }
                mountedTab(.analysis) {
                    AnalysisView()
                }
                mountedTab(.gear) {
                    EquipmentView()
                }
                mountedTab(.buddy) {
                    BuddyExperimentalView()
                }
                mountedTab(.checklist) {
                    ChecklistView()
                }
                mountedTab(.settings) {
                    MoreView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .dirCompanionTabSlot()

            DIRCompanionTabBar(
                selection: $navigation.selectedTab,
                settingsBadge: settingsTabBadge
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            DIRBackground()
                .ignoresSafeArea()
        }
        .tint(DIRTheme.cyan)
        .launchCompanionDisclaimer(isPresented: $showLaunchDisclaimer)
        .onAppear {
            mountedTabs.insert(navigation.selectedTab)
            Task { @MainActor in
                await Task.yield()
                applyPostLegalPlannerLandingIfNeeded()
            }
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
        .opacity(navigation.selectedTab == tab ? 1 : 0)
        .allowsHitTesting(navigation.selectedTab == tab)
        .accessibilityHidden(navigation.selectedTab != tab)
    }
}
