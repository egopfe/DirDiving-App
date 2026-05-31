import Foundation
import Combine

@MainActor
final class AppNavigationStore: ObservableObject {
    static private(set) weak var shared: AppNavigationStore?

    @Published var selectedPage: AppPage = .modeSelection
    @Published var underwaterNavigationToast: String?

    private var underwaterToastTask: Task<Void, Never>?

    init() {
        Self.shared = self
        if WatchModeSelectionPreferences.skipWhenSingleMode, !WatchModeSelectionPreferences.hasMultipleStableModes {
            selectedPage = .live
        }
    }

    /// Keeps `TabView` selection valid when optional pages are removed from the hierarchy.
    func clampSelectedPage() {
        if selectedPage == .modeSelection,
           WatchModeSelectionPreferences.skipWhenSingleMode,
           !WatchModeSelectionPreferences.hasMultipleStableModes {
            selectedPage = .live
        }
    }

    func reportUnderwaterNavigationBlocked() {
        underwaterNavigationToast = String(localized: "nav.underwater.blocked")
        underwaterToastTask?.cancel()
        underwaterToastTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            if !Task.isCancelled {
                underwaterNavigationToast = nil
            }
        }
    }
}
