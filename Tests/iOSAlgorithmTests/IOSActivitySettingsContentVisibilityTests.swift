import XCTest

final class IOSActivitySettingsContentVisibilityTests: XCTestCase {
    func testCompanionSettingsRootDoesNotEmbedNestedFormContent() throws {
        let root = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/IOSCompanionSettingsRootView.swift"))
        XCTAssertTrue(root.contains("IOSApneaSettingsContent()"))
        XCTAssertTrue(root.contains("IOSSnorkelingSettingsContent()"))
        XCTAssertFalse(root.contains("IOSApneaSettingsForm()"))
        XCTAssertFalse(root.contains("IOSSnorkelingSettingsForm()"))
        XCTAssertFalse(root.matches(pattern: #"Form\s*\{"#))
    }

    func testMoreViewDoesNotEmbedNestedFormContent() throws {
        let more = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/MoreView.swift"))
        XCTAssertTrue(more.contains("IOSApneaSettingsContent()"))
        XCTAssertTrue(more.contains("IOSSnorkelingSettingsContent()"))
        XCTAssertTrue(more.contains("applyCompanionSettingsSheetEnvironment"))
        XCTAssertFalse(more.contains("IOSApneaSettingsForm()"))
        XCTAssertFalse(more.contains("IOSSnorkelingSettingsForm()"))
        XCTAssertFalse(more.contains("applyInitialScope(.diving)"))
    }

    func testApneaSettingsContentContainsEditableControls() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Apnea/IOSApneaSettingsContent.swift"))
        XCTAssertTrue(source.contains("descentDetectionDepthMeters"))
        XCTAssertTrue(source.contains("surfaceDetectionDepthMeters"))
        XCTAssertTrue(source.contains("minimumRecoverySeconds"))
        XCTAssertTrue(source.contains("IOSCompanionSettingsToggleRow"))
        XCTAssertTrue(source.contains("IOSCompanionSettingsResetButton"))
        XCTAssertTrue(source.contains("IOSApneaEquipmentView"))
        XCTAssertTrue(source.contains("IOSApneaBuddySafetyView"))
        XCTAssertFalse(source.contains("Form {"))
        XCTAssertFalse(source.contains("PlannerAscentSpeedSettings"))
    }

    func testSnorkelingSettingsContentContainsEditableControls() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingSettingsContent.swift"))
        XCTAssertTrue(source.contains("autoWaterDetectionEnabled"))
        XCTAssertTrue(source.contains("gpsTrackingEnabled"))
        XCTAssertTrue(source.contains("returnToEntryDistanceMeters"))
        XCTAssertTrue(source.contains("sessionDurationAlertMinutes"))
        XCTAssertTrue(source.contains("IOSCompanionSettingsToggleRow"))
        XCTAssertTrue(source.contains("IOSCompanionSettingsResetButton"))
        XCTAssertTrue(source.contains("IOSSnorkelingEquipmentView"))
        XCTAssertTrue(source.contains("IOSSnorkelingBuddySafetyView"))
        XCTAssertFalse(source.contains("Form {"))
        XCTAssertFalse(source.contains("PlannerAscentSpeedSettings"))
    }

    func testEmbeddableContentUsesCardLayoutNotFormSections() throws {
        let apnea = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Apnea/IOSApneaSettingsContent.swift"))
        let snorkeling = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingSettingsContent.swift"))
        XCTAssertTrue(apnea.contains("DIRCard"))
        XCTAssertTrue(snorkeling.contains("DIRCard"))
        XCTAssertTrue(apnea.contains("VStack(alignment: .leading, spacing: 16)"))
        XCTAssertTrue(snorkeling.contains("VStack(alignment: .leading, spacing: 16)"))
    }

    func testStandaloneFormsAreThinWrappersWithoutFormContainer() throws {
        let apneaForm = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Apnea/IOSApneaSettingsForm.swift"))
        let snorkelingForm = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingSettingsForm.swift"))
        XCTAssertTrue(apneaForm.contains("IOSApneaSettingsContent()"))
        XCTAssertTrue(snorkelingForm.contains("IOSSnorkelingSettingsContent()"))
        XCTAssertFalse(apneaForm.contains("Form {"))
        XCTAssertFalse(snorkelingForm.contains("Form {"))
    }

    func testApneaSettingsLocalizationKeysExist() throws {
        let keys = [
            "apnea.ios.settings.detection",
            "apnea.ios.settings.descent_label",
            "apnea.ios.settings.surface_label",
            "apnea.ios.settings.recovery",
            "apnea.ios.settings.minimum_recovery_label",
            "apnea.ios.settings.feedback",
            "apnea.ios.settings.haptics",
            "apnea.ios.settings.sounds",
            "apnea.ios.settings.mission_mode",
            "apnea.ios.settings.reset",
            "settings.reset.a11y.hint",
        ]
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        for key in keys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT \(key)")
        }
    }

    func testSnorkelingSettingsLocalizationKeysExist() throws {
        let keys = [
            "snorkeling.ios.settings.detection",
            "snorkeling.ios.settings.auto_water",
            "snorkeling.ios.settings.dip_threshold_label",
            "snorkeling.ios.settings.surface_debounce_label",
            "snorkeling.ios.settings.gps",
            "snorkeling.ios.settings.gps_tracking",
            "snorkeling.ios.settings.return_distance_label",
            "snorkeling.ios.settings.alerts",
            "snorkeling.ios.settings.session_duration_alert_label",
            "snorkeling.ios.settings.feedback",
            "snorkeling.ios.settings.mission_mode",
            "snorkeling.ios.settings.reset",
        ]
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        for key in keys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT \(key)")
        }
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

private extension String {
    func matches(pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let range = NSRange(startIndex..<endIndex, in: self)
        return regex.firstMatch(in: self, range: range) != nil
    }
}
