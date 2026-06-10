import Foundation
import SwiftUI

enum DIRIOSAppLanguage: String, CaseIterable, Identifiable {
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
        LocalizedStringKey(localizedTitle)
    }

    var companionDetail: LocalizedStringKey {
        LocalizedStringKey(localizedDetail)
    }

    var localizedTitle: String {
        switch self {
        case .system:
            return DIRIOSLocalizer.string("language.option.system")
        case .italian:
            return DIRIOSLocalizer.string("language.option.italian")
        case .english:
            return DIRIOSLocalizer.string("language.option.english")
        }
    }

    var localizedDetail: String {
        switch self {
        case .system:
            return DIRIOSLocalizer.string("language.option.system.detail")
        case .italian:
            return DIRIOSLocalizer.string("language.option.italian.detail")
        case .english:
            return DIRIOSLocalizer.string("language.option.english.detail")
        }
    }

    static func fromStorage(_ rawValue: String) -> DIRIOSAppLanguage {
        DIRIOSAppLanguage(rawValue: rawValue) ?? .system
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
