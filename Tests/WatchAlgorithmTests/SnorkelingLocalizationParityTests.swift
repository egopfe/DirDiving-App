import XCTest

final class SnorkelingLocalizationParityTests: XCTestCase {
    func testAllProductionSnorkelingKeysExistInEnglish() throws {
        let english = try loadWatchStrings(named: "en")
        let missing = SnorkelingLocalizationCatalog.productionKeys.filter { english[$0, default: ""].isEmpty }
        XCTAssertTrue(missing.isEmpty, "Missing EN keys: \(missing)")
    }

    func testAllProductionSnorkelingKeysExistInItalian() throws {
        let italian = try loadWatchStrings(named: "it")
        let missing = SnorkelingLocalizationCatalog.productionKeys.filter { italian[$0, default: ""].isEmpty }
        XCTAssertTrue(missing.isEmpty, "Missing IT keys: \(missing)")
    }

    func testSnorkelingEnglishItalianKeyParity() throws {
        let english = try loadWatchStrings(named: "en")
        let italian = try loadWatchStrings(named: "it")
        let snorkelingEN = Set(english.keys.filter { $0.hasPrefix("snorkeling.") })
        let snorkelingIT = Set(italian.keys.filter { $0.hasPrefix("snorkeling.") })
        XCTAssertEqual(snorkelingEN, snorkelingIT)
    }

    func testReturnAdvisorKeysDoNotRenderAsRawKeys() throws {
        let english = try loadWatchStrings(named: "en")
        let keys = [
            "snorkeling.return.advisor.unavailable",
            "snorkeling.return.advisor.distance",
            "snorkeling.return.advisor.duration",
            "snorkeling.return.advisor.battery",
            "snorkeling.return.advisor.manual",
            "snorkeling.return.gps.unavailable",
            "snorkeling.return.gps.degraded",
            "snorkeling.return.heading.stale",
            "snorkeling.return.near.entry",
        ]
        for key in keys {
            let localized = DIRWatchLocalizer.string(key)
            XCTAssertNotEqual(localized, key, "Raw key fallback for \(key)")
            XCTAssertFalse(localized.isEmpty)
            XCTAssertFalse(english[key, default: ""].isEmpty)
        }
    }

    func testOperationalOverlayKeysDoNotRenderAsRawKeys() throws {
        let english = try loadWatchStrings(named: "en")
        for key in ["snorkeling.alarm.title", "snorkeling.gps.lost"] {
            let localized = DIRWatchLocalizer.string(key)
            XCTAssertNotEqual(localized, key)
            XCTAssertFalse(localized.isEmpty)
            XCTAssertFalse(english[key, default: ""].isEmpty)
        }
    }

    func testSnorkelingAccessibilityKeysExist() throws {
        let keys = SnorkelingLocalizationCatalog.productionKeys.filter { $0.hasPrefix("snorkeling.a11y.") }
        let english = try loadWatchStrings(named: "en")
        let italian = try loadWatchStrings(named: "it")
        for key in keys {
            XCTAssertFalse(english[key, default: ""].isEmpty, key)
            XCTAssertFalse(italian[key, default: ""].isEmpty, key)
        }
    }

    func testNoHardcodedUserFacingSnorkelingStrings() throws {
        let sources = try productionSourcePaths().map {
            try String(contentsOf: repositoryRoot().appendingPathComponent($0), encoding: .utf8)
        }
        let joined = sources.joined(separator: "\n")
        XCTAssertFalse(joined.contains("RETURN ADVISED\""))
        XCTAssertFalse(joined.contains("TURN LEFT\""))
    }

    func testProductionSourceKeysExistInBothLocales() throws {
        let sources = try productionSourcePaths().map {
            try String(contentsOf: repositoryRoot().appendingPathComponent($0), encoding: .utf8)
        }
        let referenced = SnorkelingLocalizationCatalog.keysReferencedInProductionSources(sources)
        let english = try loadWatchStrings(named: "en")
        let italian = try loadWatchStrings(named: "it")
        let missingEN = referenced.filter { english[$0, default: ""].isEmpty }
        let missingIT = referenced.filter { italian[$0, default: ""].isEmpty }
        XCTAssertTrue(missingEN.isEmpty, "Missing EN: \(missingEN.sorted())")
        XCTAssertTrue(missingIT.isEmpty, "Missing IT: \(missingIT.sorted())")
    }

    private func productionSourcePaths() -> [String] {
        [
            "Utils/SnorkelingWatchPresentation.swift",
            "Views/SnorkelingView.swift",
            "Shared/Utils/SnorkelingReturnAdvisor.swift",
            "Shared/Utils/SnorkelingOperationalEventEngine.swift",
            "Services/SnorkelingWatchRuntimeStore.swift",
        ]
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadWatchStrings(named locale: String) throws -> [String: String] {
        let url = repositoryRoot().appendingPathComponent("Resources/\(locale).lproj/Localizable.strings")
        return parseStringsFile(try String(contentsOf: url, encoding: .utf8))
    }

    private func parseStringsFile(_ raw: String) -> [String: String] {
        var result: [String: String] = [:]
        let pattern = #"\"([^\"]+)\"\s*=\s*\"([^\"]*)\";"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return result }
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
