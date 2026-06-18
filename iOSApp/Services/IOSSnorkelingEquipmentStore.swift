import Combine
import Foundation

@MainActor
final class IOSSnorkelingEquipmentStore: ObservableObject {
    static var testHook_defaults: UserDefaults?

    @Published private(set) var profiles: [SnorkelingReusableEquipmentProfile] = []

    private let storageKey = "dirdiving_ios_snorkeling_equipment_profiles_v1"
    private var defaults: UserDefaults { Self.testHook_defaults ?? .standard }

    init() {
        load()
        if profiles.isEmpty {
            profiles = [SnorkelingEquipmentCatalogPresets.defaultProfile()]
            persist()
        }
    }

    var activeProfile: SnorkelingReusableEquipmentProfile? {
        profiles.first { $0.isActive } ?? profiles.first
    }

    func add(_ profile: SnorkelingReusableEquipmentProfile) {
        profiles.append(profile)
        persist()
    }

    func update(_ profile: SnorkelingReusableEquipmentProfile) {
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

    func duplicate(_ profile: SnorkelingReusableEquipmentProfile) -> SnorkelingReusableEquipmentProfile {
        let copy = SnorkelingReusableEquipmentProfile(
            id: UUID(),
            displayName: "\(profile.displayName) copy",
            items: profile.items.map {
                SnorkelingEquipmentItem(id: UUID(), category: $0.category, label: $0.label, notes: $0.notes, sortIndex: $0.sortIndex)
            },
            isActive: false,
            notes: profile.notes
        )
        add(copy)
        return copy
    }

    func associationSummary(for session: SnorkelingSession) -> String {
        guard let active = activeProfile else { return "" }
        if session.equipment != nil { return active.displayName }
        return active.items.isEmpty ? "" : active.displayName
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([SnorkelingReusableEquipmentProfile].self, from: data) else {
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
