import XCTest

final class ScheduleGasConsumptionServiceTests: XCTestCase {
    private let environment = PlannerEnvironment.seaLevelSaltWater

    func testRockBottomUsesExtraEmergencyMinutesDefaultThree() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 36)
        input.emergencyExtraMinutes = IOSAlgorithmConfiguration.defaultEmergencyExtraMinutes
        let settings = PlannerAscentSpeedSettings.default
        let ascent = ScheduleGasConsumptionService.automaticAscentMinutes(
            plannedDepthMeters: 36,
            ascentSpeedSettings: settings
        )
        XCTAssertEqual(ascent, settings.ascentMinutes(from: 36, to: 0), accuracy: 0.001)
        XCTAssertEqual(
            ScheduleGasConsumptionService.emergencyMinutesUsed(input: input),
            ascent + 3,
            accuracy: 0.001
        )
        let rockBottom = ScheduleGasConsumptionService.rockBottomLiters(input: input, environment: environment)
        let averageAscentATA = AmbientPressureModel.ambientPressureBar(
            depthMeters: 18,
            environment: environment
        )!
        let expected = input.emergencySacLitersPerMinute
            * ScheduleGasConsumptionService.normalizedTeamSize(input.teamSize)
            * averageAscentATA
            * (ascent + 3)
        XCTAssertEqual(rockBottom, expected, accuracy: 0.01)
    }

    func testRockBottomChangesWhenExtraEmergencyMinutesChanges() {
        var baseInput = BuhlmannTestSupport.gasPlanInput(depth: 45)
        baseInput.emergencyExtraMinutes = 3
        var longerInput = baseInput
        longerInput.emergencyExtraMinutes = 6
        let baseRock = ScheduleGasConsumptionService.rockBottomLiters(input: baseInput, environment: environment)
        let longerRock = ScheduleGasConsumptionService.rockBottomLiters(input: longerInput, environment: environment)
        let averageAscentATA = AmbientPressureModel.ambientPressureBar(
            depthMeters: baseInput.plannedDepthMeters / 2,
            environment: environment
        )!
        let deltaMinutes = 3.0
        let expectedDelta = baseInput.emergencySacLitersPerMinute
            * ScheduleGasConsumptionService.normalizedTeamSize(baseInput.teamSize)
            * averageAscentATA
            * deltaMinutes
        XCTAssertEqual(longerRock - baseRock, expectedDelta, accuracy: 0.01)
    }

    func testRockBottomUsesTeamSizeDefaultTwo() {
        let input = GasPlanInput()
        XCTAssertEqual(input.teamSize, 2)
        XCTAssertEqual(ScheduleGasConsumptionService.normalizedTeamSize(input.teamSize), 2)
        let rockBottom = ScheduleGasConsumptionService.rockBottomLiters(input: input, environment: environment)
        var singleDiverInput = input
        singleDiverInput.teamSize = 1
        let singleDiverRock = ScheduleGasConsumptionService.rockBottomLiters(
            input: singleDiverInput,
            environment: environment
        )
        XCTAssertEqual(rockBottom, singleDiverRock * 2, accuracy: 0.01)
    }

    func testRockBottomChangesWhenTeamSizeChanges() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40)
        input.emergencyExtraMinutes = 3
        input.teamSize = 1
        let one = ScheduleGasConsumptionService.rockBottomLiters(input: input, environment: environment)
        input.teamSize = 2
        let two = ScheduleGasConsumptionService.rockBottomLiters(input: input, environment: environment)
        input.teamSize = 3
        let three = ScheduleGasConsumptionService.rockBottomLiters(input: input, environment: environment)
        XCTAssertEqual(two, one * 2, accuracy: 0.01)
        XCTAssertEqual(three, one * 3, accuracy: 0.01)
    }

    func testAutomaticAscentTimeUsesPlannerAscentSpeedBands() {
        let settings = PlannerAscentSpeedSettings.default
        XCTAssertEqual(
            ScheduleGasConsumptionService.automaticAscentMinutes(plannedDepthMeters: 9, ascentSpeedSettings: settings),
            settings.ascentMinutes(from: 9, to: 0),
            accuracy: 0.001
        )
        XCTAssertEqual(
            ScheduleGasConsumptionService.automaticAscentMinutes(plannedDepthMeters: 36, ascentSpeedSettings: settings),
            settings.ascentMinutes(from: 36, to: 0),
            accuracy: 0.001
        )
        XCTAssertGreaterThan(
            ScheduleGasConsumptionService.automaticAscentMinutes(plannedDepthMeters: 81, ascentSpeedSettings: settings),
            ScheduleGasConsumptionService.automaticAscentMinutes(plannedDepthMeters: 36, ascentSpeedSettings: settings)
        )

        var input = BuhlmannTestSupport.gasPlanInput(depth: 36)
        input.emergencyExtraMinutes = 12
        let ascent = ScheduleGasConsumptionService.automaticAscentMinutes(
            plannedDepthMeters: 36,
            ascentSpeedSettings: settings
        )
        XCTAssertEqual(
            ScheduleGasConsumptionService.emergencyMinutesUsed(input: input, ascentSpeedSettings: settings),
            ascent + 12,
            accuracy: 0.001
        )
    }

    func testEmergencyExtraMinutesCannotBeNegative() {
        XCTAssertEqual(ScheduleGasConsumptionService.normalizedEmergencyExtraMinutes(-5), 0)
        XCTAssertEqual(
            ScheduleGasConsumptionService.normalizedEmergencyExtraMinutes(.nan),
            IOSAlgorithmConfiguration.defaultEmergencyExtraMinutes
        )
        XCTAssertEqual(
            ScheduleGasConsumptionService.normalizedEmergencyExtraMinutes(40),
            IOSAlgorithmConfiguration.maxEmergencyExtraMinutes
        )
    }

    func testEmergencyExtraMinutesDecodesDefaultWhenKeyMissing() throws {
        var input = GasPlanInput()
        input.emergencyExtraMinutes = 7
        let encoded = try JSONEncoder().encode(input)
        guard var object = try JSONSerialization.jsonObject(with: encoded) as? [String: Any] else {
            return XCTFail("Expected JSON object")
        }
        object.removeValue(forKey: "emergencyExtraMinutes")
        let legacy = try JSONSerialization.data(withJSONObject: object)
        let decoded = try JSONDecoder().decode(GasPlanInput.self, from: legacy)
        XCTAssertEqual(decoded.emergencyExtraMinutes, IOSAlgorithmConfiguration.defaultEmergencyExtraMinutes, accuracy: 0.001)
    }
}
