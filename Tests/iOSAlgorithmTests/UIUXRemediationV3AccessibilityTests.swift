import XCTest

final class UIUXRemediationV3AccessibilityTests: XCTestCase {
    func testWatchPhotoTransferPanelIncludesAccessibilityLabels() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/WatchPhotoTransferPanel.swift"))
        XCTAssertTrue(source.contains("a11y.watch_photo_transfer.panel.label"))
        XCTAssertTrue(source.contains("a11y.watch_photo_transfer.select_photo.label"))
        XCTAssertTrue(source.contains("a11y.watch_photo_transfer.send.label"))
        XCTAssertTrue(source.contains("accessibilityLabel"))
    }

    func testCCRPlanResultViewUsesCCRChartAccessibilitySummaries() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/CCR/CCRPlanResultView.swift"))
        XCTAssertTrue(source.contains("UIUXAccessibilitySummaries.ccrPPO2Timeline"))
        XCTAssertTrue(source.contains("UIUXAccessibilitySummaries.ccrPPN2Timeline"))
        XCTAssertTrue(source.contains("UIUXAccessibilitySummaries.ccrENDTimeline"))
        XCTAssertTrue(source.contains("UIUXAccessibilitySummaries.ccrGasDensityTimeline"))
    }

    func testChecklistViewTogglesExposeAccessibilityLabels() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/ChecklistView.swift"))
        XCTAssertTrue(source.contains("checklistReadyAccessibilityLabel"))
        XCTAssertTrue(source.contains("a11y.checklist.item.toggle.hint"))
    }

    func testTissueTabSelectorUsesSelectedTrait() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/TissueAnalytics/TissueNarcosisAnalyticsView.swift"))
        XCTAssertTrue(source.contains("accessibilityAddTraits(tab == item ? [.isSelected] : [])"))
    }

    func testIOSContentViewExposesSettingsTabBadge() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/ContentView.swift"))
        XCTAssertTrue(source.contains("settingsTabBadge"))
        XCTAssertTrue(source.contains("watchSync.conflicts"))
    }

    func testCCRAccessibilitySummaryKeysExist() throws {
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        let keys = [
            "ccr.a11y.ppo2.summary",
            "ccr.a11y.ppn2.summary",
            "ccr.a11y.end.summary",
            "ccr.a11y.density.summary"
        ]
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
