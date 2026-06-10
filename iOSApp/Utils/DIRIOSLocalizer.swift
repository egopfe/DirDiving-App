import Foundation

/// Resolves iOS Companion strings from the selected in-app language bundle.
/// `String(localized:)` follows the system bundle and ignores `Environment(\.locale)`.
enum DIRIOSLocalizer {
    static func selectedLanguage() -> DIRIOSAppLanguage {
        let raw = UserDefaults.standard.string(forKey: DIRIOSAppLanguage.storageKey)
            ?? DIRIOSAppLanguage.system.rawValue
        return DIRIOSAppLanguage.fromStorage(raw)
    }

    private static var resourceHostBundle: Bundle {
        for candidate in [Bundle.main] + Bundle.allBundles {
            if candidate.path(forResource: "en", ofType: "lproj") != nil
                || candidate.path(forResource: "it", ofType: "lproj") != nil {
                return candidate
            }
        }
        return Bundle.main
    }

    static func bundle(for language: DIRIOSAppLanguage) -> Bundle {
        let code = language.resolvedLanguageCode
        let host = resourceHostBundle
        if let path = host.path(forResource: code, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        if let path = developmentLocalizationBundlePath(for: code),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return host
    }

    /// Allows unit tests (and DEBUG runs) to resolve catalogs from the source tree when the host bundle has no `.lproj`.
    private static func developmentLocalizationBundlePath(for languageCode: String) -> String? {
        #if DEBUG
        let path = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Resources/\(languageCode).lproj")
            .path
        return FileManager.default.fileExists(atPath: path) ? path : nil
        #else
        return nil
        #endif
    }

    static func string(_ key: String, language: DIRIOSAppLanguage? = nil) -> String {
        let language = language ?? selectedLanguage()
        return NSLocalizedString(
            key,
            tableName: nil,
            bundle: bundle(for: language),
            value: key,
            comment: ""
        )
    }

    static func formatted(_ key: String, language: DIRIOSAppLanguage? = nil, _ arguments: CVarArg...) -> String {
        let language = language ?? selectedLanguage()
        let format = string(key, language: language)
        return String(format: format, locale: language.locale, arguments: arguments)
    }

    static func formatted(_ key: String, language: DIRIOSAppLanguage? = nil, arguments: [CVarArg]) -> String {
        let language = language ?? selectedLanguage()
        let format = string(key, language: language)
        return withVaList(arguments) { pointer in
            NSString(format: format, locale: language.locale, arguments: pointer) as String
        }
    }
}

extension String {
    var dirLocalized: String {
        DIRIOSLocalizer.string(self)
    }
}
