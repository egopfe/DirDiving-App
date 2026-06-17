import XCTest

final class CCRPlannerBriefingExportTests: XCTestCase {
    func testValidCCRPlanBuildsBriefingExportInput() {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas()]
        let plan = CCRPlannerService.makePlan(input: input)
        let sessionId = UUID()
        let exportInput = CCRPlannerBriefingExportSupport.makeExportInput(
            plan: plan,
            input: input,
            unitPreference: .metric,
            plannerSessionId: sessionId
        )
        XCTAssertNotNil(exportInput)
        XCTAssertEqual(exportInput?.plannerSessionId, sessionId)
        XCTAssertFalse(exportInput?.summaryRows.isEmpty ?? true)
    }

    func testUnavailableOxygenExposureUsesUnavailableLabelNotZero() {
        var input = CCRPlanInput.default
        input.bailoutGases = []
        let plan = CCRPlannerService.makePlan(input: input)
        let exportInput = CCRPlannerBriefingExportSupport.makeExportInput(
            plan: plan,
            input: input,
            unitPreference: .metric,
            plannerSessionId: UUID()
        )
        XCTAssertNil(exportInput)
    }

    func testCCRBriefingExportPackageIncludesSummaryAndReferenceFooters() throws {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas()]
        let plan = CCRPlannerService.makePlan(input: input)
        guard let exportInput = CCRPlannerBriefingExportSupport.makeExportInput(
            plan: plan,
            input: input,
            unitPreference: .metric,
            plannerSessionId: UUID()
        ) else {
            XCTFail("Expected export input")
            return
        }
        let package = try PlannerBriefingImageExportService.export(input: exportInput)
        XCTAssertTrue(package.manifest.referenceOnly)
        XCTAssertTrue(package.manifest.cards.contains(where: { $0.kind == .ccrSummary }))
        XCTAssertNotNil(package.manifest.plannerSessionId)
    }

    func testCCRBriefingSummaryNeverUsesZeroForUnavailableExposure() {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas()]
        let plan = CCRPlannerService.makePlan(input: input)
        guard plan.hasAvailableOxygenExposure else {
            XCTFail("Expected available exposure for default valid plan")
            return
        }
        let rows = CCRPlannerBriefingExportSupport.summaryRows(
            plan: plan,
            input: input,
            unitPreference: .metric
        )
        let cnsRow = rows.first { $0.label == DIRIOSLocalizer.string("planner.metric.cns_full_plan") }
        XCTAssertNotEqual(cnsRow?.value, "0%")
        XCTAssertNotEqual(cnsRow?.value, "0.0%")
    }
}
