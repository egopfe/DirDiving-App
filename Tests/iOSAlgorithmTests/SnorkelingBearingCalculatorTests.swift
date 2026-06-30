import XCTest

final class SnorkelingBearingCalculatorTests: XCTestCase {
    func testCardinalBearingsFromOrigin() {
        let origin = SnorkelingCoordinate(latitude: 45, longitude: 9)
        XCTAssertEqual(
            SnorkelingBearingCalculator.bearingDegrees(from: origin, to: SnorkelingCoordinate(latitude: 46, longitude: 9)),
            0,
            accuracy: 1
        )
        XCTAssertEqual(
            SnorkelingBearingCalculator.bearingDegrees(from: origin, to: SnorkelingCoordinate(latitude: 45, longitude: 10)),
            90,
            accuracy: 1
        )
        XCTAssertEqual(
            SnorkelingBearingCalculator.bearingDegrees(from: origin, to: SnorkelingCoordinate(latitude: 44, longitude: 9)),
            180,
            accuracy: 1
        )
        XCTAssertEqual(
            SnorkelingBearingCalculator.bearingDegrees(from: origin, to: SnorkelingCoordinate(latitude: 45, longitude: 8)),
            270,
            accuracy: 1
        )
    }

    func testBearingAcrossDateline() {
        let bearing = SnorkelingBearingCalculator.bearingDegrees(
            from: SnorkelingCoordinate(latitude: 0, longitude: 179.5),
            to: SnorkelingCoordinate(latitude: 0, longitude: -179.5)
        )
        XCTAssertEqual(bearing, 90, accuracy: 2)
    }

    func testIdenticalPointsUsesDomainSupportNilHandling() {
        let point = SnorkelingCoordinate(latitude: 44.4, longitude: 8.94)
        let domain = SnorkelingDomainSupport.bearingDegrees(
            from: (point.latitude, point.longitude),
            to: (point.latitude, point.longitude)
        )
        XCTAssertNil(domain)
    }

    func testInvalidCoordinateReturnsZeroFromCalculator() {
        let valid = SnorkelingCoordinate(latitude: 44.4, longitude: 8.94)
        let invalid = SnorkelingCoordinate(latitude: 200, longitude: 8.94)
        XCTAssertEqual(SnorkelingBearingCalculator.bearingDegrees(from: valid, to: invalid), 0)
    }

    func testBearingNormalizedZeroTo360() {
        let bearing = SnorkelingBearingCalculator.bearingDegrees(
            from: SnorkelingCoordinate(latitude: 44.4, longitude: 8.94),
            to: SnorkelingCoordinate(latitude: 44.401, longitude: 8.95)
        )
        XCTAssertGreaterThanOrEqual(bearing, 0)
        XCTAssertLessThan(bearing, 360)
    }
}
