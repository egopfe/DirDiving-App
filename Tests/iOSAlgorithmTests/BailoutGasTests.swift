import XCTest

final class BailoutGasTests: XCTestCase {
    func testBailoutExcludedFromEngineRequest() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        let bailoutGas = GasMix(name: "EAN50", role: .bailout, oxygen: 0.50, helium: 0, maxPPO2: 1.6)
        input.plannerCylinders.append(
            PlannerCylinderEntry(
                role: .bailout,
                tankSize: .liters12,
                gas: bailoutGas,
                switchDepthMeters: 21,
                startPressure: 200,
                reservePressure: 50
            )
        )
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .salt) else {
            return XCTFail("Expected environment")
        }
        let request = BuhlmannPlanner.makeRequest(input: input, environment: environment)
        XCTAssertTrue(request.decoGases.allSatisfy { $0.role != .bailout })
        XCTAssertTrue(request.travelGases.allSatisfy { $0.role != .bailout })
        XCTAssertNotEqual(request.bottomGas.role, .bailout)
    }

    func testBailoutAvailabilityWarningsSurfaceInSchedule() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.plannerCylinders.append(
            PlannerCylinderEntry(
                role: .bailout,
                tankSize: .liters12,
                gas: GasMix(name: "EAN50", role: .bailout, oxygen: 0.50, helium: 0, maxPPO2: 1.6),
                switchDepthMeters: 21,
                startPressure: 200,
                reservePressure: 50
            )
        )
        let warnings = PlannerGasSchedule.bailoutAvailabilityWarnings(input: input)
        let schedule = PlannerGasSchedule.roleScheduleLines(input: input)
        XCTAssertEqual(warnings.count, 1)
        XCTAssertFalse(warnings[0].isEmpty)
        XCTAssertTrue(schedule.contains(where: { $0.contains("50") || $0.lowercased().contains("bailout") || $0.lowercased().contains("ean") }))
    }
}
