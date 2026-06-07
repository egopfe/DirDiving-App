import XCTest

final class BuhlmannGradientFactorTests: XCTestCase {
    func testGradientFactorInterpolationUsesLowAtFirstStopAndHighAtSurface() {
        XCTAssertEqual(
            BuhlmannEngine.gfAtDepth(depthMeters: 21, firstStopDepthMeters: 21, gfLow: 30, gfHigh: 70),
            0.30,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            BuhlmannEngine.gfAtDepth(depthMeters: 0, firstStopDepthMeters: 21, gfLow: 30, gfHigh: 70),
            0.70,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            BuhlmannEngine.gfAtDepth(depthMeters: 10.5, firstStopDepthMeters: 21, gfLow: 30, gfHigh: 70),
            0.50,
            accuracy: 0.0001
        )
    }

    func testGF30_70IsNotMoreAggressiveThanGF50_80() {
        let request = BuhlmannTestSupport.request(
            depth: 50,
            bottomMinutes: 30,
            bottomGas: BuhlmannTestSupport.trimix1845(switchDepth: 50),
            decoGases: [BuhlmannTestSupport.ean50(), BuhlmannTestSupport.oxygen()]
        )
        var aggressive = request
        aggressive.gfLow = 50
        aggressive.gfHigh = 80

        let conservativePlan = BuhlmannEngine.plan(request)
        let aggressivePlan = BuhlmannEngine.plan(aggressive)

        XCTAssertFalse(conservativePlan.hasBlockingIssues)
        XCTAssertFalse(aggressivePlan.hasBlockingIssues)
        XCTAssertGreaterThanOrEqual(conservativePlan.ttsMinutes, aggressivePlan.ttsMinutes)
    }

    func testEqualGradientFactorsAreRejectedByPlannerValidator() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 30, bottomMinutes: 20)
        input.gfLow = 50
        input.gfHigh = 50
        let validation = PlannerInputValidator.validate(input, mode: .technical)
        XCTAssertFalse(validation.isValid)
        XCTAssertTrue(validation.states.contains(.invalidInput))
    }
}

