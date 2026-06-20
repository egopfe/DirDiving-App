import XCTest

/// Verifies single canonical engine path and environment consistency for planner outputs.
final class BuhlmannEngineCanonicalConsistencyTests: XCTestCase {
    func testPlannerServiceTTSTMatchesEnginePlan() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let plan = PlannerService.makePlan(input: input, mode: .technical)
        let engine = BuhlmannPlanner.enginePlan(input: PlannerModePolicy.activePlanInput(from: input, mode: .technical))
        XCTAssertEqual(plan.ttsMinutes, engine.ttsMinutes)
        XCTAssertEqual(plan.decoStops.count, BuhlmannPlanner.decoStops(from: engine).count)
    }

    func testPreviewNDLUsesInputEnvironmentNotSilentSeaLevel() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 30, bottomMinutes: 20)
        input.altitudeMeters = 1_000
        input.salinity = .fresh
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            XCTFail("Expected valid environment")
            return
        }
        let preview = BuhlmannPlanner.plan(
            depthMeters: input.buhlmannPlanningDepthMeters,
            bottomGas: input.bottomGas,
            environment: environment,
            gfHigh: input.gfHigh
        )
        let seaLevel = BuhlmannPlanner.plan(
            depthMeters: input.buhlmannPlanningDepthMeters,
            bottomGas: input.bottomGas,
            environment: .seaLevelSaltWater,
            gfHigh: input.gfHigh
        )
        XCTAssertNotEqual(preview.ndlMinutes, seaLevel.ndlMinutes)
    }

    func testFullPlanCNSIncludesDecoGasContribution() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "O2", role: .deco, oxygen: 1.0, helium: 0, maxPPO2: 1.6), switchDepthMeters: 6)
        ]
        let plan = PlannerService.makePlan(input: input, mode: .technical)
        if plan.decoStops.isEmpty {
            XCTFail("No deco plan")
            return
        }
        XCTAssertGreaterThanOrEqual(plan.gasAnalysis.cnsPercent, plan.gasAnalysis.cnsDescentBottomPercent)
    }

    func testBaseModeProjectionExcludesDecoCylinderFromEngineInput() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 30, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "EAN32", role: .bottom, oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 30),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let projected = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        XCTAssertEqual(projected.plannerCylinders.filter { $0.role == .deco }.count, 0)
        XCTAssertEqual(projected.plannerCylinders.filter { $0.role == .bottom }.count, 1)
    }

    func testAscentTableRowsDerivedFromSameEngineStops() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let plan = PlannerService.makePlan(input: input, mode: .technical)
        if plan.decoStops.isEmpty {
            XCTFail("No deco stops")
            return
        }
        let decoRows = plan.ascentTableRows.filter { $0.kind == .decoStop }
        XCTAssertEqual(decoRows.count, plan.decoStops.count)
        XCTAssertEqual(decoRows.map(\.depthMeters), plan.decoStops.map(\.depthMeters))
    }
}
