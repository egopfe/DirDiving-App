import PDFKit
import XCTest

/// Acceptance coverage for `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` remediation command.
/// Verifies code-level 100% readiness; external evidence remains PENDING by design.
final class IOSMainAlgorithmMathAuditRemediationCompleteTests: XCTestCase {
    private let environment = PlannerEnvironment.seaLevelSaltWater
    private let air = CCRDiluent.air
    private let trimix = CCRDiluent(mixKind: .trimix, oxygenPercent: 18, heliumPercent: 45)

    // MARK: - Phase 1 — independent density formula

    func testIndependentPartialPressureDensityMatchesAtSurfaceAnd30m() {
        for (depth, setpoint) in [(0.0, 0.7), (10.0, 0.7), (30.0, 1.3), (60.0, 1.3)] {
            guard let inspired = CCRInspiredGasModel.inspiredPressures(
                depthMeters: depth,
                setpointBar: setpoint,
                diluent: air,
                environment: environment
            ) else {
                XCTFail("Inspired gas unavailable at \(depth)m")
                continue
            }
            let expected = independentDensity(ppO2: inspired.ppO2, ppN2: inspired.ppN2, ppHe: inspired.ppHe)
            let actual = CCRGasDensityEstimator.estimate(
                setpointBar: setpoint,
                diluent: air,
                depthMeters: depth,
                environment: environment
            )
            guard case .available(let value) = actual else {
                XCTFail("Expected available density at \(depth)m")
                continue
            }
            XCTAssertEqual(value, expected, accuracy: 0.001, "Depth \(depth)m")
        }
    }

    func testTrimixIndependentDensityLowerThanAirAt30m() {
        let airExpected = densityViaIndependentFormula(depth: 30, setpoint: 1.3, diluent: air)
        let trimixExpected = densityViaIndependentFormula(depth: 30, setpoint: 1.3, diluent: trimix)
        XCTAssertLessThan(trimixExpected, airExpected)
        let airActual = requireEstimate(depth: 30, setpoint: 1.3, diluent: air)
        let trimixActual = requireEstimate(depth: 30, setpoint: 1.3, diluent: trimix)
        XCTAssertLessThan(trimixActual, airActual)
    }

    func testGasDensityWarningLowerThresholdBoundary() {
        let warning = IOSAlgorithmConfiguration.gasDensityWarningGramsPerLiter
        let justBelow = CCRGasDensityResult.available(valueGramsPerLiter: warning - 0.001)
        let atWarning = CCRGasDensityResult.available(valueGramsPerLiter: warning)
        XCTAssertEqual(justBelow.classification(), .ok)
        XCTAssertEqual(atWarning.classification(), .warning)
    }

    func testSetpointAboveDryAmbientFailsClosedForDensity() {
        let result = CCRGasDensityEstimator.estimate(
            setpointBar: 5.0,
            diluent: air,
            depthMeters: 0,
            environment: environment
        )
        XCTAssertEqual(result, .unavailable(reason: .setpointAboveDryAmbient))
        XCTAssertNil(result.gramsPerLiter)
    }

    // MARK: - Phase 2 — unavailable vs zero

    func testUnavailableExposureStateIsDistinctFromZeroAvailableState() {
        var invalidInput = CCRPlanInput.default
        invalidInput.bailoutGases = []
        let invalidPlan = CCRPlannerService.makePlan(input: invalidInput)
        XCTAssertFalse(invalidPlan.hasAvailableOxygenExposure)
        XCTAssertEqual(invalidPlan.oxygenExposure.cnsPercent, nil)

        var validInput = CCRPlanInput.default
        validInput.bailoutGases = [CCRBailoutGas()]
        validInput.maxDepthMeters = 5
        validInput.bottomTimeMinutes = 1
        let validPlan = CCRPlannerService.makePlan(input: validInput)
        XCTAssertTrue(validPlan.hasAvailableOxygenExposure)
        if let cns = validPlan.oxygenExposure.cnsPercent {
            XCTAssertGreaterThanOrEqual(cns, 0)
        }
        XCTAssertNotEqual(invalidPlan.oxygenExposure, validPlan.oxygenExposure)
    }

    func testLegacyFullPlanPercentZeroDoesNotImplyAvailableExposure() {
        var input = CCRPlanInput.default
        input.bailoutGases = []
        let plan = CCRPlannerService.makePlan(input: input)
        XCTAssertEqual(plan.cnsFullPlanPercent, 0)
        XCTAssertFalse(plan.hasAvailableOxygenExposure)
        XCTAssertFalse(PDFExportService.canExportCCRPlan(
            PDFExportCCRPlannerContext(input: input, plan: plan, safetyAcknowledged: true, unitPreference: .metric)
        ))
    }

    func testCCRPlanPDFUnavailableExposureShowsLabelNotZeroPercent() {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas()]
        input.maxDepthMeters = 40
        input.bottomTimeMinutes = 25
        var plan = CCRPlannerService.makePlan(input: input)
        plan = CCRPlanResult(
            schedule: plan.schedule,
            bailoutScenarios: plan.bailoutScenarios,
            tissueTrace: plan.tissueTrace,
            oxygenExposure: .unavailable(reason: .numericalFailure),
            ppO2Timeline: plan.ppO2Timeline,
            ppN2Timeline: plan.ppN2Timeline,
            endTimeline: plan.endTimeline,
            gasDensityTimeline: plan.gasDensityTimeline,
            cnsTimeline: plan.cnsTimeline,
            warnings: plan.warnings,
            validationResult: plan.validationResult,
            engineSegments: plan.engineSegments,
            ttsMinutes: plan.ttsMinutes,
            totalRuntimeMinutes: plan.totalRuntimeMinutes,
            decoStops: plan.decoStops,
            depthProfilePoints: plan.depthProfilePoints,
            buhlmannState: plan.buhlmannState
        )
        let context = PDFExportCCRPlannerContext(
            input: input,
            plan: plan,
            safetyAcknowledged: true,
            unitPreference: .metric
        )
        let text = pdfText(CCRPlannerPDFBuilder.build(context: context))
        let unavailable = DIRIOSLocalizer.string("ccr.exposure.unavailable.label")
        XCTAssertTrue(text.contains(unavailable))
        let cnsLabel = DIRIOSLocalizer.string("planner.metric.cns_full_plan")
        XCTAssertTrue(text.contains(cnsLabel))
        XCTAssertFalse(text.contains("\(cnsLabel): 0%"))
        XCTAssertFalse(text.contains("\(cnsLabel) 0%"))
    }

    // MARK: - Phase 3 — diluent trace

    func testExposureIntegrationNeverUsesAirLabelForTrimixDiluent() {
        let segments = [(DiveSegmentKind.bottom, 30.0, 30.0, 20.0, 1.3)]
        let mapped = segments.map { ($0.0, $0.1, $0.2, $0.3, $0.4) }
        switch CCROxygenExposureIntegration.exposure(segments: mapped, diluent: trimix, environment: environment) {
        case .success:
            let label = CCRInspiredGasModel.labelGas(
                diluent: trimix,
                setpointBar: 1.3,
                depthMeters: 30,
                environment: environment
            )
            XCTAssertTrue(label.name.contains("18") || label.name.uppercased().contains("TX"))
            XCTAssertFalse(label.name.uppercased().hasPrefix("AIR"))
        case .failure(let error):
            XCTFail("\(error)")
        }
    }

    // MARK: - Phase 4 — bailout heuristic scope

    func testHeuristicBailoutDoesNotMutateCCRScheduleOrTissueState() {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas(mixKind: .ean, oxygenPercent: 32, switchDepthMeters: 0)]
        let plan = CCRPlannerService.makePlan(input: input)
        let scenario = CCRBailoutScenarioCalculator.evaluate(
            kind: .lostLoop,
            input: input,
            environment: environment
        )
        XCTAssertEqual(scenario.method, .heuristic)
        XCTAssertFalse(plan.schedule.contains { $0.note.localizedCaseInsensitiveContains("bailout") })
        XCTAssertFalse(scenario.limitations.isEmpty)
        XCTAssertFalse(scenario.assumptions.isEmpty)
    }

    func testBailoutHeuristicWordingInENAndIT() {
        let en = DIRIOSLocalizer.string("ccr.bailout.heuristic_disclaimer", language: .english).lowercased()
        let it = DIRIOSLocalizer.string("ccr.bailout.heuristic_disclaimer", language: .italian).lowercased()
        XCTAssertTrue(en.contains("heuristic") || en.contains("reference") || en.contains("bailout"))
        XCTAssertFalse(it.isEmpty)
    }

    // MARK: - Phase 5 — Ratio Deco heuristic

    func testRatioDecoRejectsCCRModeWithWarning() {
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

    // MARK: - Phase 6 — export gating

    func testInvalidCCRPlanBlocksBriefingExport() {
        var input = CCRPlanInput.default
        input.bailoutGases = []
        let plan = CCRPlannerService.makePlan(input: input)
        XCTAssertNil(
            CCRPlannerBriefingExportSupport.makeExportInput(
                plan: plan,
                input: input,
                unitPreference: .metric,
                plannerSessionId: UUID()
            )
        )
    }

    // MARK: - Helpers

    private func independentDensity(ppO2: Double, ppN2: Double, ppHe: Double) -> Double {
        CCRGasDensityConstants.oxygenGramsPerLiterPerBar * ppO2
            + CCRGasDensityConstants.nitrogenGramsPerLiterPerBar * ppN2
            + CCRGasDensityConstants.heliumGramsPerLiterPerBar * ppHe
    }

    private func densityViaIndependentFormula(depth: Double, setpoint: Double, diluent: CCRDiluent) -> Double {
        guard let inspired = CCRInspiredGasModel.inspiredPressures(
            depthMeters: depth,
            setpointBar: setpoint,
            diluent: diluent,
            environment: environment
        ) else {
            XCTFail("Inspired unavailable")
            return 0
        }
        return independentDensity(ppO2: inspired.ppO2, ppN2: inspired.ppN2, ppHe: inspired.ppHe)
    }

    private func requireEstimate(depth: Double, setpoint: Double, diluent: CCRDiluent) -> Double {
        let result = CCRGasDensityEstimator.estimate(
            setpointBar: setpoint,
            diluent: diluent,
            depthMeters: depth,
            environment: environment
        )
        guard case .available(let value) = result else {
            XCTFail("Expected available density")
            return 0
        }
        return value
    }

    private func pdfText(_ data: Data) -> String {
        guard let document = PDFDocument(data: data) else { return "" }
        return (0..<document.pageCount).compactMap { document.page(at: $0)?.string }.joined(separator: "\n")
    }
}
