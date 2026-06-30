import XCTest

final class SnorkelingOffRouteDetectorTests: XCTestCase {
    private let route: [SnorkelingCoordinate] = [
        SnorkelingCoordinate(latitude: 44.400, longitude: 8.940),
        SnorkelingCoordinate(latitude: 44.401, longitude: 8.941),
        SnorkelingCoordinate(latitude: 44.402, longitude: 8.942),
    ]

    func testOnRoutePositionWithinThreshold() {
        let onRoute = SnorkelingCoordinate(latitude: 44.401, longitude: 8.941)
        XCTAssertFalse(
            SnorkelingOffRouteDetector.isOffRoute(
                current: onRoute,
                routePoints: route,
                thresholdMeters: SnorkelingOffRouteDetector.defaultThresholdMeters
            )
        )
    }

    func testFarPositionIsOffRoute() {
        let far = SnorkelingCoordinate(latitude: 44.410, longitude: 8.950)
        XCTAssertTrue(
            SnorkelingOffRouteDetector.isOffRoute(
                current: far,
                routePoints: route,
                thresholdMeters: SnorkelingOffRouteDetector.defaultThresholdMeters
            )
        )
    }

    func testDistanceFromRouteMetersNilWhenInsufficientData() {
        XCTAssertNil(SnorkelingOffRouteDetector.distanceFromRouteMeters(current: route[0], routePoints: [route[0]]))
        XCTAssertNil(SnorkelingOffRouteDetector.distanceFromRouteMeters(current: nil, routePoints: route))
    }

    func testCustomThresholdRespected() {
        let slightlyOff = SnorkelingCoordinate(latitude: 44.4015, longitude: 8.9415)
        let distance = SnorkelingOffRouteDetector.distanceFromRouteMeters(current: slightlyOff, routePoints: route)
        XCTAssertNotNil(distance)
        if let distance {
            XCTAssertFalse(SnorkelingOffRouteDetector.isOffRoute(current: slightlyOff, routePoints: route, thresholdMeters: distance + 10))
            XCTAssertTrue(SnorkelingOffRouteDetector.isOffRoute(current: slightlyOff, routePoints: route, thresholdMeters: max(1, distance - 1)))
        }
    }

    func testOffRouteFalseWhenNoPosition() {
        XCTAssertFalse(SnorkelingOffRouteDetector.isOffRoute(current: nil, routePoints: route))
    }
}
