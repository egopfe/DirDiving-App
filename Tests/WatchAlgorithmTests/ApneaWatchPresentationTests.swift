import XCTest

final class ApneaWatchPresentationTests: XCTestCase {
    func testReadyStageWhenSessionNotStarted() {
        let output = ApneaWatchPresentation.make(baseInput(isSessionStarted: false))
        XCTAssertEqual(output.stage, .ready)
        XCTAssertTrue(output.startEnabled)
    }

    func testDiveStageWhenSessionStartedAndNotAscending() {
        let output = ApneaWatchPresentation.make(baseInput(isSessionStarted: true, currentDepthMeters: 8, verticalSpeed: -0.4))
        XCTAssertEqual(output.stage, ApneaWatchStage.dive)
        XCTAssertFalse(output.verticalDirectionText.isEmpty)
    }

    func testAscentStageWhenSessionStartedAndAscending() {
        let output = ApneaWatchPresentation.make(baseInput(isSessionStarted: true, currentDepthMeters: 6, verticalSpeed: 0.7))
        XCTAssertEqual(output.stage, ApneaWatchStage.ascent)
        XCTAssertTrue(output.verticalDirectionText.localizedCaseInsensitiveContains("asc") || output.verticalDirectionText.localizedCaseInsensitiveContains("risa"))
    }

    func testSurfaceRecoveryStageWhenOnSurfaceWithRecoveryRemaining() {
        let output = ApneaWatchPresentation.make(
            baseInput(
                isSessionStarted: true,
                currentDepthMeters: 0,
                recoveryRemainingSeconds: 45,
                requiredRecoverySeconds: 90,
                lastDiveDurationSeconds: 62
            )
        )
        XCTAssertEqual(output.stage, .surfaceRecovery)
        XCTAssertEqual(output.recoveryState, .inProgress)
        XCTAssertEqual(output.recoveryRemainingText, "00:45")
    }

    func testRecoveryCompletedStateUsesTextAndFormatting() {
        let output = ApneaWatchPresentation.make(
            baseInput(
                isSessionStarted: true,
                currentDepthMeters: 0,
                recoveryRemainingSeconds: 0,
                requiredRecoverySeconds: 90,
                lastDiveDurationSeconds: 62
            )
        )
        XCTAssertEqual(output.recoveryState, .completed)
        XCTAssertEqual(output.recoveryStateText, String(localized: "apnea.recovery.state.completed"))
        XCTAssertTrue(output.recoveryCompleteHapticEligible)
    }

    func testRecoveryInsufficientStateWhenFlagged() {
        let output = ApneaWatchPresentation.make(
            baseInput(
                isSessionStarted: true,
                currentDepthMeters: 0,
                recoveryRemainingSeconds: 30,
                requiredRecoverySeconds: 90,
                recoveryInsufficient: true
            )
        )
        XCTAssertEqual(output.recoveryState, .insufficient)
    }

    func testSessionSummaryStageWhenRequested() {
        let output = ApneaWatchPresentation.make(baseInput(isSessionStarted: true, showSessionSummary: true))
        XCTAssertEqual(output.stage, .sessionSummary)
    }

    func testSessionSummaryWithZeroDivesUsesPlaceholders() {
        let output = ApneaWatchPresentation.make(
            baseInput(isSessionStarted: true, showSessionSummary: true, diveCount: 0)
        )
        XCTAssertEqual(output.summaryDiveCountText, "0")
        XCTAssertEqual(output.summaryBestTimeText, "--")
        XCTAssertEqual(output.summaryAverageTimeText, "--")
    }

    func testLongSessionFormatting() {
        let output = ApneaWatchPresentation.make(
            baseInput(
                isSessionStarted: true,
                showSessionSummary: true,
                diveCount: 24,
                sessionTotalSeconds: 8_595,
                totalUnderwaterSeconds: 4_680,
                bestDiveDurationSeconds: 188,
                averageDiveDurationSeconds: 195
            )
        )
        XCTAssertEqual(output.summarySessionDurationText, "02:23:15")
        XCTAssertEqual(output.summaryTotalUnderwaterText, "01:18:00")
    }

    func testDegradedDataAddsWarningFooter() {
        let output = ApneaWatchPresentation.make(
            baseInput(isSessionStarted: true, showSessionSummary: true, sensorDegraded: true)
        )
        XCTAssertNotNil(output.summaryWarningsText)
        XCTAssertTrue(output.summaryWarningsText?.contains(String(localized: "apnea.summary.warning.data_quality")) == true)
    }

    func testOverlayPassesThroughPresentation() {
        let overlay = ApneaWatchOverlayPresentation(
            kind: .markerReached,
            title: "Marker",
            subtitle: String(localized: "apnea.recovery.state.completed"),
            depthMeters: 20,
            dismissSafe: true
        )
        let output = ApneaWatchPresentation.make(baseInput(isSessionStarted: true, activeOverlay: overlay))
        XCTAssertEqual(output.activeOverlay, overlay)
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

    func testConfiguredAlarmsPassThrough() {
        let output = ApneaWatchPresentation.make(
            baseInput(isSessionStarted: false, configuredAlarmLabels: ["Depth 20 m", "Time 90 s"])
        )
        XCTAssertEqual(output.configuredAlarms, ["Depth 20 m", "Time 90 s"])
    }

    private func baseInput(
        isSessionStarted: Bool,
        showSessionSummary: Bool = false,
        currentDepthMeters: Double = 12,
        verticalSpeed: Double = 0,
        sensorDegraded: Bool = false,
        activeAlarmCount: Int = 0,
        configuredAlarmLabels: [String] = [],
        diveCount: Int = 2,
        recoveryRemainingSeconds: TimeInterval = 0,
        requiredRecoverySeconds: TimeInterval = 0,
        recoveryInsufficient: Bool = false,
        lastDiveDurationSeconds: TimeInterval = 0,
        sessionTotalSeconds: TimeInterval = 1_395,
        totalUnderwaterSeconds: TimeInterval = 768,
        bestDiveDurationSeconds: TimeInterval = 88,
        averageDiveDurationSeconds: TimeInterval = 64,
        activeOverlay: ApneaWatchOverlayPresentation? = nil
    ) -> ApneaWatchPresentationInput {
        ApneaWatchPresentationInput(
            isSessionStarted: isSessionStarted,
            showSessionSummary: showSessionSummary,
            currentDepthMeters: currentDepthMeters,
            maxDepthMeters: 18,
            temperatureCelsius: 24,
            diveElapsedSeconds: 41,
            diveCount: diveCount,
            verticalSpeedMetersPerSecond: verticalSpeed,
            targetDepthMeters: 25,
            recoveryPolicyLabel: "1:1",
            activeAlarmCount: activeAlarmCount,
            configuredAlarmLabels: configuredAlarmLabels,
            buddyReminderEnabled: true,
            checklistCompletedCount: 0,
            checklistTotalCount: 0,
            sensorDegraded: sensorDegraded,
            hapticsEnabled: true,
            missionModeEnabled: false,
            surfaceElapsedSeconds: 75,
            lastDiveDurationSeconds: lastDiveDurationSeconds,
            lastDiveMaxDepthMeters: 18.4,
            requiredRecoverySeconds: requiredRecoverySeconds,
            recoveryElapsedSeconds: max(0, requiredRecoverySeconds - recoveryRemainingSeconds),
            recoveryRemainingSeconds: recoveryRemainingSeconds,
            recoveryInsufficient: recoveryInsufficient,
            recoveryInProgress: recoveryRemainingSeconds > 0,
            allowEarlyDiveWhenIncomplete: false,
            sessionTotalSeconds: sessionTotalSeconds,
            totalUnderwaterSeconds: totalUnderwaterSeconds,
            sessionMaxDepthMeters: 24.7,
            bestDiveDurationSeconds: bestDiveDurationSeconds,
            averageDiveDurationSeconds: averageDiveDurationSeconds,
            sessionWarnings: [],
            dataQualityDegraded: sensorDegraded,
            activeOverlay: activeOverlay,
            runtimeLayout: .freeTrainingCompact,
            sensorQualityLabels: [],
            maxRepetitions: nil,
            averageRecoverySeconds: 0,
            dataQualityLevel: sensorDegraded ? .medium : .good
        )
    }
}
