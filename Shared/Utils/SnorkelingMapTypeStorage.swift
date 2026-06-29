import Foundation

enum SnorkelingMapTypeStorage {
    static let storageKey = "dirdiving.snorkeling.mapType"

    static func load(from userDefaults: UserDefaults = .standard) -> SnorkelingMapType {
        guard let raw = userDefaults.string(forKey: storageKey),
              let parsed = SnorkelingMapType(rawValue: raw) else {
            return .defaultValue
        }
        return parsed
    }

    static func save(_ type: SnorkelingMapType, to userDefaults: UserDefaults = .standard) {
        userDefaults.set(type.rawValue, forKey: storageKey)
    }
}
