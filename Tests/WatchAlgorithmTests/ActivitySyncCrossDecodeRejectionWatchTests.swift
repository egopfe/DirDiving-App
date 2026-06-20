import XCTest

final class ActivitySyncCrossDecodeRejectionWatchTests: XCTestCase {
    func testActivityPayloadKeysAreDistinct() {
        XCTAssertNotEqual(WatchDiveSyncCodec.payloadKey, ApneaSessionSyncCodec.payloadKey)
        XCTAssertNotEqual(ApneaSessionSyncCodec.payloadKey, SnorkelingSessionSyncCodec.payloadKey)
        XCTAssertNotEqual(WatchDiveSyncCodec.payloadKey, SnorkelingSessionSyncCodec.payloadKey)
    }

    func testEnvelopeActivitiesMatchPayloadKeys() {
        XCTAssertEqual(ActivitySyncActivityType.diving.payloadKey, WatchDiveSyncCodec.payloadKey)
        XCTAssertEqual(ActivitySyncActivityType.apnea.payloadKey, ApneaSessionSyncCodec.payloadKey)
        XCTAssertEqual(ActivitySyncActivityType.snorkeling.payloadKey, SnorkelingSessionSyncCodec.payloadKey)
    }
}
