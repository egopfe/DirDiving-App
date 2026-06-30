import XCTest

final class SnorkelingRouteProfileTests: XCTestCase {
    func testAllProfileKindsHavePositiveSpeedAndLimits() {
        for kind in SnorkelingRouteProfileKind.allCases {
            XCTAssertGreaterThan(kind.estimatedSpeedMetersPerMinute, 0)
            XCTAssertGreaterThan(kind.recommendedMaxDistanceMeters, 0)
            XCTAssertGreaterThan(kind.recommendedMaxDurationMinutes, 0)
            XCTAssertEqual(kind.defaultReturnAlertPolicy, .halfPlannedTime)
            XCTAssertFalse(kind.localizationKey.isEmpty)
        }
    }

    func testPhotoReefIsSlowestProfile() {
        let speeds = SnorkelingRouteProfileKind.allCases.map(\.estimatedSpeedMetersPerMinute)
        XCTAssertEqual(SnorkelingRouteProfileKind.photoReefObservation.estimatedSpeedMetersPerMinute, speeds.min())
    }

    func testLongRouteHasHighestRecommendedDistance() {
        let distances = SnorkelingRouteProfileKind.allCases.map(\.recommendedMaxDistanceMeters)
        XCTAssertEqual(SnorkelingRouteProfileKind.longRoute.recommendedMaxDistanceMeters, distances.max())
    }

    func testPlanningMetadataUsesProfileKindWhenNoCompanionProfile() {
        var draft = SnorkelingRoutePlannerDraft(name: "Meta", routeProfileKind: .coastalExploration, routeType: .roundTrip)
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "Entry", role: .entry, latitude: 44.40, longitude: 8.94)
        draft.waypoints = [
            SnorkelingRoutePlannerPoint(name: "WP", role: .waypoint, latitude: 44.401, longitude: 8.941, routeOrder: 0),
        ]
        let metadata = SnorkelingRoutePlanningMetadata.make(from: draft, profile: nil)
        XCTAssertEqual(metadata.routeProfileKind, .coastalExploration)
        XCTAssertEqual(metadata.routeType, .roundTrip)
        XCTAssertGreaterThan(metadata.estimatedDistanceMeters, 0)
        XCTAssertGreaterThan(metadata.estimatedDurationSeconds, 0)
    }

    func testCompanionProfileOverridesKindLimitsInValidation() {
        var draft = SnorkelingRoutePlannerDraft(name: "Tight", routeProfileKind: .longRoute)
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "A", role: .entry, latitude: 44.40, longitude: 8.94)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "B", role: .exit, latitude: 44.405, longitude: 8.945)
        let tightProfile = SnorkelingCompanionProfile(
            displayName: "Tight",
            discipline: .custom,
            targetDurationSeconds: 60,
            maxDistanceMeters: 50
        )
        let result = SnorkelingRouteValidator.validate(draft: draft, profile: tightProfile)
        XCTAssertEqual(result.status, .warning)
        XCTAssertTrue(result.warnings.contains(.exceedsProfileDistance))
        XCTAssertTrue(result.warnings.contains(.exceedsProfileDuration))
    }
}
