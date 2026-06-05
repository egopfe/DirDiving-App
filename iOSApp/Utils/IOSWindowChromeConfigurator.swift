import SwiftUI
import UIKit

/// Configures UIKit chrome so unpainted window/scroll/tab areas use DIR chrome instead of system black.
enum IOSWindowChromeConfigurator {
    /// Safe during `App.init()` — only touches `UIAppearance`, not `UIApplication` / LaunchServices.
    static func applyUIKitAppearance() {
        UIScrollView.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
        UICollectionView.appearance().backgroundColor = .clear
        UIView.appearance(whenContainedInInstancesOf: [UINavigationController.self]).backgroundColor = .clear

        let tabBar = UITabBarAppearance()
        tabBar.configureWithOpaqueBackground()
        tabBar.backgroundColor = DIRTheme.uiKitBackground
        tabBar.shadowColor = .clear
        UITabBar.appearance().standardAppearance = tabBar
        UITabBar.appearance().scrollEdgeAppearance = tabBar
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().barTintColor = DIRTheme.uiKitBackground
        UITabBar.appearance().backgroundColor = DIRTheme.uiKitBackground

        let navigationBar = UINavigationBarAppearance()
        navigationBar.configureWithTransparentBackground()
        navigationBar.backgroundColor = .clear
        UINavigationBar.appearance().standardAppearance = navigationBar
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBar
        UINavigationBar.appearance().compactAppearance = navigationBar
    }

    /// Call only after the first scene is connected (e.g. root `onAppear`).
    static func applyGlobalAppearance() {
        applyUIKitAppearance()
        paintConnectedWindows()
    }

    static func paintConnectedWindows() {
        guard UIApplication.shared.applicationState != .background else { return }
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        guard !scenes.isEmpty else { return }

        for windowScene in scenes {
            for window in windowScene.windows {
                window.backgroundColor = DIRTheme.uiKitBackground
            }
        }
    }
}

/// Forces the SwiftUI root to occupy the full window bounds on all iPhone sizes.
struct IOSRootShell<Content: View>: View {
    @Environment(\.scenePhase) private var scenePhase
    @ViewBuilder private var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ZStack {
            DIRBackground()
                .ignoresSafeArea()
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            Task { @MainActor in
                IOSWindowChromeConfigurator.applyGlobalAppearance()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { @MainActor in
                IOSWindowChromeConfigurator.paintConnectedWindows()
            }
        }
    }
}

/// Full-screen onboarding / disclaimer layout: edge-to-edge background, viewport-filling scroll body.
struct DIRDisclaimerScreen<Content: View>: View {
    enum VerticalLayout {
        case top
        case center
    }

    private let verticalLayout: VerticalLayout
    @ViewBuilder private var content: () -> Content

    init(
        verticalLayout: VerticalLayout = .top,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.verticalLayout = verticalLayout
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            let metrics = IOSCompanionViewportMetrics(
                size: geometry.size,
                safeAreaInsets: geometry.safeAreaInsets
            )
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    content()
                        .frame(
                            maxWidth: .infinity,
                            minHeight: metrics.contentAreaHeight,
                            alignment: verticalLayout == .center ? .center : .top
                        )
                        .padding(.horizontal, DIRTheme.screenPadding)
                        .safeAreaPadding(.vertical)
                }
                .dirCompanionScrollSurface()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .environment(\.iosCompanionViewportMetrics, metrics)
        }
        .ignoresSafeArea()
    }
}

extension View {
    /// Hides the default UITableView-backed scroll surface so DIR backgrounds show through.
    @ViewBuilder
    func dirCompanionScrollSurface() -> some View {
        scrollContentBackground(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    /// Paints DIR chrome across the full tab slot above the tab bar on any iPhone size.
    func dirCompanionTabSlot() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                DIRBackground()
                    .ignoresSafeArea()
            }
    }

    /// Root wrapper for tab `NavigationStack` screens — fills slot and keeps scroll content top-aligned.
    func dirCompanionTabRoot() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                DIRBackground()
                    .ignoresSafeArea()
            }
    }
}
