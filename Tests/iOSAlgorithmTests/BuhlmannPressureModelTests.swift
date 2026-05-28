import XCTest

final class BuhlmannPressureModelTests: XCTestCase {
    func testAmbientPressureUsesProjectTenMetersPerBarApproximation() {
        XCTAssertEqual(IOSUnitConversions.ambientPressureBar(depthMeters: 0), 1.0, accuracy: 0.0001)
        XCTAssertEqual(IOSUnitConversions.ambientPressureBar(depthMeters: 30), 4.0, accuracy: 0.0001)
        XCTAssertEqual(IOSUnitConversions.depthMeters(forPressureBar: 4.0), 30.0, accuracy: 0.0001)
    }

    func testNegativeDepthIsClampedToSurfacePressureForPressureModel() {
        XCTAssertEqual(IOSUnitConversions.ambientPressureBar(depthMeters: -10), 1.0, accuracy: 0.0001)
    }

    func testInspiredNitrogenAndHeliumPressureSubtractWaterVapor() {
        let gas = BuhlmannTestSupport.trimix1845(switchDepth: 50)
        let dryAmbient = IOSUnitConversions.ambientPressureBar(depthMeters: 50) - BuhlmannConstants.waterVaporPressureBar

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

    func testOxygenIsNotLoadedAsInertGas() {
        let oxygen = BuhlmannTestSupport.oxygen()
        XCTAssertEqual(oxygen.inspiredPressure(depthMeters: 6, inert: .nitrogen), 0, accuracy: 0.0001)
        XCTAssertEqual(oxygen.inspiredPressure(depthMeters: 6, inert: .helium), 0, accuracy: 0.0001)
        XCTAssertGreaterThan(oxygen.ppO2(depthMeters: 6), 0)
    }

    func testAltitudeAndSalinityAreReferenceOnlyPlannerInputs() {
        var input = BuhlmannTestSupport.gasPlanInput()
        input.salinity = .fresh
        input.altitudeMeters = 1_500
        let validation = PlannerInputValidator.validate(input)

        XCTAssertTrue(validation.states.contains(.simplifiedReferenceOnly))
        XCTAssertTrue(validation.messages.contains { $0.contains("Salinita") || $0.contains("altitudine") })
    }
}

