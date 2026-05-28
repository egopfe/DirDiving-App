import XCTest

final class BuhlmannNumericalRobustnessTests: XCTestCase {
    func testInvalidProfileValuesFailClosed() {
        let nanDepth = BuhlmannTestSupport.request(depth: .nan, bottomMinutes: 20)
        let negativeDepth = BuhlmannTestSupport.request(depth: -1, bottomMinutes: 20)
        let unsupportedDepth = BuhlmannTestSupport.request(depth: IOSAlgorithmConfiguration.maxPlannerDepthMeters + 1, bottomMinutes: 20)
        let invalidGF = BuhlmannTestSupport.request(depth: 30, bottomMinutes: 20, gfLow: 80, gfHigh: 70)

        XCTAssertEqual(BuhlmannEngine.plan(nanDepth).modelState, .invalidInput)
        XCTAssertEqual(BuhlmannEngine.plan(negativeDepth).modelState, .invalidInput)
        XCTAssertEqual(BuhlmannEngine.plan(unsupportedDepth).modelState, .invalidInput)
        XCTAssertEqual(BuhlmannEngine.plan(invalidGF).modelState, .invalidInput)
    }

    func testZeroDepthFailsClosedAndMinimumDepthZeroTimeIsSafe() {
        let zeroDepth = BuhlmannTestSupport.request(depth: 0, bottomMinutes: 0)
        XCTAssertEqual(BuhlmannEngine.plan(zeroDepth).modelState, .invalidInput)

        let minimumDepth = BuhlmannTestSupport.request(
            depth: IOSAlgorithmConfiguration.minPlannerDepthMeters,
            bottomMinutes: 0,
            bottomGas: BuhlmannTestSupport.air(switchDepth: IOSAlgorithmConfiguration.minPlannerDepthMeters)
        )
        let result = BuhlmannEngine.plan(minimumDepth)

        XCTAssertEqual(result.modelState, .validReference)
        XCTAssertTrue(result.stops.isEmpty)
        XCTAssertGreaterThanOrEqual(result.ttsMinutes, 0)
    }

    func testInvalidBottomSegmentsFailClosed() {
        var negativeSegment = BuhlmannTestSupport.request(depth: 30, bottomMinutes: 0)
        negativeSegment.bottomSegments = [
            BuhlmannBottomSegment(depthMeters: 30, minutes: -1, gas: BuhlmannTestSupport.air(switchDepth: 30))
        ]

        var tooDeepSegment = BuhlmannTestSupport.request(depth: 30, bottomMinutes: 0)
        tooDeepSegment.bottomSegments = [
            BuhlmannBottomSegment(depthMeters: 40, minutes: 10, gas: BuhlmannTestSupport.air(switchDepth: 40))
        ]

        XCTAssertEqual(BuhlmannEngine.plan(negativeSegment).modelState, .invalidInput)
        XCTAssertEqual(BuhlmannEngine.plan(tooDeepSegment).modelState, .invalidInput)
    }

    func testAllValidEngineOutputsAreFiniteAndNonnegative() {
        let result = BuhlmannEngine.plan(
            BuhlmannTestSupport.request(
                depth: 50,
                bottomMinutes: 30,
                bottomGas: BuhlmannTestSupport.trimix1845(switchDepth: 50),
                decoGases: [BuhlmannTestSupport.ean50(), BuhlmannTestSupport.oxygen()]
            )
        )

        XCTAssertEqual(result.modelState, .validReference)
        XCTAssertTrue(result.segments.allSatisfy { $0.depthMeters.isFinite && $0.minutes.isFinite && $0.depthMeters >= 0 && $0.minutes >= 0 })
        XCTAssertTrue(result.stops.allSatisfy { $0.depthMeters.isFinite && $0.ppO2.isFinite && $0.maxPPO2.isFinite && $0.depthMeters >= 0 && $0.ppO2 >= 0 })
        XCTAssertFalse(result.stops.contains { $0.ppO2 > $0.maxPPO2 + 0.0001 })
    }

    func testCoefficientWeightingHandlesZeroInertGasWithoutDivisionByZero() {
        XCTAssertEqual(BuhlmannConstants.coefficientA(index: 0, pn2: 0, phe: 0), 0, accuracy: 0.0001)
        XCTAssertEqual(BuhlmannConstants.coefficientB(index: 0, pn2: 0, phe: 0), 0, accuracy: 0.0001)
        XCTAssertEqual(BuhlmannConstants.coefficientA(index: 0, pn2: 1, phe: 0), BuhlmannConstants.aN2[0], accuracy: 0.0001)
        XCTAssertEqual(BuhlmannConstants.coefficientB(index: 0, pn2: 0, phe: 1), BuhlmannConstants.bHe[0], accuracy: 0.0001)
    }

    func testPlannerInputRejectsZeroCylinderAndZeroSAC() {
        var zeroCylinder = BuhlmannTestSupport.gasPlanInput()
        zeroCylinder.plannerCylinders = []
        zeroCylinder.cylinder.volumeLiters = 0
        XCTAssertFalse(PlannerInputValidator.validate(zeroCylinder).isValid)

        var zeroSAC = BuhlmannTestSupport.gasPlanInput()
        zeroSAC.sacLitersPerMinute = 0
        XCTAssertFalse(PlannerInputValidator.validate(zeroSAC).isValid)
    }

    func testUnitConversionRoundTripsRemainStable() {
        XCTAssertEqual(IOSUnitConversions.meters(fromFeet: IOSUnitConversions.feet(fromMeters: 45)), 45, accuracy: 0.0001)
        XCTAssertEqual(IOSUnitConversions.bar(fromPSI: IOSUnitConversions.psi(fromBar: 232)), 232, accuracy: 0.0001)
    }
}
