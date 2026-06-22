import XCTest

@MainActor
final class IOSActivitySettingsModeSwitchTests: XCTestCase {
    func testSettingsScopeStoreDefaultsToDivingAndDoesNotMutateRuntime() {
        let defaults = UserDefaults(suiteName: "IOSActivitySettingsModeSwitchTests")!
        defaults.removePersistentDomain(forName: "IOSActivitySettingsModeSwitchTests")
        defer { defaults.removePersistentDomain(forName: "IOSActivitySettingsModeSwitchTests") }

        let scope = IOSCompanionSettingsScopeStore(initialMode: .diving)
        let activity = CompanionActivityPreferenceStore(defaults: defaults)

        scope.setDisplayedMode(.apnea)
        XCTAssertEqual(scope.displayedMode, .apnea)
        XCTAssertNil(activity.selectedMode)

        scope.setDisplayedMode(.snorkeling)
        XCTAssertEqual(scope.displayedMode, .snorkeling)
        XCTAssertNil(activity.selectedMode)
    }

    func testSettingsScopeInitialModeCanBeAppliedForSheetEntry() {
        let scope = IOSCompanionSettingsScopeStore(initialMode: .diving)
        scope.applyInitialScope(.snorkeling)
        XCTAssertEqual(scope.displayedMode, .snorkeling)
    }

    func testModeSwitchLocalizationKeysExist() throws {
        let keys = [
            "settings.mode_switch.title",
            "settings.mode_switch.diving",
            "settings.mode_switch.apnea",
            "settings.mode_switch.snorkeling",
            "settings.mode_switch.a11y.label",
            "settings.mode_switch.a11y.hint",
            "apnea.settings.title",
            "snorkeling.settings.title",
        ]
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        for key in keys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT \(key)")
        }
    }

    func testUnifiedSettingsRootAndModeSwitcherExist() throws {
        let root = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/IOSCompanionSettingsRootView.swift"))
        let switcher = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Components/IOSCompanionSettingsModeSwitcher.swift"))
        XCTAssertTrue(root.contains("IOSCompanionSettingsModeSwitcher"))
        XCTAssertTrue(root.contains("IOSApneaSettingsForm"))
        XCTAssertTrue(root.contains("IOSSnorkelingSettingsForm"))
        XCTAssertTrue(root.contains("IOSDivingSettingsEmbeddedContent"))
        XCTAssertTrue(switcher.contains("settings.mode_switch.title"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadIOSStrings(named locale: String) throws -> [String: String] {
        let path = repositoryRoot().appendingPathComponent("iOSApp/Resources/\(locale).lproj/Localizable.strings").path
        let text = try String(contentsOfFile: path, encoding: .utf8)
        var result: [String: String] = [:]
        let pattern = #"^\s*\"([^\"]+)\"\s*=\s*\"((?:\\.|[^\"\\])*)\"\s*;"#
        let regex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        regex.enumerateMatches(in: text, range: range) { match, _, _ in
            guard let match,
                  let keyRange = Range(match.range(at: 1), in: text),
                  let valueRange = Range(match.range(at: 2), in: text) else { return }
            result[String(text[keyRange])] = String(text[valueRange])
        }
        return result
    }
}
