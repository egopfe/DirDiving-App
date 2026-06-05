import Foundation
import Combine

@MainActor
final class AppNavigationStore: ObservableObject {
    static private(set) weak var shared: AppNavigationStore?

    @Published var selectedPage: AppPage = .modeSelection
    @Published var underwaterNavigationToast: String?
    @Published var exportCompletionPresented = false
    @Published var exportCompletionFileName = "export.csv"
    @Published var exportCompletionURL: URL?

    private var underwaterToastTask: Task<Void, Never>?

    init() {
        Self.shared = self
        // Defensive clamp for MAIN: mode selection stays unreachable when only Diving is stable.
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

    func presentExportCompletion(fileName: String, exportURL: URL?) {
        exportCompletionFileName = fileName
        exportCompletionURL = exportURL
        exportCompletionPresented = true
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
