import Foundation
import Combine

@MainActor
final class AscentRateSettingsStore: ObservableObject {
    @Published var limits: AscentRateLimits {
        didSet { save() }
    }

    private let defaults: UserDefaults
    private let key = "dirdiving_ascent_rate_limits"
    private let cloudSync = CloudSyncStore()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let cloudLimits = cloudSync.load(AscentRateLimits.self, forKey: key) {
            limits = cloudLimits
        } else if let data = defaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode(AscentRateLimits.self, from: data) {
            limits = decoded
        } else {
            limits = .standard
        }
    }

    func resetToStandard() {
        limits = .standard
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(limits) else { return }
        defaults.set(data, forKey: key)
        cloudSync.save(limits, forKey: key)
    }
}
