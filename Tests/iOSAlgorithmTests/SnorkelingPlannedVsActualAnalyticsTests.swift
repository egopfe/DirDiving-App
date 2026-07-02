import XCTest

final class SnorkelingPlannedVsActualAnalyticsTests: XCTestCase {
    func testMissingRouteUsesNoRouteSummary() {
        var session = SnorkelingSession(startMode: .watch, state: .completed)
        session.statistics.totalDistanceMeters = 420
        let presentation = SnorkelingPlannedVsActualAnalyticsPolicy.make(session: session)
        XCTAssertFalse(presentation.hasPlannedRoute)
        XCTAssertEqual(presentation.comparisonSummaryKey, "snorkeling.logbook.planned_vs_actual.no_route")
    }

    func testEmptyTrackUsesNoTrackSummary() {
        let plan = makeRoutePlan()
        var session = SnorkelingSession(startMode: .watch, state: .completed)
        session.routePlans = [plan]
        session.activeRoutePlanID = plan.id
        session.statistics.totalDistanceMeters = 0
        let presentation = SnorkelingPlannedVsActualAnalyticsPolicy.make(session: session)
        XCTAssertTrue(presentation.hasPlannedRoute)
        XCTAssertEqual(presentation.comparisonSummaryKey, "snorkeling.logbook.planned_vs_actual.no_track")
    }

    func testPlannedVsActualIncludesRuntimeSummaryFields() {
        let plan = makeRoutePlan()
        var session = SnorkelingSession(startMode: .watch, state: .completed)
        session.routePlans = [plan]
        session.activeRoutePlanID = plan.id
        session.statistics.totalDistanceMeters = 500
        session.runtimeSummary = SnorkelingSessionRuntimeSummary(
            gpsQualityBand: .good,
            trackPointCount: 12,
            gapsDetected: 1,
            averageAccuracyMeters: 8,
            maxAccuracyMeters: 15,
            routeCompletedPercentage: 72,
            returnAlertTriggered: true,
            offRouteEventCount: 2,
            maxOffRouteDistanceMeters: 35,
            timeOffRouteSeconds: 40
        )
        let presentation = SnorkelingPlannedVsActualAnalyticsPolicy.make(session: session)
        XCTAssertEqual(presentation.comparisonSummaryKey, "snorkeling.logbook.planned_vs_actual.available")
        XCTAssertNotNil(presentation.plannedDistanceMeters)
        XCTAssertEqual(presentation.routeProgressPercent, 72)
        XCTAssertEqual(presentation.maxOffRouteMeters, 35)
        XCTAssertTrue(presentation.returnAlertTriggered)
    }

    private func makeRoutePlan() -> SnorkelingRoutePlan {
        SnorkelingRoutePlan(
            name: "Coastal loop",
            waypoints: [
                SnorkelingWaypoint(name: "Start", category: .buoy, latitude: 44.10, longitude: 8.90, routeOrder: 0),
                SnorkelingWaypoint(name: "Reef", category: .reef, latitude: 44.11, longitude: 8.91, routeOrder: 1),
            ]
        )
    }
}
