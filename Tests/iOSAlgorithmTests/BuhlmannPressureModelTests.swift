import XCTest

final class BuhlmannPressureModelTests: XCTestCase {
    func testDisplayAmbientPressureUsesAmbientPressureModelAtSeaLevel() {
        let sea = PlannerEnvironment.seaLevelSaltWater
        let surface = AmbientPressureModel.ambientPressureBar(depthMeters: 0, environment: sea)!
        let at30 = AmbientPressureModel.ambientPressureBar(depthMeters: 30, environment: sea)!
        XCTAssertEqual(IOSUnitConversions.ambientPressureBar(depthMeters: 0), surface, accuracy: 0.0001)
        XCTAssertEqual(IOSUnitConversions.ambientPressureBar(depthMeters: 30), at30, accuracy: 0.0001)
        XCTAssertEqual(IOSUnitConversions.depthMeters(forPressureBar: at30), 30.0, accuracy: 0.05)
    }

    func testNegativeDepthIsClampedToSurfacePressureForPressureModel() {
        XCTAssertEqual(
            IOSUnitConversions.ambientPressureBar(depthMeters: -10),
            IOSAlgorithmConfiguration.surfacePressureBar,
            accuracy: 0.0001
        )
    }

    func testInspiredNitrogenAndHeliumPressureSubtractWaterVapor() {
        let gas = BuhlmannTestSupport.trimix1845(switchDepth: 50)
        let ambient = BuhlmannConstants.seaLevelSurfacePressureBar
            + (BuhlmannConstants.saltwaterDensityKgPerM3 * 9.80665 * 50) / 100_000.0
        let dryAmbient = ambient - BuhlmannConstants.waterVaporPressureBar

        XCTAssertEqual(
            gas.inspiredPressure(depthMeters: 50, inert: .nitrogen),
            dryAmbient * gas.nitrogenFraction,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            gas.inspiredPressure(depthMeters: 50, inert: .helium),
            dryAmbient * gas.heliumFraction,
            accuracy: 0.0001
        )
    }

    func testInspiredPressureWithEnvironmentUsesAmbientPressureModel() {
        let gas = BuhlmannTestSupport.trimix1845(switchDepth: 50)
        let sea = PlannerEnvironment.seaLevelSaltWater
        let ambient = AmbientPressureModel.ambientPressureBar(depthMeters: 50, environment: sea)!
        let dryAmbient = ambient - BuhlmannConstants.waterVaporPressureBar
        XCTAssertEqual(
            gas.inspiredPressure(depthMeters: 50, inert: .nitrogen, environment: sea),
            dryAmbient * gas.nitrogenFraction,
            accuracy: 0.0001
        )
    }

    func testOxygenIsNotLoadedAsInertGas() {
        let oxygen = BuhlmannTestSupport.oxygen()
        XCTAssertEqual(oxygen.inspiredPressure(depthMeters: 6, inert: .nitrogen), 0, accuracy: 0.0001)
        XCTAssertEqual(oxygen.inspiredPressure(depthMeters: 6, inert: .helium), 0, accuracy: 0.0001)
        XCTAssertGreaterThan(oxygen.ppO2(depthMeters: 6), 0)
    }

    func testEnvironmentAwareAmbientAndCeilingPressure() throws {
        let sea = PlannerEnvironment.seaLevelSaltWater
        guard case .success(let fresh) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .fresh),
              case .success(let altitude) = PlannerEnvironment.make(altitudeMeters: 1_500, salinity: .salt) else {
            return XCTFail("Expected valid environments")
        }

        let depth30Sea = AmbientPressureModel.ambientPressureBar(depthMeters: 30, environment: sea)!
        let depth30Fresh = AmbientPressureModel.ambientPressureBar(depthMeters: 30, environment: fresh)!
        let depth30Altitude = AmbientPressureModel.ambientPressureBar(depthMeters: 30, environment: altitude)!

        XCTAssertLessThan(depth30Altitude, depth30Sea)
        XCTAssertLessThan(depth30Fresh, depth30Sea)

        let loaded = BuhlmannTissueState.airSaturated(surfacePressureBar: sea.surfacePressureBar)
            .loadedConstantDepth(depthMeters: 40, minutes: 25, gas: BuhlmannTestSupport.air(switchDepth: 40), environment: sea)
        let ceilingSea = loaded.ceiling(gf: 0.30, environment: sea).depthMeters
        let ceilingFresh = loaded.ceiling(gf: 0.30, environment: fresh).depthMeters
        let ceilingAltitude = loaded.ceiling(gf: 0.30, environment: altitude).depthMeters
        XCTAssertTrue(ceilingSea.isFinite)
        XCTAssertNotEqual(ceilingSea, ceilingFresh, accuracy: 0.01)
        XCTAssertNotEqual(ceilingSea, ceilingAltitude, accuracy: 0.01)
    }

    func testInvalidEnvironmentFailsClosedInValidator() {
        var input = BuhlmannTestSupport.gasPlanInput()
        input.altitudeMeters = 10_000
        let validation = PlannerInputValidator.validate(input)
        XCTAssertTrue(validation.states.contains(.invalidEnvironment))
        XCTAssertFalse(validation.isValid)
    }
}

