import Foundation
import Combine

@MainActor
final class AppNavigationStore: ObservableObject {
    static private(set) weak var shared: AppNavigationStore?

    @Published var selectedPage: AppPage = .modeSelection

    init() {
        Self.shared = self
        if WatchModeSelectionPreferences.skipWhenSingleMode, !WatchModeSelectionPreferences.hasMultipleStableModes {
            selectedPage = .live
        }
    }

    /// Keeps `TabView` selection valid when optional pages (e.g. User Images) are removed from the hierarchy.
    func clampSelectedPage(userImagesAvailable: Bool) {
        if selectedPage == .userImages, !userImagesAvailable {
            selectedPage = .live
        }
        if selectedPage == .modeSelection,
           WatchModeSelectionPreferences.skipWhenSingleMode,
           !WatchModeSelectionPreferences.hasMultipleStableModes {
            selectedPage = .live
        }
    }
}
