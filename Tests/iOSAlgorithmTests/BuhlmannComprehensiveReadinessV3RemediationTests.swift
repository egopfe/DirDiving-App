import XCTest

final class BühlmannComprehensiveReadinessV3RemediationTests: XCTestCase {
    // MARK: - V3-P2-001 Logbook tissue source labeling

    func testPlannerTraceUsesPlannedBuhlmannReplaySource() {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.plannedDepthMeters = 30
        input.plannedBottomMinutes = 20
        input.plannedAverageDepthMeters = 24
        input.gfLow = 30
        input.gfHigh = 85
        input.bottomGas = GasMix(name: "Air", mixKind: .air, oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        if let index = input.plannerCylinders.firstIndex(where: { $0.role == .bottom }) {
            input.plannerCylinders[index].gas = input.bottomGas
        }
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .deco)
        let plan = PlannerService.makePlan(input: active, mode: .deco)
        guard let presentation = TissueAnalyticsService.presentationForPlanner(plan: plan, input: active, mode: .deco) else {
            return XCTFail("Expected planner presentation")
        }
        XCTAssertEqual(presentation.trace.source, .planned)
    }

    func testWatchRecordedSessionUsesRecordedBuhlmannReplay() {
        TissueAnalyticsService.invalidateCache()
        let session = TissueAnalyticsServiceTestsSupport.recordedWatchSession()
        XCTAssertEqual(TissueAnalyticsLogbookReplay.resolvedSource(for: session), .recorded)
        let presentation = TissueAnalyticsService.presentationForSession(session)
        XCTAssertNotNil(presentation)
        XCTAssertEqual(presentation?.trace.source, .recorded)
        XCTAssertFalse(presentation?.trace.samples.isEmpty ?? true)
    }

    func testManualDiveUsesSimulatedEstimateSource() {
        TissueAnalyticsService.invalidateCache()
        var session = TissueAnalyticsServiceTestsSupport.recordedWatchSession()
        session.isManual = true
        XCTAssertEqual(TissueAnalyticsLogbookReplay.resolvedSource(for: session), .simulated)
        let presentation = TissueAnalyticsService.presentationForSession(session)
        XCTAssertEqual(presentation?.trace.source, .simulated)
        let subtitle = TissueAnalyticsService.logbookEntrySubtitle(for: session)
        XCTAssertEqual(subtitle, String(localized: "tissue_analytics.logbook.entry.subtitle.manual_synthetic"))
    }

    func testTrimixLogbookFallsBackToSimulatedEstimate() {
        TissueAnalyticsService.invalidateCache()
        var session = TissueAnalyticsServiceTestsSupport.recordedWatchSession()
        session.gasLabel = .trimix
        XCTAssertEqual(TissueAnalyticsLogbookReplay.resolvedSource(for: session), .simulated)
        let presentation = TissueAnalyticsService.presentationForSession(session)
        XCTAssertEqual(presentation?.trace.source, .simulated)
    }

    func testInsufficientSampleCountReturnsNilPresentation() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let session = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(600),
            durationSeconds: 600,
            maxDepthMeters: 20,
            avgDepthMeters: 18,
            avgWaterTemperatureCelsius: nil,
            ttv: 0,
            entryGPS: nil,
            exitGPS: nil,
            samples: [DiveSample(timestamp: start, depthMeters: 20, temperatureCelsius: 18)],
            hasDepthProfile: true
        )
        XCTAssertEqual(TissueAnalyticsLogbookReplay.resolvedSource(for: session), .insufficientData)
        XCTAssertNil(TissueAnalyticsService.presentationForSession(session))
    }

    func testTissueSourceLocalizationKeysResolveENIT() {
        XCTAssertFalse(String(localized: "tissue_analytics.source.planned").isEmpty)
        XCTAssertFalse(String(localized: "tissue_analytics.source.recorded").isEmpty)
        XCTAssertFalse(String(localized: "tissue_analytics.source.simulated").isEmpty)
        XCTAssertFalse(String(localized: "tissue_analytics.source.insufficient").isEmpty)
        XCTAssertFalse(String(localized: "tissue_analytics.logbook.entry.subtitle.manual_synthetic").isEmpty)
    }

    // MARK: - IOS-BUH-P3-001 GF equality policy

    func testGFLowEqualsHighRejectedWithPolicyMessage() {
        var input = GasPlanInput()
        input.gfLow = 50
        input.gfHigh = 50
        let result = PlannerInputValidator.validate(input, mode: .technical)
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.states.contains(.invalidInput))
    }

    // MARK: - IOS-BUH-P3-002 Briefing TTS label

    func testBriefingCopyUsesTTSNotTTR() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        XCTAssertTrue(en["planner.briefing.gf_tts"]?.contains("TTS") == true)
        XCTAssertFalse(en["planner.briefing.gf_tts"]?.contains("TTR") == true)
        XCTAssertTrue(it["planner.briefing.gf_tts"]?.contains("TTS") == true)
        XCTAssertFalse(it["planner.briefing.gf_tts"]?.contains("TTR") == true)
    }

    // MARK: - IOS-BUH-P3-003 Invalid environment fails empty for planner tissue

    func testPlannerTissueAnalyticsRejectsInvalidEnvironment() {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.plannedDepthMeters = 30
        input.plannedBottomMinutes = 20
        input.altitudeMeters = 50_000
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .deco)
        let plan = PlannerService.makePlan(input: active, mode: .deco)
        let presentation = TissueAnalyticsService.presentationForPlanner(plan: plan, input: active, mode: .deco)
        XCTAssertNil(presentation)
    }

    // MARK: - V3-P3-001 Checklist PDF unit formatting

    func testChecklistPDFSwitchDepthMetric() {
        let item = EquipmentChecklistItem(
            title: "Deco stage",
            usesGas: true,
            gasMixKind: .ean,
            gasText: "EAN50",
            switchDepthMeters: 21,
            gasRole: .deco
        )
        let line = ChecklistPDFBuilder.exportLine(for: item, unitPreference: .metric)
        XCTAssertTrue(line.contains("switch @ \(Formatters.depth(21, units: .metric).text)"), "line was: \(line)")
    }

    func testChecklistPDFSwitchDepthImperial() {
        let item = EquipmentChecklistItem(
            title: "Deco stage",
            usesGas: true,
            gasMixKind: .ean,
            gasText: "EAN50",
            switchDepthMeters: 21,
            gasRole: .deco
        )
        let line = ChecklistPDFBuilder.exportLine(for: item, unitPreference: .imperial)
        let expectedFeet = Formatters.depth(21, units: .imperial).text
        XCTAssertTrue(line.contains("switch @ \(expectedFeet)"), "line was: \(line)")
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

enum TissueAnalyticsServiceTestsSupport {
    static func recordedWatchSession() -> DiveSession {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        var samples: [DiveSample] = []
        for minute in 0...30 {
            let depth: Double
            if minute < 5 {
                depth = Double(minute * 6)
            } else if minute < 25 {
                depth = 30
            } else {
                depth = max(0, 30 - Double(minute - 25) * 6)
            }
            samples.append(
                DiveSample(
                    timestamp: start.addingTimeInterval(TimeInterval(minute * 60)),
                    depthMeters: depth,
                    temperatureCelsius: 18
                )
            )
        }
        return DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(30 * 60),
            durationSeconds: 30 * 60,
            maxDepthMeters: 30,
            avgDepthMeters: 22,
            avgWaterTemperatureCelsius: 18,
            ttv: 0,
            entryGPS: nil,
            exitGPS: nil,
            samples: samples,
            gasLabel: .nitrox,
            isManual: false,
            hasDepthProfile: true
        )
    }
}
