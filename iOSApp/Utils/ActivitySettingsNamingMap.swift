import Foundation

/// Canonical audit/spec name → implementation type map (Command 7 naming alignment).
enum ActivitySettingsNamingMap {
    static let specToImplementation: [String: String] = [
        "SharedSettingsStore": "SharedIOSSettingsStore",
        "DivingSettingsStore": "IOSDivingSettingsStore",
        "ApneaSettingsStore": "IOSApneaSettingsStore",
        "SnorkelingSettingsStore": "IOSSnorkelingSettingsStore",
    ]

    static let implementationToSpec: [String: String] = {
        Dictionary(uniqueKeysWithValues: specToImplementation.map { ($1, $0) })
    }()

    static func implementationName(forSpec specName: String) -> String? {
        specToImplementation[specName]
    }

    static func specName(forImplementation implementationName: String) -> String? {
        implementationToSpec[implementationName]
    }
}
