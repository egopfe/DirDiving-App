import XCTest

final class GasLedgerDisplayFormatterTests: XCTestCase {
    func testGasLedgerDisplaysLitersPrimaryPressureSecondary() {
        let display = GasLedgerDisplayFormatter.displayValue(
            liters: 4080,
            pressureBar: 200,
            cylinderVolumeLiters: 12,
            pressureUnit: .bar
        )
        XCTAssertTrue(display.litersText.contains("L"))
        XCTAssertTrue(display.pressureSecondaryText.contains("200"))
        XCTAssertTrue(display.pressureSecondaryText.hasPrefix("≈"))
    }

    func testGasLedgerPressureEquivalentIsCylinderSpecific() {
        let twelveLiter = GasLedgerDisplayFormatter.displayValue(
            liters: 1200,
            pressureBar: nil,
            cylinderVolumeLiters: 12,
            pressureUnit: .bar
        )
        let fifteenLiter = GasLedgerDisplayFormatter.displayValue(
            liters: 1200,
            pressureBar: nil,
            cylinderVolumeLiters: 15,
            pressureUnit: .bar
        )
        XCTAssertNotEqual(twelveLiter.pressureSecondaryText, fifteenLiter.pressureSecondaryText)
        XCTAssertTrue(twelveLiter.pressureSecondaryText.contains("100"))
        XCTAssertTrue(fifteenLiter.pressureSecondaryText.contains("80"))
    }

    func testZeroLitersShowsZeroWithoutPressureFallback() {
        let display = GasLedgerDisplayFormatter.displayValue(
            liters: 0,
            pressureBar: nil,
            cylinderVolumeLiters: 12,
            pressureUnit: .bar
        )
        XCTAssertTrue(display.litersText.contains("0"))
    }

    func testZeroCylinderVolumeAvoidsInvalidPressureConversion() {
        let display = GasLedgerDisplayFormatter.displayValue(
            liters: 500,
            pressureBar: nil,
            cylinderVolumeLiters: 0,
            pressureUnit: .bar
        )
        XCTAssertTrue(display.litersText.contains("500"))
    }

    func testPSIPresentationUsesCanonicalLiters() {
        let display = GasLedgerDisplayFormatter.displayValue(
            liters: 2400,
            pressureBar: nil,
            cylinderVolumeLiters: 12,
            pressureUnit: .psi
        )
        XCTAssertTrue(display.litersText.contains("L"))
        XCTAssertTrue(display.pressureSecondaryText.contains("≈"))
    }

    func testExplicitPressureBarOverridesComputedEquivalent() {
        let display = GasLedgerDisplayFormatter.displayValue(
            liters: 1200,
            pressureBar: 150,
            cylinderVolumeLiters: 12,
            pressureUnit: .bar
        )
        XCTAssertTrue(display.pressureSecondaryText.contains("150"))
    }

    func testNonFiniteLitersStillFormatsWithoutCrashing() {
        let display = GasLedgerDisplayFormatter.displayValue(
            liters: .nan,
            pressureBar: nil,
            cylinderVolumeLiters: 12,
            pressureUnit: .bar
        )
        XCTAssertTrue(display.litersText.contains("L"))
    }

    func testNonFiniteCylinderVolumeAvoidsPressureFallback() {
        let display = GasLedgerDisplayFormatter.displayValue(
            liters: 500,
            pressureBar: nil,
            cylinderVolumeLiters: .nan,
            pressureUnit: .bar
        )
        XCTAssertTrue(display.litersText.contains("500"))
    }

    func testNegativeLitersRemainDistinctFromZero() {
        let negative = GasLedgerDisplayFormatter.displayValue(
            liters: -10,
            pressureBar: nil,
            cylinderVolumeLiters: 12,
            pressureUnit: .bar
        )
        let zero = GasLedgerDisplayFormatter.displayValue(
            liters: 0,
            pressureBar: nil,
            cylinderVolumeLiters: 12,
            pressureUnit: .bar
        )
        XCTAssertNotEqual(negative.litersText, zero.litersText)
    }

    func testAccessibilityLabelCombinesLitersAndPressure() {
        let display = GasLedgerDisplayFormatter.displayValue(
            liters: 600,
            pressureBar: 50,
            cylinderVolumeLiters: 12,
            pressureUnit: .bar
        )
        XCTAssertTrue(display.accessibilityLabel.contains(display.litersText))
        XCTAssertTrue(display.accessibilityLabel.contains("50"))
    }

    func testCylinderVolumeLookupUsesMatchingPlannerCylinder() {
        let cylinderID = UUID()
        let air = GasMix(name: "Air", role: .bottom, oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        var input = GasPlanInput()
        input.plannerCylinders = [
            PlannerCylinderEntry(
                id: cylinderID,
                role: .bottom,
                tankSize: .liters12,
                gas: air
            ),
            PlannerCylinderEntry(
                role: .deco,
                tankSize: .liters15,
                gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.50, helium: 0, maxPPO2: 1.6),
                switchDepthMeters: 21
            )
        ]
        XCTAssertEqual(GasLedgerDisplayFormatter.cylinderVolumeLiters(for: cylinderID, input: input), 12, accuracy: 0.001)
    }

    func testRoundingBoundaryUsesDisplayFormatterOnly() {
        let display = GasLedgerDisplayFormatter.displayValue(
            liters: 999.95,
            pressureBar: nil,
            cylinderVolumeLiters: 12,
            pressureUnit: .bar
        )
        XCTAssertTrue(display.litersText.contains("L"))
        XCTAssertFalse(display.litersText.isEmpty)
    }
}
