import XCTest

final class WatchSyncApplicationContextGateTests: XCTestCase {
    func testApplicationContextRequiresActivatedPairedInstalledWatch() {
        XCTAssertFalse(
            WatchSyncAuth.isApplicationContextDeliveryReady(
                activationState: .notActivated,
                isPaired: true,
                isWatchAppInstalled: true
            )
        )
        XCTAssertFalse(
            WatchSyncAuth.isApplicationContextDeliveryReady(
                activationState: .activated,
                isPaired: false,
                isWatchAppInstalled: true
            )
        )
        XCTAssertFalse(
            WatchSyncAuth.isApplicationContextDeliveryReady(
                activationState: .activated,
                isPaired: true,
                isWatchAppInstalled: false
            )
        )
        XCTAssertTrue(
            WatchSyncAuth.isApplicationContextDeliveryReady(
                activationState: .activated,
                isPaired: true,
                isWatchAppInstalled: true
            )
        )
    }
}
