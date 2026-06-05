import XCTest

final class PlannerCurveChartTests: XCTestCase {
    func testCurveChartDataIsNotNDLOnlyWhenTissueHistoryExists() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let plan = PlannerService.makePlan(input: input)
        XCTAssertFalse(plan.tissueHistory.isEmpty)
        XCTAssertFalse(plan.tissueHistory.groupedPoints.isEmpty)
        XCTAssertEqual(plan.tissueHistory.aggregationMethod, "max_load_percent_per_group")
    }

    func testNDLPreviewRemainsSeparateFromTissueHistory() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 30, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "EAN32", role: .bottom, oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        let plan = PlannerService.makePlan(input: input)
        let ndlPreview = BuhlmannPlanner.plan(depthMeters: 30, bottomGas: input.bottomGas)
        XCTAssertFalse(ndlPreview.curve.isEmpty)
        XCTAssertFalse(plan.tissueHistory.isEmpty)
        XCTAssertNotEqual(
            ndlPreview.curve.first?.depthMeters,
            plan.tissueHistory.groupedPoints.first?.elapsedMinutes
        )
    }
}
