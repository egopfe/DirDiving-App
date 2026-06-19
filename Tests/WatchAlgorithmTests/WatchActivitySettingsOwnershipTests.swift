import XCTest

final class WatchActivitySettingsOwnershipTests: XCTestCase {
    func testSettingsViewScopesSectionsBySelectedActivity() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/SettingsView.swift"))
        XCTAssertTrue(source.contains("activitySelection.selectedActivity == .diving"))
        XCTAssertTrue(source.contains("activitySelection.selectedActivity == .apnea"))
        XCTAssertTrue(source.contains("activitySelection.selectedActivity == .snorkeling"))
        XCTAssertTrue(source.contains("WatchApneaActivitySettingsSection"))
        XCTAssertTrue(source.contains("WatchSnorkelingActivitySettingsSection"))
    }

    func testDivingSafetySectionsNotUnconditionallyVisible() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/SettingsView.swift"))
        let ascentIndex = source.range(of: "AscentRateSettingsView")!.lowerBound
        let divingGateIndex = source.range(of: "if activitySelection.selectedActivity == .diving")!.lowerBound
        XCTAssertLessThan(divingGateIndex, ascentIndex)
    }

    func testDivingExportLogbookAndMissionModeAreActivityGated() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/SettingsView.swift"))
        XCTAssertTrue(source.contains("settings.row.export_logbook.title"))
        XCTAssertTrue(source.contains("settings.section.mission"))
        let exportIndex = source.range(of: "settings.row.export_logbook.title")!.lowerBound
        let exportGate = source[..<exportIndex].range(of: "activitySelection.selectedActivity == .diving", options: .backwards)!
        XCTAssertNotNil(exportGate)
    }

    func testWatchActivitySettingsScopeHelpers() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/WatchActivitySettingsSections.swift"))
        XCTAssertTrue(source.contains("isDivingOnlySettingVisible"))
        XCTAssertTrue(source.contains("activity == .diving"))
        XCTAssertTrue(source.contains("activity == .apnea"))
        XCTAssertTrue(source.contains("activity == .snorkeling"))
    }

    func testApneaAndSnorkelingSettingsLocalizationKeysExist() throws {
        let keys = [
            "settings.section.apnea",
            "settings.section.snorkeling",
            "settings.apnea.recovery.title",
            "settings.snorkeling.gps.title",
            "settings.snorkeling.route.title",
            "settings.snorkeling.return.title",
        ]
        let en = try loadWatchStrings(named: "en")
        let it = try loadWatchStrings(named: "it")
        for key in keys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT \(key)")
        }
    }

    func testDeveloperSettingsRemainProtected() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/SettingsView.swift"))
        XCTAssertTrue(source.contains("DeveloperSettings.isDeveloperSectionVisible"))
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
