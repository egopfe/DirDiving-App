import XCTest
import PDFKit

final class PlannerPresentationTests: XCTestCase {
    func testPlannerViewUsesRuntimeTitleKey() throws {
        let source = try String(contentsOfFile: plannerViewSourcePath(), encoding: .utf8)
        XCTAssertTrue(source.contains("planner.runtime.title"))
        XCTAssertTrue(source.contains("planner.runtime.subtitle"))
        XCTAssertTrue(source.contains("row.kind.localizedTitle"))
        XCTAssertTrue(source.contains("PlannerAscentRowKind.decoStop.localizedTitle"))
        XCTAssertTrue(source.contains("DecoStopsSectionView"))
        XCTAssertTrue(source.contains("showsDecoStopsSection"))
        XCTAssertTrue(source.contains("decoStopsPresentationRows"))
    }

    /// Team/Buddy planning is intentionally not surfaced in the main Planner until a full compatibility model exists.
    func testPlannerMainOutputDoesNotSurfaceTeamGasMatchSection() throws {
        let source = try String(contentsOfFile: plannerViewSourcePath(), encoding: .utf8)
        XCTAssertFalse(source.contains("teamMatchCard"))
        XCTAssertFalse(source.contains("teamPreviewCard"))
        XCTAssertFalse(source.contains("planner.team.match_title"))
        XCTAssertFalse(source.contains("planner.team.matching_title"))
        let technicalPresentation = PlannerResultPresentation.presentation(for: .technical)
        XCTAssertFalse(technicalPresentation.showsTeamMatch)
        XCTAssertFalse(technicalPresentation.showsTeamPreview)
    }

    func testTechnicalPlannerStillShowsGasLedgerPresentationFlag() {
        let presentation = PlannerResultPresentation.presentation(for: .technical)
        XCTAssertTrue(presentation.showsGasLedger)
    }

    func testGasLedgerSectionTitleIsAvailableGas() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        XCTAssertEqual(en["planner.available_gas.title"], "Available Gas")
        XCTAssertEqual(it["planner.available_gas.title"], "Gas disponibile")
        let source = try String(contentsOfFile: plannerViewSourcePath(), encoding: .utf8)
        XCTAssertTrue(source.contains("planner.available_gas.title"))
        XCTAssertTrue(source.contains("GasQuantityMetricTile"))
    }

    func testDecoStopsSectionShowsOnlyDecoStops() throws {
        let plan = try technicalDecoPlan()
        let rows = DecoStopsPresentationBuilder.rows(from: plan.decoStops)
        XCTAssertEqual(rows.count, plan.decoStops.count)
        XCTAssertEqual(rows.map(\.index), Array(1...plan.decoStops.count))
    }

    func testDecoStopsSectionPreservesDepthTimeGasPPO2() throws {
        let plan = try technicalDecoPlan()
        let rows = DecoStopsPresentationBuilder.rows(from: plan.decoStops)
        for (row, stop) in zip(rows, plan.decoStops) {
            XCTAssertEqual(row.depthMeters, stop.depthMeters, accuracy: 0.001)
            XCTAssertEqual(row.minutes, stop.minutes)
            XCTAssertEqual(row.gasLabel, stop.gas)
            XCTAssertEqual(row.ppO2, stop.ppO2, accuracy: 0.001)
        }
    }

    func testDecoStopsSectionHiddenForNoDecoBase() {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.plannedDepthMeters = 18
        input.plannedBottomMinutes = 20
        input.bottomGas = GasMix(name: "EAN32", role: .bottom, oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        let plan = PlannerService.makePlan(input: input, mode: .base)
        XCTAssertFalse(DecoStopsPresentationBuilder.shouldShowSection(mode: .base, decoStops: plan.decoStops))
    }

    func testDecoStopsSectionVisibleForDecoPlanWithStops() throws {
        let plan = try decoModePlanWithStops()
        XCTAssertTrue(DecoStopsPresentationBuilder.shouldShowSection(mode: .deco, decoStops: plan.decoStops))
    }

    func testDecoStopsSectionVisibleForTechnicalPlanWithStops() throws {
        let plan = try technicalDecoPlan()
        XCTAssertTrue(DecoStopsPresentationBuilder.shouldShowSection(mode: .technical, decoStops: plan.decoStops))
    }

    func testRuntimeAndDecoStopsSectionAreIndependent() throws {
        let plan = try technicalDecoPlan()
        let decoRows = DecoStopsPresentationBuilder.rows(from: plan.decoStops)
        XCTAssertGreaterThan(plan.ascentTableRows.count, decoRows.count)
        XCTAssertTrue(plan.ascentTableRows.contains(where: { $0.kind == .descent }))
        XCTAssertTrue(plan.ascentTableRows.contains(where: { $0.kind == .bottom }))
        XCTAssertTrue(plan.ascentTableRows.contains(where: { $0.kind == .surface }))
        XCTAssertEqual(decoRows.count, plan.decoStops.count)
    }

    func testDecoStopsTitleLocalization() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        XCTAssertEqual(en["planner.deco_stops.title"], "Deco Stops")
        XCTAssertEqual(it["planner.deco_stops.title"], "Tappe decompressive")
    }

    func testRawDecoStopEnumNameIsNotPresentedInDecoStopsSection() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        XCTAssertEqual(en["planner.deco_stops.title"], "Deco Stops")
        XCTAssertEqual(it["planner.deco_stops.title"], "Tappe decompressive")
        XCTAssertFalse(en["planner.deco_stops.title", default: ""].localizedCaseInsensitiveContains("decoStop"))
    }

    func testCCRDecoStopsSectionUsesPlannerStopsNotBailoutHeuristic() {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas(mixKind: .ean, oxygenPercent: 32, switchDepthMeters: 0)]
        let plan = CCRPlannerService.makePlan(input: input)
        XCTAssertTrue(plan.validationResult.isValid)
        let presentationRows = DecoStopsPresentationBuilder.rows(from: plan.decoStops)
        XCTAssertEqual(presentationRows.count, plan.decoStops.count)
        XCTAssertNotEqual(presentationRows.count, plan.bailoutScenarios.count)
        XCTAssertTrue(DecoStopsPresentationBuilder.shouldShowSection(mode: .ccr, decoStops: plan.decoStops) || plan.decoStops.isEmpty)
    }

    func testBriefingPDFUsesRuntimeTitleAndDecoStopLabel() throws {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.plannedDepthMeters = 45
        input.plannedBottomMinutes = 25
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        if let index = input.plannerCylinders.firstIndex(where: { $0.role == .bottom }) {
            input.plannerCylinders[index].gas = input.bottomGas
        }
        input.plannerCylinders.append(
            PlannerCylinderEntry(
                role: .deco,
                gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6),
                switchDepthMeters: 21
            )
        )
        let plan = PlannerService.makePlan(input: input, mode: .technical)
        if plan.decoStops.isEmpty {
            throw XCTSkip("No deco stops for profile")
        }
        let context = PDFExportPlannerContext(
            input: input,
            plan: plan,
            mode: .technical,
            validation: PlannerModePolicy.validate(draft: input, mode: .technical),
            modIssues: [],
            safetyAcknowledged: true,
            unitPreference: .metric,
            pressureUnitPreference: .bar
        )
        let data = BriefingPDFBuilder.build(context: context, siteName: nil)
        let text = pdfText(data)
        XCTAssertTrue(text.contains(DIRIOSLocalizer.string("planner.runtime.title")))
        XCTAssertTrue(text.contains(PlannerAscentRowKind.decoStop.localizedTitle))
        XCTAssertFalse(text.contains("decoStop"))
    }

    private func plannerViewSourcePath() -> String {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("iOSApp/Views/PlannerView.swift")
            .path
    }

    private func technicalDecoPlan() throws -> DivePlanResult {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.plannedDepthMeters = 45
        input.plannedBottomMinutes = 25
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        if let index = input.plannerCylinders.firstIndex(where: { $0.role == .bottom }) {
            input.plannerCylinders[index].gas = input.bottomGas
        }
        input.plannerCylinders.append(
            PlannerCylinderEntry(
                role: .deco,
                gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6),
                switchDepthMeters: 21
            )
        )
        let plan = PlannerService.makePlan(input: input, mode: .technical)
        if plan.decoStops.isEmpty {
            throw XCTSkip("No deco stops for profile")
        }
        return plan
    }

    private func decoModePlanWithStops() throws -> DivePlanResult {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.plannedDepthMeters = 40
        input.plannedBottomMinutes = 25
        input.bottomGas = GasMix(name: "Air", mixKind: .air, oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        if let index = input.plannerCylinders.firstIndex(where: { $0.role == .bottom }) {
            input.plannerCylinders[index].gas = input.bottomGas
        }
        input.plannerCylinders.append(
            PlannerCylinderEntry(
                role: .deco,
                gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6),
                switchDepthMeters: 21
            )
        )
        let plan = PlannerService.makePlan(input: input, mode: .deco)
        if plan.decoStops.isEmpty {
            throw XCTSkip("No deco stops for profile")
        }
        return plan
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

    private func pdfText(_ data: Data) -> String {
        guard let document = PDFDocument(data: data) else { return "" }
        return (0..<document.pageCount)
            .compactMap { document.page(at: $0)?.string }
            .joined(separator: "\n")
    }
}
