import XCTest

final class SnorkelingWatchReturnPrimaryActionTests: XCTestCase {
    func testReturnPrimaryWhenEntryExists() {
        var returnNavigation = SnorkelingReturnNavigationSnapshot.unavailable
        returnNavigation.entryPoint = SnorkelingEntryPoint(
            latitude: 44.4,
            longitude: 8.94,
            capturedAt: Date(),
            monotonicRelativeTimestampSeconds: 0,
            gpsQuality: .measured
        )
        XCTAssertTrue(SnorkelingWatchReturnPrimaryActionPolicy.isReturnAvailable(returnNavigation: returnNavigation))
        XCTAssertEqual(
            SnorkelingWatchReturnPrimaryActionPolicy.returnButtonTitle(isAvailable: true),
            DIRWatchLocalizer.string("snorkeling.return.primary")
        )
        XCTAssertTrue(
            SnorkelingWatchReturnPrimaryActionPolicy.returnIsPrimaryAction(
                isAvailable: true,
                isSessionStarted: true
            )
        )
    }

    func testReturnUnavailableWhenEntryMissing() {
        XCTAssertFalse(
            SnorkelingWatchReturnPrimaryActionPolicy.isReturnAvailable(
                returnNavigation: .unavailable
            )
        )
        XCTAssertEqual(
            SnorkelingWatchReturnPrimaryActionPolicy.returnButtonTitle(isAvailable: false),
            DIRWatchLocalizer.string("snorkeling.return.entry_unavailable")
        )
    }
}
