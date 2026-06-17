import XCTest

final class ApneaWatchPresentationTests: XCTestCase {
    func testReadyStageWhenSessionNotStarted() {
        let output = ApneaWatchPresentation.make(baseInput(isSessionStarted: false))
        XCTAssertEqual(output.stage, .ready)
        XCTAssertTrue(output.startEnabled)
    }

    func testDiveStageWhenSessionStartedAndNotAscending() {
        let output = ApneaWatchPresentation.make(baseInput(isSessionStarted: true, verticalSpeed: -0.4))
        XCTAssertEqual(output.stage, .dive)
        XCTAssertFalse(output.verticalDirectionText.isEmpty)
    }

    func testAscentStageWhenSessionStartedAndAscending() {
        let output = ApneaWatchPresentation.make(baseInput(isSessionStarted: true, verticalSpeed: 0.7))
        XCTAssertEqual(output.stage, .ascent)
        XCTAssertTrue(output.verticalDirectionText.localizedCaseInsensitiveContains("asc") || output.verticalDirectionText.localizedCaseInsensitiveContains("risa"))
    }

    func testStartDisabledWhenSensorDegraded() {
        let output = ApneaWatchPresentation.make(baseInput(isSessionStarted: false, sensorDegraded: true))
        XCTAssertFalse(output.startEnabled)
        XCTAssertNotNil(output.startDisabledReason)
    }

    func testAlarmCountFormatting() {
        let output = ApneaWatchPresentation.make(baseInput(isSessionStarted: false, activeAlarmCount: 3))
        XCTAssertFalse(output.alarmLabel.isEmpty)
    }

    private func baseInput(
        isSessionStarted: Bool,
        verticalSpeed: Double = 0,
        sensorDegraded: Bool = false,
        activeAlarmCount: Int = 0
    ) -> ApneaWatchPresentationInput {
        ApneaWatchPresentationInput(
            isSessionStarted: isSessionStarted,
            currentDepthMeters: 12,
            maxDepthMeters: 18,
            temperatureCelsius: 24,
            diveElapsedSeconds: 41,
            diveCount: 2,
            verticalSpeedMetersPerSecond: verticalSpeed,
            targetDepthMeters: 25,
            recoveryPolicyLabel: "1:1",
            activeAlarmCount: activeAlarmCount,
            buddyReminderEnabled: true,
            sensorDegraded: sensorDegraded,
            hapticsEnabled: true,
            missionModeEnabled: false,
            markerIndicatorActive: false,
            targetIndicatorActive: false
        )
    }
}
