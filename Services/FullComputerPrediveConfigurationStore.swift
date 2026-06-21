import Foundation
import Combine

@MainActor
final class FullComputerPrediveConfigurationStore: ObservableObject {
    static let shared = FullComputerPrediveConfigurationStore()

    static let storageKey = "dirdiving_watch_fc_predive_profile_v1"
    static let confirmedStorageKey = "dirdiving_watch_fc_confirmed_profile_v1"
    static let draftEnvironmentKey = "dirdiving_watch_fc_draft_environment_v1"
    static let confirmedEnvironmentKey = "dirdiving_watch_fc_confirmed_environment_v1"

    @Published private(set) var draftProfile: FullComputerGasProfile
    @Published private(set) var confirmedProfile: FullComputerGasProfile?
    @Published private(set) var draftEnvironment: FullComputerEnvironmentRecord?
    @Published private(set) var confirmedEnvironment: FullComputerEnvironmentRecord?
    @Published private(set) var pendingSensorProposal: FullComputerEnvironmentRecord?

    private init() {
        draftProfile = Self.loadProfile(key: Self.storageKey) ?? .defaultAirGF3070
        confirmedProfile = Self.loadProfile(key: Self.confirmedStorageKey)
        draftEnvironment = Self.loadEnvironment(key: Self.draftEnvironmentKey)
        confirmedEnvironment = Self.loadEnvironment(key: Self.confirmedEnvironmentKey)
    }

    var validationIssues: [FullComputerGasValidationIssue] {
        FullComputerGasProfileValidator.validate(
            draftProfile,
            environment: draftEnvironment?.plannerEnvironment
        ) + environmentValidationIssues
    }

    private var environmentValidationIssues: [FullComputerGasValidationIssue] {
        guard let draftEnvironment else {
            return [.missingEnvironment]
        }
        if let error = draftEnvironment.validateForLiveStart() {
            return [.invalidEnvironment(error.rawValue)]
        }
        return []
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

    func setDraftEnvironment(
        altitudeMeters: Double,
        salinity: SalinityMode,
        source: FullComputerEnvironmentSource
    ) {
        guard canEdit else { return }
        switch FullComputerEnvironmentRecord.make(
            altitudeMeters: altitudeMeters,
            salinity: salinity,
            source: source
        ) {
        case .success(let record):
            draftEnvironment = record
            pendingSensorProposal = nil
            persistDraftEnvironment()
        case .failure:
            draftEnvironment = nil
            persistDraftEnvironment()
        }
    }

    func importEnvironment(_ record: FullComputerEnvironmentRecord) {
        guard canEdit else { return }
        draftEnvironment = record
        confirmedEnvironment = record
        pendingSensorProposal = nil
        persistDraftEnvironment()
        persistConfirmedEnvironment()
    }

    func acceptPendingSensorProposal() {
        guard canEdit,
              let pendingSensorProposal,
              pendingSensorProposal.validateForLiveStart() == nil else {
            return
        }
        draftEnvironment = pendingSensorProposal
        self.pendingSensorProposal = nil
        persistDraftEnvironment()
    }

    func dismissPendingSensorProposal() {
        pendingSensorProposal = nil
    }

    func proposeSensorEnvironment(_ record: FullComputerEnvironmentRecord) {
        guard canEdit else { return }
        guard record.source == .watchSensorMeasuredProposal else { return }
        guard record.validateForLiveStart() == nil else { return }
        pendingSensorProposal = record
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
        confirmedEnvironment = draftEnvironment
        persistConfirmed()
    }

    func importProfile(_ profile: FullComputerGasProfile, environment: FullComputerEnvironmentRecord) {
        guard canEdit else { return }
        draftProfile = profile
        confirmedProfile = profile
        importEnvironment(environment)
        persistConfirmed()
    }

    func reloadDraftFromConfirmed() {
        draftProfile = confirmedProfile ?? .defaultAirGF3070
        draftEnvironment = confirmedEnvironment
        persistDraft()
        persistDraftEnvironment()
    }

    var canEdit: Bool {
        guard let dive = DiveManager.shared else { return true }
        return !dive.isDiveActive
    }

    func runtimePlan() -> FullComputerRuntimePlan? {
        let profile = confirmedProfile ?? draftProfile
        guard let environmentRecord = confirmedEnvironment ?? draftEnvironment,
              environmentRecord.validateForLiveStart() == nil,
              let plannerEnvironment = environmentRecord.plannerEnvironment else {
            return nil
        }
        return FullComputerRuntimePlan(profile: profile, plannerEnvironment: plannerEnvironment)
    }

    #if DEBUG
    func resetForTests() {
        draftProfile = .defaultAirGF3070
        confirmedProfile = nil
        draftEnvironment = nil
        confirmedEnvironment = nil
        pendingSensorProposal = nil
        UserDefaults.standard.removeObject(forKey: Self.storageKey)
        UserDefaults.standard.removeObject(forKey: Self.confirmedStorageKey)
        UserDefaults.standard.removeObject(forKey: Self.draftEnvironmentKey)
        UserDefaults.standard.removeObject(forKey: Self.confirmedEnvironmentKey)
        seedTestEnvironment()
    }

    func clearEnvironmentForTestsOnly() {
        draftEnvironment = nil
        confirmedEnvironment = nil
        pendingSensorProposal = nil
        UserDefaults.standard.removeObject(forKey: Self.draftEnvironmentKey)
        UserDefaults.standard.removeObject(forKey: Self.confirmedEnvironmentKey)
    }

    func seedTestEnvironment(altitudeMeters: Double = 0, salinity: SalinityMode = .salt) {
        if case .success(let record) = FullComputerEnvironmentRecord.make(
            altitudeMeters: altitudeMeters,
            salinity: salinity,
            source: .watchSettingsManual
        ) {
            draftEnvironment = record
            confirmedEnvironment = record
            persistDraftEnvironment()
            persistConfirmedEnvironment()
        }
    }
    #endif

    private func persistDraft() {
        Self.saveProfile(draftProfile, key: Self.storageKey)
    }

    private func persistConfirmed() {
        Self.saveProfile(draftProfile, key: Self.confirmedStorageKey)
        persistDraft()
        persistConfirmedEnvironment()
    }

    private func persistDraftEnvironment() {
        Self.saveEnvironment(draftEnvironment, key: Self.draftEnvironmentKey)
    }

    private func persistConfirmedEnvironment() {
        Self.saveEnvironment(confirmedEnvironment, key: Self.confirmedEnvironmentKey)
        persistDraftEnvironment()
    }

    private static func loadProfile(key: String) -> FullComputerGasProfile? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(FullComputerGasProfile.self, from: data)
    }

    private static func saveProfile(_ profile: FullComputerGasProfile, key: String) {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private static func loadEnvironment(key: String) -> FullComputerEnvironmentRecord? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(FullComputerEnvironmentRecord.self, from: data)
    }

    private static func saveEnvironment(_ environment: FullComputerEnvironmentRecord?, key: String) {
        guard let environment, let data = try? JSONEncoder().encode(environment) else {
            UserDefaults.standard.removeObject(forKey: key)
            return
        }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func migrateIfNeeded() {
        guard UserDefaults.standard.data(forKey: storageKey) == nil else { return }
        let defaults = FullComputerGasProfile.defaultAirGF3070
        saveProfile(defaults, key: storageKey)
    }
}
