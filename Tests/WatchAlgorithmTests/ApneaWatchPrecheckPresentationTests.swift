import XCTest

final class ApneaWatchPrecheckPresentationTests: XCTestCase {
    func testChecklistCountGeneratesPrecheckLabel() {
        let output = ApneaWatchPresentation.make(
            baseInput(isSessionStarted: false, checklistCompletedCount: 5, checklistTotalCount: 7)
        )
        XCTAssertTrue(output.precheckLabel.contains("5"))
        XCTAssertTrue(output.precheckLabel.contains("7"))
    }

    func testMissingChecklistCountUsesReminderLabel() {
        let output = ApneaWatchPresentation.make(
            baseInput(isSessionStarted: false, checklistCompletedCount: 0, checklistTotalCount: 0)
        )
        XCTAssertEqual(output.precheckLabel, String(localized: "apnea.watch.precheck.reminder"))
    }

    func testPrecheckDoesNotBlockStart() {
        let output = ApneaWatchPresentation.make(
            baseInput(isSessionStarted: false, checklistCompletedCount: 1, checklistTotalCount: 7)
        )
        XCTAssertTrue(output.startEnabled)
        XCTAssertFalse(output.precheckLabel.isEmpty)
    }

    func testRecoveryHapticEligibilityUnchangedWhenPrecheckIncomplete() {
        let output = ApneaWatchPresentation.make(
            baseInput(
                isSessionStarted: true,
                currentDepthMeters: 0,
                recoveryRemainingSeconds: 0,
                requiredRecoverySeconds: 90,
                lastDiveDurationSeconds: 62,
                checklistCompletedCount: 0,
                checklistTotalCount: 7
            )
        )
        XCTAssertEqual(output.recoveryState, .completed)
        XCTAssertTrue(output.recoveryCompleteHapticEligible)
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
        activeOverlay: ApneaWatchOverlayPresentation? = nil,
        checklistCompletedCount: Int = 0,
        checklistTotalCount: Int = 0
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
            checklistCompletedCount: checklistCompletedCount,
            checklistTotalCount: checklistTotalCount,
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
