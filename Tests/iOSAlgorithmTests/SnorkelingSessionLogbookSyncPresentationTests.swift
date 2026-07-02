import XCTest

final class SnorkelingSessionLogbookSyncPresentationTests: XCTestCase {
    func testWatchSessionShowsWatchSourceLabel() {
        let session = sampleSession(startMode: .watch)
        let presentation = SnorkelingSessionLogbookSyncPresentationPolicy.make(
            session: session,
            aggregateState: .imported,
            sessionBadge: .none
        )
        XCTAssertEqual(presentation.sourceKey, "snorkeling.logbook.source.watch")
        XCTAssertNil(presentation.badgeKey)
    }

    func testManualSessionShowsManualSourceLabel() {
        let session = sampleSession(startMode: .manual)
        let presentation = SnorkelingSessionLogbookSyncPresentationPolicy.make(
            session: session,
            aggregateState: .localOnly,
            sessionBadge: .none
        )
        XCTAssertEqual(presentation.sourceKey, "snorkeling.logbook.source.manual")
    }

    func testImportedSessionShowsImportedSourceLabel() {
        let session = sampleSession(startMode: .imported)
        let presentation = SnorkelingSessionLogbookSyncPresentationPolicy.make(
            session: session,
            aggregateState: .localOnly,
            sessionBadge: .none
        )
        XCTAssertEqual(presentation.sourceKey, "snorkeling.logbook.source.imported")
    }

    func testFailedSessionBadgeOnListAndDetail() {
        let session = sampleSession(startMode: .watch)
        let presentation = SnorkelingSessionLogbookSyncPresentationPolicy.make(
            session: session,
            aggregateState: .failed("decode"),
            sessionBadge: .failed("decode")
        )
        XCTAssertEqual(presentation.badgeKey, "snorkeling.logbook.sync.failed_row")
        XCTAssertTrue(presentation.badgeIsWarning)
        XCTAssertEqual(presentation.guidanceKey, "snorkeling.logbook.sync.retry_guidance")
    }

    func testPendingSessionBadgeOnListAndDetail() {
        let session = sampleSession(startMode: .watch)
        let presentation = SnorkelingSessionLogbookSyncPresentationPolicy.make(
            session: session,
            aggregateState: .localOnly,
            sessionBadge: .pending
        )
        XCTAssertEqual(presentation.badgeKey, "snorkeling.logbook.sync.pending_row")
        XCTAssertTrue(presentation.badgeIsWarning)
        XCTAssertEqual(presentation.guidanceKey, "snorkeling.logbook.sync.pending_guidance")
    }

    func testAggregateFailureSurfacesForWatchSessionWithoutPerSessionBadge() {
        let session = sampleSession(startMode: .watch)
        let presentation = SnorkelingSessionLogbookSyncPresentationPolicy.make(
            session: session,
            aggregateState: .failed("transport"),
            sessionBadge: .none
        )
        XCTAssertEqual(presentation.badgeKey, "snorkeling.logbook.sync.failed_row")
        XCTAssertEqual(presentation.guidanceKey, "snorkeling.logbook.sync.retry_guidance")
    }

    private func sampleSession(startMode: SnorkelingSessionStartMode) -> SnorkelingSession {
        SnorkelingSession(startMode: startMode, state: .completed)
    }
}
