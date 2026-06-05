import SwiftUI
import UIKit

/// Configures UIKit chrome so unpainted window/scroll/tab areas use DIR chrome instead of system black.
enum IOSWindowChromeConfigurator {
    private static let chromeUIColor = UIColor.black

    /// Safe during `App.init()` — only touches `UIAppearance`, not `UIApplication` / LaunchServices.
    static func applyUIKitAppearance() {
        UIScrollView.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
        UICollectionView.appearance().backgroundColor = .clear

        let tabBar = UITabBarAppearance()
        tabBar.configureWithOpaqueBackground()
        tabBar.backgroundColor = chromeUIColor
        UITabBar.appearance().standardAppearance = tabBar
        UITabBar.appearance().scrollEdgeAppearance = tabBar
        UITabBar.appearance().isTranslucent = false

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
                window.backgroundColor = chromeUIColor
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
            content()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            DIRBackground()
        }
        .ignoresSafeArea()
        .onAppear {
            // Defer UIApplication / window access until after LaunchServices client context is ready.
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

/// Full-screen onboarding / disclaimer layout: edge-to-edge background, scrollable body, safe-area-aware controls.
struct DIRDisclaimerScreen<Content: View>: View {
    @ViewBuilder private var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        DIRScreenContainer {
            ScrollView(showsIndicators: false) {
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DIRTheme.screenPadding)
                    .padding(.bottom, DIRTheme.spaceXL)
            }
            .dirCompanionScrollSurface()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaPadding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension View {
    /// Hides the default UITableView-backed scroll surface so DIR backgrounds show through.
    @ViewBuilder
    func dirCompanionScrollSurface() -> some View {
        scrollContentBackground(.hidden)
    }
}
