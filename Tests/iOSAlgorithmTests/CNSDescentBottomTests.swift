import XCTest

final class CNSDescentBottomTests: XCTestCase {
    private let environment = PlannerEnvironment.seaLevelSaltWater

    func testDescentCNSOnlyIncluded() throws {
        let descent = BuhlmannRuntimeSegment(
            kind: .descent,
            depthMeters: 30,
            minutes: 2,
            gas: BuhlmannTestSupport.nitrox32(),
            note: "descent"
        )
        let percent = try XCTUnwrap(OxygenExposureModel.cnsPercentDescentAndBottom(segments: [descent], environment: environment).get())
        XCTAssertGreaterThan(percent, 0)
        XCTAssertTrue(percent.isFinite)
    }

    func testBottomCNSOnlyIncluded() throws {
        let bottom = BuhlmannRuntimeSegment(
            kind: .bottom,
            depthMeters: 30,
            minutes: 20,
            gas: BuhlmannTestSupport.nitrox32(),
            note: "bottom"
        )
        let percent = try XCTUnwrap(OxygenExposureModel.cnsPercentDescentAndBottom(segments: [bottom], environment: environment).get())
        XCTAssertGreaterThan(percent, 0)
        XCTAssertTrue(percent.isFinite)
    }

    func testDescentAndBottomCombined() throws {
        let descent = BuhlmannRuntimeSegment(
            kind: .descent,
            depthMeters: 30,
            minutes: 2,
            gas: BuhlmannTestSupport.nitrox32(),
            note: "descent"
        )
        let bottom = BuhlmannRuntimeSegment(
            kind: .bottom,
            depthMeters: 30,
            minutes: 20,
            gas: BuhlmannTestSupport.nitrox32(),
            note: "bottom"
        )
        let descentOnly = try XCTUnwrap(OxygenExposureModel.cnsPercentDescentAndBottom(segments: [descent], environment: environment).get())
        let combined = try XCTUnwrap(OxygenExposureModel.cnsPercentDescentAndBottom(segments: [descent, bottom], environment: environment).get())
        XCTAssertGreaterThan(combined, descentOnly)
    }

    func testAscentExcludedFromDescentBottomMetric() throws {
        let descent = BuhlmannRuntimeSegment(
            kind: .descent,
            depthMeters: 30,
            minutes: 2,
            gas: BuhlmannTestSupport.nitrox32(),
            note: "descent"
        )
        let bottom = BuhlmannRuntimeSegment(
            kind: .bottom,
            depthMeters: 30,
            minutes: 20,
            gas: BuhlmannTestSupport.nitrox32(),
            note: "bottom"
        )
        let ascent = BuhlmannRuntimeSegment(
            kind: .ascent,
            depthMeters: 0,
            minutes: 3,
            gas: BuhlmannTestSupport.nitrox32(),
            note: "ascent"
        )
        let schedule = [descent, bottom, ascent]
        let fullProfile = try XCTUnwrap(OxygenExposureModel.from(segments: schedule, environment: environment, carryover: .zero).get())
        let descentBottom = try XCTUnwrap(OxygenExposureModel.cnsPercentDescentAndBottom(segments: schedule, environment: environment).get())
        XCTAssertGreaterThan(fullProfile.cnsSinglePercent, descentBottom)
        XCTAssertLessThan(descentBottom, fullProfile.cnsSinglePercent)
    }

    func testDecoStopExcludedFromDescentBottomMetric() throws {
        let bottom = BuhlmannRuntimeSegment(
            kind: .bottom,
            depthMeters: 40,
            minutes: 20,
            gas: BuhlmannTestSupport.trimix1845(switchDepth: 40),
            note: "bottom"
        )
        let deco = BuhlmannRuntimeSegment(
            kind: .stop,
            depthMeters: 6,
            minutes: 10,
            gas: BuhlmannTestSupport.ean50(),
            note: "deco"
        )
        let schedule = [bottom, deco]
        let fullProfile = try XCTUnwrap(OxygenExposureModel.from(segments: schedule, environment: environment, carryover: .zero).get())
        let bottomOnly = try XCTUnwrap(OxygenExposureModel.from(segments: [bottom], environment: environment, carryover: .zero).get())
        let descentBottom = try XCTUnwrap(OxygenExposureModel.cnsPercentDescentAndBottom(segments: schedule, environment: environment).get())
        XCTAssertEqual(descentBottom, bottomOnly.cnsSinglePercent, accuracy: 0.01)
        XCTAssertGreaterThan(fullProfile.cnsSinglePercent, descentBottom)
    }

    func testExactlyFifteenPercentIsAcceptable() throws {
        let gas = BuhlmannTestSupport.nitrox32()
        let depth = 30.0
        guard let ppO2 = inspiredPPO2(depthMeters: depth, gas: gas),
              let limit = NOAACNSLimitTable.singleExposureLimitMinutes(for: ppO2) else {
            return XCTFail("Expected PPO2 limit")
        }
        let target = CNSDescentBottomPlannerRule.warningThresholdPercent / CNSDescentBottomPlannerRule.maximumDailyCNSBudgetPercent
        let minutes = limit * target * 0.995
        let bottom = BuhlmannRuntimeSegment(kind: .bottom, depthMeters: depth, minutes: minutes, gas: gas, note: "bottom")
        let percent = try XCTUnwrap(OxygenExposureModel.cnsPercentDescentAndBottom(segments: [bottom], environment: environment).get())
        XCTAssertLessThanOrEqual(percent, CNSDescentBottomPlannerRule.warningThresholdPercent)
        XCTAssertFalse(CNSDescentBottomPlannerRule.exceedsPlannerThreshold(percent: percent))
    }

    func testPlannerThresholdRespectsCheckDisabled() throws {
        let gas = BuhlmannTestSupport.nitrox32()
        let depth = 30.0
        guard let ppO2 = inspiredPPO2(depthMeters: depth, gas: gas),
              let limit = NOAACNSLimitTable.singleExposureLimitMinutes(for: ppO2) else {
            return XCTFail("Expected PPO2 limit")
        }
        let bottom = BuhlmannRuntimeSegment(
            kind: .bottom,
            depthMeters: depth,
            minutes: limit * 0.25,
            gas: gas,
            note: "bottom"
        )
        let analysis = TechnicalGasAnalysis(
            gas: GasMix(name: "EAN32", role: .bottom, oxygen: 0.32, helium: 0, maxPPO2: 1.4),
            ppO2AtDepth: ppO2,
            densityAtDepth: 0,
            densityRating: .green,
            endMeters: depth,
            eadMeters: nil,
            consumptionLiters: 0,
            remainingLiters: 0,
            remainingBar: 0,
            rockBottomLiters: 0,
            minimumGasBar: 0,
            turnPressureBar: 0,
            cnsPercent: 30,
            cnsDescentBottomPercent: 25,
            cnsDescentBottomAvailable: true,
            otu: 0,
            cnsDailyPercent: 0,
            otuDaily24h: 0,
            otuWeekly: 0,
            airBreakRecoveryApplied: false,
            warnings: [],
            states: [],
            usesBottomPhaseConsumptionEstimate: false
        )
        XCTAssertTrue(analysis.cnsDescentBottomExceedsPlannerThreshold(checkEnabled: true))
        XCTAssertFalse(analysis.cnsDescentBottomExceedsPlannerThreshold(checkEnabled: false))
    }

    func testCustomThresholdTwentyPercent() {
        let analysis = TechnicalGasAnalysis(
            gas: GasMix(name: "EAN32", role: .bottom, oxygen: 0.32, helium: 0, maxPPO2: 1.4),
            ppO2AtDepth: 1.2,
            densityAtDepth: 0,
            densityRating: .green,
            endMeters: 30,
            eadMeters: nil,
            consumptionLiters: 0,
            remainingLiters: 0,
            remainingBar: 0,
            rockBottomLiters: 0,
            minimumGasBar: 0,
            turnPressureBar: 0,
            cnsPercent: 22,
            cnsDescentBottomPercent: 18,
            cnsDescentBottomAvailable: true,
            otu: 0,
            cnsDailyPercent: 0,
            otuDaily24h: 0,
            otuWeekly: 0,
            airBreakRecoveryApplied: false,
            warnings: [],
            states: [],
            usesBottomPhaseConsumptionEstimate: false
        )
        XCTAssertFalse(
            analysis.cnsDescentBottomExceedsPlannerThreshold(checkEnabled: true, thresholdPercent: 20)
        )
        XCTAssertTrue(
            analysis.cnsDescentBottomExceedsPlannerThreshold(checkEnabled: true, thresholdPercent: 15)
        )
    }

    func testThresholdSettingsClamp() {
        XCTAssertEqual(PlannerCNSDescentBottomCheckSettings.clamp(3), 5)
        XCTAssertEqual(PlannerCNSDescentBottomCheckSettings.clamp(20), 20)
        XCTAssertEqual(PlannerCNSDescentBottomCheckSettings.clamp(99), 50)
        XCTAssertEqual(PlannerCNSDescentBottomCheckSettings.defaultThresholdPercent, 15)
    }

    func testFifteenPointZeroOnePercentExceedsDefaultPlannerThreshold() throws {
        let gas = BuhlmannTestSupport.nitrox32()
        let depth = 30.0
        guard let ppO2 = inspiredPPO2(depthMeters: depth, gas: gas),
              let limit = NOAACNSLimitTable.singleExposureLimitMinutes(for: ppO2) else {
            return XCTFail("Expected PPO2 limit")
        }
        let minutes = limit * 0.1501
        let bottom = BuhlmannRuntimeSegment(kind: .bottom, depthMeters: depth, minutes: minutes, gas: gas, note: "bottom")
        let percent = try XCTUnwrap(OxygenExposureModel.cnsPercentDescentAndBottom(segments: [bottom], environment: environment).get())
        XCTAssertGreaterThan(percent, CNSDescentBottomPlannerRule.warningThresholdPercent)
        XCTAssertTrue(CNSDescentBottomPlannerRule.exceedsPlannerThreshold(percent: percent))
    }

    func testTrimixProfileDescentBottomMetric() throws {
        let input = BuhlmannTestSupport.gasPlanInput(depth: 50, bottomMinutes: 20)
        guard case .success(let env) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            return XCTFail("Expected environment")
        }
        let engine = BuhlmannEngine.plan(BuhlmannPlanner.makeRequest(input: input, environment: env))
        let analysis = GasPlanningService.analyze(input: input, enginePlan: engine)
        XCTAssertGreaterThan(analysis.cnsDescentBottomPercent, 0)
        XCTAssertTrue(analysis.cnsDescentBottomPercent.isFinite)
        XCTAssertLessThan(analysis.cnsDescentBottomPercent, analysis.cnsPercent + 0.01)
    }

    func testNitroxProfileDescentBottomMetric() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 30, bottomMinutes: 25)
        input.bottomGas = GasMix(name: "EAN32", role: .bottom, oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        guard case .success(let env) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            return XCTFail("Expected environment")
        }
        let engine = BuhlmannEngine.plan(BuhlmannPlanner.makeRequest(input: input, environment: env))
        let analysis = GasPlanningService.analyze(input: input, enginePlan: engine)
        XCTAssertGreaterThan(analysis.cnsDescentBottomPercent, 0)
        XCTAssertFalse(analysis.cnsDescentBottomPercent.isNaN)
        XCTAssertFalse(analysis.cnsDescentBottomPercent.isInfinite)
    }

    func testInvalidSegmentFailsClosedForDescentBottomMetric() {
        let invalid = BuhlmannRuntimeSegment(kind: .bottom, depthMeters: .nan, minutes: 10, gas: BuhlmannTestSupport.air(), note: "invalid")
        if case .success = OxygenExposureModel.cnsPercentDescentAndBottom(segments: [invalid], environment: environment) {
            XCTFail("Expected invalid exposure to fail closed")
        }
    }

    func testGasSwitchExcludedFromDescentBottomMetric() throws {
        let bottom = BuhlmannRuntimeSegment(
            kind: .bottom,
            depthMeters: 30,
            minutes: 15,
            gas: BuhlmannTestSupport.nitrox32(),
            note: "bottom"
        )
        let gasSwitch = BuhlmannRuntimeSegment(
            kind: .gasSwitch,
            depthMeters: 30,
            minutes: 2,
            gas: BuhlmannTestSupport.ean50(),
            note: "switch"
        )
        let schedule = [bottom, gasSwitch]
        let descentBottom = try XCTUnwrap(OxygenExposureModel.cnsPercentDescentAndBottom(segments: schedule, environment: environment).get())
        let bottomOnly = try XCTUnwrap(OxygenExposureModel.cnsPercentDescentAndBottom(segments: [bottom], environment: environment).get())
        XCTAssertEqual(descentBottom, bottomOnly, accuracy: 0.01)
    }

    private func inspiredPPO2(depthMeters: Double, gas: BuhlmannGas) -> Double? {
        guard let ambient = AmbientPressureModel.ambientPressureBar(depthMeters: depthMeters, environment: environment) else {
            return nil
        }
        return max(0, gas.oxygenFraction) * ambient
    }
}
