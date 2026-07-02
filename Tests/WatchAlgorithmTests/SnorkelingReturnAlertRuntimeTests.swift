import XCTest

final class SnorkelingReturnAlertRuntimeTests: XCTestCase {
    private let route: [SnorkelingCoordinate] = [
        SnorkelingCoordinate(latitude: 44.400, longitude: 8.940),
        SnorkelingCoordinate(latitude: 44.401, longitude: 8.941),
    ]

    private func metadata(policy: SnorkelingReturnAlertPolicy) -> SnorkelingRoutePlanningMetadata {
        SnorkelingRoutePlanningMetadata(
            routeType: .roundTrip,
            estimatedDistanceMeters: 400,
            estimatedDurationSeconds: 600,
            returnAlertPolicy: policy,
            routeProfileKind: .relaxBeginner,
            checklistCompletedCount: 0,
            waypointCount: 2,
            offRouteThresholdMeters: nil,
            maxSessionDurationSeconds: nil,
            maxDistanceMeters: nil,
            gpsQualityWarningAccuracyMeters: nil,
            buddyReminderEnabled: nil
        )
    }

    func testRuntimeFiresReturnAlertHapticAtHalfTime() {
        var state = SnorkelingRouteRuntimeState()
        let evaluation = SnorkelingRouteRuntimeEvaluator.evaluate(
            metadata: metadata(policy: .halfPlannedTime),
            routeCoordinates: route,
            currentCoordinate: route[0],
            horizontalAccuracyMeters: 8,
            fixAgeSeconds: 2,
            sessionElapsedSeconds: 300,
            traveledDistanceMeters: 0,
            monotonicNow: 300,
            state: &state
        )
        XCTAssertTrue(evaluation.plannedReturnAlertTriggered)
        XCTAssertTrue(state.returnAlertTriggered)
        XCTAssertTrue(evaluation.hapticCues.contains(where: { $0.pattern == .returnAdvised }))
    }

    func testRuntimeReturnAlertDoesNotFireTwice() {
        var state = SnorkelingRouteRuntimeState()
        _ = SnorkelingRouteRuntimeEvaluator.evaluate(
            metadata: metadata(policy: .halfPlannedTime),
            routeCoordinates: route,
            currentCoordinate: route[0],
            horizontalAccuracyMeters: 8,
            fixAgeSeconds: 2,
            sessionElapsedSeconds: 300,
            traveledDistanceMeters: 0,
            monotonicNow: 300,
            state: &state
        )
        let second = SnorkelingRouteRuntimeEvaluator.evaluate(
            metadata: metadata(policy: .halfPlannedTime),
            routeCoordinates: route,
            currentCoordinate: route[0],
            horizontalAccuracyMeters: 8,
            fixAgeSeconds: 2,
            sessionElapsedSeconds: 600,
            traveledDistanceMeters: 0,
            monotonicNow: 600,
            state: &state
        )
        XCTAssertFalse(second.plannedReturnAlertTriggered)
        XCTAssertTrue(second.hapticCues.filter { $0.pattern == .returnAdvised }.isEmpty)
    }

    func testOffRouteNotDeclaredWhenGPSLost() {
        var state = SnorkelingRouteRuntimeState()
        let far = SnorkelingCoordinate(latitude: 44.410, longitude: 8.950)
        let evaluation = SnorkelingRouteRuntimeEvaluator.evaluate(
            metadata: nil,
            routeCoordinates: route,
            currentCoordinate: far,
            horizontalAccuracyMeters: 5,
            fixAgeSeconds: 120,
            sessionElapsedSeconds: 10,
            traveledDistanceMeters: 0,
            monotonicNow: 10,
            state: &state
        )
        XCTAssertEqual(evaluation.gpsQualityBand, .lost)
        XCTAssertFalse(evaluation.isOffRoute)
        XCTAssertTrue(evaluation.offRouteWarningPaused)
    }

    func testOffRouteHapticWhenGPSReliableAndFarFromRoute() {
        var state = SnorkelingRouteRuntimeState()
        let far = SnorkelingCoordinate(latitude: 44.410, longitude: 8.950)
        let evaluation = SnorkelingRouteRuntimeEvaluator.evaluate(
            metadata: nil,
            routeCoordinates: route,
            currentCoordinate: far,
            horizontalAccuracyMeters: 10,
            fixAgeSeconds: 3,
            sessionElapsedSeconds: 10,
            traveledDistanceMeters: 0,
            monotonicNow: 10,
            state: &state
        )
        XCTAssertTrue(evaluation.isOffRoute)
        XCTAssertTrue(evaluation.hapticCues.contains(where: { $0.pattern == .alarmWarning }))
        XCTAssertEqual(state.offRouteEventCount, 1)
    }

    func testRuntimeSummaryCapturesReturnAndOffRouteMetrics() {
        var state = SnorkelingRouteRuntimeState()
        state.returnAlertTriggered = true
        state.offRouteEventCount = 2
        state.maxOffRouteDistanceMeters = 80
        state.timeOffRouteSeconds = 15
        let summary = SnorkelingRouteRuntimeEvaluator.makeRuntimeSummary(
            state: state,
            gpsQualityBand: .good,
            routeProgressPercent: 42,
            trackPointCount: 10
        )
        XCTAssertTrue(summary.returnAlertTriggered)
        XCTAssertEqual(summary.offRouteEventCount, 2)
        XCTAssertEqual(summary.maxOffRouteDistanceMeters, 80)
        XCTAssertEqual(summary.routeCompletedPercentage, 42)
    }
}
