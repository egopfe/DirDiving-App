import XCTest

final class BuhlmannNDLTests: XCTestCase {
    func testAirAndNitroxNDLAreFiniteAndDoNotUseFake999Fallback() {
        let airNDL = BuhlmannEngine.noDecompressionLimit(
            depthMeters: 30,
            gas: BuhlmannTestSupport.air(switchDepth: 30),
            gfHigh: 85
        )
        let nitroxNDL = BuhlmannEngine.noDecompressionLimit(
            depthMeters: 30,
            gas: BuhlmannTestSupport.nitrox32(switchDepth: 30),
            gfHigh: 85
        )

        XCTAssertNotNil(airNDL)
        XCTAssertNotNil(nitroxNDL)
        XCTAssertGreaterThan(airNDL ?? 0, 0)
        XCTAssertLessThan(airNDL ?? 0, 999)
        XCTAssertGreaterThan(nitroxNDL ?? 0, airNDL ?? 0)
    }

    func testInvalidGasDoesNotReturnNDL() {
        let invalid = BuhlmannGas(
            name: "Invalid",
            role: .bottom,
            oxygenFraction: 1.2,
            heliumFraction: 0,
            maxPPO2Bar: 1.6,
            switchDepthMeters: 30
        )

        XCTAssertNil(BuhlmannEngine.noDecompressionLimit(depthMeters: 30, gas: invalid, gfHigh: 85))
    }

    func testPlannerTrimixPreviewReturnsValidatedReferenceInsteadOfUnsupportedTrimix() {
        let result = BuhlmannPlanner.plan(
            depthMeters: 40,
            bottomGas: GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        )

        XCTAssertEqual(result.modelState, .validReference)
        XCTAssertGreaterThanOrEqual(result.ndlMinutes, 0)
        XCTAssertLessThan(result.ndlMinutes, 999)
    }
}

