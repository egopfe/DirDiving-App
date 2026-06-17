import Combine
import Foundation

@MainActor
final class IOSApneaEquipmentStore: ObservableObject {
    static var testHook_defaults: UserDefaults?

    @Published private(set) var profiles: [ApneaReusableEquipmentProfile] = []

    private let storageKey = "dirdiving_ios_apnea_equipment_profiles_v1"
    private var defaults: UserDefaults { Self.testHook_defaults ?? .standard }

    init() {
        load()
        if profiles.isEmpty {
            profiles = [ApneaEquipmentCatalogPresets.defaultProfile()]
            persist()
        }
    }

    var activeProfile: ApneaReusableEquipmentProfile? {
        profiles.first { $0.isActive } ?? profiles.first
    }

    func add(_ profile: ApneaReusableEquipmentProfile) {
        profiles.append(profile)
        persist()
    }

    func update(_ profile: ApneaReusableEquipmentProfile) {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else { return }
        profiles[index] = profile
        persist()
    }

    func delete(id: UUID) {
        profiles.removeAll { $0.id == id }
        if !profiles.contains(where: \.isActive), let first = profiles.first {
            var active = first
            active.isActive = true
            update(active)
        }
        persist()
    }

    func setActive(id: UUID) {
        profiles = profiles.map { profile in
            var copy = profile
            copy.isActive = (profile.id == id)
            return copy
        }
        persist()
    }

    func duplicate(_ profile: ApneaReusableEquipmentProfile) -> ApneaReusableEquipmentProfile {
        var copy = profile
        copy = ApneaReusableEquipmentProfile(
            id: UUID(),
            displayName: "\(profile.displayName) copy",
            items: profile.items.map {
                ApneaEquipmentItem(id: UUID(), category: $0.category, label: $0.label, notes: $0.notes, sortIndex: $0.sortIndex)
            },
            isActive: false,
            notes: profile.notes
        )
        add(copy)
        return copy
    }

    func associationSummary(for session: ApneaSession) -> String {
        guard let active = activeProfile else { return "" }
        let categories = Set(active.items.map(\.category))
        if let equipment = session.equipment, equipment.suitNotes != nil || equipment.lanyardDescription != nil {
            return active.displayName
        }
        return categories.isEmpty ? "" : active.displayName
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([ApneaReusableEquipmentProfile].self, from: data) else {
            profiles = []
            return
        }
        profiles = decoded
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(profiles) {
            defaults.set(data, forKey: storageKey)
        }
    }
}
