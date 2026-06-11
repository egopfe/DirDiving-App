import XCTest
import PDFKit

final class PlannerPresentationTests: XCTestCase {
    func testPlannerViewUsesRuntimeTitleKey() throws {
        let source = try String(contentsOfFile: plannerViewSourcePath(), encoding: .utf8)
        XCTAssertTrue(source.contains("planner.runtime.title"))
        XCTAssertTrue(source.contains("planner.runtime.subtitle"))
        XCTAssertTrue(source.contains("row.kind.localizedTitle"))
        XCTAssertTrue(source.contains("PlannerAscentRowKind.decoStop.localizedTitle"))
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

    private func pdfText(_ data: Data) -> String {
        guard let document = PDFDocument(data: data) else { return "" }
        return (0..<document.pageCount)
            .compactMap { document.page(at: $0)?.string }
            .joined(separator: "\n")
    }
}
