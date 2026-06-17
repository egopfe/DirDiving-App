import XCTest

/// Command 13 — repository-wide Watch MAIN localization gate.
final class DIRDivingCompleteLocalizationAuditTests: XCTestCase {
    private let excludedPaths: Set<String> = [
        "Views/ApneaView.swift",
        "Views/SnorkelingView.swift",
        "Views/BuddyAssistView.swift",
        "Views/ExperimentalConceptsView.swift",
    ]

    private let requiredFullComputerKeys = [
        "startup.diving_mode.full_computer.title",
        "startup.fc_confirm.error.sensor",
        "live.fc.metric.ndl",
        "live.fc.metric.tts",
        "live.fc.deco.too_shallow.title",
        "live.fc.deco.too_deep.title",
        "live.fc.gas_switch.available.title",
        "watch.full_computer.recovery_active",
        "fc.imported_plan.technical_header",
        "fc.imported_plan.runtime_minutes_format",
        "sync.legacy_schema.v1_warning",
        "live.unit.min",
        "live.unit.m",
    ]

    func testWatchEnglishItalianKeyParity() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        XCTAssertEqual(en.keys.count, it.keys.count)
        XCTAssertEqual(Set(en.keys), Set(it.keys))
    }

    func testRequiredFullComputerAndSyncKeysExistInBothLocales() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        for key in requiredFullComputerKeys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT \(key)")
            XCTAssertNotEqual(en[key], key, "Untranslated EN \(key)")
            XCTAssertNotEqual(it[key], key, "Untranslated IT \(key)")
        }
    }

    func testSemanticKeysReferencedInWatchMainSourcesResolveInBothLocales() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        let used = try semanticKeysUsedInWatchMainSources()
        for key in used.sorted() {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN for \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT for \(key)")
        }
    }

    func testFullComputerAccessibilityKeysAreNotRawKeys() throws {
        let bundle = try XCTUnwrap(Bundle(path: Bundle.main.path(forResource: "en", ofType: "lproj") ?? ""))
        let keys = [
            "live.fc.gas_switch.confirm.a11y",
            "live.fc.a11y.direction.ascend",
            "watch.full_computer.recovery_active.a11y",
        ]
        for key in keys {
            let value = bundle.localizedString(forKey: key, value: nil, table: nil)
            XCTAssertNotEqual(value, key)
            XCTAssertFalse(value.hasPrefix("live.fc."))
        }
    }

    func testImportedPlanTechnicalHeaderFormats() {
        let formatted = String(
            format: String(localized: "fc.imported_plan.technical_header"),
            "a1b2c3d4",
            3
        )
        XCTAssertTrue(formatted.contains("a1b2c3d4"))
        XCTAssertTrue(formatted.contains("3"))
    }

    func testLegacySyncSchemaWarningFormats() {
        let message = String(
            format: String(localized: "sync.legacy_schema.v1_warning"),
            "2026-12-01"
        )
        XCTAssertTrue(message.contains("2026-12-01"))
        XCTAssertFalse(message.hasPrefix("sync."))
    }

    private func semanticKeysUsedInWatchMainSources() throws -> Set<String> {
        let root = repositoryRoot()
        let pattern = #"String\(localized:\s*(?:String\.LocalizationValue\()?\"([^\"\\]+)\""#
        let regex = try NSRegularExpression(pattern: pattern)
        var keys = Set<String>()
        for relative in try swiftFilesUnderWatchMain(root: root) {
            let source = try String(contentsOf: root.appendingPathComponent(relative), encoding: .utf8)
            let range = NSRange(source.startIndex..<source.endIndex, in: source)
            regex.enumerateMatches(in: source, range: range) { match, _, _ in
                guard let match, let keyRange = Range(match.range(at: 1), in: source) else { return }
                let key = String(source[keyRange])
                if key.contains("."), key.first?.isLowercase == true {
                    keys.insert(key)
                }
            }
            for match in source.matches(of: /"(live\.fc\.[^"]+)"/) {
                keys.insert(String(match.1))
            }
        }
        return keys
    }

    private func swiftFilesUnderWatchMain(root: URL) throws -> [String] {
        var results: [String] = []
        for sourceRoot in ["App", "Services", "Views", "Utils"] {
            let directory = root.appendingPathComponent(sourceRoot)
            guard FileManager.default.fileExists(atPath: directory.path) else { continue }
            let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: nil)
            while let url = enumerator?.nextObject() as? URL {
                guard url.pathExtension == "swift" else { continue }
                let relative = url.path.replacingOccurrences(of: root.path + "/", with: "")
                if excludedPaths.contains(relative) { continue }
                results.append(relative)
            }
        }
        return results.sorted()
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadStrings(named locale: String) throws -> [String: String] {
        let url = repositoryRoot().appendingPathComponent("Resources/\(locale).lproj/Localizable.strings")
        let raw = try String(contentsOf: url, encoding: .utf8)
        return parseStringsFile(raw)
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
