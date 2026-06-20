import Combine
import Foundation

/// Canonical Diving settings entry point — facade over existing sub-stores (no duplicate persistence).
@MainActor
final class IOSDivingSettingsStore: ObservableObject {
    static let registryNamespace = "dirdiving.settings.diving.v1"

    let sharedSettings: SharedIOSSettingsStore
    let plannerAscentSpeedSettings: PlannerAscentSpeedSettingsStore

    init(
        sharedSettings: SharedIOSSettingsStore,
        plannerAscentSpeedSettings: PlannerAscentSpeedSettingsStore
    ) {
        self.sharedSettings = sharedSettings
        self.plannerAscentSpeedSettings = plannerAscentSpeedSettings
    }

    /// Registry keys owned by the Diving settings surface (shared keys used in Diving + diving-only keys).
    var documentedRegistryKeys: [String] {
        ActivitySettingsVisibility.registry
            .filter { $0.visibleInDiving }
            .map(\.key)
            .sorted()
    }
}
