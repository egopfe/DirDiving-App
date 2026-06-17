import Combine
import Foundation

@MainActor
final class IOSApneaProfileStore: ObservableObject {
    static var testHook_defaults: UserDefaults?

    @Published private(set) var profiles: [ApneaCompanionProfile] = []
    @Published private(set) var loadErrorMessage: String?

    private let storageKey = "dirdiving_ios_apnea_profiles_v1"
    private var defaults: UserDefaults { Self.testHook_defaults ?? .standard }

    init() {
        load()
    }

    func allProfiles() -> [ApneaCompanionProfile] {
        ApneaCompanionProfilePolicy.mergePresetsWithUserProfiles(profiles)
    }

    func profile(id: UUID) -> ApneaCompanionProfile? {
        allProfiles().first { $0.id == id }
    }

    func add(_ profile: ApneaCompanionProfile) {
        var copy = profile
        copy.isPreset = false
        copy.updatedAt = Date()
        profiles.removeAll { $0.id == copy.id }
        profiles.append(copy)
        save()
    }

    func update(_ profile: ApneaCompanionProfile) {
        guard !profile.isPreset else { return }
        var copy = profile
        copy.updatedAt = Date()
        profiles.removeAll { $0.id == copy.id }
        profiles.append(copy)
        save()
    }

    func duplicate(_ profile: ApneaCompanionProfile) -> ApneaCompanionProfile {
        var copy = profile.editableCopy()
        copy.displayName = profile.displayName + " copy"
        copy.updatedAt = Date()
        profiles.append(copy)
        save()
        return copy
    }

    func delete(id: UUID) {
        profiles.removeAll { $0.id == id }
        save()
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey) else {
            profiles = []
            return
        }
        do {
            profiles = try JSONDecoder().decode([ApneaCompanionProfile].self, from: data)
        } catch {
            loadErrorMessage = error.localizedDescription
            profiles = []
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(profiles) else { return }
        defaults.set(data, forKey: storageKey)
    }

    #if DEBUG
    func resetForTesting() {
        profiles = []
        defaults.removeObject(forKey: storageKey)
    }
    #endif
}
