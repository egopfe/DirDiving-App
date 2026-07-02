import XCTest

final class SnorkelingOperationalSettingsRouteSyncTests: XCTestCase {
    func testOperationalThresholdsAreEmbeddedInRouteMetadata() throws {
        var draft = SnorkelingRoutePlannerDraft(name: "Operational route")
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "Entry", role: .entry, latitude: 44.4, longitude: 8.94, routeOrder: 0)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "Exit", role: .exit, latitude: 44.402, longitude: 8.942, routeOrder: 2)
        draft.waypoints = [
            SnorkelingRoutePlannerPoint(name: "WP1", role: .waypoint, latitude: 44.401, longitude: 8.941, routeOrder: 1)
        ]
        draft.returnAlertPolicy = .halfPlannedDistance

        let operational = SnorkelingOperationalThresholds(
            maxSessionDurationMinutes: 75,
            maxDistanceMeters: 800,
            returnAlertDistanceMeters: 60,
            returnAlertDurationMinutes: 45,
            defaultReturnAlertPolicy: .halfPlannedTime,
            offRouteThresholdMeters: 35,
            gpsQualityWarningAccuracyMeters: 40,
            buddyReminderEnabled: true
        )

        let package = try SnorkelingRoutePackageBuilder.build(
            draft: draft,
            profile: nil,
            packageID: UUID(),
            revision: 1,
            operational: operational
        )

        let metadata = try XCTUnwrap(package.body.planningMetadata)
        XCTAssertEqual(metadata.waypointCount, 1)
        XCTAssertEqual(metadata.offRouteThresholdMeters, 35)
        XCTAssertEqual(metadata.maxSessionDurationSeconds, 75 * 60)
        XCTAssertEqual(metadata.maxDistanceMeters, 800)
        XCTAssertEqual(metadata.gpsQualityWarningAccuracyMeters, 40)
        XCTAssertEqual(metadata.buddyReminderEnabled, true)
    }
}
