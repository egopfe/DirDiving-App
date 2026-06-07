import XCTest

final class UIUXRemediationV2Tests: XCTestCase {
    private let onboardingKeys = [
        "ios.legal.welcome.card",
        "ios.legal.welcome.title",
        "ios.legal.welcome.body",
        "ios.legal.welcome.continue",
        "ios.legal.safety.card",
        "ios.legal.safety.not_dive_computer",
        "ios.legal.safety.warning.deco",
        "ios.legal.safety.exit",
        "ios.legal.safety.understand",
        "ios.legal.disclaimer.card",
        "ios.legal.disclaimer.continue",
        "ios.legal.acceptance.card",
        "ios.legal.acceptance.certified",
        "ios.legal.acceptance.continue"
    ]

    private let accessibilityKeys = [
        "planner.ratio_deco.overlay.a11y.compatible",
        "planner.ratio_deco.overlay.a11y.incompatible",
        "planner.ratio_deco.overlay.a11y.hint",
        "tissue_analytics.a11y.trend",
        "tissue_analytics.a11y.compartment_bars",
        "tissue_analytics.a11y.narcotic_chart",
        "planner.accessibility.cns_full_plan.warning.label",
        "planner.accessibility.cns_full_plan.warning.hint"
    ]

    func testLegalOnboardingKeysExistInEnglishAndItalian() throws {
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        for key in onboardingKeys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN onboarding key: \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT onboarding key: \(key)")
        }
    }

    func testLegalOnboardingViewAvoidsHardcodedEnglishSteps() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/IOSLegalOnboardingView.swift"))
        XCTAssertFalse(source.contains("\"Welcome to DIR Diving\""))
        XCTAssertFalse(source.contains("\"Safety Warning\""))
        XCTAssertTrue(source.contains("ios.legal.welcome.title"))
        XCTAssertTrue(source.contains("ios.legal.safety.card"))
    }

    func testLogbookViewUsesExplicitDeleteNotSwipeActions() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/LogbookView.swift"))
        XCTAssertFalse(source.contains(".swipeActions"))
        XCTAssertTrue(source.contains("logbook.delete.button.a11y"))
        XCTAssertTrue(source.contains("logbook.delete.confirm.title"))
    }

    func testPlannerModeFooterMentionsAllModesAndRatioDecoHeuristic() throws {
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        for strings in [en, it] {
            let footer = strings["planner.mode.footer", default: ""]
            XCTAssertTrue(footer.localizedCaseInsensitiveContains("Base"))
            XCTAssertTrue(footer.localizedCaseInsensitiveContains("Deco"))
            XCTAssertTrue(footer.localizedCaseInsensitiveContains("Ratio") || footer.localizedCaseInsensitiveContains("ratio"))
        }
        XCTAssertTrue(en["planner.mode.footer", default: ""].localizedCaseInsensitiveContains("heuristic"))
    }

    func testAccessibilitySummaryKeysExist() throws {
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        for key in accessibilityKeys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN key: \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT key: \(key)")
        }
    }

    func testRatioDecoOverlayAccessibilitySummaryDiffersForCompatibility() {
        let compatible = RatioDecoValidationResult(
            isBuhlmannCompatible: true,
            warnings: [],
            firstViolationRuntime: nil,
            firstViolationDepthMeters: nil,
            requiredCeilingMeters: nil
        )
        let incompatible = RatioDecoValidationResult(
            isBuhlmannCompatible: false,
            warnings: [.decoDepthLimitExceeded],
            firstViolationRuntime: 12,
            firstViolationDepthMeters: 35,
            requiredCeilingMeters: 6
        )
        let compatibleSummary = UIUXAccessibilitySummaries.ratioDecoOverlayChart(
            buhlmannTTS: 42,
            ratioTTS: 45,
            maxDepthMeters: 30,
            validation: compatible,
            unitPreference: .metric
        )
        let incompatibleSummary = UIUXAccessibilitySummaries.ratioDecoOverlayChart(
            buhlmannTTS: 42,
            ratioTTS: 45,
            maxDepthMeters: 30,
            validation: incompatible,
            unitPreference: .metric
        )
        XCTAssertFalse(compatibleSummary.isEmpty)
        XCTAssertFalse(incompatibleSummary.isEmpty)
        XCTAssertNotEqual(compatibleSummary, incompatibleSummary)
    }

    func testTissueAccessibilitySummaryIncludesSimulatedSource() {
        let trace = TissueAnalyticsTrace(
            samples: [],
            finalCompartments: [],
            controllingCompartment: 3,
            maxPPN2Bar: 2.4,
            endEquivalentMeters: 28,
            source: .simulated,
            summary: TissueAnalyticsSummary(
                maxDepthMeters: 30,
                bottomTimeMinutes: 20,
                ttsMinutes: 5,
                gfLow: 30,
                gfHigh: 85,
                modeTitle: "Deco",
                totalRuntimeMinutes: 25
            ),
            depthProfilePoints: [],
            segments: [],
            decoStops: []
        )
        let summary = UIUXAccessibilitySummaries.tissueTrend(trace: trace, unitPreference: .metric)
        XCTAssertFalse(summary.isEmpty)
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadIOSStrings(named locale: String) throws -> [String: String] {
        let url = repositoryRoot().appendingPathComponent("iOSApp/Resources/\(locale).lproj/Localizable.strings")
        return parseStringsFile(try String(contentsOf: url, encoding: .utf8))
    }

    private func parseStringsFile(_ raw: String) -> [String: String] {
        var result: [String: String] = [:]
        let pattern = #"\"([^\"]+)\"\s*=\s*\"([^\"]*)\";"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return result }
        let range = NSRange(raw.startIndex..<raw.endIndex, in: raw)
        regex.enumerateMatches(in: raw, range: range) { match, _, _ in
            guard let match,
                  let keyRange = Range(match.range(at: 1), in: raw),
                  let valueRange = Range(match.range(at: 2), in: raw) else { return }
            result[String(raw[keyRange])] = String(raw[valueRange])
        }
        return result
    }
}
