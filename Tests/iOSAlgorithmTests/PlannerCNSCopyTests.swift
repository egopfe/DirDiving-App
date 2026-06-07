import Foundation
import XCTest

final class PlannerCNSCopyTests: XCTestCase {
    private let requiredKeys = [
        "planner.metric.cns_full_plan",
        "planner.metric.cns_full_plan.footnote",
        "planner.metric.cns_preview",
        "planner.metric.cns_preview.footnote",
        "planner.metric.cns_descent_bottom",
        "planner.metric.cns_descent_bottom.footnote",
        "planner.cns_descent_bottom.warning",
        "planner.cns_descent_bottom.warning.hint",
        "planner.metric.cns_ascent_deco_estimate",
        "planner.metric.cns_ascent_deco_estimate.footnote",
        "planner.settings.cns_descent_bottom_15_check.description",
        "planner.accessibility.cns_descent_bottom.warning.label",
        "planner.accessibility.cns_descent_bottom.warning.hint",
        "planner.metric.otu_weekly",
        "planner.metric.otu_weekly.footnote",
        "planner.warning.otu_weekly_elevated"
    ]

    func testPlannerCNSLocalizationKeysExistInEnglishAndItalian() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        for key in requiredKeys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN key: \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT key: \(key)")
        }
    }

    func testEnglishCNSLabelsUseFullPlanAndPreviewWording() throws {
        let en = try loadStrings(named: "en")
        XCTAssertTrue(en["planner.metric.cns_full_plan"]?.contains("full plan") == true)
        XCTAssertTrue(en["planner.metric.cns_preview"]?.contains("preview") == true)
        XCTAssertTrue(en["planner.metric.cns_full_plan.footnote"]?.contains("decompression") == true)
        XCTAssertTrue(en["planner.metric.cns_descent_bottom.footnote"]?.contains("excludes") == true)
        XCTAssertTrue(en["planner.cns_descent_bottom.warning.hint"]?.contains("Reference only") == true)
    }

    func testItalianCNSLabelsUseFullPlanAndPreviewWording() throws {
        let it = try loadStrings(named: "it")
        XCTAssertTrue(it["planner.metric.cns_full_plan"]?.contains("piano completo") == true)
        XCTAssertTrue(it["planner.metric.cns_preview"]?.contains("anteprima") == true)
        XCTAssertTrue(it["planner.metric.cns_full_plan.footnote"]?.contains("decompressione") == true)
        XCTAssertTrue(it["planner.metric.cns_descent_bottom.footnote"]?.contains("esclude") == true)
    }

    func testCNSAscentDecoEstimateEqualsDerivedDifference() {
        let analysis = TechnicalGasAnalysis(
            gas: GasMix(name: "Air", oxygen: 0.21, helium: 0, maxPPO2: 1.4),
            ppO2AtDepth: 1.2,
            densityAtDepth: 5,
            densityRating: .green,
            endMeters: 20,
            eadMeters: 20,
            consumptionLiters: 100,
            remainingLiters: 500,
            remainingBar: 150,
            rockBottomLiters: 50,
            minimumGasBar: 50,
            turnPressureBar: 120,
            cnsPercent: 42,
            cnsDescentBottomPercent: 18,
            otu: 10,
            cnsDailyPercent: 42,
            otuDaily24h: 10,
            otuWeekly: 10,
            airBreakRecoveryApplied: false,
            warnings: [],
            states: [],
            usesBottomPhaseConsumptionEstimate: false
        )
        XCTAssertEqual(analysis.cnsAscentDecoEstimatePercent, 24, accuracy: 0.001)
    }

    func testCNSAscentDecoEstimateClampsNegativeDeltaToZero() {
        let analysis = TechnicalGasAnalysis(
            gas: GasMix(name: "Air", oxygen: 0.21, helium: 0, maxPPO2: 1.4),
            ppO2AtDepth: 1.2,
            densityAtDepth: 5,
            densityRating: .green,
            endMeters: 20,
            eadMeters: 20,
            consumptionLiters: 100,
            remainingLiters: 500,
            remainingBar: 150,
            rockBottomLiters: 50,
            minimumGasBar: 50,
            turnPressureBar: 120,
            cnsPercent: 10,
            cnsDescentBottomPercent: 15,
            otu: 10,
            cnsDailyPercent: 10,
            otuDaily24h: 10,
            otuWeekly: 10,
            airBreakRecoveryApplied: false,
            warnings: [],
            states: [],
            usesBottomPhaseConsumptionEstimate: false
        )
        XCTAssertEqual(analysis.cnsAscentDecoEstimatePercent, 0, accuracy: 0.001)
    }

    func testFullPlanOxygenExposureWarningUsesExistingPlannerState() {
        let elevated = TechnicalGasAnalysis(
            gas: GasMix(name: "Air", oxygen: 0.21, helium: 0, maxPPO2: 1.4),
            ppO2AtDepth: 1.2,
            densityAtDepth: 5,
            densityRating: .green,
            endMeters: 20,
            eadMeters: 20,
            consumptionLiters: 100,
            remainingLiters: 500,
            remainingBar: 150,
            rockBottomLiters: 50,
            minimumGasBar: 50,
            turnPressureBar: 120,
            cnsPercent: 95,
            cnsDescentBottomPercent: 18,
            otu: 40,
            cnsDailyPercent: 95,
            otuDaily24h: 40,
            otuWeekly: 40,
            airBreakRecoveryApplied: false,
            warnings: [],
            states: [.oxygenExposureElevated],
            usesBottomPhaseConsumptionEstimate: false
        )
        let normal = TechnicalGasAnalysis(
            gas: GasMix(name: "Air", oxygen: 0.21, helium: 0, maxPPO2: 1.4),
            ppO2AtDepth: 1.2,
            densityAtDepth: 5,
            densityRating: .green,
            endMeters: 20,
            eadMeters: 20,
            consumptionLiters: 100,
            remainingLiters: 500,
            remainingBar: 150,
            rockBottomLiters: 50,
            minimumGasBar: 50,
            turnPressureBar: 120,
            cnsPercent: 20,
            cnsDescentBottomPercent: 18,
            otu: 10,
            cnsDailyPercent: 20,
            otuDaily24h: 10,
            otuWeekly: 10,
            airBreakRecoveryApplied: false,
            warnings: [],
            states: [],
            usesBottomPhaseConsumptionEstimate: false
        )
        XCTAssertTrue(elevated.showsFullPlanOxygenExposureWarning)
        XCTAssertFalse(normal.showsFullPlanOxygenExposureWarning)
    }

    func testBriefingUsesTTSTerminologyOnly() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        XCTAssertTrue(en["planner.briefing.gf_tts"]?.contains("TTS estimate") == true)
        XCTAssertFalse(en["planner.briefing.gf_tts"]?.contains("TTR") == true)
        XCTAssertTrue(it["planner.briefing.gf_tts"]?.contains("stima TTS") == true)
        XCTAssertFalse(it["planner.briefing.gf_tts"]?.contains("TTR") == true)
    }

    private func loadStrings(named language: String) throws -> [String: String] {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let url = root
            .appendingPathComponent("iOSApp/Resources/\(language).lproj/Localizable.strings")
        let contents = try String(contentsOf: url, encoding: .utf8)
        var map: [String: String] = [:]
        let pattern = #""([^"]+)"\s*=\s*"((?:\\.|[^"\\])*)";"#
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(contents.startIndex..<contents.endIndex, in: contents)
        regex.enumerateMatches(in: contents, range: range) { match, _, _ in
            guard let match, match.numberOfRanges == 3,
                  let keyRange = Range(match.range(at: 1), in: contents),
                  let valueRange = Range(match.range(at: 2), in: contents) else { return }
            map[String(contents[keyRange])] = String(contents[valueRange])
        }
        return map
    }
}
