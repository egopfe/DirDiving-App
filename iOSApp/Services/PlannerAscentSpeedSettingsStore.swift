import Foundation
import Combine

@MainActor
final class PlannerAscentSpeedSettingsStore: ObservableObject {
    @Published var settings: PlannerAscentSpeedSettings {
        didSet { persist() }
    }

    init() {
        settings = PlannerAscentSpeedSettings.load()
    }

    func resetToDefaults() {
        settings = .default
    }

    private func persist() {
        let normalized = settings.normalized()
        if normalized != settings {
            settings = normalized
            return
        }
        PlannerAscentSpeedSettings.save(normalized)
        NotificationCenter.default.post(name: .plannerAscentSpeedSettingsDidChange, object: nil)
    }
}
