import XCTest
@testable import DIRDivingWatchApp

final class WatchUnderwaterPagePolicyTests: XCTestCase {
    func testNoActiveSessionUsesNormalPageInventory() {
        let pages = WatchUnderwaterPagePolicy.allowedPages(
            activity: .diving,
            divingMode: .gauge,
            isSessionActive: false,
            hasUserImages: true
        )
        XCTAssertTrue(pages.contains(.diveLog))
        XCTAssertTrue(pages.contains(.settings))
    }

    func testDivingActiveAllowsLiveAndCompass() {
        let pages = WatchUnderwaterPagePolicy.allowedPages(
            activity: .diving,
            divingMode: .gauge,
            isSessionActive: true,
            hasUserImages: false
        )
        XCTAssertTrue(pages.contains(.live))
        XCTAssertTrue(pages.contains(.compass))
    }

    func testDivingActiveIncludesUserImagesWhenPresent() {
        let pages = WatchUnderwaterPagePolicy.allowedPages(
            activity: .diving,
            divingMode: .gauge,
            isSessionActive: true,
            hasUserImages: true
        )
        XCTAssertTrue(pages.contains(.userImages))
    }

    func testDivingActiveExcludesDiveLog() {
        let pages = WatchUnderwaterPagePolicy.allowedPages(
            activity: .diving,
            divingMode: .fullComputer,
            isSessionActive: true,
            hasUserImages: true
        )
        XCTAssertFalse(pages.contains(.diveLog))
    }

    func testDivingActiveExcludesModeSelection() {
        let pages = WatchUnderwaterPagePolicy.allowedPages(
            activity: .diving,
            divingMode: .gauge,
            isSessionActive: true,
            hasUserImages: true,
            includeModeSelection: true
        )
        XCTAssertFalse(pages.contains(.modeSelection))
    }

    func testDivingActiveExcludesSettingsPhaseOne() {
        let pages = WatchUnderwaterPagePolicy.allowedPages(
            activity: .diving,
            divingMode: .gauge,
            isSessionActive: true,
            hasUserImages: true
        )
        XCTAssertFalse(pages.contains(.settings))
    }

    func testApneaActiveOnlyLive() {
        let pages = WatchUnderwaterPagePolicy.allowedPages(
            activity: .apnea,
            divingMode: .gauge,
            isSessionActive: true,
            hasUserImages: true
        )
        XCTAssertEqual(pages, [.live])
    }

    func testSnorkelingActiveOnlyLive() {
        let pages = WatchUnderwaterPagePolicy.allowedPages(
            activity: .snorkeling,
            divingMode: .gauge,
            isSessionActive: true,
            hasUserImages: true
        )
        XCTAssertEqual(pages, [.live])
    }
}
