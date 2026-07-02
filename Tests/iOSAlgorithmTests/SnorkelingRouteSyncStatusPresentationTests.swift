import XCTest

@MainActor
final class SnorkelingRouteSyncStatusPresentationTests: XCTestCase {
    func testAcknowledgedStateMapsToActivated() {
        let presentation = SnorkelingRouteSyncStatusPresentationPolicy.make(
            state: .acknowledged(packageID: UUID(), revision: 2, syncedAt: Date()),
            routeName: "Reef",
            lastSuccessfulSyncAt: nil,
            lastErrorMessage: nil
        )
        XCTAssertEqual(presentation.revision, 2)
        XCTAssertEqual(presentation.statusSummaryKey, "snorkeling.route_sync.activated")
        if case .imported = presentation.ackStatus {} else {
            XCTFail("Expected imported ack status")
        }
    }

    func testStaleRevisionRejectedMapsToRejected() {
        let presentation = SnorkelingRouteSyncStatusPresentationPolicy.make(
            state: .failed(messageKey: "snorkeling.ios.watch.stale_revision"),
            routeName: "Reef",
            lastSuccessfulSyncAt: nil,
            lastErrorMessage: "snorkeling.ios.watch.stale_revision"
        )
        XCTAssertEqual(presentation.statusSummaryKey, "snorkeling.route_sync.rejected")
        if case .rejected = presentation.ackStatus {} else {
            XCTFail("Expected rejected ack status")
        }
    }

    func testPendingWhileAwaitingAck() {
        let presentation = SnorkelingRouteSyncStatusPresentationPolicy.make(
            state: .awaitingAck(packageID: UUID(), revision: 1, checksum: "abc"),
            routeName: "Reef",
            lastSuccessfulSyncAt: nil,
            lastErrorMessage: nil
        )
        XCTAssertTrue(presentation.pendingActivation)
        XCTAssertEqual(presentation.statusSummaryKey, "snorkeling.route_sync.pending")
    }
}
