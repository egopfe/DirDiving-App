import XCTest

final class OTUIntegrationRefinementTests: XCTestCase {
    func testLinearRampIntegrationExceedsMidpointConstantOnDescent() throws {
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .salt) else {
            return XCTFail("Expected environment")
        }
        let gas = BuhlmannTestSupport.nitrox32()
        let descent = BuhlmannRuntimeSegment(
            kind: .descent,
            depthMeters: 30,
            minutes: 2,
            gas: gas,
            note: "Descent"
        )
        let result = try XCTUnwrap(OxygenExposureModel.from(segments: [descent], environment: environment).get())
        let midPPO2 = (AmbientPressureModel.ambientPressureBar(depthMeters: 15, environment: environment) ?? 1) * 0.32
        let midpointOnly = OTUModel.otuIncrementConstant(ppO2: midPPO2, minutes: 2) ?? 0
        XCTAssertNotEqual(result.otu, midpointOnly, accuracy: 0.0001)
    }

    func testProgressiveOTURecoveryBeforeDailyReset() {
        let carryover = OxygenExposureCarryover(cnsSinglePercent: 0, cnsDailyPercent: 0, otuDaily24h: 400, otuWeekly: 900)
        let afterHalfDay = OxygenExposureModel.applySurfaceInterval(to: carryover, minutes: 720)
        XCTAssertLessThan(afterHalfDay.otuDaily24h, carryover.otuDaily24h)
        XCTAssertGreaterThan(afterHalfDay.otuDaily24h, 0)
        XCTAssertLessThan(afterHalfDay.otuWeekly, carryover.otuWeekly)
        XCTAssertGreaterThan(afterHalfDay.otuWeekly, 0)
    }

    func testOTUBudgetFullyResetsAfterWindow() {
        let carryover = OxygenExposureCarryover(cnsSinglePercent: 0, cnsDailyPercent: 0, otuDaily24h: 400, otuWeekly: 900)
        let afterDay = OxygenExposureModel.applySurfaceInterval(to: carryover, minutes: OTUREPEXLimits.dailyResetSurfaceIntervalMinutes)
        let afterWeek = OxygenExposureModel.applySurfaceInterval(to: carryover, minutes: OTUREPEXLimits.weeklyResetSurfaceIntervalMinutes)
        XCTAssertEqual(afterDay.otuDaily24h, 0, accuracy: 0.001)
        XCTAssertEqual(afterWeek.otuWeekly, 0, accuracy: 0.001)
    }
}
