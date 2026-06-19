import Foundation

/// Resolves Watch MAIN strings from the Watch app bundle, with DEBUG source-tree fallback for unit tests.
enum DIRWatchLocalizer {
    private static var resourceHostBundle: Bundle {
        for candidate in [Bundle.main] + Bundle.allBundles {
            if candidate.path(forResource: "en", ofType: "lproj") != nil
                || candidate.path(forResource: "it", ofType: "lproj") != nil {
                return candidate
            }
        }
        return Bundle.main
    }

    static func bundle(forLanguageCode languageCode: String) -> Bundle {
        let host = resourceHostBundle
        if let path = host.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        if let path = developmentLocalizationBundlePath(for: languageCode),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return host
    }

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

    static func currentLanguageCode() -> String {
        if let preferred = Bundle.main.preferredLocalizations.first,
           !preferred.isEmpty {
            return preferred
        }
        return "en"
    }

    static func string(_ key: String, languageCode: String? = nil) -> String {
        let resolved = languageCode ?? currentLanguageCode()
        return NSLocalizedString(
            key,
            tableName: nil,
            bundle: bundle(forLanguageCode: resolved),
            value: key,
            comment: ""
        )
    }

    static func formatted(_ key: String, languageCode: String? = nil, _ arguments: CVarArg...) -> String {
        let resolved = languageCode ?? currentLanguageCode()
        let format = string(key, languageCode: resolved)
        return String(format: format, arguments: arguments)
    }
}
