import XCTest

final class BuhlmannMultigasPlannerTests: XCTestCase {
    func testTrimixBottomGasWithEAN50AndOxygenDecoProducesEngineGeneratedStops() {
        let request = BuhlmannTestSupport.request(
            depth: 50,
            bottomMinutes: 30,
            bottomGas: BuhlmannTestSupport.trimix1845(switchDepth: 50),
            decoGases: [BuhlmannTestSupport.ean50(), BuhlmannTestSupport.oxygen()]
        )
        let plan = BuhlmannEngine.plan(request)

        XCTAssertEqual(plan.modelState, .validReference)
        XCTAssertFalse(plan.hasBlockingIssues)
        XCTAssertGreaterThan(plan.ttsMinutes, Int(request.bottomMinutes))
        XCTAssertFalse(plan.stops.isEmpty)
        XCTAssertTrue(plan.segments.contains { $0.kind == .gasSwitch })
        XCTAssertTrue(plan.stops.contains { $0.gas.oxygenFraction >= 0.50 })
    }

    func testPlannerServiceUsesFullHeliumEngineForTrimixInsteadOfUnsupportedState() {
        let plan = PlannerService.makePlan(input: BuhlmannTestSupport.gasPlanInput())

        XCTAssertFalse(plan.states.contains(.unsupportedTrimix))
        XCTAssertTrue(plan.states.contains(.nonCertifiedReference))
        XCTAssertEqual(plan.buhlmannState, .validReference)
        XCTAssertFalse(plan.decoStops.isEmpty)
        XCTAssertGreaterThan(plan.ttsMinutes, 30)
    }

    func testPlannerMODBlockingUsesEngineGeneratedStops() {
        let input = BuhlmannTestSupport.gasPlanInput()
        XCTAssertFalse(PlannerGasSchedule.hasMODBlockingIssues(input: input))

        var invalid = input
        invalid.plannerCylinders[1].switchDepthMeters = 30
        XCTAssertTrue(PlannerGasSchedule.hasMODBlockingIssues(input: invalid))
    }

    func testEngineSupportsMultipleValidatedBottomGasSegments() {
        let secondBottomGas = BuhlmannGas(
            name: "TX 21/35",
            role: .bottom,
            oxygenFraction: 0.21,
            heliumFraction: 0.35,
            maxPPO2Bar: 1.4,
            switchDepthMeters: 45
        )
        var request = BuhlmannTestSupport.request(
            depth: 50,
            bottomMinutes: 0,
            bottomGas: BuhlmannTestSupport.trimix1845(switchDepth: 50),
            decoGases: [BuhlmannTestSupport.ean50(), BuhlmannTestSupport.oxygen()]
        )
        request.bottomSegments = [
            BuhlmannBottomSegment(depthMeters: 50, minutes: 20, gas: BuhlmannTestSupport.trimix1845(switchDepth: 50)),
            BuhlmannBottomSegment(depthMeters: 45, minutes: 10, gas: secondBottomGas)
        ]

        let plan = BuhlmannEngine.plan(request)

        XCTAssertEqual(plan.modelState, .validReference)
        XCTAssertEqual(plan.segments.filter { $0.kind == .bottom }.count, 2)
        XCTAssertTrue(plan.segments.contains { $0.kind == .gasSwitch && $0.gas.name == "TX 21/35" })
        XCTAssertGreaterThan(plan.ttsMinutes, 30)
    }
}
