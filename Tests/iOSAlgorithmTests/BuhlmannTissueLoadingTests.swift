import XCTest

final class BuhlmannTissueLoadingTests: XCTestCase {
    func testAirSaturationHasNitrogenAndNoHelium() {
        let state = BuhlmannTissueState.airSaturated()
        XCTAssertEqual(state.compartments.count, BuhlmannConstants.compartmentCount)
        XCTAssertTrue(state.compartments.allSatisfy { $0.nitrogenPressure > 0 })
        XCTAssertTrue(state.compartments.allSatisfy { $0.heliumPressure == 0 })
    }

    func testTrimixConstantDepthLoadsHeliumTissues() {
        let state = BuhlmannTissueState.airSaturated()
            .loadedConstantDepth(depthMeters: 50, minutes: 25, gas: BuhlmannTestSupport.trimix1845(switchDepth: 50))

        XCTAssertTrue(state.compartments.contains { $0.heliumPressure > 0.05 })
        XCTAssertTrue(state.compartments.allSatisfy { $0.nitrogenPressure.isFinite && $0.heliumPressure.isFinite })
    }

    func testSchreinerAscentAndDescentRemainFinite() {
        let gas = BuhlmannTestSupport.trimix1845(switchDepth: 50)
        let descended = BuhlmannTissueState.airSaturated()
            .loadedLinearDepth(fromDepthMeters: 0, toDepthMeters: 50, minutes: 3, gas: gas)
        let ascended = descended.loadedLinearDepth(fromDepthMeters: 50, toDepthMeters: 21, minutes: 4, gas: gas)

        XCTAssertTrue(ascended.compartments.allSatisfy { $0.nitrogenPressure.isFinite && $0.heliumPressure.isFinite })
        XCTAssertGreaterThanOrEqual(ascended.ceiling(gf: 0.30).depthMeters, 0)
    }
}
