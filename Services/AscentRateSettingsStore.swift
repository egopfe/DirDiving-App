import Foundation
import Combine

@MainActor
final class AscentRateSettingsStore: ObservableObject {
    @Published var limits: AscentRateLimits {
        didSet { save() }
    }

    private let defaults: UserDefaults
    // F8: canonical key uses `dirdiving` prefix; legacy `dirmotion` key is read once
    // as a migration source and then re-saved under the canonical key.
    private let key = "dirdiving_ascent_rate_limits"
    private let legacyKey = "dirmotion_ascent_rate_limits"
    private let cloudSync = CloudSyncStore()
    private var cloudObserver: NSObjectProtocol?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let cloudLimits = cloudSync.load(AscentRateLimits.self, forKey: key) {
            limits = cloudLimits
        } else if let data = defaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode(AscentRateLimits.self, from: data) {
            limits = decoded
        } else if let cloudLegacy = cloudSync.load(AscentRateLimits.self, forKey: legacyKey) {
            limits = cloudLegacy
        } else if let legacyData = defaults.data(forKey: legacyKey),
                  let decodedLegacy = try? JSONDecoder().decode(AscentRateLimits.self, from: legacyData) {
            limits = decodedLegacy
        } else {
            limits = .standard
        }
        limits = limits.normalized()
        cloudObserver = NotificationCenter.default.addObserver(
            forName: .cloudSyncDidChangeExternally,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.reloadFromCloud() }
        }
    }

    deinit {
        if let cloudObserver {
            NotificationCenter.default.removeObserver(cloudObserver)
        }
    }

    func resetToStandard() {
        limits = .standard
    }

    private func reloadFromCloud() {
        guard let cloudLimits = cloudSync.load(AscentRateLimits.self, forKey: key) else { return }
        limits = cloudLimits.normalized()
    }

    private func save() {
        let normalizedLimits = limits.normalized()
        guard let data = try? JSONEncoder().encode(normalizedLimits) else { return }
        defaults.set(data, forKey: key)
        cloudSync.save(normalizedLimits, forKey: key)
    }
}
