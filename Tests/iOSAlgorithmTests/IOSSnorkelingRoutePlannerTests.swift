import XCTest

final class IOSSnorkelingRoutePlannerTests: XCTestCase {
    func testRouteDistanceCalculation() {
        var draft = SnorkelingRoutePlannerDraft(name: "Test")
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "A", role: .entry, latitude: 0, longitude: 0)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "B", role: .exit, latitude: 0, longitude: 0.01)
        let distance = SnorkelingRoutePlanValidator.routeDistanceMeters(draft.orderedPoints)
        XCTAssertGreaterThan(distance, 1_000)
        XCTAssertLessThan(distance, 1_200)
    }

    func testInvalidCoordinateRejected() {
        var draft = SnorkelingRoutePlannerDraft(name: "Bad")
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "A", role: .entry, latitude: 95, longitude: 0)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "B", role: .exit, latitude: 0, longitude: 0)
        XCTAssertTrue(SnorkelingRoutePlanValidator.validationIssues(for: draft).contains(.invalidCoordinate))
    }

    func testEmptyRouteRejected() {
        let draft = SnorkelingRoutePlannerDraft(name: "Empty")
        XCTAssertTrue(SnorkelingRoutePlanValidator.validationIssues(for: draft).contains(.missingEntry))
        XCTAssertTrue(SnorkelingRoutePlanValidator.validationIssues(for: draft).contains(.missingExit))
    }

    func testReorderWaypoints() {
        var draft = SnorkelingRoutePlannerDraft(name: "Reorder")
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "E", role: .entry, latitude: 1, longitude: 1)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "X", role: .exit, latitude: 2, longitude: 2)
        draft.waypoints = [
            SnorkelingRoutePlannerPoint(name: "W1", role: .waypoint, latitude: 1.1, longitude: 1.1, routeOrder: 0),
            SnorkelingRoutePlannerPoint(name: "W2", role: .waypoint, latitude: 1.2, longitude: 1.2, routeOrder: 1),
        ]
        SnorkelingRoutePlanValidator.moveWaypoint(in: &draft, from: 0, to: 1)
        XCTAssertEqual(draft.waypoints.sorted { $0.routeOrder < $1.routeOrder }.first?.name, "W2")
    }

    func testExceedsMaxDistanceLimit() {
        var draft = SnorkelingRoutePlannerDraft(name: "Long", maxDistanceLimitMeters: 10)
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "A", role: .entry, latitude: 0, longitude: 0)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "B", role: .exit, latitude: 0, longitude: 0.01)
        XCTAssertTrue(SnorkelingRoutePlanValidator.validationIssues(for: draft).contains(.exceedsMaxDistance))
    }

    func testMapPermissionStatesExist() {
        XCTAssertEqual(IOSSnorkelingLocationPermission.currentState(), ApneaMapPermissionState.notDetermined)
    }
}
