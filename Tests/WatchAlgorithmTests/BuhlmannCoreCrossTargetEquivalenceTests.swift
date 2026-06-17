import XCTest

/// Cross-target smoke tests: shared Bühlmann core compiles and returns deterministic results on watchOS.
final class BuhlmannCoreCrossTargetEquivalenceTests: XCTestCase {
    func testAirNDLAt30mGF3070IsDeterministic() {
        let gas = BuhlmannGas(
            name: "Air",
            role: .bottom,
            oxygenFraction: 0.21,
            heliumFraction: 0,
            maxPPO2Bar: 1.4,
            switchDepthMeters: 0
        )
        let first = BuhlmannEngine.noDecompressionLimit(
            depthMeters: 30,
            gas: gas,
            gfHigh: 70,
            plannerEnvironment: .seaLevelSaltWater
        )
        let second = BuhlmannEngine.noDecompressionLimit(
            depthMeters: 30,
            gas: gas,
            gfHigh: 70,
            plannerEnvironment: .seaLevelSaltWater
        )
        XCTAssertNotNil(first)
        XCTAssertEqual(first, second)
        XCTAssertGreaterThan(first ?? 0, 0)
    }

    func testSchreinerLinearLoadMatchesConstantAtZeroRate() {
        let gas = BuhlmannGas(
            name: "Air",
            role: .bottom,
            oxygenFraction: 0.21,
            heliumFraction: 0,
            maxPPO2Bar: 1.4,
            switchDepthMeters: 0
        )
        let start = BuhlmannTissueState.airSaturated()
        let loaded = start.loadedLinearDepth(
            fromDepthMeters: 30,
            toDepthMeters: 30,
            minutes: 2,
            gas: gas,
            environment: .seaLevelSaltWater
        )
        let constant = start.loadedConstantDepth(
            depthMeters: 30,
            minutes: 2,
            gas: gas,
            environment: .seaLevelSaltWater
        )
        XCTAssertEqual(
            loaded.compartments[0].nitrogenPressure,
            constant.compartments[0].nitrogenPressure,
            accuracy: 0.000_1
        )
    }

    func testCeilingIncreasesWithLoadedTissues() {
        let gas = BuhlmannGas(
            name: "Air",
            role: .bottom,
            oxygenFraction: 0.21,
            heliumFraction: 0,
            maxPPO2Bar: 1.4,
            switchDepthMeters: 0
        )
        let saturated = BuhlmannTissueState.airSaturated()
        let loaded = saturated.loadedConstantDepth(
            depthMeters: 40,
            minutes: 20,
            gas: gas,
            environment: .seaLevelSaltWater
        )
        let saturatedCeiling = saturated.ceiling(gf: 0.7, environment: .seaLevelSaltWater).depthMeters
        let loadedCeiling = loaded.ceiling(gf: 0.7, environment: .seaLevelSaltWater).depthMeters
        XCTAssertGreaterThan(loadedCeiling, saturatedCeiling)
    }

    func testDecoPlanIsDeterministicOnWatch() {
        let gas = BuhlmannGas(
            name: "Air",
            role: .bottom,
            oxygenFraction: 0.21,
            heliumFraction: 0,
            maxPPO2Bar: 1.4,
            switchDepthMeters: 0
        )
        let request = BuhlmannPlanRequest(
            maxDepthMeters: 40,
            bottomMinutes: 25,
            bottomGas: gas,
            travelGases: [],
            decoGases: [],
            gfLow: 30,
            gfHigh: 70
        )
        let first = BuhlmannEngine.plan(request)
        let second = BuhlmannEngine.plan(request)
        XCTAssertEqual(first.ttsMinutes, second.ttsMinutes)
        XCTAssertEqual(first.ndlMinutes, second.ndlMinutes)
        XCTAssertEqual(first.stops, second.stops)
        XCTAssertFalse(first.hasBlockingIssues)
    }

    func testInvalidDepthRequestReturnsBlockingIssues() {
        let gas = BuhlmannGas(
            name: "Air",
            role: .bottom,
            oxygenFraction: 0.21,
            heliumFraction: 0,
            maxPPO2Bar: 1.4,
            switchDepthMeters: 0
        )
        let request = BuhlmannPlanRequest(
            maxDepthMeters: 0,
            bottomMinutes: 20,
            bottomGas: gas,
            travelGases: [],
            decoGases: [],
            gfLow: 30,
            gfHigh: 70
        )
        let result = BuhlmannEngine.plan(request)
        XCTAssertTrue(result.hasBlockingIssues)
        XCTAssertEqual(result.modelState, .invalidInput)
    }
}
