import Foundation
import Combine

@MainActor
final class EquipmentStore: ObservableObject {
    @Published var profile: EquipmentProfile {
        didSet { saveIfReady() }
    }

    private let cloudSync: CloudSyncStore?
    private let key = "dirdiving_ios_equipment_profile"
    private var isReady = false

    init(cloudSync: CloudSyncStore? = nil) {
        self.cloudSync = cloudSync
        profile = cloudSync?.load(EquipmentProfile.self, forKey: key) ?? EquipmentProfile()
        isReady = true
        saveIfReady()
    }

    func reset() {
        profile = EquipmentProfile()
    }

    private func saveIfReady() {
        guard isReady else { return }
        cloudSync?.save(profile, forKey: key)
    }
}
