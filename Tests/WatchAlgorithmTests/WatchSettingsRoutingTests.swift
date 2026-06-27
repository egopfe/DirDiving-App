import XCTest

final class WatchSettingsRoutingTests: XCTestCase {
    func testApneaViewExposesSettingsAccessButton() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/ApneaView.swift"))
        XCTAssertTrue(source.contains("WatchInModeSettingsAccessButton"))
        XCTAssertTrue(source.contains("apnea.settings.a11y.open"))
        XCTAssertTrue(source.contains("AppNavigationStore"))
    }

    func testSnorkelingViewExposesSettingsAccessButton() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/SnorkelingView.swift"))
        XCTAssertTrue(source.contains("WatchInModeSettingsAccessButton"))
        XCTAssertTrue(source.contains("snorkeling.settings.a11y.open"))
        XCTAssertTrue(source.contains("AppNavigationStore"))
    }

    func testInModeSettingsAccessPolicyBlocksActiveSessions() {
        XCTAssertFalse(WatchInModeSettingsAccessPolicy.canPresentSettings(isSessionActive: true))
        XCTAssertTrue(WatchInModeSettingsAccessPolicy.canPresentSettings(isSessionActive: false))
    }

    func testContentViewUsesUnderwaterNavigationClampPolicy() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/ContentView.swift"))
        XCTAssertTrue(source.contains("WatchUnderwaterNavigationClampPolicy.clampIfNeeded"))
        XCTAssertTrue(source.contains("reportUnderwaterNavigationBlocked(activity:"))
        XCTAssertTrue(source.contains("beginInitialLaunchIfNeeded()"))
        XCTAssertTrue(source.contains("!showLaunchDisclaimer && activitySelection.isStartupFlowActive"))
        XCTAssertFalse(source.contains("page != .live && page != .compass"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
