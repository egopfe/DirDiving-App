import XCTest
@testable import DIRDivingWatchApp

final class WatchUnderwaterNavigationClampPolicyTests: XCTestCase {
    func testDivingActiveAllowsLiveCompassAndImagesWhenPresent() {
        let live = WatchUnderwaterNavigationClampPolicy.clampIfNeeded(
            selectedPage: .live,
            activity: .diving,
            divingMode: .gauge,
            isSessionActive: true,
            hasUserImages: true,
            includeModeSelection: false
        )
        XCTAssertFalse(live.wasBlocked)

        let compass = WatchUnderwaterNavigationClampPolicy.clampIfNeeded(
            selectedPage: .compass,
            activity: .diving,
            divingMode: .gauge,
            isSessionActive: true,
            hasUserImages: true,
            includeModeSelection: false
        )
        XCTAssertFalse(compass.wasBlocked)

        let images = WatchUnderwaterNavigationClampPolicy.clampIfNeeded(
            selectedPage: .userImages,
            activity: .diving,
            divingMode: .gauge,
            isSessionActive: true,
            hasUserImages: true,
            includeModeSelection: false
        )
        XCTAssertFalse(images.wasBlocked)
    }

    func testDivingActiveNoImagesBlocksUserImages() {
        let result = WatchUnderwaterNavigationClampPolicy.clampIfNeeded(
            selectedPage: .userImages,
            activity: .diving,
            divingMode: .gauge,
            isSessionActive: true,
            hasUserImages: false,
            includeModeSelection: false
        )
        XCTAssertTrue(result.wasBlocked)
        XCTAssertEqual(result.page, .live)
        XCTAssertEqual(result.blockedPage, .userImages)
    }

    func testDivingActiveBlocksSettingsAndLogbook() {
        let settings = WatchUnderwaterNavigationClampPolicy.clampIfNeeded(
            selectedPage: .settings,
            activity: .diving,
            divingMode: .gauge,
            isSessionActive: true,
            hasUserImages: true,
            includeModeSelection: false
        )
        XCTAssertTrue(settings.wasBlocked)
        XCTAssertEqual(settings.page, .live)

        let logbook = WatchUnderwaterNavigationClampPolicy.clampIfNeeded(
            selectedPage: .diveLog,
            activity: .diving,
            divingMode: .gauge,
            isSessionActive: true,
            hasUserImages: true,
            includeModeSelection: false
        )
        XCTAssertTrue(logbook.wasBlocked)
        XCTAssertEqual(logbook.page, .live)
    }

    func testApneaActiveOnlyLive() {
        let compass = WatchUnderwaterNavigationClampPolicy.clampIfNeeded(
            selectedPage: .compass,
            activity: .apnea,
            divingMode: .gauge,
            isSessionActive: true,
            hasUserImages: false,
            includeModeSelection: false
        )
        XCTAssertTrue(compass.wasBlocked)
        XCTAssertEqual(compass.page, .live)

        let live = WatchUnderwaterNavigationClampPolicy.clampIfNeeded(
            selectedPage: .live,
            activity: .apnea,
            divingMode: .gauge,
            isSessionActive: true,
            hasUserImages: false,
            includeModeSelection: false
        )
        XCTAssertFalse(live.wasBlocked)
    }

    func testSnorkelingActiveOnlyLive() {
        let settings = WatchUnderwaterNavigationClampPolicy.clampIfNeeded(
            selectedPage: .settings,
            activity: .snorkeling,
            divingMode: .gauge,
            isSessionActive: true,
            hasUserImages: false,
            includeModeSelection: false
        )
        XCTAssertTrue(settings.wasBlocked)
    }

    func testBlockedMessageKeysPerActivity() {
        XCTAssertEqual(WatchUnderwaterNavigationClampPolicy.blockedMessageKey(activity: .diving), "nav.underwater.blocked.diving")
        XCTAssertEqual(WatchUnderwaterNavigationClampPolicy.blockedMessageKey(activity: .apnea), "nav.underwater.blocked.apnea")
        XCTAssertEqual(WatchUnderwaterNavigationClampPolicy.blockedMessageKey(activity: .snorkeling), "nav.underwater.blocked.snorkeling")
    }
}
