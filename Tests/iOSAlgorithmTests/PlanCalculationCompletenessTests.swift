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

    func testPlannerServiceClearsPartialStopsForIncompleteEngineOutput() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 45, bottomMinutes: 30)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 45),
            PlannerCylinderEntry(
                role: .deco,
                gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6),
                switchDepthMeters: 21
            )
        ]
        let engine = BuhlmannPlanner.enginePlan(input: input)
        let rawStops = BuhlmannPlanner.decoStops(from: engine)
        let resolution = PlanCalculationCompletenessResolver.resolve(enginePlan: engine, stops: rawStops)
        let plan = PlannerService.makePlan(input: input)
        XCTAssertEqual(plan.calculationCompleteness, resolution.completeness)
        if resolution.completeness == .incompletePartialStops {
            XCTAssertTrue(plan.decoStops.isEmpty)
            XCTAssertTrue(plan.states.contains(.calculationIncomplete))
            XCTAssertEqual(plan.resultHeader.kind, .calculationIncomplete)
        }
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
