import XCTest

/// Unit conversion round-trip and canonical storage guards.
final class WatchUnitConversionRoundTripTests: XCTestCase {
    func testDepthMetersFeetRoundTrip() {
        let meters = 25.4
        let feet = DIRUnitConversions.metersToFeet(meters)
        let back = DIRUnitConversions.feetToMeters(feet)
        XCTAssertEqual(back, meters, accuracy: 0.001)
    }

    func testTemperatureCelsiusFahrenheitRoundTrip() {
        let celsius = 18.5
        let fahrenheit = DIRUnitConversions.celsiusToFahrenheit(celsius)
        let back = DIRUnitConversions.fahrenheitToCelsius(fahrenheit)
        XCTAssertEqual(back, celsius, accuracy: 0.01)
    }

    func testPressureBarPSIRoundTrip() {
        let bar = 200.0
        let psi = DIRUnitConversions.barToPSI(bar)
        let back = DIRUnitConversions.psiToBar(psi)
        XCTAssertEqual(back, bar, accuracy: 0.01)
    }

    func testRepeatedUnitSwitchDoesNotDriftCanonicalMeters() {
        var canonical = 30.0
        for _ in 0..<50 {
            let feet = DIRUnitConversions.metersToFeet(canonical)
            canonical = DIRUnitConversions.feetToMeters(feet)
        }
        XCTAssertEqual(canonical, 30.0, accuracy: 0.001)
    }
}
