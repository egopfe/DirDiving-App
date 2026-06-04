import XCTest

final class BottomGasSwitchDepthTests: XCTestCase {
    func testBottomGasSwitchDepthUsesCylinderSwitchWhenSet() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 60, bottomMinutes: 20)
        let travelGas = GasMix(name: "EAN32", role: .travel, oxygen: 0.32, helium: 0, maxPPO2: 1.6)
        let bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        let travel = PlannerCylinderEntry(role: .travel, gas: travelGas, switchDepthMeters: 30)
        let bottom = PlannerCylinderEntry(role: .bottom, gas: bottomGas, switchDepthMeters: 45)
        input.plannerCylinders = [travel, bottom]
        input.syncLegacyGasesFromPlannerCylinders()
        XCTAssertEqual(PlannerGasSchedule.bottomGasSwitchDepthMeters(from: input), 45, accuracy: 0.01)
    }

    func testBottomGasSwitchDepthDefaultsToMaxDepth() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 50, bottomMinutes: 15)
        let bottom = PlannerCylinderEntry(
            role: .bottom,
            gas: GasMix(name: "Air", role: .bottom, oxygen: 0.21, helium: 0, maxPPO2: 1.4),
            switchDepthMeters: 0
        )
        input.plannerCylinders = [bottom]
        XCTAssertEqual(PlannerGasSchedule.bottomGasSwitchDepthMeters(from: input), 50, accuracy: 0.01)
    }

    func testDescentSwitchPointsPlaceBottomGasAtSwitchDepth() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 60, bottomMinutes: 20)
        let travelGas = GasMix(name: "EAN32", role: .travel, oxygen: 0.32, helium: 0, maxPPO2: 1.6)
        let bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        let travel = PlannerCylinderEntry(role: .travel, gas: travelGas, switchDepthMeters: 30)
        let bottom = PlannerCylinderEntry(role: .bottom, gas: bottomGas, switchDepthMeters: 45)
        input.plannerCylinders = [travel, bottom]
        input.syncLegacyGasesFromPlannerCylinders()
        let points = PlannerGasSchedule.descentSwitchPoints(input: input)
        XCTAssertTrue(points.contains(where: { $0.role == .bottom && abs($0.depthMeters - 45) < 0.01 }))
    }

    func testHypoxicTravelPlanShowsLimitationWhenBottomSwitchAtMaxDepth() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 60, bottomMinutes: 20)
        let travelGas = GasMix(name: "EAN32", role: .travel, oxygen: 0.32, helium: 0, maxPPO2: 1.6)
        let travel = PlannerCylinderEntry(role: .travel, gas: travelGas, switchDepthMeters: 30)
        let bottomGas = GasMix(name: "TX 16/50", role: .bottom, oxygen: 0.16, helium: 0.50, maxPPO2: 1.4)
        let bottom = PlannerCylinderEntry(role: .bottom, gas: bottomGas, switchDepthMeters: 0)
        input.plannerCylinders = [travel, bottom]
        input.syncLegacyGasesFromPlannerCylinders()
        let warnings = PlannerGasSchedule.travelToBottomSwitchLimitationWarnings(input: input)
        XCTAssertFalse(warnings.isEmpty, "Expected hypoxic trimix with travel and max-depth bottom switch to surface limitation")
    }
}
