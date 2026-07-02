import XCTest

final class SnorkelingWaypointReachedReportTests: XCTestCase {
    func testNoPlannedRouteReturnsEmptyReport() {
        let session = SnorkelingSession(startMode: .watch, state: .completed)
        let report = SnorkelingWaypointReachedReportPolicy.make(session: session)
        XCTAssertFalse(report.hasPlannedRoute)
        XCTAssertEqual(report.reachedCount, 0)
        XCTAssertEqual(report.missedCount, 0)
        XCTAssertTrue(report.reachedWaypointNames.isEmpty)
    }

    func testReportDoesNotInventReachedWaypointsWithoutEvents() {
        let plan = makeRoutePlan()
        var session = SnorkelingSession(startMode: .watch, state: .completed)
        session.routePlans = [plan]
        session.activeRoutePlanID = plan.id
        let report = SnorkelingWaypointReachedReportPolicy.make(session: session)
        XCTAssertTrue(report.hasPlannedRoute)
        XCTAssertEqual(report.reachedCount, 0)
        XCTAssertEqual(report.missedCount, plan.waypoints.count)
        XCTAssertTrue(report.reachedWaypointNames.isEmpty)
        XCTAssertFalse(report.isDerived)
    }

    func testReportUsesPersistedWaypointReachedEventsOnly() {
        let plan = makeRoutePlan()
        let reachedWaypoint = plan.waypoints[0]
        var session = SnorkelingSession(startMode: .watch, state: .completed)
        session.routePlans = [plan]
        session.activeRoutePlanID = plan.id
        session.events = [
            SnorkelingEvent(
                kind: .waypointReached,
                monotonicRelativeTimestampSeconds: 30,
                relatedWaypointID: reachedWaypoint.id
            )
        ]
        let report = SnorkelingWaypointReachedReportPolicy.make(session: session)
        XCTAssertEqual(report.reachedCount, 1)
        XCTAssertEqual(report.missedCount, plan.waypoints.count - 1)
        XCTAssertEqual(report.reachedWaypointNames, [reachedWaypoint.name])
        XCTAssertFalse(report.isDerived)
    }

    private func makeRoutePlan() -> SnorkelingRoutePlan {
        SnorkelingRoutePlan(
            name: "Reef tour",
            waypoints: [
                SnorkelingWaypoint(name: "Buoy", category: .buoy, latitude: 44.10, longitude: 8.90, routeOrder: 0),
                SnorkelingWaypoint(name: "Reef", category: .reef, latitude: 44.11, longitude: 8.91, routeOrder: 1),
            ]
        )
    }
}
