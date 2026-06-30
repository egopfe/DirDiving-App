import XCTest
@testable import DIRDivingiOSApp

final class SnorkelingDemoLogbookPresentationTests: XCTestCase {
    func testToggleOffShowsOnlyRealLogs() {
        let real = [SnorkelingSession(startMode: .manual, state: .completed)]
        let entries = IOSLogbookDisplayComposer.snorkelingEntries(realSessions: real, demoSessions: [])
        XCTAssertEqual(entries.count, 1)
        XCTAssertTrue(entries.allSatisfy { $0.origin == .real })
    }

    func testToggleOnIncludesDemoSection() {
        let demo = FakeSnorkelingLogbookProvider.entries()
        let entries = IOSLogbookDisplayComposer.snorkelingEntries(realSessions: [], demoSessions: demo)
        XCTAssertEqual(entries.count, demo.count)
        XCTAssertTrue(entries.allSatisfy(\.isDemo))
    }

    func testMixedRealAndDemoAreSeparated() {
        let real = [SnorkelingSession(startMode: .manual, state: .completed)]
        let demo = FakeSnorkelingLogbookProvider.entries()
        let entries = IOSLogbookDisplayComposer.snorkelingEntries(realSessions: real, demoSessions: demo)
        XCTAssertEqual(IOSLogbookDisplayComposer.realSnorkelingSessions(from: entries).count, 1)
        XCTAssertEqual(entries.filter(\.isDemo).count, demo.count)
    }

    func testStatisticsExcludeDemoCatalogIDs() {
        let real = SnorkelingSession(startMode: .manual, state: .completed)
        let demo = FakeSnorkelingLogbookProvider.entries().first!
        let combined = [real, demo]
        let statsSessions = combined.filter { !DemoSnorkelingSessionCatalog.isDemoSession(id: $0.id) }
        XCTAssertEqual(statsSessions.count, 1)
    }
}
