import Combine
import Foundation

/// iOS-only Settings UI scope — controls which activity settings surface is visible.
/// Does not mutate companion runtime routing (`CompanionActivityPreferenceStore`).
@MainActor
final class IOSCompanionSettingsScopeStore: ObservableObject {
    @Published private(set) var displayedMode: DIRActivityMode

    init(initialMode: DIRActivityMode = .diving) {
        displayedMode = initialMode
    }

    func setDisplayedMode(_ mode: DIRActivityMode) {
        guard displayedMode != mode else { return }
        displayedMode = mode
    }

    func applyInitialScope(_ mode: DIRActivityMode) {
        displayedMode = mode
    }
}
