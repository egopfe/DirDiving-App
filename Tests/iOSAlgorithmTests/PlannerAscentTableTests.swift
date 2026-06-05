import XCTest

final class PlannerAscentTableTests: XCTestCase {
    private func environment() -> PlannerEnvironment {
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .salt) else {
            fatalError("Expected environment")
        }
        return environment
    }

    func testAscentTableIncludesBottomRow() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let plan = PlannerService.makePlan(input: input)
        XCTAssertTrue(plan.ascentTableRows.contains(where: { $0.kind == .bottom }))
    }

    func testAscentTableIncludesDecompressionStopRows() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let plan = PlannerService.makePlan(input: input)
        if plan.decoStops.isEmpty {
            throw XCTSkip("No deco stops for profile")
        }
        let stopRows = plan.ascentTableRows.filter { $0.kind == .decoStop }
        XCTAssertEqual(stopRows.count, plan.decoStops.count)
    }

    func testSurfaceRowRemains() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 18, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "EAN32", role: .bottom, oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        let plan = PlannerService.makePlan(input: input)
        XCTAssertTrue(plan.ascentTableRows.contains(where: { $0.kind == .surface }))
    }

    func testTTSLabelMapsToEngineTTS() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let engine = BuhlmannPlanner.enginePlan(input: input)
        let plan = PlannerService.makePlan(input: input)
        XCTAssertEqual(plan.ttsMinutes, engine.ttsMinutes)
        XCTAssertGreaterThanOrEqual(plan.totalRuntimeMinutes, plan.ttsMinutes)
    }

    func testTrimixDisplayLabelUsesReadableName() {
        let gas = BuhlmannTestSupport.trimix1845()
        XCTAssertEqual(gas.displayLabel, "TRIMIX 18/45")
        let engine = BuhlmannEngine.plan(
            BuhlmannPlanRequest(
                maxDepthMeters: 40,
                bottomMinutes: 20,
                bottomGas: gas,
                travelGases: [],
                decoGases: [BuhlmannTestSupport.ean50()],
                gfLow: 30,
                gfHigh: 85
            )
        )
        let rows = PlannerAscentTableBuilder.rows(from: engine, decoStops: BuhlmannPlanner.decoStops(from: engine), environment: environment())
        XCTAssertTrue(rows.contains(where: { $0.gas.contains("TRIMIX") }))
    }
}
