import XCTest

/// Independent Lambertsen UPTD constant-depth OTU fixtures (not derived from production implementation).
final class OTUCanonicalFixtureTests: XCTestCase {
    private let otuExponent = 5.0 / 6.0
    private let fixtureTolerance = 0.05

    func testPPO2AtOrBelowHalfBarProducesZeroOTU() {
        XCTAssertEqual(OTUModel.otuIncrementConstant(ppO2: 0.5, minutes: 60) ?? -1, 0, accuracy: 0.0001)
        XCTAssertEqual(OTUModel.otuIncrementConstant(ppO2: 0.4, minutes: 60) ?? -1, 0, accuracy: 0.0001)
    }

    func testCanonicalOTUFixturesAtSixtyMinutes() {
        let fixtures: [(ppO2: Double, expected: Double)] = [
            (0.6, 15.6919258321),
            (1.0, 60.0),
            (1.3, 88.7669373263),
            (1.4, 97.9215632279),
            (1.6, 115.7453318456)
        ]
        for fixture in fixtures {
            let actual = OTUModel.otuIncrementConstant(ppO2: fixture.ppO2, minutes: 60) ?? -1
            XCTAssertEqual(
                actual,
                fixture.expected,
                accuracy: fixtureTolerance,
                "OTU mismatch at PPO2 \(fixture.ppO2)"
            )
        }
    }

    func testOTUMonotonicityAcrossCanonicalPPO2Levels() {
        let ppO2Levels = [0.6, 1.0, 1.3, 1.4, 1.6]
        var previous = 0.0
        for ppO2 in ppO2Levels {
            let value = OTUModel.otuIncrementConstant(ppO2: ppO2, minutes: 60) ?? -1
            XCTAssertGreaterThan(value, previous, "OTU should increase with PPO2 at \(ppO2)")
            previous = value
        }
    }

    func testZeroMinutesProducesZeroOTU() {
        XCTAssertEqual(OTUModel.otuIncrementConstant(ppO2: 1.4, minutes: 0) ?? -1, 0, accuracy: 0.0001)
    }

    func testNegativeMinutesFailsClosed() {
        XCTAssertNil(OTUModel.otuIncrementConstant(ppO2: 1.4, minutes: -5))
    }

    func testInvalidPPO2FailsClosed() {
        XCTAssertNil(OTUModel.otuIncrementConstant(ppO2: .nan, minutes: 10))
        XCTAssertNil(OTUModel.otuIncrementConstant(ppO2: .infinity, minutes: 10))
    }

    func testHighPPO2RemainsFinite() {
        let value = OTUModel.otuIncrementConstant(ppO2: 2.5, minutes: 30) ?? -1
        XCTAssertTrue(value.isFinite)
        XCTAssertGreaterThan(value, OTUModel.otuIncrementConstant(ppO2: 1.6, minutes: 30) ?? 0)
    }

    func testConstantDepthMatchesSegmentIntegrationForFlatProfile() throws {
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .salt) else {
            return XCTFail("Expected environment")
        }
        let gas = BuhlmannTestSupport.nitrox32()
        let bottom = BuhlmannRuntimeSegment(kind: .bottom, depthMeters: 30, minutes: 20, gas: gas, note: "bottom")
        let integrated = try XCTUnwrap(OxygenExposureModel.from(segments: [bottom], environment: environment).get())
        let ppO2 = (AmbientPressureModel.ambientPressureBar(depthMeters: 30, environment: environment) ?? 1) * 0.32
        let constantOnly = OTUModel.otuIncrementConstant(ppO2: ppO2, minutes: 20) ?? 0
        XCTAssertEqual(integrated.otu, constantOnly, accuracy: 0.5)
    }

    func testIncreasingPPO2RampBetweenConstantBounds() {
        let low = OTUModel.otuIncrementConstant(ppO2: 1.0, minutes: 10) ?? 0
        let high = OTUModel.otuIncrementConstant(ppO2: 1.4, minutes: 10) ?? 0
        let ramp = OTUModel.otuIncrementLinearRamp(ppO2Initial: 1.0, ppO2Final: 1.4, minutes: 10) ?? 0
        XCTAssertGreaterThan(ramp, low)
        XCTAssertLessThan(ramp, high + 0.001)
    }

    func testDecreasingPPO2RampStillNonNegative() {
        let ramp = OTUModel.otuIncrementLinearRamp(ppO2Initial: 1.4, ppO2Final: 1.0, minutes: 10) ?? -1
        XCTAssertGreaterThanOrEqual(ramp, 0)
    }

    func testMultiSegmentOTUEqualsSumOfSegments() throws {
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .salt) else {
            return XCTFail("Expected environment")
        }
        let gas = BuhlmannTestSupport.nitrox32()
        let first = BuhlmannRuntimeSegment(kind: .bottom, depthMeters: 30, minutes: 10, gas: gas, note: "a")
        let second = BuhlmannRuntimeSegment(kind: .bottom, depthMeters: 30, minutes: 10, gas: gas, note: "b")
        let combined = try XCTUnwrap(OxygenExposureModel.from(segments: [first, second], environment: environment).get())
        let single = try XCTUnwrap(OxygenExposureModel.from(segments: [first], environment: environment).get())
        XCTAssertEqual(combined.otu, single.otu * 2, accuracy: 0.5)
    }

    private func independentOTU(ppO2: Double, minutes: Double) -> Double {
        guard ppO2 > 0.5, minutes >= 0 else { return 0 }
        return minutes * pow((ppO2 - 0.5) / 0.5, otuExponent)
    }
}
