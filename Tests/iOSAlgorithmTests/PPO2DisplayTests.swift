import XCTest

final class PPO2DisplayTests: XCTestCase {
    func testBoundedPPO2ReturnsActualOverLimitValue() {
        let gas = GasMix(name: "O2", role: .deco, oxygen: 1.0, helium: 0, maxPPO2: 1.6)
        let actual = GasPlanningService.boundedPPO2(gas: gas, depthMeters: 6)
        let expected = GasPlanningService.ppO2(gas: gas, depthMeters: 6)
        XCTAssertEqual(actual, expected, accuracy: 0.0001)
        XCTAssertGreaterThan(actual, gas.maxPPO2)
    }
}
