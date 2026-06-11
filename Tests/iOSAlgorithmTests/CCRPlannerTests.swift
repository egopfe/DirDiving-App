import XCTest

final class CCRPlannerTests: XCTestCase {
    func testDefaultCCRInputProducesValidPlan() {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas(mixKind: .ean, oxygenPercent: 32, switchDepthMeters: 0)]
        let plan = CCRPlannerService.makePlan(input: input)
        XCTAssertTrue(plan.validationResult.isValid)
        XCTAssertFalse(plan.schedule.isEmpty)
        XCTAssertTrue(plan.cnsFullPlanPercent.isFinite)
        XCTAssertTrue(plan.otuFullPlan.isFinite)
    }

    func testCCRInspiredGasUsesSetpointNotDiluentFO2ForInert() {
        let diluent = CCRDiluent(mixKind: .air, oxygenPercent: 21, heliumPercent: 0)
        let env = PlannerEnvironment.seaLevelSaltWater
        let inspired = CCRInspiredGasModel.inspiredPressures(
            depthMeters: 30,
            setpointBar: 1.3,
            diluent: diluent,
            environment: env
        )
        XCTAssertNotNil(inspired)
        XCTAssertEqual(inspired?.ppO2 ?? 0, 1.3, accuracy: 0.01)
        XCTAssertGreaterThan(inspired?.ppN2 ?? 0, 0)
    }

    func testPureOxygenDiluentBlocked() {
        var input = CCRPlanInput.default
        input.diluent.mixKind = .oxygen
        input.diluent.applyMixKind(.oxygen)
        let plan = CCRPlannerService.makePlan(input: input)
        XCTAssertFalse(plan.validationResult.isValid)
    }

    func testSetpointSwitchingUsesLowThenHigh() {
        let profile = CCRSetpointProfile(lowSetpoint: 0.7, highSetpoint: 1.3, switchDepthMeters: 20)
        XCTAssertEqual(profile.activeSetpointBar(depthMeters: 10), 0.7, accuracy: 0.001)
        XCTAssertEqual(profile.activeSetpointBar(depthMeters: 25), 1.3, accuracy: 0.001)
    }

    func testNoNegativeInertPressureWhenAmbientBelowSetpoint() {
        let diluent = CCRDiluent.air
        let env = PlannerEnvironment.seaLevelSaltWater
        let inspired = CCRInspiredGasModel.inspiredPressures(
            depthMeters: 0,
            setpointBar: 1.5,
            diluent: diluent,
            environment: env
        )
        XCTAssertNotNil(inspired)
        XCTAssertEqual(inspired?.ppN2 ?? -1, 0, accuracy: 0.001)
        XCTAssertEqual(inspired?.ppHe ?? -1, 0, accuracy: 0.001)
    }

    func testBailoutScenariosEvaluate() {
        var input = CCRPlanInput.default
        input.bailoutGases = [
            CCRBailoutGas(mixKind: .ean, oxygenPercent: 32, tankSize: .liters12, startPressure: 200, reservePressure: 50, switchDepthMeters: 0)
        ]
        let scenarios = CCRBailoutScenarioCalculator.evaluateAll(input: input, environment: .seaLevelSaltWater)
        XCTAssertEqual(scenarios.count, CCRBailoutScenarioKind.allCases.count)
    }

    func testOCPlannerModePolicyUnchangedForBase() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 25
        let projected = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        XCTAssertEqual(projected.plannerCylinders.filter { $0.role == .deco }.count, 0)
    }

    func testCCRModeSkipsOCProjection() {
        let validation = PlannerModePolicy.validate(draft: GasPlanInput(), mode: .ccr)
        XCTAssertTrue(validation.isValid)
    }

    func testTissueTraceFinite() {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas()]
        let plan = CCRPlannerService.makePlan(input: input)
        XCTAssertTrue(plan.validationResult.isValid)
        XCTAssertFalse(plan.tissueTrace.samples.isEmpty)
    }

    func testManualShallowAscentUsesLowSetpointOnAscent() {
        var profile = CCRSetpointProfile(
            lowSetpoint: 0.7,
            highSetpoint: 1.3,
            switchDepthMeters: 20,
            mode: .manual,
            useLowSetpointOnShallowAscent: true,
            shallowAscentSetpointDepthMeters: 6
        )
        XCTAssertEqual(profile.activeSetpointBar(depthMeters: 30, isAscent: true), 1.3, accuracy: 0.001)
        XCTAssertEqual(profile.activeSetpointBar(depthMeters: 5, isAscent: true), 0.7, accuracy: 0.001)
        XCTAssertEqual(profile.activeSetpointBar(depthMeters: 5, isAscent: false), 0.7, accuracy: 0.001)
    }

    func testCNSTimelineTracksExposure() {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas(mixKind: .ean, oxygenPercent: 32, switchDepthMeters: 0)]
        let plan = CCRPlannerService.makePlan(input: input)
        XCTAssertTrue(plan.validationResult.isValid)
        XCTAssertGreaterThan(plan.cnsTimeline.count, 1)
        XCTAssertEqual(plan.cnsTimeline.first?.cnsPercent ?? -1, 0, accuracy: 0.001)
        XCTAssertEqual(
            plan.cnsTimeline.last?.cnsPercent ?? -1,
            plan.cnsFullPlanPercent,
            accuracy: 0.5
        )
    }

    func testCCRScheduleIncludesDescentPhaseWithRuntimeLabels() {
        let plan = CCRPlannerService.makePlan(input: .default)
        XCTAssertTrue(plan.validationResult.isValid)
        XCTAssertTrue(plan.schedule.contains(where: { $0.phase == .descent }))
        XCTAssertEqual(DiveSegmentKind.stop.runtimeRowTitle, PlannerAscentRowKind.decoStop.localizedTitle)
    }
}
