import XCTest
@testable import DIRDivingiOSApp

@MainActor
final class FakeSnorkelingLogbookProviderTests: XCTestCase {
    func testGeneratesAtLeastFiveSessions() {
        XCTAssertGreaterThanOrEqual(FakeSnorkelingLogbookProvider.entries().count, FakeSnorkelingLogbookProvider.minimumEntryCount)
    }

    func testAllSessionsUseDemoCatalogIDs() {
        for session in FakeSnorkelingLogbookProvider.entries() {
            XCTAssertTrue(DemoSnorkelingSessionCatalog.isDemoSession(id: session.id))
            XCTAssertEqual(session.state, .completed)
            XCTAssertFalse(session.trackPoints.isEmpty)
            XCTAssertNotNil(session.entryPoint)
        }
    }

    func testProviderDoesNotWriteToRealStore() {
        let store = IOSSnorkelingLogbookStore()
        let beforeCount = store.sessions.count
        _ = FakeSnorkelingLogbookProvider.entries()
        XCTAssertEqual(store.sessions.count, beforeCount)
    }
}
