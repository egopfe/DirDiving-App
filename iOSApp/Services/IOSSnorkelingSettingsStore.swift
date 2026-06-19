import Combine
import Foundation

@MainActor
final class IOSSnorkelingSettingsStore: ObservableObject {
    static var testHook_defaults: UserDefaults?

    @Published var settings: SnorkelingCompanionSettings

    private let storageKey = SnorkelingCompanionSettings.storageNamespace
    private var defaults: UserDefaults { Self.testHook_defaults ?? .standard }
    private var isReady = false

    init() {
        let defaults = Self.testHook_defaults ?? UserDefaults.standard
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(SnorkelingCompanionSettings.self, from: data) {
            settings = decoded
        } else {
            settings = .default
        }
        isReady = true
    }

    func persist() {
        guard isReady else { return }
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
