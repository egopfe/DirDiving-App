import SwiftUI

enum IOSSnorkelingTab: String, Hashable, CaseIterable, Identifiable {
    case dashboard
    case sessions
    case statistics
    case routePlanner
    case profiles

    var id: String { rawValue }

    var labelKey: String {
        switch self {
        case .dashboard: return "snorkeling.ios.tab.dashboard"
        case .sessions: return "snorkeling.ios.tab.sessions"
        case .statistics: return "snorkeling.ios.tab.statistics"
        case .routePlanner: return "snorkeling.ios.tab.route_planner"
        case .profiles: return "snorkeling.ios.tab.profiles"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: return "house.fill"
        case .sessions: return "doc.text.fill"
        case .statistics: return "chart.bar.fill"
        case .routePlanner: return "map.fill"
        case .profiles: return "person.fill"
        }
    }
}

@MainActor
final class IOSSnorkelingNavigationStore: ObservableObject {
    @Published var selectedTab: IOSSnorkelingTab = .dashboard
    @Published var showSettings = false
    @Published var pendingSessionDetailID: UUID?
}

struct IOSSnorkelingRootView: View {
    @EnvironmentObject private var snorkelingNavigation: IOSSnorkelingNavigationStore
    @State private var mountedTabs: Set<IOSSnorkelingTab> = [.dashboard]

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                mountedTab(.dashboard) { IOSSnorkelingDashboardView() }
                mountedTab(.sessions) { IOSSnorkelingSessionsListView() }
                mountedTab(.statistics) { IOSSnorkelingStatisticsView() }
                mountedTab(.routePlanner) { IOSSnorkelingRoutePlannerView() }
                mountedTab(.profiles) { IOSSnorkelingProfilesView() }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            iosSnorkelingTabBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            DIRBackground().ignoresSafeArea()
        }
        .tint(DIRTheme.cyan)
        .sheet(isPresented: $snorkelingNavigation.showSettings) {
            NavigationStack {
                IOSSnorkelingSettingsView()
            }
        }
        .onChange(of: snorkelingNavigation.selectedTab) { _, tab in
            mountedTabs.insert(tab)
        }
        .onAppear {
            applyPostSelectionLandingIfNeeded()
        }
    }

    private func applyPostSelectionLandingIfNeeded() {
        guard IOSCompanionPostLegalEntry.consumePendingSnorkelingLanding() else { return }
        snorkelingNavigation.selectedTab = .dashboard
        mountedTabs.insert(.dashboard)
    }

    private var iosSnorkelingTabBar: some View {
        VStack(spacing: 0) {
            Rectangle().fill(DIRTheme.hairline).frame(height: 1)
            HStack(spacing: 0) {
                ForEach(IOSSnorkelingTab.allCases) { tab in
                    Button {
                        snorkelingNavigation.selectedTab = tab
                    } label: {
                        VStack(spacing: 3) {
                            Image(systemName: tab.systemImage)
                                .font(.system(size: 17, weight: snorkelingNavigation.selectedTab == tab ? .semibold : .regular))
                            Text(DIRIOSLocalizer.string(tab.labelKey))
                                .font(.system(size: 10, weight: snorkelingNavigation.selectedTab == tab ? .semibold : .regular))
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)
                        }
                        .foregroundStyle(snorkelingNavigation.selectedTab == tab ? DIRTheme.cyan : DIRTheme.muted)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: DIRTheme.buttonMinHeight)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(DIRIOSLocalizer.string(tab.labelKey))
                    .accessibilityAddTraits(snorkelingNavigation.selectedTab == tab ? [.isSelected, .isButton] : .isButton)
                }
            }
            .padding(.horizontal, 2)
            .padding(.top, 6)
            .padding(.bottom, 4)
        }
        .background(DIRTheme.background.ignoresSafeArea(edges: .bottom))
    }

    @ViewBuilder
    private func mountedTab<Content: View>(_ tab: IOSSnorkelingTab, @ViewBuilder content: () -> Content) -> some View {
        Group {
            if mountedTabs.contains(tab) {
                content()
            } else {
                Color.clear
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .opacity(snorkelingNavigation.selectedTab == tab ? 1 : 0)
        .allowsHitTesting(snorkelingNavigation.selectedTab == tab)
        .accessibilityHidden(snorkelingNavigation.selectedTab != tab)
    }
}
