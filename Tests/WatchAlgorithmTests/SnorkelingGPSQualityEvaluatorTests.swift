import XCTest

final class SnorkelingGPSQualityEvaluatorTests: XCTestCase {
    func testGoodBandRequiresTightAccuracyAndFreshFix() {
        let band = SnorkelingGPSQualityEvaluator.evaluate(
            horizontalAccuracyMeters: 10,
            fixAgeSeconds: 5,
            hasCoordinate: true
        )
        XCTAssertEqual(band, .good)
    }

    func testMediumBandAllowsModerateAccuracyAndAge() {
        let band = SnorkelingGPSQualityEvaluator.evaluate(
            horizontalAccuracyMeters: 30,
            fixAgeSeconds: 15,
            hasCoordinate: true
        )
        XCTAssertEqual(band, .medium)
    }

    func testPoorBandWhenAccuracyOrAgeExceedsMediumThresholds() {
        let band = SnorkelingGPSQualityEvaluator.evaluate(
            horizontalAccuracyMeters: 40,
            fixAgeSeconds: 5,
            hasCoordinate: true
        )
        XCTAssertEqual(band, .poor)
    }

    func testLostWhenNoCoordinate() {
        XCTAssertEqual(
            SnorkelingGPSQualityEvaluator.evaluate(
                horizontalAccuracyMeters: 5,
                fixAgeSeconds: 1,
                hasCoordinate: false
            ),
            .lost
        )
    }

    func testLostWhenFixAgeExceedsLostThreshold() {
        let band = SnorkelingGPSQualityEvaluator.evaluate(
            horizontalAccuracyMeters: 5,
            fixAgeSeconds: 90,
            hasCoordinate: true
        )
        XCTAssertEqual(band, .lost)
    }

    func testLostWhenAccuracyMissing() {
        XCTAssertEqual(
            SnorkelingGPSQualityEvaluator.evaluate(
                horizontalAccuracyMeters: nil,
                fixAgeSeconds: 1,
                hasCoordinate: true
            ),
            .lost
        )
    }

    func testCustomThresholdsHonored() {
        let thresholds = SnorkelingGPSQualityThresholds(
            goodAccuracyMeters: 5,
            mediumAccuracyMeters: 10,
            goodFixAgeSeconds: 3,
            mediumFixAgeSeconds: 6,
            lostFixAgeSeconds: 20
        )
        let band = SnorkelingGPSQualityEvaluator.evaluate(
            horizontalAccuracyMeters: 8,
            fixAgeSeconds: 4,
            hasCoordinate: true,
            thresholds: thresholds
        )
        XCTAssertEqual(band, .medium)
    }
}
