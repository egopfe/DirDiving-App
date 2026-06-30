import XCTest

final class SnorkelingReturnAlertPolicyTests: XCTestCase {
    func testHalfPlannedTimeTriggersAtFiftyPercent() {
        var state = SnorkelingPlannedRouteReturnAlertEngine.State()
        let fired = SnorkelingPlannedRouteReturnAlertEngine.shouldTrigger(
            policy: .halfPlannedTime,
            plannedDurationSeconds: 1_800,
            plannedDistanceMeters: 500,
            elapsedSeconds: 900,
            traveledDistanceMeters: 0,
            state: &state
        )
        XCTAssertTrue(fired)
        XCTAssertTrue(state.alreadyTriggered)
    }

    func testHalfPlannedDistanceTriggersAtFiftyPercent() {
        var state = SnorkelingPlannedRouteReturnAlertEngine.State()
        let fired = SnorkelingPlannedRouteReturnAlertEngine.shouldTrigger(
            policy: .halfPlannedDistance,
            plannedDurationSeconds: 1_800,
            plannedDistanceMeters: 400,
            elapsedSeconds: 60,
            traveledDistanceMeters: 200,
            state: &state
        )
        XCTAssertTrue(fired)
    }

    func testOffPolicyNeverTriggers() {
        var state = SnorkelingPlannedRouteReturnAlertEngine.State()
        let fired = SnorkelingPlannedRouteReturnAlertEngine.shouldTrigger(
            policy: .off,
            plannedDurationSeconds: 1_800,
            plannedDistanceMeters: 400,
            elapsedSeconds: 2_000,
            traveledDistanceMeters: 400,
            state: &state
        )
        XCTAssertFalse(fired)
        XCTAssertFalse(state.alreadyTriggered)
    }

    func testAlertDoesNotFireTwice() {
        var state = SnorkelingPlannedRouteReturnAlertEngine.State()
        let first = SnorkelingPlannedRouteReturnAlertEngine.shouldTrigger(
            policy: .halfPlannedTime,
            plannedDurationSeconds: 600,
            plannedDistanceMeters: 0,
            elapsedSeconds: 300,
            traveledDistanceMeters: 0,
            state: &state
        )
        let second = SnorkelingPlannedRouteReturnAlertEngine.shouldTrigger(
            policy: .halfPlannedTime,
            plannedDurationSeconds: 600,
            plannedDistanceMeters: 0,
            elapsedSeconds: 600,
            traveledDistanceMeters: 0,
            state: &state
        )
        XCTAssertTrue(first)
        XCTAssertFalse(second)
    }

    func testNoTriggerBeforeThreshold() {
        var state = SnorkelingPlannedRouteReturnAlertEngine.State()
        let fired = SnorkelingPlannedRouteReturnAlertEngine.shouldTrigger(
            policy: .halfPlannedDistance,
            plannedDurationSeconds: 1_800,
            plannedDistanceMeters: 400,
            elapsedSeconds: 100,
            traveledDistanceMeters: 199,
            state: &state
        )
        XCTAssertFalse(fired)
    }
}
