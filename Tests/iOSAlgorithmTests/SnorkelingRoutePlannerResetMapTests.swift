import XCTest

final class SnorkelingRoutePlannerResetMapTests: XCTestCase {
    func testResetMapPointsClearsRouteGeometry() {
        var draft = SnorkelingRoutePlannerDraft(name: "Route")
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "E", role: .entry, latitude: 44.4, longitude: 8.9)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "X", role: .exit, latitude: 44.41, longitude: 8.91)
        draft.waypoints = [
            SnorkelingRoutePlannerPoint(name: "W", role: .waypoint, latitude: 44.405, longitude: 8.905, routeOrder: 0)
        ]
        XCTAssertFalse(draft.orderedPoints.isEmpty)

        draft.resetMapPoints()

        XCTAssertNil(draft.entryPoint)
        XCTAssertTrue(draft.waypoints.isEmpty)
        XCTAssertNil(draft.exitPoint)
        XCTAssertTrue(draft.orderedPoints.isEmpty)
        XCTAssertFalse(draft.hasRoutePoints)
    }

    func testResetDoesNotClearProfile() {
        let profileID = UUID()
        var draft = SnorkelingRoutePlannerDraft(name: "Named", profileID: profileID)
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "E", role: .entry, latitude: 1, longitude: 1)
        draft.resetMapPoints()
        XCTAssertEqual(draft.profileID, profileID)
        XCTAssertEqual(draft.name, "Named")
    }

    func testHasRoutePointsReflectsDraftState() {
        var empty = SnorkelingRoutePlannerDraft(name: "")
        XCTAssertFalse(empty.hasRoutePoints)

        empty.entryPoint = SnorkelingRoutePlannerPoint(name: "E", role: .entry, latitude: 0, longitude: 0)
        XCTAssertTrue(empty.hasRoutePoints)
    }

    func testValidationFailsAfterReset() {
        var draft = SnorkelingRoutePlannerDraft(name: "Plan")
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "E", role: .entry, latitude: 44, longitude: 8)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "X", role: .exit, latitude: 44.01, longitude: 8.01)
        XCTAssertTrue(SnorkelingRoutePlanValidator.isValid(draft: draft))

        draft.resetMapPoints()
        XCTAssertFalse(SnorkelingRoutePlanValidator.isValid(draft: draft))
    }
}
