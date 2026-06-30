import XCTest

final class SnorkelingRouteProgressCalculatorTests: XCTestCase {
    private let route: [SnorkelingCoordinate] = [
        SnorkelingCoordinate(latitude: 44.400, longitude: 8.940),
        SnorkelingCoordinate(latitude: 44.401, longitude: 8.941),
        SnorkelingCoordinate(latitude: 44.402, longitude: 8.942),
    ]

    func testNilWhenInsufficientRouteOrMissingPosition() {
        XCTAssertNil(SnorkelingRouteProgressCalculator.progressPercent(current: route[0], routePoints: [route[0]]))
        XCTAssertNil(SnorkelingRouteProgressCalculator.progressPercent(current: nil, routePoints: route))
    }

    func testProgressAtStartIsNearZero() {
        let progress = SnorkelingRouteProgressCalculator.progressPercent(current: route[0], routePoints: route)
        XCTAssertNotNil(progress)
        XCTAssertEqual(progress ?? -1, 0, accuracy: 5)
    }

    func testProgressAtEndIsNearOneHundred() {
        let progress = SnorkelingRouteProgressCalculator.progressPercent(current: route[2], routePoints: route)
        XCTAssertNotNil(progress)
        XCTAssertEqual(progress ?? 0, 100, accuracy: 5)
    }

    func testProgressMidRouteIsBetweenEndpoints() {
        let midpoint = SnorkelingCoordinate(latitude: 44.401, longitude: 8.941)
        let progress = SnorkelingRouteProgressCalculator.progressPercent(current: midpoint, routePoints: route)
        XCTAssertNotNil(progress)
        XCTAssertGreaterThan(progress ?? 0, 20)
        XCTAssertLessThan(progress ?? 100, 80)
    }

    func testProgressClampedZeroToOneHundred() {
        let far = SnorkelingCoordinate(latitude: 44.500, longitude: 9.000)
        let progress = SnorkelingRouteProgressCalculator.progressPercent(current: far, routePoints: route)
        XCTAssertNotNil(progress)
        XCTAssertGreaterThanOrEqual(progress ?? -1, 0)
        XCTAssertLessThanOrEqual(progress ?? 200, 100)
    }
}
