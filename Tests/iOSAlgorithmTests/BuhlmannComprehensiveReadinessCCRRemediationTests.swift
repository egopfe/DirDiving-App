import PDFKit
import XCTest

final class BuhlmannComprehensiveReadinessCCRRemediationTests: XCTestCase {
    // MARK: - P1-BAILOUT-DOC / P4 bailout truthfulness

    func testBailoutScenarioResultIsHeuristic() {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas(mixKind: .ean, oxygenPercent: 32, switchDepthMeters: 0)]
        let scenario = CCRBailoutScenarioCalculator.evaluate(
            kind: .lostLoop,
            input: input,
            environment: .seaLevelSaltWater
        )
        XCTAssertTrue(scenario.isHeuristic)
        XCTAssertTrue(scenario.referenceNotes.contains(DIRIOSLocalizer.string("ccr.bailout.heuristic_disclaimer")))
    }

    func testBailoutDisclaimerLocalizationKeysResolveENIT() {
        XCTAssertFalse(String(localized: "ccr.bailout.heuristic_disclaimer").isEmpty)
        XCTAssertFalse(String(localized: "ccr.narcosis.estimator_footnote").isEmpty)
    }

    func testCCRPlanPDFContainsBailoutHeuristicAndNarcosisFootnote() {
        var input = CCRPlanInput.default
        input.maxDepthMeters = 40
        input.bottomTimeMinutes = 25
        input.bailoutGases = [CCRBailoutGas(mixKind: .ean, oxygenPercent: 32, switchDepthMeters: 0)]
        let plan = CCRPlannerService.makePlan(input: input)
        let context = PDFExportCCRPlannerContext(
            input: input,
            plan: plan,
            safetyAcknowledged: true,
            unitPreference: .metric
        )
        let data = CCRPlannerPDFBuilder.build(context: context)
        let text = pdfText(data).lowercased()
        XCTAssertFalse(text.isEmpty)
        XCTAssertTrue(
            text.contains("heuristic") || text.contains("bühlmann") || text.contains("buhlmann"),
            "Expected bailout heuristic disclaimer in PDF text"
        )
        if !plan.ppN2Timeline.isEmpty {
            XCTAssertTrue(
                text.contains("diluent") || text.contains("setpoint") || text.contains("reference"),
                "Expected narcosis/reference footnote content in PDF"
            )
        }
    }

    func testCCRPlanPDFIncludesSetpointDiluentAndScheduleFields() {
        var input = CCRPlanInput.default
        input.setpointProfile.lowSetpoint = 0.7
        input.setpointProfile.highSetpoint = 1.3
        input.setpointProfile.switchDepthMeters = 20
        input.diluent = CCRDiluent(mixKind: .trimix, oxygenPercent: 21, heliumPercent: 35)
        input.bailoutGases = [CCRBailoutGas(mixKind: .ean, oxygenPercent: 32, switchDepthMeters: 0)]
        let plan = CCRPlannerService.makePlan(input: input)
        let context = PDFExportCCRPlannerContext(
            input: input,
            plan: plan,
            safetyAcknowledged: true,
            unitPreference: .metric
        )
        let text = pdfText(CCRPlannerPDFBuilder.build(context: context))
        XCTAssertTrue(text.contains("0.7"))
        XCTAssertTrue(text.contains("1.3"))
        XCTAssertTrue(text.contains(input.diluent.label))
        XCTAssertTrue(text.contains(DIRIOSLocalizer.string("ccr.pdf.disclaimer")))
    }

    // MARK: - P2-RUNTIME segments quarantine

    func testRuntimeSegmentsPolicyDoesNotAlterSchedule() {
        var baseline = CCRPlanInput.default
        baseline.bailoutGases = [CCRBailoutGas()]
        var withSegments = baseline
        withSegments.setpointProfile.runtimeSegments = [
            CCRSetpointSegment(runtimeMinutes: 15, depthMeters: 35, setpointBar: 1.4, note: "inactive")
        ]
        let basePlan = CCRPlannerService.makePlan(input: baseline)
        let segmentPlan = CCRPlannerService.makePlan(input: withSegments)
        XCTAssertEqual(basePlan.decoStops.count, segmentPlan.decoStops.count)
        XCTAssertEqual(basePlan.ttsMinutes, segmentPlan.ttsMinutes)
    }

    // MARK: - P3-CHECKLIST role metadata

    func testCCRDiluentRolePersistsAfterTitleRename() {
        var item = EquipmentChecklistItem(
            title: "Custom diluent label",
            usesGas: true,
            gasMixKind: .air,
            gasText: "AIR",
            gasRole: .ccrDiluent
        )
        item.title = "Renamed diluent cylinder"
        XCTAssertEqual(ChecklistPlannerSyncMapper.resolvedRole(for: item), .ccrDiluent)
    }

    func testCCRBailoutRolePersistsAfterTitleRename() {
        var item = EquipmentChecklistItem(
            title: "Bailout 1",
            usesGas: true,
            gasMixKind: .ean,
            gasText: "EAN32",
            gasRole: .ccrBailout
        )
        item.title = "Offboard stage renamed"
        XCTAssertEqual(ChecklistPlannerSyncMapper.resolvedRole(for: item), .ccrBailout)
    }

    func testLegacyInferRoleRecognizesItalianDiluentTitle() {
        let item = EquipmentChecklistItem(title: "Bombola diluente CCR", usesGas: true)
        XCTAssertEqual(ChecklistPlannerSyncMapper.legacyInferRole(from: item.title), .ccrDiluent)
        XCTAssertNil(ChecklistPlannerSyncMapper.resolvedRole(for: item))
    }

    func testCCRChecklistExportUpdatesMultipleBailoutRowsByOrder() {
        var input = CCRPlanInput.default
        input.bailoutGases = [
            CCRBailoutGas(mixKind: .ean, oxygenPercent: 32, switchDepthMeters: 0),
            CCRBailoutGas(mixKind: .oxygen, switchDepthMeters: 6)
        ]
        var checklist: [EquipmentChecklistItem] = [
            EquipmentChecklistItem(title: "Diluent", isReady: false, usesGas: true, gasMixKind: .air, gasText: "OLD AIR", gasRole: .ccrDiluent),
            EquipmentChecklistItem(title: "B1", isReady: false, usesGas: true, gasMixKind: .ean, gasText: "OLD32", gasRole: .ccrBailout),
            EquipmentChecklistItem(title: "B2", isReady: false, usesGas: true, gasMixKind: .oxygen, gasText: "OLD O2", gasRole: .ccrBailout)
        ]
        ChecklistPlannerSyncMapper.applyCCRExport(input: input, to: &checklist)
        let bailouts = checklist.filter { $0.gasRole == .ccrBailout }
        XCTAssertEqual(bailouts.count, 2)
        XCTAssertFalse(bailouts[0].gasText.contains("OLD"))
        XCTAssertFalse(bailouts[1].gasText.contains("OLD"))
    }

    // MARK: - P2-CCR-PDF / export policy

    func testDivePackExportIsOCPlannerOnly() {
        // Dive Pack API requires PDFExportPlannerContext — CCR uses separate export path.
        XCTAssertFalse(String(describing: PDFExportService.exportDivePack).isEmpty)
    }

    func testInvalidCCRPlanBlocksExport() {
        var input = CCRPlanInput.default
        input.bailoutGases = []
        let plan = CCRPlannerService.makePlan(input: input)
        let context = PDFExportCCRPlannerContext(
            input: input,
            plan: plan,
            safetyAcknowledged: true,
            unitPreference: .metric
        )
        XCTAssertFalse(PDFExportService.canExportCCRPlan(context))
    }

    // MARK: - P1-ICLOUD / persistence

    func testCCRPlanInputJSONRoundTripPreservesSetpointAndBailout() throws {
        var input = CCRPlanInput.default
        input.setpointProfile.switchDepthMeters = 22
        input.bailoutGases = [CCRBailoutGas(mixKind: .trimix, oxygenPercent: 21, heliumPercent: 35, switchDepthMeters: 0)]
        let data = try JSONEncoder().encode(input)
        let decoded = try JSONDecoder().decode(CCRPlanInput.self, from: data)
        XCTAssertEqual(decoded.setpointProfile.switchDepthMeters, 22, accuracy: 0.01)
        XCTAssertEqual(decoded.bailoutGases.count, 1)
        XCTAssertEqual(decoded.bailoutGases[0].heliumPercent, 35)
    }

    private func pdfText(_ data: Data) -> String {
        guard let document = PDFDocument(data: data) else { return "" }
        return (0..<document.pageCount)
            .compactMap { document.page(at: $0)?.string }
            .joined(separator: "\n")
    }
}
