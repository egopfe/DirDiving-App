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

    func testFreshTissuesRequireExplicitSnapshot() {
        let request = BuhlmannPlanner.makeRequest(input: sampleInput(), environment: environment)
        switch RepetitiveDivePlannerService.seedRequest(request, snapshot: nil, surfaceIntervalMinutes: 0, environment: environment) {
        case .success:
            XCTFail("Fresh planning must not silently seed from nil snapshot")
        case .failure(.missing):
            break
        case .failure(let error):
            XCTFail("Expected missing snapshot, got \(error)")
        }
    }

    func testMediumSurfaceIntervalOffGassesBetweenShortAndLong() throws {
        let snapshot = try XCTUnwrap(makeSnapshot(fromBottomMinutes: 25))
        let short = try XCTUnwrap(seededTissues(snapshot: snapshot, surfaceMinutes: 30))
        let medium = try XCTUnwrap(seededTissues(snapshot: snapshot, surfaceMinutes: 120))
        let long = try XCTUnwrap(seededTissues(snapshot: snapshot, surfaceMinutes: 480))
        let shortSum = short.compartments.map(\.nitrogenPressure).reduce(0, +)
        let mediumSum = medium.compartments.map(\.nitrogenPressure).reduce(0, +)
        let longSum = long.compartments.map(\.nitrogenPressure).reduce(0, +)
        XCTAssertGreaterThan(shortSum, mediumSum)
        XCTAssertGreaterThan(mediumSum, longSum)
    }

    func testOneSecondBeforeStalenessBoundaryIsAccepted() {
        let snapshot = TissueSnapshot(
            createdAt: Date().addingTimeInterval(-(TissueSnapshot.maxAge - 1)),
            plannerEnvironment: environment,
            tissueState: .airSaturated()
        )
        switch RepetitiveDivePlannerService.validateSnapshot(snapshot) {
        case .success:
            break
        case .failure(let error):
            XCTFail("Expected acceptance one second before boundary, got \(error)")
        }
    }

    func testInvalidNegativeSurfaceIntervalIsRejected() throws {
        let snapshot = try XCTUnwrap(makeSnapshot(fromBottomMinutes: 10))
        let request = BuhlmannPlanner.makeRequest(input: sampleInput(), environment: environment)
        switch RepetitiveDivePlannerService.seedRequest(request, snapshot: snapshot, surfaceIntervalMinutes: -1, environment: environment) {
        case .success:
            XCTFail("Expected invalid surface interval rejection")
        case .failure(.invalidSurfaceInterval):
            break
        case .failure(let error):
            XCTFail("Expected invalidSurfaceInterval, got \(error)")
        }
    }

    func testSchemaMismatchSnapshotIsRejected() {
        let snapshot = TissueSnapshot(
            createdAt: Date(),
            plannerEnvironment: environment,
            tissueState: .airSaturated(),
            schemaVersion: 99
        )
        switch RepetitiveDivePlannerService.validateSnapshot(snapshot) {
        case .success:
            XCTFail("Expected schema mismatch rejection")
        case .failure(.schemaMismatch):
            break
        case .failure(let error):
            XCTFail("Expected schemaMismatch, got \(error)")
        }
    }

    func testTrimixPreviousDiveRetainsHeliumLoading() throws {
        let trimix = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        let input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20, bottomGas: trimix)
        let engine = BuhlmannEngine.plan(BuhlmannPlanner.makeRequest(input: input, environment: environment))
        let snapshot = try XCTUnwrap(RepetitiveDivePlannerService.makeSnapshot(from: engine, environment: environment))
        let seeded = try XCTUnwrap(seededTissues(snapshot: snapshot, surfaceMinutes: 60))
        let heliumSum = seeded.compartments.map(\.heliumPressure).reduce(0, +)
        XCTAssertGreaterThan(heliumSum, 0)
    }

    private func makeAirSnapshot(fromBottomMinutes minutes: Double) -> TissueSnapshot? {
        let air = GasMix(name: "Air", role: .bottom, oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        var input = BuhlmannTestSupport.gasPlanInput(depth: 30, bottomMinutes: minutes, bottomGas: air)
        let engine = BuhlmannEngine.plan(BuhlmannPlanner.makeRequest(input: input, environment: environment))
        return RepetitiveDivePlannerService.makeSnapshot(from: engine, environment: environment)
    }

    func testN2OnlyPreviousDiveHasZeroHeliumAfterOffGas() throws {
        let snapshot = try XCTUnwrap(makeAirSnapshot(fromBottomMinutes: 18))
        let seeded = try XCTUnwrap(seededTissues(snapshot: snapshot, surfaceMinutes: 45))
        XCTAssertEqual(seeded.compartments.map(\.heliumPressure).reduce(0, +), 0, accuracy: 0.001)
    }

    func testSeededStateRetainsSixteenCompartments() throws {
        let snapshot = try XCTUnwrap(makeSnapshot(fromBottomMinutes: 22))
        let seeded = try XCTUnwrap(seededTissues(snapshot: snapshot, surfaceMinutes: 75))
        XCTAssertEqual(seeded.compartments.count, BuhlmannConstants.compartmentCount)
        let fastCompartment = seeded.compartments[0].nitrogenPressure
        let slowCompartment = seeded.compartments[BuhlmannConstants.compartmentCount - 1].nitrogenPressure
        XCTAssertLessThan(fastCompartment, slowCompartment)
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
