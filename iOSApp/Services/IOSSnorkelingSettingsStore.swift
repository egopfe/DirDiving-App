import Combine
import Foundation

@MainActor
final class IOSSnorkelingSettingsStore: ObservableObject {
    static var testHook_defaults: UserDefaults?

    static let mapTypeStorageKey = SnorkelingMapTypeStorage.storageKey

    @Published var settings: SnorkelingCompanionSettings
    @Published var mapType: SnorkelingMapType {
        didSet {
            guard isReady else { return }
            SnorkelingMapTypeStorage.save(mapType, to: defaults)
        }
    }

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
        mapType = SnorkelingMapTypeStorage.load(from: defaults)
        isReady = true
    }

    func setMapType(_ type: SnorkelingMapType) {
        mapType = type
    }

    func persist() {
        guard isReady else { return }
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: storageKey)
        }
    }

    func resetToDefaults() {
        settings = .default
        mapType = .defaultValue
        persist()
        SnorkelingMapTypeStorage.save(mapType, to: defaults)
    }

    #if DEBUG
    func resetForTesting() {
        defaults.removeObject(forKey: storageKey)
        defaults.removeObject(forKey: Self.mapTypeStorageKey)
        settings = .default
        mapType = .defaultValue
    }
    #endif
}
