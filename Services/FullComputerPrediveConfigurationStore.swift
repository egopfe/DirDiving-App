import Foundation
import Combine

@MainActor
final class FullComputerPrediveConfigurationStore: ObservableObject {
    static let shared = FullComputerPrediveConfigurationStore()

    static let storageKey = "dirdiving_watch_fc_predive_profile_v1"
    static let confirmedStorageKey = "dirdiving_watch_fc_confirmed_profile_v1"

    @Published private(set) var draftProfile: FullComputerGasProfile
    @Published private(set) var confirmedProfile: FullComputerGasProfile?

    private init() {
        draftProfile = Self.loadProfile(key: Self.storageKey) ?? .defaultAirGF3070
        confirmedProfile = Self.loadProfile(key: Self.confirmedStorageKey)
    }

    var validationIssues: [FullComputerGasValidationIssue] {
        FullComputerGasProfileValidator.validate(draftProfile)
    }

    var isDraftValid: Bool {
        validationIssues.isEmpty
    }

    func updateDraft(_ transform: (inout FullComputerGasProfile) -> Void) {
        guard canEdit else { return }
        var profile = draftProfile
        transform(&profile)
        profile.normalizeSortOrders()
        draftProfile = profile
        persistDraft()
    }

    func setBottomGasKind(_ kind: FullComputerBottomGasKind) {
        updateDraft { $0.applyBottomGasKind(kind) }
    }

    func upsertDecoGas(_ gas: FullComputerConfiguredGas) {
        updateDraft { profile in
            if let index = profile.decoGases.firstIndex(where: { $0.id == gas.id }) {
                profile.decoGases[index] = gas
            } else {
                profile.decoGases.append(gas)
            }
        }
    }

    func removeDecoGas(id: UUID) {
        updateDraft { profile in
            profile.decoGases.removeAll { $0.id == id }
        }
    }

    func commitConfirmedProfile() {
        guard isDraftValid else { return }
        confirmedProfile = draftProfile
        persistConfirmed()
    }

    func importProfile(_ profile: FullComputerGasProfile) {
        guard canEdit else { return }
        draftProfile = profile
        confirmedProfile = profile
        persistConfirmed()
    }

    func reloadDraftFromConfirmed() {
        draftProfile = confirmedProfile ?? .defaultAirGF3070
        persistDraft()
    }

    var canEdit: Bool {
        guard let dive = DiveManager.shared else { return true }
        return !dive.isDiveActive
    }

    func runtimePlan() -> FullComputerRuntimePlan {
        let profile = confirmedProfile ?? draftProfile
        return FullComputerRuntimePlan(profile: profile)
    }

    #if DEBUG
    func resetForTests() {
        draftProfile = .defaultAirGF3070
        confirmedProfile = nil
        UserDefaults.standard.removeObject(forKey: Self.storageKey)
        UserDefaults.standard.removeObject(forKey: Self.confirmedStorageKey)
    }
    #endif

    private func persistDraft() {
        Self.saveProfile(draftProfile, key: Self.storageKey)
    }

    private func persistConfirmed() {
        Self.saveProfile(draftProfile, key: Self.confirmedStorageKey)
        persistDraft()
    }

    private static func loadProfile(key: String) -> FullComputerGasProfile? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(FullComputerGasProfile.self, from: data)
    }

    private static func saveProfile(_ profile: FullComputerGasProfile, key: String) {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func migrateIfNeeded() {
        guard UserDefaults.standard.data(forKey: storageKey) == nil else { return }
        let defaults = FullComputerGasProfile.defaultAirGF3070
        saveProfile(defaults, key: storageKey)
    }
}
