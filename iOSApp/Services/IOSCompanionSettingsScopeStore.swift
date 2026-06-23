import Combine
import Foundation

/// iOS-only Settings UI scope — controls which activity settings surface is visible.
/// Does not mutate companion runtime routing (`CompanionActivityPreferenceStore`).
@MainActor
final class IOSCompanionSettingsScopeStore: ObservableObject {
    @Published private(set) var displayedMode: DIRActivityMode
    private let defaults: UserDefaults

    init(initialMode: DIRActivityMode? = nil, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let initialMode {
            displayedMode = initialMode
        } else if let token = IOSCompanionNavigationPersistence.restoreSettingsScopeToken(defaults: defaults),
                  let mode = DIRActivityMode(rawValue: token) {
            displayedMode = mode
        } else {
            displayedMode = .diving
        }
    }

    func setDisplayedMode(_ mode: DIRActivityMode) {
        guard displayedMode != mode else { return }
        displayedMode = mode
        IOSCompanionNavigationPersistence.persistSettingsScopeToken(mode.rawValue, defaults: defaults)
    }

    func applyInitialScope(_ mode: DIRActivityMode) {
        setDisplayedMode(mode)
    }
}
