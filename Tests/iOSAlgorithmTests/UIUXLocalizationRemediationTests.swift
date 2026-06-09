import XCTest

final class UIUXLocalizationRemediationTests: XCTestCase {
    private let forbiddenPatterns = [
        "LIMITI PERSONALIZZATI",
        "\"GF Lo\"",
        "\"GF Hi\"",
        "\"SHORTCUT\""
    ]

    func testAscentSettingsViewAvoidsHardcodedItalian() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/AscentRateSettingsView.swift"))
        XCTAssertFalse(source.contains("LIMITI PERSONALIZZATI"))
        XCTAssertTrue(source.contains("ascent.settings.custom_limits.title"))
        XCTAssertTrue(source.contains("ascent.settings.reset_standard.button"))
    }

    func testCCRPlannerViewUsesLocalizedGFLabels() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/CCR/CCRPlannerView.swift"))
        XCTAssertFalse(source.contains("\"GF Lo\""))
        XCTAssertFalse(source.contains("\"GF Hi\""))
        XCTAssertTrue(source.contains("ccr.gf.low.label"))
        XCTAssertTrue(source.contains("ccr.gf.high.label"))
    }

    func testSettingsShortcutTitleLocalized() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/SettingsView.swift"))
        XCTAssertFalse(source.contains("Text(\"SHORTCUT\")"))
        XCTAssertTrue(source.contains("settings.shortcut.title"))
    }

    func testIOSWatchSyncServiceUsesSemanticSyncStatusKeys() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Services/WatchSyncService.swift"))
        XCTAssertTrue(source.contains("sync.status.not_synced"))
        XCTAssertFalse(source.contains("String(localized: \"Non sincronizzato\")"))
        XCTAssertFalse(source.contains("String(localized: \"Attivo\")"))
    }

    func testCCRChecklistImportCoordinatorExists() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Utils/CCRChecklistImportCoordinator.swift"))
        XCTAssertTrue(source.contains("importAll"))
        XCTAssertTrue(source.contains("importSelected"))
    }

    func testRemediationLocalizationKeysExistInBothCatalogs() throws {
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        let watchEN = try loadWatchStrings(named: "en")
        let watchIT = try loadWatchStrings(named: "it")
        let keys = [
            "sync.status.not_synced",
            "ccr.gf.low.label",
            "a11y.watch_photo_transfer.panel.label",
            "ascent.settings.custom_limits.title",
            "settings.shortcut.title"
        ]
        for key in keys {
            if key.hasPrefix("ascent.") || key.hasPrefix("settings.shortcut") {
                XCTAssertFalse(watchEN[key, default: ""].isEmpty, "Missing watch EN \(key)")
                XCTAssertFalse(watchIT[key, default: ""].isEmpty, "Missing watch IT \(key)")
            } else if key.hasPrefix("sync.") || key.hasPrefix("ccr.") || key.hasPrefix("a11y.") {
                XCTAssertFalse(en[key, default: ""].isEmpty, "Missing iOS EN \(key)")
                XCTAssertFalse(it[key, default: ""].isEmpty, "Missing iOS IT \(key)")
            }
        }
    }

    func testCCRChecklistImportPreservesRoles() {
        var input = CCRPlanInput()
        input.diluent = CCRDiluent(mixKind: .air, oxygenPercent: 21, heliumPercent: 0)
        let checklist = [
            EquipmentChecklistItem(
                title: "Diluent",
                usesGas: true,
                gasMixKind: .ean,
                gasText: "EAN32",
                gasRole: .ccrDiluent
            ),
            EquipmentChecklistItem(
                title: "Bailout 1",
                usesGas: true,
                gasMixKind: .air,
                gasText: "AIR",
                tankSize: .liters12,
                gasRole: .ccrBailout
            )
        ]
        CCRChecklistImportCoordinator.importAll(checklist: checklist, to: &input)
        XCTAssertEqual(input.diluent.oxygenPercent, 32)
        XCTAssertEqual(input.bailoutGases.count, 1)
        XCTAssertEqual(input.bailoutGases.first?.mixKind, .air)
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadIOSStrings(named language: String) throws -> [String: String] {
        try parseStrings(at: repositoryRoot().appendingPathComponent("iOSApp/Resources/\(language).lproj/Localizable.strings"))
    }

    private func loadWatchStrings(named language: String) throws -> [String: String] {
        try parseStrings(at: repositoryRoot().appendingPathComponent("Resources/\(language).lproj/Localizable.strings"))
    }

    private func parseStrings(at url: URL) throws -> [String: String] {
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
