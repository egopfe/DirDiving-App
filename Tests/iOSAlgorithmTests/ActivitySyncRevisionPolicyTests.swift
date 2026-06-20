import XCTest

final class ActivitySyncRevisionPolicyTests: XCTestCase {
    func testHigherRevisionAccepted() {
        XCTAssertEqual(ActivitySyncRevisionPolicy.compare(existing: 1, incoming: 2), .acceptIncoming)
    }

    func testLowerRevisionStale() {
        XCTAssertEqual(ActivitySyncRevisionPolicy.compare(existing: 3, incoming: 2), .stale)
    }

    func testSameRevisionIdempotent() {
        XCTAssertEqual(ActivitySyncRevisionPolicy.compare(existing: 2, incoming: 2), .idempotent)
    }

    func testSameRevisionDifferentHashIsConflict() {
        XCTAssertEqual(
            ActivitySyncRevisionPolicy.compare(
                existing: 2,
                incoming: 2,
                existingContentHash: "a",
                incomingContentHash: "b"
            ),
            .conflictSameRevisionDifferentHash
        )
    }
}
