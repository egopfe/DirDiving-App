import Combine
import Foundation

@MainActor
final class IOSApneaSettingsStore: ObservableObject {
    static var testHook_defaults: UserDefaults?

    @Published var settings: ApneaCompanionSettings

    private let storageKey = "dirdiving_ios_apnea_settings_v1"
    private var defaults: UserDefaults { Self.testHook_defaults ?? .standard }
    private var isReady = false

    init() {
        let defaults = Self.testHook_defaults ?? UserDefaults.standard
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(ApneaCompanionSettings.self, from: data) {
            settings = decoded
        } else {
            settings = .default
        }
        isReady = true
    }

    var isChecklistComplete: Bool {
        ApneaChecklistProgress.isComplete(settings.preApneaChecklist)
    }

    var buddyChecklistConfirmed: Bool {
        ApneaChecklistProgress.buddyConfirmed(in: settings.preApneaChecklist)
    }

    var checklistCompletedCount: Int {
        ApneaChecklistProgress.completedCount(in: settings.preApneaChecklist)
    }

    var checklistTotalCount: Int {
        ApneaChecklistProgress.totalCount(in: settings.preApneaChecklist)
    }

    func setChecklistItem(id: UUID, isChecked: Bool) {
        guard let index = settings.preApneaChecklist.firstIndex(where: { $0.id == id }) else { return }
        settings.preApneaChecklist[index].isChecked = isChecked
        persist()
    }

    func resetChecklist() {
        settings.preApneaChecklist = ApneaChecklistCatalog.defaultItems()
        persist()
    }

    func persist() {
        guard isReady else { return }
        settings.schemaVersion = ApneaCompanionSettings.currentSchemaVersion
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: storageKey)
        }
    }

    func resetToDefaults() {
        settings = .default
        persist()
    }

    #if DEBUG
    func resetForTesting() {
        defaults.removeObject(forKey: storageKey)
        settings = .default
    }
    #endif
}
