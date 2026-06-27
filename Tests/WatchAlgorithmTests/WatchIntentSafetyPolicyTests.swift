import XCTest
@testable import DIRDivingWatchApp

@MainActor
final class WatchIntentSafetyPolicyTests: XCTestCase {
    override func setUp() {
        super.setUp()
        #if DEBUG
        DIRStartupSelectionPolicy.resetForTests()
        #endif
    }

    func testLegacyStopwatchIntentDoesNotBypassRouterDuringActiveSession() throws {
        let source = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Services/ActionButtonIntents.swift"),
            encoding: .utf8
        )
        let pattern = "struct ToggleStopwatchIntent[\\s\\S]*?routePrimaryActionIfUnderwaterSession"
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(source.startIndex..<source.endIndex, in: source)
        XCTAssertNotNil(regex.firstMatch(in: source, range: range))
    }

    func testLegacyResetBlockedDuringActiveSessionInSource() throws {
        let source = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Services/ActionButtonIntents.swift"),
            encoding: .utf8
        )
        let pattern = "struct ResetStopwatchIntent[\\s\\S]*?requireNoActiveUnderwaterSessionForLegacyIntent"
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(source.startIndex..<source.endIndex, in: source)
        XCTAssertNotNil(regex.firstMatch(in: source, range: range))
    }

    func testStartManualDiveIntentDoesNotStartWhenAnySessionActiveInSource() throws {
        let source = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Services/ActionButtonIntents.swift"),
            encoding: .utf8
        )
        let pattern = "struct StartManualDiveIntent[\\s\\S]*?requireNoActiveUnderwaterSessionForLegacyIntent"
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(source.startIndex..<source.endIndex, in: source)
        XCTAssertNotNil(regex.firstMatch(in: source, range: range))
    }

    func testUnderwaterPrimaryIntentUsesRouterInSource() throws {
        let source = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Services/ActionButtonIntents.swift"),
            encoding: .utf8
        )
        let pattern = "struct ExecuteUnderwaterPrimaryActionIntent[\\s\\S]*?executePrimaryAction\\(\\)"
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(source.startIndex..<source.endIndex, in: source)
        XCTAssertNotNil(regex.firstMatch(in: source, range: range))
    }

    func testAppShortcutUserGuideMentionsRecommendedActionButtonShortcut() throws {
        let en = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Resources/en.lproj/Localizable.strings"),
            encoding: .utf8
        )
        XCTAssertTrue(en.contains("shortcuts.help.underwater_primary.title"))
        XCTAssertTrue(en.contains("Underwater Primary Action"))
    }

    func testIsAnySessionActiveWhenDiveActive() {
        let logStore = DiveLogStore()
        let gps = GPSManager()
        let ascent = AscentRateSettingsStore()
        let dive = DiveManager(logStore: logStore, gpsManager: gps, ascentSettings: ascent)
        dive.isDiveActive = true
        XCTAssertTrue(WatchIntentSafetyPolicy.isAnySessionActive())
        _ = dive
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
