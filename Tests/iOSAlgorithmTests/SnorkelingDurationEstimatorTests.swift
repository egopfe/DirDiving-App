import XCTest

final class SnorkelingDurationEstimatorTests: XCTestCase {
    func testProfileSpeedOverridesRouteProfileKind() {
        var draft = SnorkelingRoutePlannerDraft(name: "Speed", routeProfileKind: .relaxBeginner)
        let profile = SnorkelingCompanionProfile(
            displayName: "Custom",
            discipline: .custom,
            estimatedSpeedMetersPerMinute: 30
        )
        XCTAssertEqual(SnorkelingDurationEstimator.speedMetersPerMinute(draft: draft, profile: profile), 30)
    }

    func testRouteProfileKindSpeedWhenNoProfileOverride() {
        var draft = SnorkelingRoutePlannerDraft(name: "Kind", routeProfileKind: .trainingSwim)
        XCTAssertEqual(
            SnorkelingDurationEstimator.speedMetersPerMinute(draft: draft, profile: nil),
            SnorkelingRouteProfileKind.trainingSwim.estimatedSpeedMetersPerMinute
        )
    }

    func testEstimatedDurationFromDistanceAndProfileSpeed() {
        var draft = SnorkelingRoutePlannerDraft(name: "Duration", routeProfileKind: .relaxBeginner)
        let profile = SnorkelingCompanionProfile(
            displayName: "Slow",
            discipline: .custom,
            estimatedSpeedMetersPerMinute: 15
        )
        let duration = SnorkelingDurationEstimator.estimatedDurationSeconds(
            distanceMeters: 300,
            draft: draft,
            profile: profile
        )
        XCTAssertEqual(duration, 1_200, accuracy: 0.001)
    }

    func testZeroDistanceOrSpeedReturnsZero() {
        var draft = SnorkelingRoutePlannerDraft(name: "Zero")
        XCTAssertEqual(
            SnorkelingDurationEstimator.estimatedDurationSeconds(distanceMeters: 0, draft: draft, profile: nil),
            0
        )
        draft.routeProfileKind = .relaxBeginner
        let zeroSpeedProfile = SnorkelingCompanionProfile(
            displayName: "Still",
            discipline: .custom,
            estimatedSpeedMetersPerMinute: 0
        )
        XCTAssertEqual(
            SnorkelingDurationEstimator.estimatedDurationSeconds(distanceMeters: 100, draft: draft, profile: zeroSpeedProfile),
            0
        )
    }

    func testDefaultSpeedWhenNoKindOrProfile() {
        let draft = SnorkelingRoutePlannerDraft(name: "Default")
        let speed = SnorkelingDurationEstimator.speedMetersPerMinute(draft: draft, profile: nil)
        XCTAssertEqual(speed, SnorkelingRouteProfileKind.relaxBeginner.estimatedSpeedMetersPerMinute)
    }
}
