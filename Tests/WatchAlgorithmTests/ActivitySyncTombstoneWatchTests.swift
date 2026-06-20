import XCTest

final class ActivitySyncTombstoneWatchTests: XCTestCase {
    func testApneaTombstoneBroadcastKeyDistinctFromDiving() {
        XCTAssertNotEqual(
            ActivitySyncTombstoneBroadcast.broadcastKey(for: .diving),
            ActivitySyncTombstoneBroadcast.broadcastKey(for: .apnea)
        )
        XCTAssertNotEqual(
            ActivitySyncTombstoneBroadcast.broadcastKey(for: .apnea),
            ActivitySyncTombstoneBroadcast.broadcastKey(for: .snorkeling)
        )
    }
}
