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

    func testContentViewBlocksSettingsDuringActiveSessions() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/ContentView.swift"))
        XCTAssertTrue(source.contains("reportUnderwaterNavigationBlocked"))
        XCTAssertTrue(source.contains("page != .live && page != .compass"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
