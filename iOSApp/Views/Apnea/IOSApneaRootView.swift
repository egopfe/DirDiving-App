import SwiftUI

enum IOSApneaTab: String, Hashable, CaseIterable, Identifiable {
    case dashboard
    case sessions
    case statistics
    case profiles

    var id: String { rawValue }

    var labelKey: String {
        switch self {
        case .dashboard: return "apnea.ios.tab.dashboard"
        case .sessions: return "apnea.ios.tab.sessions"
        case .statistics: return "apnea.ios.tab.statistics"
        case .profiles: return "apnea.ios.tab.profiles"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: return "house.fill"
        case .sessions: return "doc.text.fill"
        case .statistics: return "chart.bar.fill"
        case .profiles: return "person.fill"
        }
    }
}

@MainActor
final class IOSApneaNavigationStore: ObservableObject {
    @Published var selectedTab: IOSApneaTab = .dashboard
    @Published var showPlanner = false
    @Published var showSettings = false
    @Published var pendingSessionDetailID: UUID?
}

struct IOSApneaRootView: View {
    @EnvironmentObject private var apneaNavigation: IOSApneaNavigationStore
    @EnvironmentObject private var coordinator: IOSCompanionStoreCoordinator
    @State private var mountedTabs: Set<IOSApneaTab> = [.dashboard]

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                mountedTab(.dashboard) { IOSApneaDashboardView() }
                mountedTab(.sessions) { IOSApneaSessionsListView() }
                mountedTab(.statistics) { IOSApneaStatisticsView() }
                mountedTab(.profiles) { IOSApneaProfilesView() }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            iosApneaTabBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            DIRBackground().ignoresSafeArea()
        }
        .tint(DIRTheme.cyan)
        .sheet(isPresented: $apneaNavigation.showPlanner) {
            NavigationStack {
                IOSApneaSessionPlannerView()
            }
        }
        .sheet(isPresented: $apneaNavigation.showSettings) {
            coordinator.applyCompanionSettingsSheetEnvironment(to:
                NavigationStack {
                    IOSCompanionSettingsRootView(initialMode: .apnea)
                }
            )
        }
        .onChange(of: apneaNavigation.selectedTab) { _, tab in
            mountedTabs.insert(tab)
        }
        .onAppear {
            applyPostSelectionLandingIfNeeded()
        }
    }

    private func applyPostSelectionLandingIfNeeded() {
        guard IOSCompanionPostLegalEntry.consumePendingApneaLanding() else { return }
        apneaNavigation.selectedTab = .dashboard
        mountedTabs.insert(.dashboard)
    }

    private var iosApneaTabBar: some View {
        VStack(spacing: 0) {
            Rectangle().fill(DIRTheme.hairline).frame(height: 1)
            HStack(spacing: 0) {
                ForEach(IOSApneaTab.allCases) { tab in
                    Button {
                        apneaNavigation.selectedTab = tab
                    } label: {
                        VStack(spacing: 3) {
                            Image(systemName: tab.systemImage)
                                .font(.system(size: 17, weight: apneaNavigation.selectedTab == tab ? .semibold : .regular))
                            Text(DIRIOSLocalizer.string(tab.labelKey))
                                .font(.system(size: 10, weight: apneaNavigation.selectedTab == tab ? .semibold : .regular))
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)
                        }
                        .foregroundStyle(apneaNavigation.selectedTab == tab ? DIRTheme.cyan : DIRTheme.muted)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: DIRTheme.buttonMinHeight)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(DIRIOSLocalizer.string(tab.labelKey))
                    .accessibilityAddTraits(apneaNavigation.selectedTab == tab ? [.isSelected, .isButton] : .isButton)
                }
            }
            .padding(.horizontal, 2)
            .padding(.top, 6)
            .padding(.bottom, 4)
        }
        .background(DIRTheme.background.ignoresSafeArea(edges: .bottom))
    }

    @ViewBuilder
    private func mountedTab<Content: View>(_ tab: IOSApneaTab, @ViewBuilder content: () -> Content) -> some View {
        Group {
            if mountedTabs.contains(tab) {
                content()
            } else {
                Color.clear
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .opacity(apneaNavigation.selectedTab == tab ? 1 : 0)
        .allowsHitTesting(apneaNavigation.selectedTab == tab)
        .accessibilityHidden(apneaNavigation.selectedTab != tab)
    }
}
