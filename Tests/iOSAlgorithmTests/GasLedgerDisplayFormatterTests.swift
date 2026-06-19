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
}
