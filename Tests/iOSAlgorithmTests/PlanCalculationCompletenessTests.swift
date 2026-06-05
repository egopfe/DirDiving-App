import XCTest

final class PlanCalculationCompletenessTests: XCTestCase {
    func testResolverSuppressesPartialStopsWhenCalculationLimitReached() {
        let gas = BuhlmannTestSupport.air(switchDepth: 30)
        let stop = BuhlmannDecompressionStop(
            depthMeters: 21,
            minutes: 5,
            gas: gas,
            ppO2: 1.2,
            maxPPO2: 1.4,
            gradientFactor: 0.7
        )
        let engine = BuhlmannEngineResult(
            ndlMinutes: 0,
            ttsMinutes: 45,
            totalRuntimeMinutes: 60,
            descentMinutes: 2,
            bottomMinutes: 30,
            gasSwitchMinutes: 0,
            finalTissueState: nil,
            stops: [stop],
            segments: [],
            tissueHistory: .empty,
            issues: [.calculationLimitReached],
            modelState: .modelIncomplete
        )
        let rawStops = engine.stops.map(BuhlmannPlanner.makeDecoStop)
        let resolution = PlanCalculationCompletenessResolver.resolve(enginePlan: engine, stops: rawStops)

        XCTAssertEqual(resolution.completeness, .incompletePartialStops)
        XCTAssertTrue(resolution.presentationStops.isEmpty)
        XCTAssertTrue(resolution.extraStates.contains(.calculationIncomplete))
    }

    func testPlannerServiceClearsPartialStopsForIncompleteEngineOutput() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 55, bottomMinutes: 45)
        input.bottomGas = GasMix(name: "Air", role: .bottom, oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        input.gfLow = 30
        input.gfHigh = 85
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .salt) else {
            return XCTFail("Expected environment")
        }
        let request = BuhlmannPlanner.makeRequest(input: input, environment: environment)
        let engine = BuhlmannEngine.plan(request)
        guard engine.issues.contains(.calculationLimitReached) || (engine.modelState == .modelIncomplete && !engine.stops.isEmpty) else {
            throw XCTSkip("Profile did not produce partial incomplete stops in this environment")
        }

        let plan = PlannerService.makePlan(input: input)
        XCTAssertEqual(plan.calculationCompleteness, .incompletePartialStops)
        XCTAssertTrue(plan.decoStops.isEmpty)
        XCTAssertTrue(plan.states.contains(.calculationIncomplete))
        XCTAssertEqual(plan.resultHeader.kind, .calculationIncomplete)
    }

    func testCompletePlanKeepsStops() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 25)
        input.bottomGas = GasMix(name: "EAN32", role: .bottom, oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        let plan = PlannerService.makePlan(input: input)
        XCTAssertEqual(plan.calculationCompleteness, .complete)
        if !plan.decoStops.isEmpty {
            XCTAssertFalse(plan.states.contains(.calculationIncomplete))
        }
    }
}
