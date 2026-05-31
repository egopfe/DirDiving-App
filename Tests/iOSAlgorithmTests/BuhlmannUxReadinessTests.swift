import XCTest

final class BuhlmannUxReadinessTests: XCTestCase {
    private let safetyCriticalStates: [PlannerResultState] = [
        .snapshotMissing,
        .snapshotStale,
        .snapshotCorrupt,
        .snapshotSchemaMismatch,
        .snapshotEnvironmentMismatch,
        .surfaceIntervalRejected,
        .gasAllocationIncomplete,
        .missingCylinder,
        .noValidDecompressionSolution,
        .invalidEnvironment,
        .oxygenExposureElevated
    ]

    func testAllPlannerResultStatesHaveUserFacingCopy() {
        for state in PlannerResultState.allCases {
            let message = state.userFacingMessage
            XCTAssertFalse(message.title.isEmpty, "Missing title for \(state.rawValue)")
            XCTAssertFalse(message.message.isEmpty, "Missing message for \(state.rawValue)")
            XCTAssertFalse(message.id.isEmpty)
        }
    }

    func testSafetyCriticalStatesAreNotGeneric() {
        for state in safetyCriticalStates {
            let message = state.userFacingMessage
            XCTAssertNotNil(message.correctiveHint, "Expected corrective hint for \(state.rawValue)")
            XCTAssertNotEqual(message.severity, .info)
            XCTAssertFalse(message.title.isEmpty)
            XCTAssertFalse(message.message.isEmpty)
        }
    }

    func testSnapshotErrorsMapToDistinctStates() {
        let mapping: [(RepetitiveDivePlannerService.SnapshotError, PlannerResultState)] = [
            (.missing, .snapshotMissing),
            (.corrupted, .snapshotCorrupt),
            (.stale, .snapshotStale),
            (.schemaMismatch, .snapshotSchemaMismatch),
            (.invalidEnvironment, .snapshotEnvironmentMismatch),
            (.invalidSurfaceInterval, .surfaceIntervalRejected)
        ]
        for (error, expected) in mapping {
            XCTAssertEqual(PlannerUserFacingCopy.snapshotIssue(for: error), expected)
        }
    }

    func testRepetitivePlanningEnabledWithoutSnapshotSurfacesMissingState() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 30, bottomMinutes: 18)
        let plan = PlannerService.makePlan(
            input: input,
            repetitivePlanningEnabled: true,
            repetitiveSnapshot: nil,
            surfaceIntervalMinutes: 60
        )
        XCTAssertEqual(plan.repetitiveContext?.snapshotIssue, .snapshotMissing)
        XCTAssertFalse(plan.repetitiveContext?.tissueStateApplied ?? true)
        XCTAssertTrue(plan.states.contains(.snapshotMissing))
    }

    func testRepetitivePlanningAppliedWhenSnapshotValid() throws {
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
            surfaceIntervalMinutes: 45
        )
        XCTAssertTrue(plan.repetitiveContext?.tissueStateApplied ?? false)
        XCTAssertTrue(plan.states.contains(.repetitivePlanningActive))
        XCTAssertEqual(plan.resultHeader.kind, .repetitiveReferencePlan)
    }

    func testScheduleGasLedgerIsExposedPerCylinder() {
        let input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        let plan = PlannerService.makePlan(input: input)
        XCTAssertNotNil(plan.gasLedger)
        XCTAssertFalse(plan.gasLedger?.entries.isEmpty ?? true)
        XCTAssertNil(plan.gasLedgerFailure)
    }

    func testEnvironmentInvalidMessageMatchesValidator() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 30, bottomMinutes: 18)
        input.altitudeMeters = 10_000
        let validation = PlannerInputValidator.validate(input)
        XCTAssertTrue(validation.states.contains(.invalidEnvironment))
        XCTAssertTrue(
            validation.messages.contains(where: { $0.contains(String(localized: "planner.environment.invalid_altitude.message")) })
                || validation.messages.contains(where: { $0.localizedCaseInsensitiveContains("4500") })
        )
    }

    func testEnvironmentActiveSummaryWhenAltitudeSet() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 30, bottomMinutes: 18)
        input.altitudeMeters = 1500
        let plan = PlannerService.makePlan(input: input)
        XCTAssertTrue(plan.environmentSummary?.isActive ?? false)
        XCTAssertGreaterThan(plan.environmentSummary?.surfacePressureBar ?? 0, 0)
    }

    func testNoDecoVersusDecoRequiredHeaders() {
        let shallow = BuhlmannTestSupport.gasPlanInput(depth: 18, bottomMinutes: 10)
        let noDecoPlan = PlannerService.makePlan(input: shallow)
        XCTAssertEqual(noDecoPlan.resultHeader.kind, .noDecoReference)

        var decoInput = BuhlmannTestSupport.gasPlanInput(depth: 55, bottomMinutes: 30)
        decoInput.gfLow = 30
        decoInput.gfHigh = 70
        let decoPlan = PlannerService.makePlan(input: decoInput)
        if decoPlan.decoStops.isEmpty {
            XCTAssertNotEqual(decoPlan.resultHeader.kind, .decoRequiredReference)
        } else {
            XCTAssertEqual(decoPlan.resultHeader.kind, .decoRequiredReference)
        }
    }

    func testOxygenExposureStateIncludesReferencePositioning() {
        let message = PlannerResultState.oxygenExposureElevated.userFacingMessage
        XCTAssertEqual(message.severity, .warning)
        XCTAssertNotNil(message.correctiveHint)
        XCTAssertTrue(message.message.localizedCaseInsensitiveContains("CNS") || message.title.localizedCaseInsensitiveContains("oxygen"))
    }

    func testReferenceHeadersUseNonCertifiedSeverityMix() {
        XCTAssertEqual(PlannerUserFacingCopy.header(for: .noDecoReference).severity, .info)
        XCTAssertEqual(PlannerUserFacingCopy.header(for: .decoRequiredReference).severity, .warning)
        XCTAssertEqual(PlannerUserFacingCopy.header(for: .invalidInput).severity, .blocking)
        XCTAssertEqual(PlannerUserFacingCopy.header(for: .noValidDecompressionSolution).severity, .blocking)
    }

    func testGasLedgerFailureHasCorrectiveCopy() {
        let failures: [GasLedgerFailureReason] = [
            .invalidSegment,
            .invalidCylinder,
            .missingCylinder(UUID())
        ]
        for failure in failures {
            XCTAssertFalse(failure.userFacingMessage.title.isEmpty)
            XCTAssertNotNil(failure.userFacingMessage.correctiveHint)
            XCTAssertEqual(failure.userFacingMessage.severity, .blocking)
        }
    }
}
