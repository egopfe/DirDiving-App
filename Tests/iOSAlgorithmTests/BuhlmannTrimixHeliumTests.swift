import XCTest

final class BuhlmannTrimixHeliumTests: XCTestCase {
    func testTrimixHasIndependentNitrogenAndHeliumFractions() {
        let gas = BuhlmannTestSupport.trimix1845(switchDepth: 50)
        XCTAssertEqual(gas.oxygenFraction, 0.18, accuracy: 0.0001)
        XCTAssertEqual(gas.heliumFraction, 0.45, accuracy: 0.0001)
        XCTAssertEqual(gas.nitrogenFraction, 0.37, accuracy: 0.0001)
        XCTAssertTrue(gas.isCompositionValid)
    }

    func testHelioxIsCompositionallyValidWhenNitrogenIsZero() {
        let heliox = BuhlmannGas(
            name: "Heliox 21/79",
            role: .bottom,
            oxygenFraction: 0.21,
            heliumFraction: 0.79,
            maxPPO2Bar: 1.4,
            switchDepthMeters: 45
        )
        XCTAssertEqual(heliox.nitrogenFraction, 0, accuracy: 0.0001)
        XCTAssertTrue(heliox.isCompositionValid)

        let loaded = BuhlmannTissueState.airSaturated()
            .loadedConstantDepth(depthMeters: 45, minutes: 20, gas: heliox)
        XCTAssertTrue(loaded.compartments.contains { $0.heliumPressure > 0.05 })
    }

    func testFullHeliumPlannerDoesNotReturnUnsupportedTrimixForMathematicallyValidProfile() {
        let request = BuhlmannTestSupport.request(
            depth: 50,
            bottomMinutes: 25,
            bottomGas: BuhlmannTestSupport.trimix1845(switchDepth: 50),
            decoGases: [BuhlmannTestSupport.ean50(), BuhlmannTestSupport.oxygen()]
        )
        let result = BuhlmannEngine.plan(request)

        XCTAssertEqual(result.modelState, .validReference)
        XCTAssertTrue(result.issues.isEmpty)
    }
}

