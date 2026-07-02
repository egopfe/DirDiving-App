import XCTest

final class SnorkelingP3NoRegressionTests: XCTestCase {
    func testSessionSyncNamespaceRemainsIsolated() {
        XCTAssertNotEqual(SnorkelingReleaseSelfCheck.sessionSyncPayloadKey, SnorkelingReleaseSelfCheck.checkpointNamespace)
        XCTAssertNotEqual(SnorkelingReleaseSelfCheck.sessionSyncPayloadKey, SnorkelingReleaseSelfCheck.diveSessionPayloadKey)
        XCTAssertNotEqual(SnorkelingReleaseSelfCheck.sessionSyncPayloadKey, SnorkelingReleaseSelfCheck.apneaSessionPayloadKey)
    }

    func testMicroMapPresentationDoesNotReplaceBearingRingContract() {
        let presentation = SnorkelingWatchMicroMapPresentationPolicy.make(
            routeCoordinates: [],
            current: SnorkelingCoordinate(latitude: 44.10, longitude: 8.90),
            entry: nil,
            nextWaypoint: nil,
            headingDegrees: nil,
            headingQuality: .unavailable,
            gpsPresentationState: .unavailable,
            isUnderwater: false
        )
        XCTAssertFalse(presentation.isAvailable)
        XCTAssertEqual(presentation, .unavailable)
    }

    func testWaypointReportNeverMarksAllWaypointsReachedWithoutEvents() {
        let plan = SnorkelingRoutePlan(
            name: "Loop",
            waypoints: [
                SnorkelingWaypoint(name: "A", category: .buoy, latitude: 44.1, longitude: 8.9, routeOrder: 0),
                SnorkelingWaypoint(name: "B", category: .reef, latitude: 44.2, longitude: 8.91, routeOrder: 1),
            ]
        )
        var session = SnorkelingSession(startMode: .watch, state: .completed)
        session.routePlans = [plan]
        session.activeRoutePlanID = plan.id
        let report = SnorkelingWaypointReachedReportPolicy.make(session: session)
        XCTAssertLessThan(report.reachedCount, plan.waypoints.count)
    }
}
