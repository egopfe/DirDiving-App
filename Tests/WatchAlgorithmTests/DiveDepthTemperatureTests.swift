import XCTest

final class DiveDepthTemperatureTests: XCTestCase {
    func testSanitizedTemperatureWithinPlausibleRange() {
        XCTAssertEqual(DiveAlgorithm.sanitizedTemperatureCelsius(18.5), 18.5)
    }

    func testSanitizedTemperatureRejectsOutOfRangeAndNonFinite() {
        XCTAssertNil(DiveAlgorithm.sanitizedTemperatureCelsius(41))
        XCTAssertNil(DiveAlgorithm.sanitizedTemperatureCelsius(-2.1))
        XCTAssertNil(DiveAlgorithm.sanitizedTemperatureCelsius(Double.nan))
    }

    func testDepthValidationPreservesSanitizedTemperature() {
        let now = Date(timeIntervalSince1970: 1_000)
        var validator = DepthSampleValidationState()
        let validated = validator.validate(
            rawDepthMeters: 5,
            timestamp: now,
            receivedAt: now,
            temperatureCelsius: 20
        )
        XCTAssertEqual(validated.sample?.temperatureCelsius, 20)
    }

    func testDepthValidationNilTemperatureWhenNotProvided() {
        let now = Date(timeIntervalSince1970: 1_000)
        var validator = DepthSampleValidationState()
        let validated = validator.validate(
            rawDepthMeters: 5,
            timestamp: now,
            receivedAt: now,
            temperatureCelsius: nil
        )
        XCTAssertNil(validated.sample?.temperatureCelsius)
    }
}
