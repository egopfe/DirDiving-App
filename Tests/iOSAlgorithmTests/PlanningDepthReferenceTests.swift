import XCTest

final class PlanningDepthReferenceTests: XCTestCase {
    func testMakeRequestUsesAverageDepthWhenReferenceIsAverage() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 50, bottomMinutes: 20)
        input.planningDepthReference = .averageDepth
        input.plannedAverageDepthMeters = 28
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            return XCTFail("Expected valid environment")
        }

        let request = BuhlmannPlanner.makeRequest(input: input, environment: environment)
        XCTAssertEqual(request.maxDepthMeters, 28, accuracy: 0.001)
        XCTAssertEqual(request.bottomGas.switchDepthMeters, 28, accuracy: 0.001)
    }

    func testMakeRequestUsesMaximumDepthWhenReferenceIsMaximum() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 50, bottomMinutes: 20)
        input.planningDepthReference = .maximumDepth
        input.plannedAverageDepthMeters = 28
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            return XCTFail("Expected valid environment")
        }

        let request = BuhlmannPlanner.makeRequest(input: input, environment: environment)
        XCTAssertEqual(request.maxDepthMeters, 50, accuracy: 0.001)
        XCTAssertEqual(request.bottomGas.switchDepthMeters, 50, accuracy: 0.001)
    }

    func testMODBottomValidationUsesEffectivePlanningDepth() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 50)
        input.planningDepthReference = .averageDepth
        input.plannedAverageDepthMeters = 30
        input.bottomGas = GasMix(name: "EAN32", role: .bottom, oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, startPressure: 200, reservePressure: 50)
        ]
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            return XCTFail("Expected valid environment")
        }

        let issuesAtAverage = PlannerMODValidator.validatePlannerCylinders(input: input, environment: environment)
        XCTAssertTrue(issuesAtAverage.isEmpty)

        input.planningDepthReference = .maximumDepth
        let issuesAtMax = PlannerMODValidator.validatePlannerCylinders(input: input, environment: environment)
        XCTAssertFalse(issuesAtMax.isEmpty)
    }

    func testBuhlmannPreviewUsesSamePlanningDepthAsEngine() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 45)
        input.planningDepthReference = .averageDepth
        input.plannedAverageDepthMeters = 25
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            return XCTFail("Expected valid environment")
        }

        let preview = BuhlmannPlanner.plan(
            depthMeters: input.buhlmannPlanningDepthMeters,
            bottomGas: input.buhlmannBackGas,
            environment: environment,
            gfHigh: input.gfHigh
        )
        let request = BuhlmannPlanner.makeRequest(input: input, environment: environment)
        XCTAssertEqual(input.buhlmannPlanningDepthMeters, request.maxDepthMeters, accuracy: 0.001)
        XCTAssertEqual(preview.depthMeters, request.maxDepthMeters, accuracy: 0.001)
    }
}
