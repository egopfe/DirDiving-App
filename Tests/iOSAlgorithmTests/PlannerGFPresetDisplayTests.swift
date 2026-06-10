import XCTest

final class PlannerGFPresetDisplayTests: XCTestCase {
    func testConservativeGFPresetValuesUnchanged() {
        XCTAssertEqual(PlannerGFPreset.conservative.gfLow, 20, accuracy: 0.001)
        XCTAssertEqual(PlannerGFPreset.conservative.gfHigh, 70, accuracy: 0.001)
        XCTAssertEqual(PlannerGFPreset.conservative.displayPair, "20/70")
    }

    func testStandardGFPresetValuesUnchanged() {
        XCTAssertEqual(PlannerGFPreset.standard.gfLow, 30, accuracy: 0.001)
        XCTAssertEqual(PlannerGFPreset.standard.gfHigh, 80, accuracy: 0.001)
        XCTAssertEqual(PlannerGFPreset.standard.displayPair, "30/80")
    }

    func testAggressiveGFPresetValuesUnchanged() {
        XCTAssertEqual(PlannerGFPreset.aggressive.gfLow, 40, accuracy: 0.001)
        XCTAssertEqual(PlannerGFPreset.aggressive.gfHigh, 85, accuracy: 0.001)
        XCTAssertEqual(PlannerGFPreset.aggressive.displayPair, "40/85")
    }

    func testLocalizedTitleWithValuesIncludesDisplayPair() {
        for preset in PlannerGFPreset.allCases {
            XCTAssertTrue(preset.localizedTitleWithValues.contains(preset.displayPair))
            XCTAssertTrue(preset.localizedTitleWithValues.contains(preset.localizedTitle))
        }
    }

    func testLocalizedCompactTitleWithValuesIncludesDisplayPair() {
        for preset in PlannerGFPreset.allCases {
            XCTAssertTrue(preset.localizedCompactTitleWithValues.contains(preset.displayPair))
        }
    }

    func testDisplayPairDerivesFromGFPresetValues() {
        for preset in PlannerGFPreset.allCases {
            XCTAssertEqual(
                preset.displayPair,
                "\(Int(preset.gfLow))/\(Int(preset.gfHigh))"
            )
            XCTAssertEqual(preset.localizedGFValueLine, "GF \(preset.displayPair)")
        }
    }

    func testGFPresetAccessibilityLabelIncludesNameAndValues() {
        for preset in PlannerGFPreset.allCases {
            XCTAssertTrue(preset.accessibilityLabel.contains(preset.localizedTitle))
            XCTAssertTrue(preset.accessibilityLabel.contains(preset.displayPair))
        }
    }

    func testPlannerViewUsesVerticalGFPresetCards() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/PlannerView.swift"))
        XCTAssertTrue(source.contains("gfPresetOptionCard"))
        XCTAssertTrue(source.contains("preset.localizedTitle"))
        XCTAssertTrue(source.contains("preset.localizedGFValueLine"))
        XCTAssertTrue(source.contains("planner.gf.preset.explanation_format"))
        XCTAssertFalse(source.contains("pickerStyle(.segmented)"))
        XCTAssertFalse(source.contains("localizedCompactTitleWithValues"))
    }

    func testGFPresetExplanationLocalizationKeysExist() throws {
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        let keys = [
            "planner.gf.preset.explanation_format",
            "planner.gf.preset.accessibility_format",
            "planner.gf.preset.conservative.compact_format",
            "planner.gf.preset.standard.compact_format",
            "planner.gf.preset.aggressive.compact_format"
        ]
        for key in keys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT \(key)")
        }
        XCTAssertTrue(en["planner.gf.preset.explanation_format"]!.contains("%@"))
        XCTAssertTrue(it["planner.gf.preset.explanation_format"]!.contains("%@"))
    }

    func testDecoShowsGFPresetsBaseAndTechnicalUnchanged() {
        XCTAssertTrue(PlannerResultPresentation.presentation(for: .deco).showsGFPresets)
        XCTAssertFalse(PlannerResultPresentation.presentation(for: .base).showsGFPresets)
        XCTAssertFalse(PlannerResultPresentation.presentation(for: .technical).showsGFPresets)
        XCTAssertFalse(PlannerResultPresentation.presentation(for: .ccr).showsGFPresets)
        XCTAssertTrue(PlannerResultPresentation.presentation(for: .technical).showsManualGFControls)
        XCTAssertTrue(PlannerResultPresentation.presentation(for: .ccr).showsManualGFControls)
    }

    func testApplyGFPresetSemanticsUnchanged() {
        var input = GasPlanInput()
        PlannerModePolicy.applyGFPreset(.conservative, to: &input)
        XCTAssertEqual(input.gfLow, 20, accuracy: 0.001)
        XCTAssertEqual(input.gfHigh, 70, accuracy: 0.001)
        PlannerModePolicy.applyGFPreset(.aggressive, to: &input)
        XCTAssertEqual(input.gfLow, 40, accuracy: 0.001)
        XCTAssertEqual(input.gfHigh, 85, accuracy: 0.001)
        XCTAssertEqual(PlannerModePolicy.matchingGFPreset(for: input), .aggressive)
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadIOSStrings(named locale: String) throws -> [String: String] {
        let path = repositoryRoot()
            .appendingPathComponent("iOSApp/Resources/\(locale).lproj/Localizable.strings")
        let content = try String(contentsOf: path, encoding: .utf8)
        var result: [String: String] = [:]
        let pattern = #""([^"]+)"\s*=\s*"((?:\\.|[^"\\])*)";"#
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(content.startIndex..<content.endIndex, in: content)
        for match in regex.matches(in: content, range: range) {
            guard
                let keyRange = Range(match.range(at: 1), in: content),
                let valueRange = Range(match.range(at: 2), in: content)
            else { continue }
            result[String(content[keyRange])] = String(content[valueRange])
        }
        return result
    }
}
