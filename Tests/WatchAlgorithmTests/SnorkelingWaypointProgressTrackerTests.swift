import XCTest

final class SnorkelingWaypointProgressTrackerTests: XCTestCase {
    private func routePlan() -> SnorkelingRoutePlan {
        SnorkelingRoutePlan(
            name: "Tracker",
            waypoints: [
                SnorkelingWaypoint(name: "A", category: .reef, latitude: 44.400, longitude: 8.940, routeOrder: 0),
                SnorkelingWaypoint(name: "B", category: .reef, latitude: 44.401, longitude: 8.941, routeOrder: 1),
                SnorkelingWaypoint(name: "C", category: .reef, latitude: 44.402, longitude: 8.942, routeOrder: 2),
            ]
        )
    }

    func testNextWaypointIDSkipsReached() {
        let plan = routePlan()
        let first = plan.waypoints.sorted { $0.routeOrder < $1.routeOrder }[0].id
        let second = plan.waypoints.sorted { $0.routeOrder < $1.routeOrder }[1].id
        XCTAssertEqual(SnorkelingWaypointProgressTracker.nextWaypointID(routePlan: plan, reachedIDs: []), first)
        XCTAssertEqual(SnorkelingWaypointProgressTracker.nextWaypointID(routePlan: plan, reachedIDs: [first]), second)
    }

    func testMarkReachedOnlyWithinThreshold() {
        var state = SnorkelingWaypointProgressTracker.State()
        let plan = routePlan()
        let first = plan.waypoints.sorted { $0.routeOrder < $1.routeOrder }[0]
        let far = SnorkelingCoordinate(latitude: 44.500, longitude: 9.000)
        XCTAssertNil(
            SnorkelingWaypointProgressTracker.markReachedIfNeeded(
                current: far,
                routePlan: plan,
                thresholdMeters: SnorkelingWaypointProgressTracker.defaultReachedThresholdMeters,
                state: &state
            )
        )
        XCTAssertTrue(state.reachedWaypointIDs.isEmpty)

        let near = SnorkelingCoordinate(latitude: first.latitude, longitude: first.longitude)
        let reachedID = SnorkelingWaypointProgressTracker.markReachedIfNeeded(
            current: near,
            routePlan: plan,
            thresholdMeters: SnorkelingWaypointProgressTracker.defaultReachedThresholdMeters,
            state: &state
        )
        XCTAssertEqual(reachedID, first.id)
        XCTAssertTrue(state.reachedWaypointIDs.contains(first.id))
    }

    func testReachedWaypointsNotMarkedAgain() {
        var state = SnorkelingWaypointProgressTracker.State()
        let plan = routePlan()
        let first = plan.waypoints.sorted { $0.routeOrder < $1.routeOrder }[0]
        let near = SnorkelingCoordinate(latitude: first.latitude, longitude: first.longitude)
        _ = SnorkelingWaypointProgressTracker.markReachedIfNeeded(
            current: near,
            routePlan: plan,
            state: &state
        )
        let secondAttempt = SnorkelingWaypointProgressTracker.markReachedIfNeeded(
            current: near,
            routePlan: plan,
            state: &state
        )
        XCTAssertNil(secondAttempt)
        XCTAssertEqual(state.reachedWaypointIDs.count, 1)
    }

    func testNilWhenNoRouteOrPosition() {
        var state = SnorkelingWaypointProgressTracker.State()
        XCTAssertNil(SnorkelingWaypointProgressTracker.nextWaypointID(routePlan: nil, reachedIDs: []))
        XCTAssertNil(
            SnorkelingWaypointProgressTracker.markReachedIfNeeded(
                current: nil,
                routePlan: routePlan(),
                state: &state
            )
        )
    }
}
