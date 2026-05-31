import Foundation
import SwiftUI

enum DIRAppLanguage: String, CaseIterable, Identifiable {
    case system
    case italian = "it"
    case english = "en"

    static let storageKey = "dirdiving_app_language"

    var id: String { rawValue }

    var locale: Locale {
        switch self {
        case .system:
            return Self.supportedSystemLocale
        case .italian:
            return Locale(identifier: "it")
        case .english:
            return Locale(identifier: "en")
        }
    }

    var resolvedLanguageCode: String {
        switch self {
        case .system:
            return Self.supportedSystemLanguageCode
        case .italian:
            return "it"
        case .english:
            return "en"
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .system:
            return "System Language"
        case .italian:
            return "Italiano"
        case .english:
            return "English"
        }
    }

    var watchDetail: LocalizedStringKey {
        switch self {
        case .system:
            return "Follows Apple Watch language"
        case .italian:
            return "Forza interfaccia italiana"
        case .english:
            return "Forces English interface"
        }
    }

    static func fromStorage(_ rawValue: String) -> DIRAppLanguage {
        DIRAppLanguage(rawValue: rawValue) ?? .system
    }

    private static var supportedSystemLanguageCode: String {
        let preferred = Locale.preferredLanguages.first?.lowercased() ?? "it"
        if preferred.hasPrefix("en") {
            return "en"
        }
        if preferred.hasPrefix("it") {
            return "it"
        }
        return "it"
    }

    private static var supportedSystemLocale: Locale {
        let preferred = Locale.preferredLanguages.first?.lowercased() ?? "it"
        if preferred.hasPrefix("en") || preferred.hasPrefix("it") {
            return .autoupdatingCurrent
        }
        return Locale(identifier: "it")
    }
}
