import XCTest

/// Regression coverage for Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md
/// post-remediation verification (@ 8147b3f+).
final class BuhlmannComprehensiveReadinessRemediationV1Tests: XCTestCase {
    private let environment = PlannerEnvironment.seaLevelSaltWater
    private let air = CCRDiluent.air
    private let trimix = CCRDiluent(mixKind: .trimix, oxygenPercent: 18, heliumPercent: 45)

    // MARK: - IOS-CCR-P1-001 density (extended)

    func testAirDiluentDensityAtSurface10And60m() {
        let d0 = requireDensity(depth: 0, setpoint: 0.7)
        let d10 = requireDensity(depth: 10, setpoint: 0.7)
        let d60 = requireDensity(depth: 60, setpoint: 1.3)
        XCTAssertGreaterThan(d10, d0)
        XCTAssertGreaterThan(d60, d10)
    }

    func testTrimixDensityAt30And60m() {
        let d30 = requireDensity(depth: 30, setpoint: 1.3, diluent: trimix)
        let d60 = requireDensity(depth: 60, setpoint: 1.3, diluent: trimix)
        XCTAssertGreaterThan(d60, d30)
    }

    func testLowAndHighSetpointDensityOrderingAt30m() {
        let low = requireDensity(depth: 30, setpoint: 0.7)
        let high = requireDensity(depth: 30, setpoint: 1.3)
        XCTAssertNotEqual(low, high, accuracy: 0.01)
    }

    func testSetpointAboveDryAmbientIsUnavailable() {
        let result = CCRGasDensityEstimator.estimate(
            setpointBar: 5.0,
            diluent: air,
            depthMeters: 0,
            environment: environment
        )
        XCTAssertEqual(result, .unavailable(reason: .setpointAboveDryAmbient))
    }

    func testNegativeDepthIsUnavailable() {
        let result = CCRGasDensityEstimator.estimate(
            setpointBar: 1.0,
            diluent: air,
            depthMeters: -1,
            environment: environment
        )
        XCTAssertEqual(result, .unavailable(reason: .invalidDepth))
    }

    func testDensityThresholdDangerClassification() {
        let danger = IOSAlgorithmConfiguration.gasDensityDangerGramsPerLiter
        let result = CCRGasDensityResult.available(valueGramsPerLiter: danger + 0.1)
        XCTAssertEqual(result.classification(), .danger)
    }

    func testDensityUnavailableNeverReturnsZeroGramsPerLiter() {
        let result = CCRGasDensityEstimator.estimate(
            setpointBar: -1,
            diluent: air,
            depthMeters: 20,
            environment: environment
        )
        XCTAssertNil(result.gramsPerLiter)
    }

    // MARK: - IOS-CCR-P1-002 exposure

    func testUnavailableExposureDoesNotSerializeAsZeroInPDFPath() throws {
        var input = CCRPlanInput.default
        input.bailoutGases = []
        let plan = CCRPlannerService.makePlan(input: input)
        XCTAssertFalse(plan.hasAvailableOxygenExposure)
        XCTAssertNil(plan.oxygenExposure.cnsPercent)
        XCTAssertNil(plan.oxygenExposure.otu)
        let context = PDFExportCCRPlannerContext(
            input: input,
            plan: plan,
            safetyAcknowledged: true,
            unitPreference: .metric
        )
        XCTAssertFalse(PDFExportService.canExportCCRPlan(context))
    }

    func testValidCCRPlanExposureStableAcrossRepeatedRuns() {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas()]
        let first = CCRPlannerService.makePlan(input: input)
        let second = CCRPlannerService.makePlan(input: input)
        guard let firstCNS = first.oxygenExposure.cnsPercent,
              let secondCNS = second.oxygenExposure.cnsPercent,
              let firstOTU = first.oxygenExposure.otu,
              let secondOTU = second.oxygenExposure.otu else {
            XCTFail("Expected available exposure")
            return
        }
        XCTAssertEqual(firstCNS, secondCNS, accuracy: 0.001)
        XCTAssertEqual(firstOTU, secondOTU, accuracy: 0.001)
    }

    // MARK: - Policy A bailout

    func testHeuristicBailoutNotInCanonicalCCRSchedule() {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas(mixKind: .ean, oxygenPercent: 32, switchDepthMeters: 0)]
        let plan = CCRPlannerService.makePlan(input: input)
        XCTAssertFalse(plan.schedule.contains { $0.note.localizedCaseInsensitiveContains("bailout") })
        XCTAssertFalse(plan.decoStops.contains { $0.gas.localizedCaseInsensitiveContains("bailout") })
    }

    func testRatioDecoBlockedInCCRMode() {
        var input = BuhlmannTestSupport.gasPlanInput()
        input.plannedDepthMeters = 40
        input.plannedBottomMinutes = 20
        let schedule = RatioDecoPlanner.makeSchedule(
            input: input,
            mode: .ccr,
            preset: .preset1to1,
            environment: environment,
            descentMinutes: 4
        )
        XCTAssertNotNil(schedule)
        XCTAssertTrue(schedule?.warnings.contains(.unavailableInCCRMode) ?? false)
        XCTAssertTrue(schedule?.stops.isEmpty ?? false)
    }

    // MARK: - Diluent trace

    func testNoAirDiluentInExposureIntegrationSource() {
        let segments = [(DiveSegmentKind.bottom, 30.0, 30.0, 20.0, 1.3)]
        let mapped = segments.map { ($0.0, $0.1, $0.2, $0.3, $0.4) }
        switch CCROxygenExposureIntegration.exposure(segments: mapped, diluent: trimix, environment: environment) {
        case .success:
            let gas = CCRInspiredGasModel.labelGas(diluent: trimix, setpointBar: 1.3, depthMeters: 30, environment: environment)
            XCTAssertFalse(gas.name.uppercased().hasPrefix("AIR"))
        case .failure(let error):
            XCTFail("\(error)")
        }
    }

    // MARK: - Localization keys

    func testCCRExposureAndBailoutLocalizationKeysExist() {
        let keys = [
            "ccr.exposure.unavailable.label",
            "ccr.exposure.unavailable.numericalFailure",
            "ccr.bailout.heuristic_disclaimer",
            "ccr.bailout.limitation.not_oc_deco"
        ]
        for key in keys {
            XCTAssertFalse(DIRIOSLocalizer.string(key, language: .english).isEmpty, key)
            XCTAssertFalse(DIRIOSLocalizer.string(key, language: .italian).isEmpty, key)
        }
    }

    private func requireDensity(depth: Double, setpoint: Double, diluent: CCRDiluent? = nil) -> Double {
        let result = CCRGasDensityEstimator.estimate(
            setpointBar: setpoint,
            diluent: diluent ?? air,
            depthMeters: depth,
            environment: environment
        )
        guard case .available(let value) = result else {
            XCTFail("Expected density at \(depth)m")
            return 0
        }
        return value
    }
}
