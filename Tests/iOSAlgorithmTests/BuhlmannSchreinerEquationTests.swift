import XCTest

final class BuhlmannSchreinerEquationTests: XCTestCase {
    func testZeroAndNegativeSegmentDurationsReturnUnchangedTissueState() {
        let initial = BuhlmannTissueState.airSaturated()
        let zero = initial.loadedLinearDepth(
            fromDepthMeters: 0,
            toDepthMeters: 30,
            minutes: 0,
            gas: BuhlmannTestSupport.air()
        )
        let negative = initial.loadedLinearDepth(
            fromDepthMeters: 0,
            toDepthMeters: 30,
            minutes: -1,
            gas: BuhlmannTestSupport.air()
        )

        XCTAssertEqual(zero, initial)
        XCTAssertEqual(negative, initial)
    }

    func testConstantDepthLoadingMovesTowardInspiredPressure() {
        let gas = BuhlmannTestSupport.air(switchDepth: 30)
        let initial = BuhlmannTissueState.airSaturated()
        let loaded = initial.loadedConstantDepth(depthMeters: 30, minutes: 20, gas: gas)

        XCTAssertGreaterThan(loaded.compartments[0].nitrogenPressure, initial.compartments[0].nitrogenPressure)
        XCTAssertLessThanOrEqual(
            loaded.compartments[0].nitrogenPressure,
            gas.inspiredPressure(depthMeters: 30, inert: .nitrogen) + 0.0001
        )
    }

    func testAscentOffGassesFastCompartments() {
        let gas = BuhlmannTestSupport.air(switchDepth: 30)
        let loaded = BuhlmannTissueState.airSaturated()
            .loadedConstantDepth(depthMeters: 30, minutes: 40, gas: gas)
        let ascended = loaded.loadedLinearDepth(fromDepthMeters: 30, toDepthMeters: 0, minutes: 4, gas: gas)

        XCTAssertLessThan(ascended.compartments[0].nitrogenPressure, loaded.compartments[0].nitrogenPressure)
        XCTAssertTrue(ascended.compartments.allSatisfy { $0.nitrogenPressure.isFinite && $0.heliumPressure.isFinite })
    }

    func testGasSwitchPreservesStateAndChangesSubsequentInertLoading() {
        let trimix = BuhlmannTestSupport.trimix1845(switchDepth: 50)
        let ean50 = BuhlmannTestSupport.ean50()
        let beforeSwitch = BuhlmannTissueState.airSaturated()
            .loadedConstantDepth(depthMeters: 50, minutes: 20, gas: trimix)
        let afterSwitch = beforeSwitch.loadedConstantDepth(depthMeters: 21, minutes: 10, gas: ean50)

        XCTAssertGreaterThan(beforeSwitch.compartments[0].heliumPressure, afterSwitch.compartments[0].heliumPressure)
        XCTAssertGreaterThan(afterSwitch.compartments[0].nitrogenPressure, 0)
    }
}

