import XCTest
import PDFKit

final class BriefingPDFBuilderTests: XCTestCase {
    private func validPlannerContext(mode: PlannerMode = .deco) -> PDFExportPlannerContext {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.plannedDepthMeters = 30
        input.plannedBottomMinutes = 20
        input.plannedAverageDepthMeters = 24
        input.bottomGas = GasMix(name: "Air", mixKind: .air, oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        if let index = input.plannerCylinders.firstIndex(where: { $0.role == .bottom }) {
            input.plannerCylinders[index].gas = input.bottomGas
        }
        let active = PlannerModePolicy.activePlanInput(from: input, mode: mode)
        let plan = PlannerService.makePlan(input: active, mode: mode)
        return PDFExportPlannerContext(
            input: input,
            plan: plan,
            mode: mode,
            validation: PlannerModePolicy.validate(draft: input, mode: mode),
            modIssues: [],
            safetyAcknowledged: true,
            unitPreference: .metric
        )
    }

    private func pdfText(_ data: Data) -> String {
        guard let document = PDFDocument(data: data) else { return "" }
        return (0..<document.pageCount)
            .compactMap { document.page(at: $0)?.string }
            .joined(separator: "\n")
    }

    func testBriefingPDFIncludesProfileGasAscentAndDisclaimer() {
        let context = validPlannerContext()
        let data = BriefingPDFBuilder.build(context: context, siteName: "Blue Hole")
        XCTAssertFalse(data.isEmpty)
        XCTAssertTrue(String(data: data.prefix(5), encoding: .ascii)?.hasPrefix("%PDF") == true)
        let text = pdfText(data)
        XCTAssertTrue(text.contains(String(localized: "pdf.export.section.briefing")))
        XCTAssertTrue(text.contains(String(localized: "pdf.export.briefing.overview")))
        XCTAssertTrue(text.contains(String(localized: "pdf.export.briefing.gas_plan")))
        XCTAssertTrue(text.contains(String(localized: "pdf.export.briefing.ascent")))
        XCTAssertTrue(text.contains(String(localized: "pdf.export.briefing.gas_management")))
        XCTAssertTrue(text.contains(String(localized: "pdf.export.disclaimer")))
        XCTAssertTrue(text.contains("Blue Hole"))
        XCTAssertTrue(text.contains("TTS"))
    }

    func testBriefingPDFIncludesRatioDecoDisclaimerWhenSelected() {
        var input = BuhlmannTestSupport.gasPlanInput()
        input.plannedDepthMeters = 45
        input.plannedBottomMinutes = 25
        let buhlmannPlan = PlannerService.makePlan(
            input: input,
            mode: .technical,
            repetitivePlanningEnabled: false,
            repetitiveSnapshot: nil,
            surfaceIntervalMinutes: 0,
            decompressionMethod: .buhlmann
        )
        let ratioPlan = PlannerService.makePlan(
            input: input,
            mode: .technical,
            repetitivePlanningEnabled: false,
            repetitiveSnapshot: nil,
            surfaceIntervalMinutes: 0,
            decompressionMethod: .ratioDeco,
            ratioDecoPreset: .preset1to1
        )
        XCTAssertNotNil(ratioPlan.ratioDeco)
        XCTAssertEqual(ratioPlan.ratioDeco?.method, .ratioDeco)
        let buhlmannContext = PDFExportPlannerContext(
            input: input,
            plan: buhlmannPlan,
            mode: .technical,
            validation: PlannerModePolicy.validate(draft: input, mode: .technical),
            modIssues: [],
            safetyAcknowledged: true,
            unitPreference: .metric
        )
        let ratioContext = PDFExportPlannerContext(
            input: input,
            plan: ratioPlan,
            mode: .technical,
            validation: PlannerModePolicy.validate(draft: input, mode: .technical),
            modIssues: [],
            safetyAcknowledged: true,
            unitPreference: .metric
        )
        let buhlmannData = BriefingPDFBuilder.build(context: buhlmannContext, siteName: nil)
        let ratioData = BriefingPDFBuilder.build(context: ratioContext, siteName: nil)
        XCTAssertNil(buhlmannPlan.ratioDeco)
        XCTAssertGreaterThan(ratioData.count, buhlmannData.count)
        XCTAssertFalse(ratioPlan.ratioDeco?.schedule.stops.isEmpty ?? true)
        let text = pdfText(ratioData)
        XCTAssertFalse(text.isEmpty)
        XCTAssertTrue(text.contains("TTS"))
    }

    func testBriefingPDFOmitsRatioDecoSectionForBuhlmannOnlyPlan() {
        let context = validPlannerContext(mode: .technical)
        let text = pdfText(BriefingPDFBuilder.build(context: context, siteName: nil))
        XCTAssertFalse(text.contains(String(localized: "pdf.export.ratio_deco.section")))
    }
}
