import XCTest
@testable import DIRDivingiOSApp

final class ApneaDemoLogbookPresentationTests: XCTestCase {
    func testToggleOffShowsOnlyRealLogs() {
        let real = [ApneaSession(startMode: .manual, state: .completed)]
        let entries = IOSLogbookDisplayComposer.apneaEntries(realSessions: real, demoSessions: [])
        XCTAssertEqual(entries.count, 1)
        XCTAssertTrue(entries.allSatisfy { $0.origin == .real })
    }

    func testToggleOnIncludesDemoSection() {
        let demo = FakeApneaLogbookProvider.entries()
        let entries = IOSLogbookDisplayComposer.apneaEntries(realSessions: [], demoSessions: demo)
        XCTAssertEqual(entries.count, demo.count)
        XCTAssertTrue(entries.allSatisfy(\.isDemo))
    }

    func testMixedRealAndDemoAreSeparated() {
        let real = [ApneaSession(startMode: .manual, state: .completed)]
        let demo = FakeApneaLogbookProvider.entries()
        let entries = IOSLogbookDisplayComposer.apneaEntries(realSessions: real, demoSessions: demo)
        XCTAssertEqual(IOSLogbookDisplayComposer.realApneaSessions(from: entries).count, 1)
        XCTAssertEqual(entries.filter(\.isDemo).count, demo.count)
    }

    func testStatisticsExcludeDemoCatalogIDs() {
        let real = ApneaSession(startMode: .manual, state: .completed)
        let demo = FakeApneaLogbookProvider.entries().first!
        let combined = [real, demo]
        let statsSessions = combined.filter { !DemoApneaSessionCatalog.isDemoSession(id: $0.id) }
        XCTAssertEqual(statsSessions.count, 1)
    }
}
