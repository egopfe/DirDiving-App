import XCTest

final class BuhlmannReferenceFixtureTests: XCTestCase {
    func testAirAndNitroxReferenceFixturesAreFiniteAndOrdered() {
        let air = BuhlmannPlanner.plan(
            depthMeters: 30,
            bottomGas: GasMix(name: "Air", role: .bottom, oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        )
        let nitrox = BuhlmannPlanner.plan(
            depthMeters: 30,
            bottomGas: GasMix(name: "EAN32", role: .bottom, oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        )

        XCTAssertEqual(air.modelState, .validReference)
        XCTAssertEqual(nitrox.modelState, .validReference)
        XCTAssertGreaterThan(air.ndlMinutes, 1)
        XCTAssertLessThan(air.ndlMinutes, 120)
        XCTAssertGreaterThan(nitrox.ndlMinutes, air.ndlMinutes)
    }

    func testTrimixMultigasReferenceFixtureCreatesNonStaticRuntimeSchedule() {
        let plan = BuhlmannEngine.plan(
            BuhlmannTestSupport.request(
                depth: 50,
                bottomMinutes: 30,
                bottomGas: BuhlmannTestSupport.trimix1845(switchDepth: 50),
                decoGases: [BuhlmannTestSupport.ean50(), BuhlmannTestSupport.oxygen()]
            )
        )

        XCTAssertEqual(plan.modelState, .validReference)
        XCTAssertFalse(plan.stops.isEmpty)
        XCTAssertGreaterThan(plan.ttsMinutes, 30)
        XCTAssertTrue(plan.stops.allSatisfy { abs($0.depthMeters.truncatingRemainder(dividingBy: 3)) < 0.0001 })
        XCTAssertTrue(plan.stops.allSatisfy { $0.ppO2 <= $0.maxPPO2 + 0.0001 })
    }

    func testInvalidReferenceFixtureFailsClosed() {
        let plan = BuhlmannEngine.plan(
            BuhlmannTestSupport.request(
                depth: 40,
                bottomMinutes: 20,
                bottomGas: BuhlmannTestSupport.nitrox32(switchDepth: 40)
            )
        )

        XCTAssertEqual(plan.modelState, .invalidInput)
        XCTAssertTrue(plan.hasBlockingIssues)
        XCTAssertTrue(plan.stops.isEmpty)
    }
}
