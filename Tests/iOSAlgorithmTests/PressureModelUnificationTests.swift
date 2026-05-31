import XCTest

final class PressureModelUnificationTests: XCTestCase {
    func testSeaLevelMODMatchesLegacyApproximation() {
        let gas = GasMix(name: "EAN32", oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        let sea = PlannerEnvironment.seaLevelSaltWater
        let mod = GasMixValidator.modMeters(for: gas, environment: sea)
        XCTAssertNotNil(mod)
        XCTAssertEqual(mod ?? 0, PlannerMODValidator.modMeters(for: gas, environment: sea), accuracy: 0.01)
    }

    func testAltitude3000mReducesMODComparedToSeaLevel() throws {
        guard case .success(let altitude) = PlannerEnvironment.make(altitudeMeters: 3_000, salinity: .salt) else {
            return XCTFail("Expected valid 3000 m environment")
        }
        let sea = PlannerEnvironment.seaLevelSaltWater
        let gas = GasMix(name: "Air", oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        let modSea = GasMixValidator.modMeters(for: gas, environment: sea)!
        let modAltitude = GasMixValidator.modMeters(for: gas, environment: altitude)!
        XCTAssertGreaterThan(modAltitude, modSea)
    }

    func testValidatorPPO2MatchesBuhlmannGasAtSeaLevel() {
        let sea = PlannerEnvironment.seaLevelSaltWater
        let gas = BuhlmannTestSupport.nitrox32(switchDepth: 30)
        let depth = 30.0
        let validatorPPO2 = GasMixValidator.actualPPO2(
            oxygenFraction: gas.oxygenFraction,
            depthMeters: depth,
            environment: sea
        )
        let buhlmannPPO2 = gas.ppO2(depthMeters: depth, environment: sea)
        XCTAssertEqual(validatorPPO2 ?? 0, buhlmannPPO2, accuracy: 0.0001)
    }

    func testValidatorPPO2MatchesBuhlmannGasAt3000mAltitude() throws {
        guard case .success(let altitude) = PlannerEnvironment.make(altitudeMeters: 3_000, salinity: .salt) else {
            return XCTFail("Expected valid 3000 m environment")
        }
        let gas = BuhlmannTestSupport.trimix1845(switchDepth: 40)
        let depth = 40.0
        let validatorPPO2 = GasMixValidator.actualPPO2(
            oxygenFraction: gas.oxygenFraction,
            depthMeters: depth,
            environment: altitude
        )
        let buhlmannPPO2 = gas.ppO2(depthMeters: depth, environment: altitude)
        XCTAssertEqual(validatorPPO2 ?? 0, buhlmannPPO2, accuracy: 0.0001)
    }

    func testAmbientPressureBarUsesEnvironmentFromInput() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 30)
        input.altitudeMeters = 1_500
        input.salinity = .fresh
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            return XCTFail("Expected valid environment")
        }
        let expected = AmbientPressureModel.ambientPressureBar(
            depthMeters: input.effectivePlanningDepthMeters,
            environment: environment
        )
        XCTAssertEqual(input.ambientPressureBar, expected ?? 0, accuracy: 0.0001)
    }
}
