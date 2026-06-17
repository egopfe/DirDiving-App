import XCTest

final class IOSI18nRemediationTests: XCTestCase {
    func testPDFExportKeysUsedByIOSCodeExistInBothCatalogs() throws {
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        let used = try pdfExportKeysReferencedInIOSCode()
        for key in used.sorted() {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing iOS EN key: \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing iOS IT key: \(key)")
        }
    }

    func testIOSWatchSyncServiceUsesSemanticDiveTransferKeys() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Services/WatchSyncService.swift"))
        let forbidden = [
            "Immersione aggiornata dal Watch",
            "Immersione duplicata ignorata",
            "Immersione ricevuta dal Watch",
            "Immersione inviata al Watch",
            "Invio Watch in coda non completato",
            "Invio Watch in coda (transferUserInfo)",
            "Invio Watch completato ma sessione non identificabile",
            "Tombstone Watch applicata",
            "Conflitto sync salvato per revisione",
            "Errore sync Watch:",
            "Errore invio Watch:",
            "In attesa attivazione"
        ]
        for phrase in forbidden {
            XCTAssertFalse(source.contains("String(localized: \"\(phrase)"), "Found legacy Italian-as-key phrase: \(phrase)")
        }
        XCTAssertTrue(source.contains("sync.dive.updated_from_watch"))
        XCTAssertTrue(source.contains("sync.dive.sent_to_watch"))
    }

    func testCCRPlannerUsesResolvableLocalizationKeys() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/CCR/CCRPlannerView.swift"))
        XCTAssertTrue(source.contains("planner.field.max_depth"))
        XCTAssertTrue(source.contains("planner.field.avg_depth"))
        XCTAssertTrue(source.contains("planner.field.bottom_time"))
        XCTAssertTrue(source.contains("planner.calculate"))
        XCTAssertFalse(source.contains("planner.max_depth"))
        XCTAssertFalse(source.contains("planner.avg_depth"))

        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        for key in ["planner.field.max_depth", "planner.field.avg_depth", "planner.field.bottom_time", "planner.calculate"] {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT \(key)")
        }
    }

    func testChecklistAndSettingsCopyConsistency() throws {
        let checklist = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/ChecklistView.swift"))
        let more = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/MoreView.swift"))
        XCTAssertFalse(checklist.contains(" READY\""))
        XCTAssertTrue(checklist.contains("checklist.status.required_badge_format"))
        XCTAssertTrue(checklist.contains("checklist.status.optional_badge_format"))
        XCTAssertTrue(more.contains("settings.title"))

        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        XCTAssertEqual(en["checklist.empty.open_gear"], "Open Equipment")
        XCTAssertEqual(it["checklist.empty.open_gear"], "Apri Attrezzatura")
        XCTAssertEqual(en["settings.title"], "Settings")
        XCTAssertEqual(it["settings.title"], "Impostazioni")
    }

    func testCommonCancelAndOKKeysExist() throws {
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        XCTAssertEqual(en["common.cancel"], "Cancel")
        XCTAssertEqual(it["common.cancel"], "Annulla")
        XCTAssertFalse(en["common.ok", default: ""].isEmpty)
        XCTAssertFalse(it["common.ok", default: ""].isEmpty)
    }

    private func pdfExportKeysReferencedInIOSCode() throws -> Set<String> {
        let root = repositoryRoot().appendingPathComponent("iOSApp")
        var keys = Set<String>()
        let pattern = #"String\(localized:\s*"(pdf\.export[^"]*)""#
        let regex = try NSRegularExpression(pattern: pattern)
        for file in try FileManager.default.subpathsOfDirectory(atPath: root.path) where file.hasSuffix(".swift") {
            let url = root.appendingPathComponent(file)
            let text = try String(contentsOf: url)
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            regex.enumerateMatches(in: text, range: range) { match, _, _ in
                guard let match, match.numberOfRanges > 1, let r = Range(match.range(at: 1), in: text) else { return }
                keys.insert(String(text[r]))
            }
        }
        return keys
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadIOSStrings(named language: String) throws -> [String: String] {
        let url = repositoryRoot()
            .appendingPathComponent("iOSApp/Resources/\(language).lproj/Localizable.strings")
        let raw = try String(contentsOf: url, encoding: .utf8)
        var result: [String: String] = [:]
        let pattern = #"^\s*"(.+?)"\s*=\s*"(.*)";\s*$"#
        let regex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        let range = NSRange(raw.startIndex..<raw.endIndex, in: raw)
        regex.enumerateMatches(in: raw, options: [], range: range) { match, _, _ in
            guard let match, match.numberOfRanges == 3,
                  let keyRange = Range(match.range(at: 1), in: raw),
                  let valueRange = Range(match.range(at: 2), in: raw) else { return }
            result[String(raw[keyRange])] = String(raw[valueRange])
        }
        return result
    }
}
