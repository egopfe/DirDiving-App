import XCTest

final class PlannerOxygenWarningGranularityTests: XCTestCase {
    func testDecoPlanMapsGranularOxygenStatesWhenElevated() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "O2", role: .deco, oxygen: 1.0, helium: 0, maxPPO2: 1.6), switchDepthMeters: 6)
        ]
        let plan = PlannerService.makePlan(input: input)
        if plan.decoStops.isEmpty {
            throw XCTSkip("No deco plan generated")
        }
        let states = plan.gasAnalysis.states
        if states.contains(.oxygenExposureElevated) {
            XCTAssertTrue(
                states.contains(.cnsSingleElevated)
                    || states.contains(.otuDiveElevated)
                    || states.contains(.otuDailyElevated)
                    || states.contains(.otuWeeklyElevated)
                    || states.contains(.cnsDailyElevated)
            )
        }
        if plan.gasAnalysis.cnsDescentBottomExceedsPlannerThreshold(checkEnabled: true) {
            XCTAssertTrue(states.contains(.cnsDescentBottomThresholdExceeded))
        }
    }

    func testWeeklyOTULocalizationKeysExist() throws {
        let keys = [
            "planner.metric.otu_weekly",
            "planner.metric.otu_weekly.footnote",
            "planner.warning.otu_weekly_elevated",
            "planner.state.cns_single_elevated.title",
            "planner.state.otu_dive_elevated.title"
        ]
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        for key in keys {
            XCTAssertFalse(en[key, default: ""].isEmpty, key)
            XCTAssertFalse(it[key, default: ""].isEmpty, key)
        }
        XCTAssertTrue(en["planner.metric.otu_weekly"]?.contains("Weekly") == true)
        XCTAssertTrue(it["planner.metric.otu_weekly"]?.contains("settimanale") == true)
        XCTAssertTrue(en["planner.metric.otu_weekly.footnote"]?.contains("Reference only") == true)
    }

    func testWeeklyOTUMetricAvailability() {
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
            cnsPercent: 20,
            cnsDescentBottomPercent: 10,
            otu: 10,
            cnsDailyPercent: 20,
            otuDaily24h: 10,
            otuWeekly: 1_900,
            airBreakRecoveryApplied: false,
            warnings: [],
            states: [.otuWeeklyElevated, .oxygenExposureElevated],
            usesBottomPhaseConsumptionEstimate: false
        )
        XCTAssertTrue(elevated.showsWeeklyOTUMetric)
        XCTAssertTrue(elevated.showsWeeklyOTUElevatedWarning)
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
