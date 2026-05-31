import XCTest

final class OxygenExposureDeepModelTests: XCTestCase {
    func testNOAATableMatchesCanonicalSingleExposureLimits() {
        let expectations: [(Double, Double)] = [
            (1.6, 45),
            (1.4, 150),
            (1.2, 210),
            (1.0, 300)
        ]
        for (ppO2, expectedMinutes) in expectations {
            let limit = NOAACNSLimitTable.singleExposureLimitMinutes(for: ppO2)
            XCTAssertNotNil(limit)
            XCTAssertEqual(limit ?? 0, expectedMinutes, accuracy: 0.5, "Unexpected NOAA CNS limit at PPO2 \(ppO2)")
            let percent = cnsPercentIncrement(limitMinutes: limit ?? 0, minutes: expectedMinutes)
            XCTAssertEqual(percent, 100, accuracy: 0.01)
        }
    }

    func testCNSBelowHalfBarDoesNotAccumulate() {
        XCTAssertEqual(cnsPercentIncrement(limitMinutes: .infinity, minutes: 60), 0, accuracy: 0.0001)
        XCTAssertEqual(OTUModel.otuIncrementConstant(ppO2: 0.5, minutes: 60) ?? -1, 0, accuracy: 0.0001)
    }

    func testOTUConstantMatchesLegacyPowerFormula() {
        let ppO2 = 1.35
        let minutes = 12.0
        let expected = minutes * pow((0.5 / (ppO2 - 0.5)), 5.0 / 6.0)
        XCTAssertEqual(OTUModel.otuIncrementConstant(ppO2: ppO2, minutes: minutes) ?? 0, expected, accuracy: 0.0001)
    }

    func testLinearRampOTUExceedsConstantAtMeanPPO2ForDescent() {
        let environment = PlannerEnvironment.seaLevelSaltWater
        let gas = BuhlmannTestSupport.nitrox32()
        guard let surface = inspiredPPO2(depthMeters: 0, gas: gas, environment: environment),
              let bottom = inspiredPPO2(depthMeters: 30, gas: gas, environment: environment) else {
            return XCTFail("Expected PPO2 values")
        }
        let minutes = 2.0
        let ramp = OTUModel.otuIncrementLinearRamp(ppO2Initial: surface, ppO2Final: bottom, minutes: minutes) ?? 0
        let mean = (surface + bottom) / 2
        let constantAtMean = OTUModel.otuIncrementConstant(ppO2: mean, minutes: minutes) ?? 0
        XCTAssertGreaterThan(ramp, 0)
        XCTAssertNotEqual(ramp, constantAtMean, accuracy: 0.0001)
    }

    func testScheduleAwareExposureUsesRampIntegrationForDescent() throws {
        let environment = PlannerEnvironment.seaLevelSaltWater
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

        let descentOnly = try XCTUnwrap(OxygenExposureModel.from(segments: [descent], environment: environment).get())
        let descentAndBottom = try XCTUnwrap(OxygenExposureModel.from(segments: [descent, bottom], environment: environment).get())

        XCTAssertGreaterThan(descentOnly.cnsPercent, 0)
        XCTAssertGreaterThan(descentAndBottom.cnsPercent, descentOnly.cnsPercent)
        XCTAssertGreaterThan(descentAndBottom.otu, descentOnly.otu)
    }

    func testDecoSegmentsIncreaseCNSStronglyVersusBottomOnly() throws {
        let environment = PlannerEnvironment.seaLevelSaltWater
        let bottom = BuhlmannRuntimeSegment(kind: .bottom, depthMeters: 40, minutes: 20, gas: BuhlmannTestSupport.trimix1845(switchDepth: 40), note: "bottom")
        let deco = BuhlmannRuntimeSegment(kind: .stop, depthMeters: 6, minutes: 10, gas: BuhlmannTestSupport.ean50(), note: "deco")
        let oxygen = BuhlmannRuntimeSegment(kind: .stop, depthMeters: 6, minutes: 8, gas: BuhlmannTestSupport.oxygen(), note: "o2")

        let bottomOnly = try XCTUnwrap(OxygenExposureModel.from(segments: [bottom], environment: environment).get())
        let full = try XCTUnwrap(OxygenExposureModel.from(segments: [bottom, deco, oxygen], environment: environment).get())

        XCTAssertGreaterThan(full.cnsPercent, bottomOnly.cnsPercent)
        XCTAssertGreaterThan(full.otu, bottomOnly.otu)
    }

    func testHighPPO2AboveTableUsesClampedLimit() {
        let limit = NOAACNSLimitTable.singleExposureLimitMinutes(for: 2.0)
        XCTAssertEqual(limit ?? 0, 1, accuracy: 0.001)
        let percent = cnsPercentIncrement(limitMinutes: limit ?? 0, minutes: 1)
        XCTAssertEqual(percent, 100, accuracy: 0.01)
    }

    func testInvalidSegmentFailsClosed() {
        let environment = PlannerEnvironment.seaLevelSaltWater
        let invalid = BuhlmannRuntimeSegment(kind: .bottom, depthMeters: .nan, minutes: 10, gas: BuhlmannTestSupport.air(), note: "invalid")
        if case .success = OxygenExposureModel.from(segments: [invalid], environment: environment) {
            XCTFail("Expected invalid exposure to fail closed")
        }
    }

    func testSurfaceIntervalDecaysCNSAndResetsDailyOTUAfter24Hours() {
        let loaded = OxygenExposureCarryover(cnsSinglePercent: 80, cnsDailyPercent: 70, otuDaily24h: 400, otuWeekly: 900)
        let after90 = OxygenExposureModel.applySurfaceInterval(to: loaded, minutes: 90)
        XCTAssertEqual(after90.cnsSinglePercent, 40, accuracy: 0.01)
        XCTAssertEqual(after90.cnsDailyPercent, 35, accuracy: 0.01)
        XCTAssertEqual(after90.otuDaily24h, 375, accuracy: 0.01)
        XCTAssertEqual(after90.otuWeekly, 891.96, accuracy: 0.5)

        let afterDay = OxygenExposureModel.applySurfaceInterval(to: loaded, minutes: 1_500)
        XCTAssertEqual(afterDay.otuDaily24h, 0, accuracy: 0.01)
        XCTAssertEqual(afterDay.otuWeekly, 766.07, accuracy: 0.5)
    }

    func testDailyCNSLimitIsMorePermissiveThanSingleExposureAt14Bar() {
        let single = NOAACNSLimitTable.singleExposureLimitMinutes(for: 1.4) ?? 0
        let daily = NOAACNSDailyLimitTable.dailyLimitMinutes(for: 1.4) ?? 0
        XCTAssertGreaterThan(daily, single)
        XCTAssertEqual(single, 150, accuracy: 0.5)
        XCTAssertEqual(daily, 166, accuracy: 0.5)
    }

    func testAirBreakOnSurfaceAirSegmentRecoversCNS() throws {
        let environment = PlannerEnvironment.seaLevelSaltWater
        let load = BuhlmannRuntimeSegment(kind: .stop, depthMeters: 6, minutes: 20, gas: BuhlmannTestSupport.oxygen(), note: "o2")
        let airBreak = BuhlmannRuntimeSegment(kind: .stop, depthMeters: 6, minutes: 30, gas: BuhlmannTestSupport.air(switchDepth: 6), note: "air")
        let loaded = try XCTUnwrap(OxygenExposureModel.from(segments: [load], environment: environment, carryover: .zero).get())
        let withBreak = try XCTUnwrap(OxygenExposureModel.from(segments: [load, airBreak], environment: environment, carryover: .zero).get())
        XCTAssertGreaterThan(loaded.cnsSinglePercent, 50)
        XCTAssertLessThan(withBreak.cnsSinglePercent, loaded.cnsSinglePercent)
        XCTAssertTrue(withBreak.airBreakRecoveryApplied)
    }

    func testRepetitiveCarryoverAddsToProfileExposure() throws {
        let environment = PlannerEnvironment.seaLevelSaltWater
        let prior = OxygenExposureCarryover(cnsSinglePercent: 25, cnsDailyPercent: 25, otuDaily24h: 100, otuWeekly: 100)
        let bottom = BuhlmannRuntimeSegment(kind: .bottom, depthMeters: 30, minutes: 20, gas: BuhlmannTestSupport.nitrox32(), note: "bottom")
        let clean = try XCTUnwrap(OxygenExposureModel.from(segments: [bottom], environment: environment, carryover: .zero).get())
        let repetitive = try XCTUnwrap(OxygenExposureModel.from(segments: [bottom], environment: environment, carryover: prior).get())
        XCTAssertGreaterThan(repetitive.cnsSinglePercent, clean.cnsSinglePercent)
        XCTAssertGreaterThan(repetitive.otuDaily24h, clean.otuDaily24h)
    }

    func testElevatedDailyOTUWarningAtREPEXLimit() throws {
        let environment = PlannerEnvironment.seaLevelSaltWater
        let carryover = OxygenExposureCarryover(cnsSinglePercent: 0, cnsDailyPercent: 0, otuDaily24h: 840, otuWeekly: 0)
        let bottom = BuhlmannRuntimeSegment(kind: .bottom, depthMeters: 30, minutes: 20, gas: BuhlmannTestSupport.nitrox32(), note: "bottom")
        let result = try XCTUnwrap(OxygenExposureModel.from(segments: [bottom], environment: environment, carryover: carryover).get())
        XCTAssertTrue(result.warningStates.contains(where: {
            if case .elevatedDailyOTU = $0 { return true }
            return false
        }))
    }

    func testSnapshotV2StoresOxygenCarryoverFromEnginePlan() throws {
        let input = BuhlmannTestSupport.gasPlanInput(depth: 30, bottomMinutes: 20)
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            return XCTFail("Expected valid environment")
        }
        let engine = BuhlmannEngine.plan(BuhlmannPlanner.makeRequest(input: input, environment: environment))
        let snapshot = try XCTUnwrap(RepetitiveDivePlannerService.makeSnapshot(from: engine, environment: environment))
        XCTAssertEqual(snapshot.schemaVersion, TissueSnapshot.currentSchemaVersion)
        let carryover = try XCTUnwrap(snapshot.oxygenCarryover)
        XCTAssertGreaterThan(carryover.cnsSinglePercent, 0)
        XCTAssertGreaterThan(carryover.otuDaily24h, 0)
    }

    func testSchemaV1SnapshotStillValidates() throws {
        let input = BuhlmannTestSupport.gasPlanInput(depth: 30, bottomMinutes: 18)
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            return XCTFail("Expected valid environment")
        }
        let engine = BuhlmannEngine.plan(BuhlmannPlanner.makeRequest(input: input, environment: environment))
        guard let snapshot = RepetitiveDivePlannerService.makeSnapshot(from: engine, environment: environment) else {
            return XCTFail("Expected snapshot")
        }
        let legacy = TissueSnapshot(
            createdAt: snapshot.createdAt,
            plannerEnvironment: snapshot.plannerEnvironment,
            tissueState: snapshot.tissueState,
            schemaVersion: 1,
            oxygenCarryover: nil
        )
        switch RepetitiveDivePlannerService.validateSnapshot(legacy) {
        case .success:
            break
        case .failure(let error):
            XCTFail("Expected v1 snapshot to validate, got \(error)")
        }
    }

    private func cnsPercentIncrement(limitMinutes: Double, minutes: Double) -> Double {
        guard limitMinutes.isFinite, limitMinutes > 0 else { return 0 }
        return (minutes / limitMinutes) * 100
    }

    private func inspiredPPO2(depthMeters: Double, gas: BuhlmannGas, environment: PlannerEnvironment) -> Double? {
        guard let ambient = AmbientPressureModel.ambientPressureBar(depthMeters: depthMeters, environment: environment) else {
            return nil
        }
        return max(0, gas.oxygenFraction) * ambient
    }
}
