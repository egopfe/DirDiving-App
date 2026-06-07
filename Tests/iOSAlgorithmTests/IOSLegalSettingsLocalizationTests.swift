import XCTest

final class IOSLegalSettingsLocalizationTests: XCTestCase {
    private let requiredKeys = [
        "ios.legal.exit_guidance.body",
        "ios.legal.disclaimer.card",
        "ios.legal.disclaimer.continue",
        "ios.legal.settings.title",
        "ios.legal.settings.acceptance_log",
        "ios.legal.settings.version_accepted",
        "ios.legal.settings.acceptance_timestamp",
        "ios.legal.settings.language",
        "ios.legal.settings.full_disclaimer",
        "ios.legal.settings.terms_privacy",
        "ios.legal.settings.terms",
        "ios.legal.settings.privacy"
    ]

    func testLegalSettingsLocalizationKeysExistInEnglishAndItalian() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        for key in requiredKeys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN key: \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT key: \(key)")
        }
    }

    func testItalianLegalSettingsTitleIsLocalized() throws {
        let it = try loadStrings(named: "it")
        XCTAssertEqual(it["ios.legal.settings.title"], "Legale e Sicurezza")
        XCTAssertEqual(it["more.legal_safety"], "Legale e Sicurezza")
    }

    private func loadStrings(named locale: String) throws -> [String: String] {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("iOSApp/Resources/\(locale).lproj/Localizable.strings")
        let raw = try String(contentsOf: url, encoding: .utf8)
        var result: [String: String] = [:]
        let pattern = #"\"([^\"]+)\"\s*=\s*\"([^\"]*)\";"#
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(raw.startIndex..<raw.endIndex, in: raw)
        regex.enumerateMatches(in: raw, range: range) { match, _, _ in
            guard let match,
                  let keyRange = Range(match.range(at: 1), in: raw),
                  let valueRange = Range(match.range(at: 2), in: raw) else { return }
            result[String(raw[keyRange])] = String(raw[valueRange])
        }
        return result
    }
}
