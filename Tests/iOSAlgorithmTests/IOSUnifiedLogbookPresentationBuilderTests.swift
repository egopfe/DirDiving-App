import XCTest
@testable import DIRDivingiOSApp

final class IOSUnifiedLogbookPresentationBuilderTests: XCTestCase {
    func testBuildWithOnlyDivingSessionsReturnsOnlyDivingEntries() {
        let dive = makeDiveSession(start: Date(timeIntervalSince1970: 1_000))
        let entries = IOSUnifiedLogbookPresentationBuilder.build(
            divingSessions: [dive],
            snorkelingSessions: [],
            apneaSessions: []
        )
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.activity, .diving)
    }

    func testBuildWithOnlySnorkelingSessionsReturnsOnlySnorkelingEntries() {
        let session = SnorkelingSession(startMode: .manual, state: .completed)
        let entries = IOSUnifiedLogbookPresentationBuilder.build(
            divingSessions: [],
            snorkelingSessions: [session],
            apneaSessions: []
        )
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.activity, .snorkeling)
    }

    func testBuildWithOnlyApneaSessionsReturnsOnlyApneaEntries() {
        let session = ApneaSession(startMode: .manual, state: .completed)
        let entries = IOSUnifiedLogbookPresentationBuilder.build(
            divingSessions: [],
            snorkelingSessions: [],
            apneaSessions: [session]
        )
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.activity, .apnea)
    }

    func testBuildWithAllThreeReturnsAllEntries() {
        let dive = makeDiveSession(start: Date(timeIntervalSince1970: 1_000))
        let snorkel = SnorkelingSession(startMode: .manual, state: .completed)
        let apnea = ApneaSession(startMode: .manual, state: .completed)
        let entries = IOSUnifiedLogbookPresentationBuilder.build(
            divingSessions: [dive],
            snorkelingSessions: [snorkel],
            apneaSessions: [apnea]
        )
        XCTAssertEqual(entries.count, 3)
        XCTAssertEqual(Set(entries.map(\.activity)), Set(IOSUnifiedLogbookActivityKind.allCases))
    }

    func testEntriesSortedByDateDescending() {
        let older = makeDiveSession(start: Date(timeIntervalSince1970: 1_000))
        let newer = makeDiveSession(start: Date(timeIntervalSince1970: 2_000))
        let entries = IOSUnifiedLogbookPresentationBuilder.build(
            divingSessions: [older, newer],
            snorkelingSessions: [],
            apneaSessions: []
        )
        XCTAssertEqual(entries.map(\.sourceID), [newer.id, older.id])
    }

    func testEntryIDsAreActivityPrefixedAndCollisionSafe() {
        let dive = makeDiveSession(start: Date(timeIntervalSince1970: 1_000))
        let entry = IOSUnifiedLogbookPresentationBuilder.build(
            divingSessions: [dive],
            snorkelingSessions: [],
            apneaSessions: []
        ).first!
        XCTAssertEqual(entry.id, "diving-\(dive.id.uuidString)")
        XCTAssertEqual(entry.sourceID, dive.id)
    }

    func testMetricsAreNotEmpty() {
        let dive = makeDiveSession(start: Date(timeIntervalSince1970: 1_000))
        let snorkel = SnorkelingSession(startMode: .manual, state: .completed)
        let apnea = ApneaSession(startMode: .manual, state: .completed)
        let entries = IOSUnifiedLogbookPresentationBuilder.build(
            divingSessions: [dive],
            snorkelingSessions: [snorkel],
            apneaSessions: [apnea]
        )
        for entry in entries {
            XCTAssertFalse(entry.title.isEmpty)
            XCTAssertFalse(entry.primaryMetric.isEmpty)
            XCTAssertFalse(entry.subtitle.isEmpty)
        }
    }

    func testFakeDemoEntriesExcludedByDefault() {
        let demoDive = makeDiveSession(id: DemoDiveCatalog.sessionIDs[0], start: Date(timeIntervalSince1970: 1_000), isDemo: true)
        let demoSnorkel = FakeSnorkelingLogbookProvider.entries().first!
        let demoApnea = FakeApneaLogbookProvider.entries().first!
        let entries = IOSUnifiedLogbookPresentationBuilder.build(
            divingSessions: [demoDive],
            snorkelingSessions: [demoSnorkel],
            apneaSessions: [demoApnea],
            includeDemo: false
        )
        XCTAssertTrue(entries.isEmpty)
    }

    func testSelectionMappingFromEntries() {
        let dive = makeDiveSession(start: Date(timeIntervalSince1970: 1_000))
        let entry = IOSUnifiedLogbookPresentationBuilder.build(
            divingSessions: [dive],
            snorkelingSessions: [],
            apneaSessions: []
        ).first!
        let selection: IOSUnifiedLogbookSelection
        switch entry.activity {
        case .diving: selection = .diving(entry.sourceID)
        case .snorkeling: selection = .snorkeling(entry.sourceID)
        case .apnea: selection = .apnea(entry.sourceID)
        }
        if case .diving(let id) = selection {
            XCTAssertEqual(id, dive.id)
        } else {
            XCTFail("Expected diving selection")
        }
    }

    private func makeDiveSession(
        id: UUID = UUID(),
        start: Date,
        isDemo: Bool = false
    ) -> DiveSession {
        let end = start.addingTimeInterval(120)
        let samples = [
            DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 20),
            DiveSample(timestamp: end, depthMeters: 18, temperatureCelsius: 19),
        ]
        let summary = DiveProfileMath.summary(samples: samples, startDate: start, endDate: end)
        return DiveSession(
            id: id,
            startDate: start,
            endDate: end,
            durationSeconds: summary.durationSeconds,
            maxDepthMeters: summary.maxDepthMeters,
            avgDepthMeters: summary.averageDepthMeters,
            avgWaterTemperatureCelsius: summary.averageTemperatureCelsius,
            ttv: summary.ttv,
            entryGPS: nil,
            exitGPS: nil,
            samples: samples,
            isDemo: isDemo
        )
    }
}
