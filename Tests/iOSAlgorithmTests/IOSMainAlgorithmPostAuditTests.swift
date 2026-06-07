import XCTest

final class IOSMainAlgorithmPostAuditTests: XCTestCase {
    private func technicalInput(depth: Double = 45, bottom: Double = 25) -> GasPlanInput {
        var input = BuhlmannTestSupport.gasPlanInput()
        input.plannedDepthMeters = depth
        input.plannedBottomMinutes = bottom
        return input
    }

    func testRatioDecoMODViolationMarksIncompatibleAndDoesNotAlterBuhlmann() {
        var input = technicalInput(depth: 45, bottom: 25)
        if let index = input.plannerCylinders.firstIndex(where: { $0.role == .deco }) {
            input.plannerCylinders[index].gas = GasMix(
                name: "EAN50",
                role: .deco,
                oxygen: 0.50,
                helium: 0,
                maxPPO2: 1.4
            )
            input.plannerCylinders[index].switchDepthMeters = 21
        }
        guard let schedule = RatioDecoPlanner.makeSchedule(
            input: input,
            mode: .technical,
            preset: .preset1to1,
            environment: .seaLevelSaltWater,
            descentMinutes: 5
        ) else {
            return XCTFail("Expected schedule")
        }
        XCTAssertTrue(schedule.warnings.contains(where: {
            if case .modViolation = $0 { return true }
            return false
        }))
        let request = BuhlmannPlanner.makeRequest(input: input, environment: .seaLevelSaltWater)
        let enginePlan = BuhlmannEngine.plan(request)
        let validation = RatioDecoValidator.validate(
            schedule: schedule,
            input: input,
            mode: .technical,
            enginePlan: enginePlan,
            request: request,
            environment: .seaLevelSaltWater
        )
        XCTAssertFalse(validation.isBuhlmannCompatible)
        XCTAssertTrue(validation.warnings.contains(where: {
            if case .modExceeded = $0 { return true }
            return false
        }))
        let buhlmannOnly = PlannerService.makePlan(
            input: input,
            mode: .technical,
            repetitivePlanningEnabled: false,
            repetitiveSnapshot: nil,
            surfaceIntervalMinutes: 0,
            decompressionMethod: .buhlmann
        )
        let withRatio = PlannerService.makePlan(
            input: input,
            mode: .technical,
            repetitivePlanningEnabled: false,
            repetitiveSnapshot: nil,
            surfaceIntervalMinutes: 0,
            decompressionMethod: .ratioDeco,
            ratioDecoPreset: .preset1to1
        )
        XCTAssertEqual(buhlmannOnly.ttsMinutes, withRatio.ttsMinutes)
        XCTAssertEqual(buhlmannOnly.decoStops.count, withRatio.decoStops.count)
    }

    func testLogbookTissuePresentationUsesSimulatedSource() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let end = start.addingTimeInterval(45 * 60)
        let samples = ManualDiveSampleBuilder.makeSamples(
            startDate: start,
            endDate: end,
            maxDepthMeters: 30,
            avgDepthMeters: 18
        )
        let session = DiveSession(
            startDate: start,
            endDate: end,
            durationSeconds: end.timeIntervalSince(start),
            maxDepthMeters: 30,
            avgDepthMeters: 18,
            avgWaterTemperatureCelsius: nil,
            ttv: 0,
            entryGPS: nil,
            exitGPS: nil,
            samples: samples,
            siteName: "Test",
            gasLabel: .oc,
            isManual: true
        )
        let presentation = TissueAnalyticsService.presentationForSession(session)
        XCTAssertNotNil(presentation)
        XCTAssertEqual(presentation?.trace.source, .simulated)
    }
}
