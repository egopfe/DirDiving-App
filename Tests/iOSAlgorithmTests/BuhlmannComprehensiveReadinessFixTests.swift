import XCTest

final class BuhlmannComprehensiveReadinessFixTests: XCTestCase {
    private let ndlAlignmentToleranceMinutes = 0.5

    func testAirSaturatedDefaultMatchesSeaLevelSaltWaterEnvironment() {
        let defaultState = BuhlmannTissueState.airSaturated()
        let explicitState = BuhlmannTissueState.airSaturated(
            surfacePressureBar: PlannerEnvironment.seaLevelSaltWater.surfacePressureBar
        )
        XCTAssertEqual(defaultState, explicitState)
        XCTAssertEqual(BuhlmannConstants.seaLevelSurfacePressureBar, 1.01325, accuracy: 0.00001)
    }

    func testPreviewNDLChangesWithAltitude() {
        let gas = GasMix(name: "Air", role: .bottom, oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        guard case .success(let sea) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .salt),
              case .success(let altitude) = PlannerEnvironment.make(altitudeMeters: 1_500, salinity: .salt) else {
            return XCTFail("Expected valid environments")
        }
        let seaPreview = BuhlmannPlanner.plan(depthMeters: 30, bottomGas: gas, environment: sea)
        let altitudePreview = BuhlmannPlanner.plan(depthMeters: 30, bottomGas: gas, environment: altitude)
        XCTAssertEqual(seaPreview.modelState, .validReference)
        XCTAssertEqual(altitudePreview.modelState, .validReference)
        XCTAssertNotEqual(seaPreview.ndlMinutes, altitudePreview.ndlMinutes)
        XCTAssertGreaterThan(seaPreview.ndlMinutes, altitudePreview.ndlMinutes)
    }

    func testPreviewNDLChangesWithSalinity() {
        let gas = GasMix(name: "Air", role: .bottom, oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        guard case .success(let salt) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .salt),
              case .success(let fresh) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .fresh) else {
            return XCTFail("Expected valid environments")
        }
        let saltPreview = BuhlmannPlanner.plan(depthMeters: 30, bottomGas: gas, environment: salt)
        let freshPreview = BuhlmannPlanner.plan(depthMeters: 30, bottomGas: gas, environment: fresh)
        XCTAssertNotEqual(saltPreview.ndlMinutes, freshPreview.ndlMinutes)
        XCTAssertGreaterThan(freshPreview.ndlMinutes, saltPreview.ndlMinutes)
    }

    func testPreviewNDLAlignsWithPlanNDLForSameEnvironment() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 30, bottomMinutes: 18)
        input.salinity = .salt
        input.altitudeMeters = 0
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            return XCTFail("Expected valid environment")
        }
        let preview = BuhlmannPlanner.plan(
            depthMeters: input.buhlmannPlanningDepthMeters,
            bottomGas: input.buhlmannBackGas,
            environment: environment,
            gfHigh: input.gfHigh
        )
        let plan = PlannerService.makePlan(input: input)
        XCTAssertEqual(preview.modelState, .validReference)
        XCTAssertLessThanOrEqual(abs(preview.ndlMinutes - plan.ndlMinutes), ndlAlignmentToleranceMinutes)
    }

    func testBuhlmannGasNilEnvironmentUsesSeaLevelSaltwaterConstantsNotLegacyOneBar() {
        let gas = BuhlmannTestSupport.air()
        let legacyOneBar = IOSUnitConversions.ambientPressureBar(depthMeters: 30)
        let buhlmannFallback = gas.inspiredPressure(depthMeters: 30, inert: .nitrogen, environment: nil)
        let explicitSea = gas.inspiredPressure(depthMeters: 30, inert: .nitrogen, environment: .seaLevelSaltWater)
        XCTAssertEqual(buhlmannFallback, explicitSea, accuracy: 0.0001)
        XCTAssertNotEqual(legacyOneBar, PlannerEnvironment.seaLevelSaltWater.surfacePressureBar + (30 * 0.1), accuracy: 0.001)
    }

    func testInvalidSurfaceIntervalEmitsSurfaceIntervalRejected() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 30, bottomMinutes: 18)
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            return XCTFail("Expected valid environment")
        }
        let engine = BuhlmannEngine.plan(BuhlmannPlanner.makeRequest(input: input, environment: environment))
        guard let snapshot = RepetitiveDivePlannerService.makeSnapshot(from: engine, environment: environment) else {
            return XCTFail("Expected snapshot")
        }
        let plan = PlannerService.makePlan(
            input: input,
            repetitivePlanningEnabled: true,
            repetitiveSnapshot: snapshot,
            surfaceIntervalMinutes: -5
        )
        XCTAssertEqual(plan.repetitiveContext?.snapshotIssue, .surfaceIntervalRejected)
        XCTAssertTrue(plan.states.contains(.surfaceIntervalRejected))
    }

    func testMissingSnapshotShowsMissingState() {
        let input = BuhlmannTestSupport.gasPlanInput(depth: 30, bottomMinutes: 18)
        let plan = PlannerService.makePlan(
            input: input,
            repetitivePlanningEnabled: true,
            repetitiveSnapshot: nil,
            surfaceIntervalMinutes: 60
        )
        XCTAssertEqual(plan.repetitiveContext?.snapshotIssue, .snapshotMissing)
    }

    func testStaleSnapshotShowsStaleState() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 30, bottomMinutes: 18)
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            return XCTFail("Expected valid environment")
        }
        let engine = BuhlmannEngine.plan(BuhlmannPlanner.makeRequest(input: input, environment: environment))
        guard var snapshot = RepetitiveDivePlannerService.makeSnapshot(from: engine, environment: environment) else {
            return XCTFail("Expected snapshot")
        }
        snapshot = TissueSnapshot(
            createdAt: Date().addingTimeInterval(-(TissueSnapshot.maxAge + 60)),
            plannerEnvironment: snapshot.plannerEnvironment,
            tissueState: snapshot.tissueState,
            schemaVersion: snapshot.schemaVersion
        )
        let plan = PlannerService.makePlan(
            input: input,
            repetitivePlanningEnabled: true,
            repetitiveSnapshot: snapshot,
            surfaceIntervalMinutes: 45
        )
        XCTAssertEqual(plan.repetitiveContext?.snapshotIssue, .snapshotStale)
    }

    func testSchemaMismatchSnapshotShowsSchemaMismatchState() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 30, bottomMinutes: 18)
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            return XCTFail("Expected valid environment")
        }
        let engine = BuhlmannEngine.plan(BuhlmannPlanner.makeRequest(input: input, environment: environment))
        guard let snapshot = RepetitiveDivePlannerService.makeSnapshot(from: engine, environment: environment) else {
            return XCTFail("Expected snapshot")
        }
        let mismatched = TissueSnapshot(
            createdAt: snapshot.createdAt,
            plannerEnvironment: snapshot.plannerEnvironment,
            tissueState: snapshot.tissueState,
            schemaVersion: snapshot.schemaVersion + 1
        )
        let plan = PlannerService.makePlan(
            input: input,
            repetitivePlanningEnabled: true,
            repetitiveSnapshot: mismatched,
            surfaceIntervalMinutes: 45
        )
        XCTAssertEqual(plan.repetitiveContext?.snapshotIssue, .snapshotSchemaMismatch)
    }

    func testGFComparisonCacheDoesNotChangeOutputs() {
        let request = BuhlmannTestSupport.request(depth: 40, bottomMinutes: 20, bottomGas: BuhlmannTestSupport.trimix1845(switchDepth: 40))
        BuhlmannPlanner.clearGFComparisonCacheForTesting()
        let first = BuhlmannPlanner.gfComparisons(baseRequest: request)
        let second = BuhlmannPlanner.gfComparisons(baseRequest: request)
        XCTAssertEqual(first.count, second.count)
        zip(first, second).forEach { lhs, rhs in
            XCTAssertEqual(lhs.label, rhs.label)
            XCTAssertEqual(lhs.ttsMinutes, rhs.ttsMinutes)
            XCTAssertEqual(lhs.stopCount, rhs.stopCount)
            XCTAssertEqual(lhs.gfLow, rhs.gfLow)
            XCTAssertEqual(lhs.gfHigh, rhs.gfHigh)
        }
    }

    func testSurfaceIntervalRejectedHasUserFacingCopy() {
        let message = PlannerResultState.surfaceIntervalRejected.userFacingMessage
        XCTAssertFalse(message.title.isEmpty)
        XCTAssertFalse(message.message.isEmpty)
        XCTAssertNotNil(message.correctiveHint)
    }

    func testInvalidSurfaceIntervalErrorMapsToSurfaceIntervalRejected() {
        XCTAssertEqual(
            PlannerUserFacingCopy.snapshotIssue(for: .invalidSurfaceInterval),
            .surfaceIntervalRejected
        )
    }

    func testBailoutLocalizationPresent() {
        let hint = String(localized: "planner.bailout.schedule_hint")
        XCTAssertFalse(hint.isEmpty)
        XCTAssertTrue(hint.localizedCaseInsensitiveContains("Bühlmann") || hint.localizedCaseInsensitiveContains("bailout"))
    }

    func testRepetitiveNotFromLogLocalizationPresent() {
        let copy = String(localized: "planner.repetitive.not_from_log")
        XCTAssertTrue(copy.localizedCaseInsensitiveContains("log") || copy.localizedCaseInsensitiveContains("logbook"))
    }
}
