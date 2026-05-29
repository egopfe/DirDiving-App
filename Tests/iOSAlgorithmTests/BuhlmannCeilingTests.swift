import XCTest

final class BuhlmannCeilingTests: XCTestCase {
    func testConservativeGradientFactorProducesDeeperOrEqualCeiling() {
        let loaded = BuhlmannTissueState.airSaturated()
            .loadedConstantDepth(depthMeters: 40, minutes: 30, gas: BuhlmannTestSupport.air(switchDepth: 40))

        let conservative = loaded.ceiling(gf: 0.30, environment: .seaLevelSaltWater).depthMeters
        let liberal = loaded.ceiling(gf: 0.85, environment: .seaLevelSaltWater).depthMeters
        XCTAssertGreaterThanOrEqual(conservative + 0.0001, liberal)
    }

    func testN2HeMixedCompartmentCeilingIsFiniteAndControlled() {
        let loaded = BuhlmannTissueState.airSaturated()
            .loadedConstantDepth(depthMeters: 55, minutes: 30, gas: BuhlmannTestSupport.trimix1845(switchDepth: 55))
        let ceiling = loaded.ceiling(gf: 0.70, environment: .seaLevelSaltWater)

        XCTAssertTrue(ceiling.depthMeters.isFinite)
        XCTAssertGreaterThanOrEqual(ceiling.depthMeters, 0)
        XCTAssertGreaterThanOrEqual(ceiling.controllingCompartment, 0)
        XCTAssertLessThan(ceiling.controllingCompartment, BuhlmannConstants.compartmentCount)
    }
}

