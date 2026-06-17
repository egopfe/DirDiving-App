import XCTest

/// Command 13 — repository-wide iOS Companion localization gate.
final class DIRDivingCompleteLocalizationAuditTests: XCTestCase {
    private let excludedPaths: Set<String> = [
        "iOSApp/Views/BuddyExperimentalView.swift",
        "iOSApp/Views/ExperimentalFutureConceptsView.swift",
        "iOSApp/Views/ExplorationCenterView.swift",
    ]

    private let requiredFullComputerPlanKeys = [
        "fc.plan.transfer.title",
        "fc.plan.transfer.send",
        "fc.plan.transfer.validation_failed",
        "fc.plan.transfer.watch_unavailable",
        "fc.plan.transfer.rejected",
    ]

    func testIOSEnglishItalianKeyParity() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        XCTAssertEqual(en.keys.count, it.keys.count)
        XCTAssertEqual(Set(en.keys), Set(it.keys))
    }

    func testFullComputerPlanTransferKeysExistInBothLocales() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        for key in requiredFullComputerPlanKeys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT \(key)")
            XCTAssertNotEqual(en[key], key)
            XCTAssertNotEqual(it[key], key)
        }
    }

    func testDIRIOSLocalizerKeysReferencedInProductionCodeResolve() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        let used = try dirLocalizerKeysReferencedInIOSCode()
        for key in used.sorted() {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT \(key)")
        }
    }

    func testCommonCancelAndPlannerKeysRemainLocalized() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        XCTAssertEqual(en["common.cancel"], "Cancel")
        XCTAssertEqual(it["common.cancel"], "Annulla")
        XCTAssertFalse(en["planner.calculate", default: ""].isEmpty)
        XCTAssertFalse(it["planner.calculate", default: ""].isEmpty)
    }

    private func dirLocalizerKeysReferencedInIOSCode() throws -> Set<String> {
        let root = repositoryRoot().appendingPathComponent("iOSApp")
        let pattern = #"DIRIOSLocalizer\.string\(\"([^\"\\]+)\"\)"#
        let regex = try NSRegularExpression(pattern: pattern)
        var keys = Set<String>()
        for file in try FileManager.default.subpathsOfDirectory(atPath: root.path) where file.hasSuffix(".swift") {
            let relative = "iOSApp/\(file)"
            if excludedPaths.contains(relative) { continue }
            let text = try String(contentsOf: root.appendingPathComponent(file), encoding: .utf8)
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            regex.enumerateMatches(in: text, range: range) { match, _, _ in
                guard let match, let keyRange = Range(match.range(at: 1), in: text) else { return }
                keys.insert(String(text[keyRange]))
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

    private func loadStrings(named locale: String) throws -> [String: String] {
        let url = repositoryRoot().appendingPathComponent("iOSApp/Resources/\(locale).lproj/Localizable.strings")
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
