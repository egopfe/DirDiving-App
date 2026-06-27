import XCTest

final class WatchWaterAutoOpenSettingsCopyTests: XCTestCase {
    func testWaterAutoOpenLimitationCopyExistsENIT() throws {
        let en = try String(contentsOf: repositoryRoot().appendingPathComponent("Resources/en.lproj/Localizable.strings"))
        let it = try String(contentsOf: repositoryRoot().appendingPathComponent("Resources/it.lproj/Localizable.strings"))
        for key in [
            "settings.water_auto_open.cold_launch_limitation",
            "settings.water_auto_open.apply_now.button",
            "shortcuts.help.underwater_primary.title",
            "nav.underwater.blocked.diving",
            "shortcut.error.legacy_blocked_active_session"
        ] {
            XCTAssertTrue(en.contains("\"\(key)\""), "Missing EN key: \(key)")
            XCTAssertTrue(it.contains("\"\(key)\""), "Missing IT key: \(key)")
        }
    }

    func testNoForbiddenAutoLaunchClaimInStrings() throws {
        let en = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Resources/en.lproj/Localizable.strings"),
            encoding: .utf8
        ).lowercased()
        XCTAssertFalse(en.contains("automatically launches whenever apple watch enters water"))
        XCTAssertFalse(en.contains("guaranteed automatic system launch"))
    }

    func testItalianUsesBussolaNotCompassoInUnderwaterHelp() throws {
        let it = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Resources/it.lproj/Localizable.strings"),
            encoding: .utf8
        )
        XCTAssertTrue(it.contains("shortcuts.help.underwater.body"))
        let range = it.range(of: "shortcuts.help.underwater.body")!
        let snippet = it[range.lowerBound..<it.index(range.lowerBound, offsetBy: 200)]
        XCTAssertTrue(snippet.contains("BUSSOLA"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
