import XCTest
@testable import DIRDivingiOSApp

@MainActor
final class FakeApneaLogbookProviderTests: XCTestCase {
    func testGeneratesAtLeastFiveSessions() {
        XCTAssertGreaterThanOrEqual(FakeApneaLogbookProvider.entries().count, FakeApneaLogbookProvider.minimumEntryCount)
    }

    func testAllSessionsUseDemoCatalogIDs() {
        for session in FakeApneaLogbookProvider.entries() {
            XCTAssertTrue(DemoApneaSessionCatalog.isDemoSession(id: session.id))
            XCTAssertEqual(session.state, .completed)
            XCTAssertFalse(session.dives.isEmpty)
        }
    }

    func testProviderDoesNotWriteToRealStore() {
        let store = IOSApneaLogbookStore()
        let beforeCount = store.sessions.count
        _ = FakeApneaLogbookProvider.entries()
        XCTAssertEqual(store.sessions.count, beforeCount)
    }
}
