import Combine
import Foundation

@MainActor
final class SnorkelingMapTypeSettingsStore: ObservableObject {
    static var testHook_defaults: UserDefaults?

    static let mapTypeStorageKey = SnorkelingMapTypeStorage.storageKey

    @Published private(set) var mapType: SnorkelingMapType

    private var defaults: UserDefaults { Self.testHook_defaults ?? .standard }

    init(userDefaults: UserDefaults? = nil) {
        let resolved = userDefaults ?? Self.testHook_defaults ?? .standard
        mapType = SnorkelingMapTypeStorage.load(from: resolved)
    }

    func setMapType(_ type: SnorkelingMapType) {
        mapType = type
        SnorkelingMapTypeStorage.save(type, to: defaults)
    }

    func resetToDefault() {
        setMapType(.defaultValue)
    }
}
