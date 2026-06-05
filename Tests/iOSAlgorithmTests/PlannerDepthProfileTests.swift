import XCTest

final class PlannerDepthProfileTests: XCTestCase {
    func testDepthProfilePointsDeriveFromRealPlanSegments() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let plan = PlannerService.makePlan(input: input)
        XCTAssertFalse(plan.depthProfilePoints.isEmpty)
        XCTAssertFalse(plan.segments.isEmpty)
        let rebuilt = PlannerDepthProfileBuilder.points(from: plan.segments)
        XCTAssertEqual(plan.depthProfilePoints.count, rebuilt.count)
        XCTAssertEqual(plan.depthProfilePoints.map(\.depthMeters).max(), plan.segments.map(\.depthMeters).max())
    }

    func testDepthProfileEndsAtSurface() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 30, bottomMinutes: 15)
        let plan = PlannerService.makePlan(input: input)
        XCTAssertEqual(plan.depthProfilePoints.last?.depthMeters ?? -1, 0, accuracy: 0.01)
    }
}
