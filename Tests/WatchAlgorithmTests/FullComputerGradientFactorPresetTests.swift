import XCTest

final class FullComputerGradientFactorPresetTests: XCTestCase {
    func testConservativePresetValues() {
        XCTAssertEqual(FullComputerGradientFactorPreset.conservative2080.gfLow, 20)
        XCTAssertEqual(FullComputerGradientFactorPreset.conservative2080.gfHigh, 80)
        XCTAssertEqual(FullComputerGradientFactorPreset.conservative2080.valueText, "GF 20/80")
    }

    func testStandardPresetValuesAndDefault() {
        XCTAssertEqual(FullComputerGradientFactorPreset.standard3070.gfLow, 30)
        XCTAssertEqual(FullComputerGradientFactorPreset.standard3070.gfHigh, 70)
        XCTAssertEqual(FullComputerGradientFactorPreset.watchDefault, .standard3070)
    }

    func testModeratePresetValues() {
        XCTAssertEqual(FullComputerGradientFactorPreset.moderate4085.gfLow, 40)
        XCTAssertEqual(FullComputerGradientFactorPreset.moderate4085.gfHigh, 85)
    }

    func testOnlyThreePresetsExist() {
        XCTAssertEqual(FullComputerGradientFactorPreset.allCases.count, 3)
    }

    func testMatchingAcceptsOnlySupportedPairs() {
        XCTAssertEqual(FullComputerGradientFactorPreset.matching(low: 20, high: 80), .conservative2080)
        XCTAssertEqual(FullComputerGradientFactorPreset.matching(low: 30, high: 70), .standard3070)
        XCTAssertEqual(FullComputerGradientFactorPreset.matching(low: 40, high: 85), .moderate4085)
        XCTAssertNil(FullComputerGradientFactorPreset.matching(low: 30, high: 80))
        XCTAssertNil(FullComputerGradientFactorPreset.matching(low: 50, high: 90))
    }

    func testInvalidRawValueFallsBackToStandard() {
        XCTAssertEqual(FullComputerGradientFactorPreset.load(from: "invalid"), .standard3070)
        XCTAssertEqual(FullComputerGradientFactorPreset.load(from: nil), .standard3070)
    }
}
