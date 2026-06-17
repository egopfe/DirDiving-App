import XCTest

final class CCRMathAuditRemediationV1Tests: XCTestCase {
    private let environment = PlannerEnvironment.seaLevelSaltWater
    private let airDiluent = CCRDiluent.air
    private let trimixDiluent = CCRDiluent(mixKind: .trimix, oxygenPercent: 18, heliumPercent: 45)

    // MARK: - IOS-MATH-P1-001 Gas density pressure scaling

    func testGasDensityIncreasesWithDepthForAirDiluent() {
        let surface = density(at: 0, setpoint: 0.7)
        let ten = density(at: 10, setpoint: 0.7)
        let thirty = density(at: 30, setpoint: 1.3)
        let sixty = density(at: 60, setpoint: 1.3)
        XCTAssertGreaterThan(ten, surface)
        XCTAssertGreaterThan(thirty, ten)
        XCTAssertGreaterThan(sixty, thirty)
    }

    func testTrimixDiluentLowerDensityThanAirAtSameDepthAndSetpoint() {
        let air = density(at: 30, setpoint: 1.3, diluent: airDiluent)
        let trimix = density(at: 30, setpoint: 1.3, diluent: trimixDiluent)
        XCTAssertLessThan(trimix, air)
    }

    func testGasDensityUsesPartialPressureFormulaAt30m() {
        guard let inspired = CCRInspiredGasModel.inspiredPressures(
            depthMeters: 30,
            setpointBar: 1.3,
            diluent: airDiluent,
            environment: environment
        ) else {
            XCTFail("Inspired gas unavailable")
            return
        }
        let expected =
            CCRGasDensityConstants.oxygenGramsPerLiterPerBar * inspired.ppO2
            + CCRGasDensityConstants.nitrogenGramsPerLiterPerBar * inspired.ppN2
            + CCRGasDensityConstants.heliumGramsPerLiterPerBar * inspired.ppHe
        let actual = density(at: 30, setpoint: 1.3)
        XCTAssertEqual(actual, expected, accuracy: 0.02)
    }

    func testGasDensityInvalidSetpointIsUnavailable() {
        let result = CCRGasDensityEstimator.estimate(
            setpointBar: 0,
            diluent: airDiluent,
            depthMeters: 20,
            environment: environment
        )
        XCTAssertEqual(result, .unavailable(reason: .invalidSetpoint))
        XCTAssertNil(result.gramsPerLiter)
    }

    func testGasDensityNonFiniteDepthIsUnavailable() {
        let result = CCRGasDensityEstimator.estimate(
            setpointBar: 1.0,
            diluent: airDiluent,
            depthMeters: .nan,
            environment: environment
        )
        if case .unavailable = result {
            XCTAssertNil(result.gramsPerLiter)
        } else {
            XCTFail("Expected unavailable density")
        }
    }

    func testGasDensityClassificationUsesFullPrecisionBeforeDisplayRounding() {
        let warning = IOSAlgorithmConfiguration.gasDensityWarningGramsPerLiter
        let value = warning + 0.04
        let result = CCRGasDensityResult.available(valueGramsPerLiter: value)
        XCTAssertEqual(result.classification(), .warning)
        XCTAssertEqual(Formatters.one(value), Formatters.one(warning))
    }

    // MARK: - IOS-MATH-P1-002 Oxygen exposure unavailable semantics

    func testValidCCRPlanHasAvailableOxygenExposure() {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas()]
        let plan = CCRPlannerService.makePlan(input: input)
        XCTAssertTrue(plan.hasAvailableOxygenExposure)
        XCTAssertGreaterThan(plan.oxygenExposure.cnsPercent ?? 0, 0)
    }

    func testInvalidCCRPlanMarksOxygenExposureUnavailable() {
        var input = CCRPlanInput.default
        input.bailoutGases = []
        let plan = CCRPlannerService.makePlan(input: input)
        XCTAssertFalse(plan.hasAvailableOxygenExposure)
        XCTAssertEqual(plan.oxygenExposure.cnsPercent, nil)
        XCTAssertEqual(plan.oxygenExposure.otu, nil)
    }

    func testUnavailableOxygenExposureBlocksPDFExport() {
        var input = CCRPlanInput.default
        input.bailoutGases = []
        let plan = CCRPlannerService.makePlan(input: input)
        let context = PDFExportCCRPlannerContext(
            input: input,
            plan: plan,
            safetyAcknowledged: true,
            unitPreference: .metric
        )
        XCTAssertFalse(PDFExportService.canExportCCRPlan(context))
    }

    func testExposureIntegrationUsesActualTrimixDiluentLabel() {
        let segments: [(DiveSegmentKind, Double, Double, Double, Double)] = [
            (.bottom, 30, 30, 20, 1.3)
        ]
        let mapped = segments.map { ($0.0, $0.1, $0.2, $0.3, $0.4) }
        switch CCROxygenExposureIntegration.exposure(
            segments: mapped,
            diluent: trimixDiluent,
            environment: environment
        ) {
        case .success:
            break
        case .failure(let error):
            XCTFail("Expected success, got \(error)")
        }
    }

    // MARK: - IOS-MATH-P2-001 Bailout heuristic metadata

    func testBailoutScenarioIncludesHeuristicMetadata() {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas(mixKind: .ean, oxygenPercent: 32, switchDepthMeters: 0)]
        let scenario = CCRBailoutScenarioCalculator.evaluate(
            kind: .lostLoop,
            input: input,
            environment: environment
        )
        XCTAssertEqual(scenario.method, .heuristic)
        XCTAssertTrue(scenario.isHeuristic)
        XCTAssertFalse(scenario.limitations.isEmpty)
        XCTAssertFalse(scenario.assumptions.isEmpty)
        XCTAssertTrue(scenario.referenceNotes.contains(DIRIOSLocalizer.string("ccr.bailout.heuristic_disclaimer")))
    }

    // MARK: - IOS-MATH-P3-001 Diluent trace

    func testLabelGasReflectsTrimixDiluent() {
        let gas = CCRInspiredGasModel.labelGas(
            diluent: trimixDiluent,
            setpointBar: 1.3,
            depthMeters: 30,
            environment: environment
        )
        XCTAssertTrue(gas.name.contains("TX 18/45"))
        XCTAssertGreaterThan(gas.heliumFraction, 0.4)
    }

    private func density(at depth: Double, setpoint: Double, diluent: CCRDiluent? = nil) -> Double {
        let result = CCRGasDensityEstimator.estimate(
            setpointBar: setpoint,
            diluent: diluent ?? airDiluent,
            depthMeters: depth,
            environment: environment
        )
        guard case .available(let value) = result else {
            XCTFail("Expected available density at \(depth)m")
            return 0
        }
        return value
    }
}
