import XCTest

final class RepetitiveDiveMathematicalTests: XCTestCase {
    private let environment = PlannerEnvironment.seaLevelSaltWater

    func testMissingSnapshotDoesNotSilentlySeedFreshTissues() {
        let request = BuhlmannPlanner.makeRequest(input: sampleInput(), environment: environment)
        switch RepetitiveDivePlannerService.seedRequest(request, snapshot: nil, surfaceIntervalMinutes: 60, environment: environment) {
        case .success:
            XCTFail("Expected missing snapshot rejection")
        case .failure(.missing):
            break
        case .failure(let error):
            XCTFail("Expected missing, got \(error)")
        }
    }

    func testShortSurfaceIntervalRetainsMoreLoadingThanLongInterval() throws {
        let snapshot = try XCTUnwrap(makeSnapshot(fromBottomMinutes: 20))
        let short = try XCTUnwrap(seededTissues(snapshot: snapshot, surfaceMinutes: 30))
        let long = try XCTUnwrap(seededTissues(snapshot: snapshot, surfaceMinutes: 240))
        let shortSum = short.compartments.map(\.nitrogenPressure).reduce(0, +)
        let longSum = long.compartments.map(\.nitrogenPressure).reduce(0, +)
        XCTAssertGreaterThan(shortSum, longSum)
    }

    func testExactlyFourteenDaySnapshotIsAccepted() throws {
        let base = try XCTUnwrap(makeSnapshot(fromBottomMinutes: 10))
        let snapshot = TissueSnapshot(
            createdAt: Date().addingTimeInterval(-(TissueSnapshot.maxAge - 1)),
            plannerEnvironment: environment,
            tissueState: base.tissueState
        )
        switch RepetitiveDivePlannerService.validateSnapshot(snapshot) {
        case .success:
            break
        case .failure(let error):
            XCTFail("Expected boundary acceptance, got \(error)")
        }
    }

    func testOneSecondAfterStalenessBoundaryIsRejected() {
        let snapshot = TissueSnapshot(
            createdAt: Date().addingTimeInterval(-(TissueSnapshot.maxAge + 1)),
            plannerEnvironment: environment,
            tissueState: .airSaturated()
        )
        switch RepetitiveDivePlannerService.validateSnapshot(snapshot) {
        case .success:
            XCTFail("Expected stale rejection")
        case .failure(.stale):
            break
        case .failure(let error):
            XCTFail("Expected stale, got \(error)")
        }
    }

    func testEnvironmentMismatchIsRejected() throws {
        let base = try XCTUnwrap(makeSnapshot(fromBottomMinutes: 10))
        guard case .success(let mismatchedEnvironment) = PlannerEnvironment.make(altitudeMeters: 1_500, salinity: .salt) else {
            return XCTFail("Expected altitude environment")
        }
        let mismatched = TissueSnapshot(
            createdAt: base.createdAt,
            plannerEnvironment: mismatchedEnvironment,
            tissueState: base.tissueState
        )
        let request = BuhlmannPlanner.makeRequest(input: sampleInput(), environment: environment)
        switch RepetitiveDivePlannerService.seedRequest(request, snapshot: mismatched, surfaceIntervalMinutes: 60, environment: environment) {
        case .success:
            XCTFail("Expected environment mismatch")
        case .failure(.invalidEnvironment):
            break
        case .failure(let error):
            XCTFail("Expected invalidEnvironment, got \(error)")
        }
    }

    func testDeterministicRepeatedCalculation() throws {
        let snapshot = try XCTUnwrap(makeSnapshot(fromBottomMinutes: 15))
        let first = try XCTUnwrap(seededTissues(snapshot: snapshot, surfaceMinutes: 90))
        let second = try XCTUnwrap(seededTissues(snapshot: snapshot, surfaceMinutes: 90))
        XCTAssertEqual(first, second)
    }

    // MARK: - Helpers

    private func sampleInput() -> GasPlanInput {
        BuhlmannTestSupport.gasPlanInput(depth: 30, bottomMinutes: 20)
    }

    private func makeSnapshot(fromBottomMinutes minutes: Double) -> TissueSnapshot? {
        var input = sampleInput()
        input.plannedBottomMinutes = minutes
        let engine = BuhlmannEngine.plan(BuhlmannPlanner.makeRequest(input: input, environment: environment))
        return RepetitiveDivePlannerService.makeSnapshot(from: engine, environment: environment)
    }

    private func seededTissues(snapshot: TissueSnapshot, surfaceMinutes: Double) -> BuhlmannTissueState? {
        let request = BuhlmannPlanner.makeRequest(input: sampleInput(), environment: environment)
        switch RepetitiveDivePlannerService.seedRequest(request, snapshot: snapshot, surfaceIntervalMinutes: surfaceMinutes, environment: environment) {
        case .success(let seeded):
            return seeded.initialTissueState
        case .failure:
            return nil
        }
    }
}
