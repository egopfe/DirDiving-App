import XCTest

@MainActor
final class SnorkelingWatchSyncStatusPresentationTests: XCTestCase {
    func testPendingLabelWhenWatchQueueHasSessions() {
        let presentation = SnorkelingWatchSyncStatusPresentationPolicy.make(
            sessionSyncState: .localOnly,
            pendingWatchToIOSSessionCount: 2
        )
        XCTAssertEqual(presentation.statusKey, "snorkeling.sync.status.pending")
        XCTAssertEqual(presentation.pendingSessionCount, 2)
    }

    func testDeliveredLabelForImportedSession() {
        let presentation = SnorkelingWatchSyncStatusPresentationPolicy.make(
            sessionSyncState: .imported,
            pendingWatchToIOSSessionCount: 0
        )
        XCTAssertEqual(presentation.statusKey, "snorkeling.sync.status.delivered")
        if case .delivered = presentation.deliveryStatus {} else {
            XCTFail("Expected delivered status")
        }
    }

    func testFailedLabelForImportFailure() {
        let presentation = SnorkelingWatchSyncStatusPresentationPolicy.make(
            sessionSyncState: .failed("decode"),
            pendingWatchToIOSSessionCount: 0
        )
        XCTAssertEqual(presentation.statusKey, "snorkeling.sync.status.failed")
        if case .failed("decode") = presentation.deliveryStatus {} else {
            XCTFail("Expected failed status")
        }
    }
}
