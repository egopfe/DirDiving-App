import XCTest
@testable import DIRDivingiOSApp

final class IOSUnifiedLogbookNoContaminationTests: XCTestCase {
    func testMapperDoesNotMutateSourceSessions() {
        var dive = makeDiveSession(start: Date(timeIntervalSince1970: 1_000))
        var snorkel = SnorkelingSession(startMode: .manual, state: .completed)
        var apnea = ApneaSession(startMode: .manual, state: .completed)
        let diveBefore = dive
        let snorkelBefore = snorkel
        let apneaBefore = apnea

        _ = IOSUnifiedLogbookPresentationBuilder.build(
            divingSessions: [dive],
            snorkelingSessions: [snorkel],
            apneaSessions: [apnea]
        )

        XCTAssertEqual(dive, diveBefore)
        XCTAssertEqual(snorkel, snorkelBefore)
        XCTAssertEqual(apnea, apneaBefore)
    }

    func testUnifiedBuilderIsPureOverInputCollections() {
        let diving = [makeDiveSession(start: Date(timeIntervalSince1970: 1_000))]
        let snorkeling = [SnorkelingSession(startMode: .manual, state: .completed)]
        let apnea = [ApneaSession(startMode: .manual, state: .completed)]
        let divingCount = diving.count
        let snorkelingCount = snorkeling.count
        let apneaCount = apnea.count

        let first = IOSUnifiedLogbookPresentationBuilder.build(
            divingSessions: diving,
            snorkelingSessions: snorkeling,
            apneaSessions: apnea
        )
        let second = IOSUnifiedLogbookPresentationBuilder.build(
            divingSessions: diving,
            snorkelingSessions: snorkeling,
            apneaSessions: apnea
        )

        XCTAssertEqual(diving.count, divingCount)
        XCTAssertEqual(snorkeling.count, snorkelingCount)
        XCTAssertEqual(apnea.count, apneaCount)
        XCTAssertEqual(first, second)
    }

    func testFakeDemoEntriesExcludedFromRealUnifiedEntries() {
        let demoDive = makeDiveSession(id: DemoDiveCatalog.sessionIDs[0], start: Date(timeIntervalSince1970: 1_000), isDemo: true)
        let realDive = makeDiveSession(start: Date(timeIntervalSince1970: 2_000))
        let entries = IOSUnifiedLogbookPresentationBuilder.build(
            divingSessions: [demoDive, realDive],
            snorkelingSessions: FakeSnorkelingLogbookProvider.entries(),
            apneaSessions: FakeApneaLogbookProvider.entries()
        )
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.activity, .diving)
        XCTAssertFalse(entries.first?.isDemo ?? true)
    }

    func testActivitySpecificOffBehaviorUsesOnlyCurrentActivitySessions() {
        let dive = makeDiveSession(start: Date(timeIntervalSince1970: 1_000))
        let snorkelingOnly = IOSUnifiedLogbookPresentationBuilder.build(
            divingSessions: [],
            snorkelingSessions: [SnorkelingSession(startMode: .manual, state: .completed)],
            apneaSessions: []
        )
        let divingOnly = IOSUnifiedLogbookPresentationBuilder.build(
            divingSessions: [dive],
            snorkelingSessions: [],
            apneaSessions: []
        )
        XCTAssertTrue(snorkelingOnly.allSatisfy { $0.activity == .snorkeling })
        XCTAssertTrue(divingOnly.allSatisfy { $0.activity == .diving })
    }

    func testUnifiedSelectionRoutesToCorrectActivityDetailKind() {
        let diveID = UUID()
        let snorkelID = UUID()
        let apneaID = UUID()
        let selections: [IOSUnifiedLogbookSelection] = [
            .diving(diveID),
            .snorkeling(snorkelID),
            .apnea(apneaID)
        ]
        XCTAssertEqual(selections[0].id, "diving-\(diveID.uuidString)")
        XCTAssertEqual(selections[1].id, "snorkeling-\(snorkelID.uuidString)")
        XCTAssertEqual(selections[2].id, "apnea-\(apneaID.uuidString)")
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
