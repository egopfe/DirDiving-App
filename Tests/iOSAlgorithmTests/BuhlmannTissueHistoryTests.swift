import XCTest

final class BuhlmannTissueHistoryTests: XCTestCase {
    private func decoRequest() -> BuhlmannPlanRequest {
        BuhlmannPlanRequest(
            maxDepthMeters: 40,
            bottomMinutes: 20,
            bottomGas: BuhlmannTestSupport.trimix1845(switchDepth: 40),
            travelGases: [],
            decoGases: [
                BuhlmannTestSupport.ean50(switchDepth: 21),
                BuhlmannTestSupport.oxygen(switchDepth: 6)
            ],
            gfLow: 30,
            gfHigh: 85
        )
    }

    func testTissueHistoryExistsForSuccessfulPlan() {
        let result = BuhlmannEngine.plan(decoRequest())
        XCTAssertFalse(result.hasBlockingIssues)
        XCTAssertFalse(result.tissueHistory.isEmpty)
    }

    func testTissueHistoryContainsSixteenCompartmentsPerTimestamp() {
        let result = BuhlmannEngine.plan(decoRequest())
        let timestamps = Set(result.tissueHistory.samples.map(\.elapsedMinutes))
        XCTAssertFalse(timestamps.isEmpty)
        for time in timestamps {
            let atTime = result.tissueHistory.samples.filter { $0.elapsedMinutes == time }
            XCTAssertEqual(atTime.count, 16)
            XCTAssertEqual(Set(atTime.map(\.compartmentIndex)), Set(0..<16))
        }
    }

    func testTissueHistoryIncludesProfilePhases() {
        let result = BuhlmannEngine.plan(decoRequest())
        let maxElapsed = result.tissueHistory.samples.map(\.elapsedMinutes).max() ?? 0
        XCTAssertGreaterThan(maxElapsed, Double(result.bottomMinutes))
        XCTAssertFalse(result.stops.isEmpty)
    }

    func testGroupedHistoryContainsFourGroups() {
        let result = BuhlmannEngine.plan(decoRequest())
        let groups = Set(result.tissueHistory.groupedPoints.map(\.compartmentGroup))
        XCTAssertEqual(groups, Set(["1-4", "5-8", "9-12", "13-16"]))
    }

    func testGroupedHistoryHasFiniteValues() {
        let result = BuhlmannEngine.plan(decoRequest())
        for point in result.tissueHistory.groupedPoints {
            XCTAssertTrue(point.loadPercent.isFinite)
            XCTAssertTrue(point.supersaturationPercent.isFinite)
            XCTAssertFalse(point.loadPercent.isNaN)
            XCTAssertFalse(point.loadPercent.isInfinite)
            XCTAssertGreaterThanOrEqual(point.loadPercent, 0)
            XCTAssertLessThanOrEqual(point.loadPercent, 100)
        }
    }

    func testGroupedHistoryUpdatesWhenPlanChanges() {
        var shallow = decoRequest()
        shallow.maxDepthMeters = 30
        shallow.bottomMinutes = 10
        let deep = decoRequest()
        let shallowHistory = BuhlmannEngine.plan(shallow).tissueHistory
        let deepHistory = BuhlmannEngine.plan(deep).tissueHistory
        XCTAssertNotEqual(
            shallowHistory.groupedPoints.map(\.loadPercent),
            deepHistory.groupedPoints.map(\.loadPercent)
        )
    }

    func testCompartmentMetricsFailsExplicitlyForInvalidDisplayDepth() {
        let state = BuhlmannTissueState.airSaturated(surfacePressureBar: PlannerEnvironment.seaLevelSaltWater.surfacePressureBar)
        let metrics = BuhlmannTissueHistorySampler.compartmentMetrics(
            compartmentIndex: 0,
            state: state,
            depthMeters: -1,
            gas: BuhlmannTestSupport.nitrox32(),
            gf: 0.85,
            environment: .seaLevelSaltWater
        )
        XCTAssertNil(metrics)
    }

    func testDecompressionOutputsUnchangedAfterAddingTissueSampling() throws {
        let fixtures = try FixtureLoader.loadAll()
        for fixture in fixtures where fixture.isValid {
            let result = BuhlmannEngine.plan(try fixture.makeRequest())
            XCTAssertFalse(result.ttsMinutes < 0)
            if let range = fixture.expectedTTSRangeMinutes {
                XCTAssertGreaterThanOrEqual(Double(result.ttsMinutes), range.min - fixture.toleranceMinutes)
                XCTAssertLessThanOrEqual(Double(result.ttsMinutes), range.max + fixture.toleranceMinutes)
            }
            if let firstStop = fixture.expectedFirstStopDepthMeters {
                XCTAssertEqual(result.stops.first?.depthMeters ?? 0, firstStop, accuracy: fixture.toleranceMinutes)
            }
        }
    }

    func testInvalidPlanReturnsEmptyHistory() {
        var invalid = decoRequest()
        invalid.maxDepthMeters = -1
        let result = BuhlmannEngine.plan(invalid)
        XCTAssertTrue(result.tissueHistory.isEmpty)
    }
}
