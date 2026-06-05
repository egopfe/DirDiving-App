import SwiftUI
import UIKit

/// Configures UIKit chrome so unpainted window/scroll/tab areas use DIR chrome instead of system black.
enum IOSWindowChromeConfigurator {
    private static let chromeUIColor = UIColor(red: 0.005, green: 0.018, blue: 0.030, alpha: 1)

    static func applyGlobalAppearance() {
        paintConnectedWindows()

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

    static func paintConnectedWindows() {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
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
        GeometryReader { geometry in
            ZStack {
                DIRBackground()
                content()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea()
        .onAppear {
            IOSWindowChromeConfigurator.applyGlobalAppearance()
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            IOSWindowChromeConfigurator.paintConnectedWindows()
        }
    }
}

extension View {
    /// Hides the default UITableView-backed scroll surface so DIR backgrounds show through.
    @ViewBuilder
    func dirCompanionScrollSurface() -> some View {
        scrollContentBackground(.hidden)
    }
}
