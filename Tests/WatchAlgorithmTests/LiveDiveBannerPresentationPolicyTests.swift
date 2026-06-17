import XCTest

final class LiveDiveBannerPresentationPolicyTests: XCTestCase {
    func testCriticalSafetyKeepsSafetyBannersAndCompactsSecondaryNotices() {
        let input = LiveDiveBannerPresentationPolicy.Input(
            showAscentAlarmBanner: true,
            depthSafetyState: .critical,
            exceededSupportedDepthRange: false,
            isDepthDataStale: true,
            isManualNoDepthSession: false,
            hapticsEnabled: false,
            isDepthAutomationMockFallbackActive: true,
            isSimulationDepthActive: false,
            showsAutoDiveHint: true,
            showsManualHandoffNote: false
        )
        let output = LiveDiveBannerPresentationPolicy.evaluate(input)

        XCTAssertTrue(output.showAscentBanner)
        XCTAssertTrue(output.showDepthSafetyBanner)
        XCTAssertTrue(output.compactSecondaryNotices)
        XCTAssertFalse(output.showSensorBanner)
        XCTAssertGreaterThanOrEqual(output.secondaryNoticeTitles.count, 2)
        XCTAssertFalse(output.showsAutoDiveHint)
    }

    func testFourBannerScenarioPrioritizesCriticalWarnings() {
        let input = LiveDiveBannerPresentationPolicy.Input(
            showAscentAlarmBanner: true,
            depthSafetyState: .exceeded,
            exceededSupportedDepthRange: true,
            isDepthDataStale: true,
            isManualNoDepthSession: true,
            hapticsEnabled: false,
            isDepthAutomationMockFallbackActive: true,
            isSimulationDepthActive: true,
            showsAutoDiveHint: true,
            showsManualHandoffNote: true
        )
        let output = LiveDiveBannerPresentationPolicy.evaluate(input)

        XCTAssertTrue(output.showAscentBanner)
        XCTAssertTrue(output.showDepthSafetyBanner)
        XCTAssertTrue(output.compactSecondaryNotices)
        XCTAssertFalse(output.showSensorBanner)
        XCTAssertGreaterThanOrEqual(output.secondaryNoticeTitles.count, 2)
    }

    func testNormalStateShowsIndividualSecondaryBanners() {
        let input = LiveDiveBannerPresentationPolicy.Input(
            showAscentAlarmBanner: false,
            depthSafetyState: .normal,
            exceededSupportedDepthRange: false,
            isDepthDataStale: true,
            isManualNoDepthSession: false,
            hapticsEnabled: true,
            isDepthAutomationMockFallbackActive: false,
            isSimulationDepthActive: false,
            showsAutoDiveHint: false,
            showsManualHandoffNote: false
        )
        let output = LiveDiveBannerPresentationPolicy.evaluate(input)

        XCTAssertFalse(output.compactSecondaryNotices)
        XCTAssertTrue(output.showSensorBanner)
        XCTAssertTrue(output.secondaryNoticeTitles.contains(String(localized: "live.depth.stale.title")))
    }

    func testMockFallbackNoticeRemainsVisibleInNormalState() {
        let input = LiveDiveBannerPresentationPolicy.Input(
            showAscentAlarmBanner: false,
            depthSafetyState: .normal,
            exceededSupportedDepthRange: false,
            isDepthDataStale: false,
            isManualNoDepthSession: false,
            hapticsEnabled: true,
            isDepthAutomationMockFallbackActive: true,
            isSimulationDepthActive: false,
            showsAutoDiveHint: false,
            showsManualHandoffNote: false
        )
        let output = LiveDiveBannerPresentationPolicy.evaluate(input)
        XCTAssertFalse(output.compactSecondaryNotices)
        XCTAssertTrue(
            output.secondaryNoticeTitles.contains(String(localized: "watch.depth_source.mock_fallback")),
            "Mock fallback warning must remain visible when no critical safety banners compact notices"
        )
    }

    func testCompactWatchLayoutDefersSecondaryPanelsWhenCriticalSafetyActive() {
        let input = LiveDiveBannerPresentationPolicy.Input(
            showAscentAlarmBanner: true,
            depthSafetyState: .critical,
            exceededSupportedDepthRange: false,
            isDepthDataStale: false,
            isManualNoDepthSession: false,
            hapticsEnabled: true,
            isDepthAutomationMockFallbackActive: false,
            isSimulationDepthActive: false,
            showsAutoDiveHint: false,
            showsManualHandoffNote: false,
            isCompactLayout: true
        )
        let output = LiveDiveBannerPresentationPolicy.evaluate(input)

        XCTAssertTrue(output.prioritizeDepthAndRuntime)
        XCTAssertTrue(output.deferStopwatchPanel)
        XCTAssertTrue(output.deferControlsPanel)
    }

    func testLargeWatchLayoutKeepsSecondaryPanelsWhenOnlyOneCriticalBanner() {
        let input = LiveDiveBannerPresentationPolicy.Input(
            showAscentAlarmBanner: true,
            depthSafetyState: .normal,
            exceededSupportedDepthRange: false,
            isDepthDataStale: false,
            isManualNoDepthSession: false,
            hapticsEnabled: true,
            isDepthAutomationMockFallbackActive: false,
            isSimulationDepthActive: false,
            showsAutoDiveHint: false,
            showsManualHandoffNote: false,
            isCompactLayout: false
        )
        let output = LiveDiveBannerPresentationPolicy.evaluate(input)

        XCTAssertFalse(output.deferStopwatchPanel)
        XCTAssertFalse(output.deferControlsPanel)
    }

    func testGPSAndCompassSemanticKeysExistInBothCatalogs() throws {
        let en = try loadWatchStrings(named: "en")
        let it = try loadWatchStrings(named: "it")
        let keys = [
            "watch.gps.status.available",
            "watch.gps.status.searching",
            "watch.gps.status.permission_denied",
            "watch.compass.status.ready",
            "watch.compass.status.active",
            "watch.compass.status.calibration_required"
        ]
        for key in keys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT \(key)")
        }
        XCTAssertTrue(it["watch.compass.status.ready", default: ""].contains("BUSSOLA"))
        XCTAssertFalse(it["watch.compass.status.ready", default: ""].contains("COMPASSO"))
    }

    func testBriefingFreshnessKeysExistInBothCatalogs() throws {
        let en = try loadWatchStrings(named: "en")
        let it = try loadWatchStrings(named: "it")
        for key in [
            "watch.planner_briefing.freshness.old",
            "watch.planner_briefing.freshness.session_mismatch",
            "watch.planner_briefing.freshness.incomplete",
            "briefing.reference_only.footer"
        ] {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT \(key)")
        }
    }

    func testCollapsedBannerAccessibilityKeyExists() throws {
        let en = try loadWatchStrings(named: "en")
        let it = try loadWatchStrings(named: "it")
        XCTAssertFalse(en["live.banner.collapsed.a11y", default: ""].isEmpty)
        XCTAssertFalse(it["live.banner.collapsed.a11y", default: ""].isEmpty)
    }

    private func loadWatchStrings(named locale: String) throws -> [String: String] {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let url = root.appendingPathComponent("Resources/\(locale).lproj/Localizable.strings")
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
