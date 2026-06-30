import XCTest

final class SnorkelingDistanceCalculatorTests: XCTestCase {
    func testZeroOrSinglePointReturnsZero() {
        XCTAssertEqual(SnorkelingDistanceCalculator.distanceMeters(points: []), 0)
        XCTAssertEqual(
            SnorkelingDistanceCalculator.distanceMeters(points: [SnorkelingCoordinate(latitude: 44.4, longitude: 8.94)]),
            0
        )
    }

    func testKnownEquatorSegmentDistance() {
        let points = [
            SnorkelingCoordinate(latitude: 0, longitude: 0),
            SnorkelingCoordinate(latitude: 0, longitude: 1),
        ]
        let distance = SnorkelingDistanceCalculator.distanceMeters(points: points)
        XCTAssertEqual(distance, 111_195, accuracy: 500)
    }

    func testMultiSegmentDistanceSumsLegs() {
        let plannerPoints = [
            SnorkelingRoutePlannerPoint(name: "A", role: .entry, latitude: 44.405, longitude: 8.946, routeOrder: 0),
            SnorkelingRoutePlannerPoint(name: "B", role: .waypoint, latitude: 44.40505, longitude: 8.94605, routeOrder: 1),
            SnorkelingRoutePlannerPoint(name: "C", role: .exit, latitude: 44.40510, longitude: 8.94610, routeOrder: 2),
        ]
        let direct = SnorkelingDistanceCalculator.distanceMeters(points: [
            SnorkelingCoordinate(latitude: 44.405, longitude: 8.946),
            SnorkelingCoordinate(latitude: 44.40510, longitude: 8.94610),
        ])
        let stepped = SnorkelingDistanceCalculator.distanceMeters(points: plannerPoints)
        XCTAssertGreaterThan(stepped, 0)
        XCTAssertGreaterThanOrEqual(stepped, direct)
    }

    func testInvalidCoordinateSegmentContributesZero() {
        let points = [
            SnorkelingCoordinate(latitude: 44.4, longitude: 8.94),
            SnorkelingCoordinate(latitude: 999, longitude: 8.94),
            SnorkelingCoordinate(latitude: 44.401, longitude: 8.941),
        ]
        let withInvalid = SnorkelingDistanceCalculator.distanceMeters(points: points)
        let validOnly = SnorkelingDistanceCalculator.distanceMeters(points: [
            points[0],
            points[2],
        ])
        XCTAssertEqual(withInvalid, validOnly, accuracy: 0.001)
    }

    func testMatchesDomainSupportHaversine() {
        let start = SnorkelingCoordinate(latitude: 44.405, longitude: 8.946)
        let end = SnorkelingCoordinate(latitude: 44.406, longitude: 8.947)
        let expected = SnorkelingDomainSupport.distanceMeters(
            from: (start.latitude, start.longitude),
            to: (end.latitude, end.longitude)
        )
        XCTAssertEqual(
            SnorkelingDistanceCalculator.distanceMeters(points: [start, end]),
            expected,
            accuracy: 0.001
        )
    }
}
