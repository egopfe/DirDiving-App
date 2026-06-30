import XCTest

final class ApneaRecoveryPolicyLifecycleTests: XCTestCase {
    private var startDate = Date(timeIntervalSince1970: 1_700_000_000)

    func testRatio2to1RecoveryLongerThanDefaultMinimum() {
        var config = testConfiguration()
        config.recoveryMinimumSeconds = 10
        var engine = ApneaSessionEngine(
            configuration: config,
            recoveryPolicy: .init(
                mode: .fixedDuration,
                minimumSurfaceSeconds: 2,
                recommendedSurfaceSeconds: 120,
                fixedDurationSeconds: 45
            ),
            sessionStart: startDate
        )
        engine.armSession(at: startDate)

        let diveEnd = replayDepths(&engine, depths: [0, 2, 8, 4, 0, 0, 0, 0], interval: 1)
        XCTAssertEqual(engine.snapshot.phase, ApneaLifecyclePhase.recovery)
        XCTAssertEqual(engine.snapshot.requiredRecoverySeconds, 45, accuracy: 0.01)

        keepAliveSurface(&engine, from: diveEnd, seconds: 12)
        XCTAssertEqual(engine.snapshot.phase, ApneaLifecyclePhase.recovery)
        XCTAssertGreaterThan(engine.snapshot.recoveryRemainingSeconds ?? 0, 0)

        keepAliveSurface(&engine, from: diveEnd + 12, seconds: 40)
        XCTAssertTrue([ApneaLifecyclePhase.surface, ApneaLifecyclePhase.ready].contains(engine.snapshot.phase))
        XCTAssertEqual(engine.snapshot.recoveryRemainingSeconds ?? 0, 0, accuracy: 0.01)
    }

    func testRecoveryIncompleteBlocksManualStartWhenEarlyDiveDisabled() {
        var engine = ApneaSessionEngine(
            configuration: testConfiguration(),
            recoveryPolicy: .init(
                mode: .fixedDuration,
                minimumSurfaceSeconds: 2,
                recommendedSurfaceSeconds: 120,
                allowEarlyDiveWhenIncomplete: false,
                fixedDurationSeconds: 30
            ),
            sessionStart: startDate
        )
        engine.armSession(at: startDate)
        let diveEnd = replayDepths(&engine, depths: [0, 2, 6, 8, 4, 0, 0, 0, 0], interval: 1)
        XCTAssertEqual(engine.snapshot.phase, ApneaLifecyclePhase.recovery)
        keepAliveSurface(&engine, from: diveEnd, seconds: 5)
        XCTAssertEqual(engine.snapshot.phase, ApneaLifecyclePhase.recovery)

        engine.enableManualFallback()
        engine.triggerManualDescent(at: startDate.addingTimeInterval(diveEnd + 5))
        XCTAssertEqual(engine.snapshot.phase, ApneaLifecyclePhase.recovery)
    }

    func testRecoveryIncompleteAllowsManualStartWhenEarlyDiveEnabled() {
        var engine = ApneaSessionEngine(
            configuration: testConfiguration(),
            recoveryPolicy: .init(
                mode: .fixedDuration,
                minimumSurfaceSeconds: 2,
                recommendedSurfaceSeconds: 120,
                allowEarlyDiveWhenIncomplete: true,
                fixedDurationSeconds: 30
            ),
            sessionStart: startDate
        )
        engine.armSession(at: startDate)
        let diveEnd = replayDepths(&engine, depths: [0, 2, 6, 8, 4, 0, 0, 0, 0], interval: 1)
        keepAliveSurface(&engine, from: diveEnd, seconds: 5)
        XCTAssertEqual(engine.snapshot.phase, ApneaLifecyclePhase.recovery)

        ingest(&engine, depth: 1.0, offset: diveEnd + 5)
        engine.enableManualFallback()
        engine.triggerManualDescent(at: startDate.addingTimeInterval(diveEnd + 5.5))
        XCTAssertEqual(engine.snapshot.phase, ApneaLifecyclePhase.descending)
        XCTAssertTrue(engine.snapshot.session.warnings.contains(ApneaSessionWarning.incompleteRecovery))
    }

    func testWatchPresentationBlocksStartDuringIncompleteRecovery() {
        let input = ApneaWatchPresentationInput(
            isSessionStarted: true,
            showSessionSummary: false,
            currentDepthMeters: 0,
            maxDepthMeters: 12,
            temperatureCelsius: 24,
            diveElapsedSeconds: 0,
            diveCount: 1,
            verticalSpeedMetersPerSecond: 0,
            targetDepthMeters: 20,
            recoveryPolicyLabel: "2:1",
            activeAlarmCount: 0,
            configuredAlarmLabels: [],
            buddyReminderEnabled: true,
            sensorDegraded: false,
            hapticsEnabled: true,
            missionModeEnabled: false,
            surfaceElapsedSeconds: 30,
            lastDiveDurationSeconds: 90,
            lastDiveMaxDepthMeters: 12,
            requiredRecoverySeconds: 180,
            recoveryElapsedSeconds: 30,
            recoveryRemainingSeconds: 150,
            recoveryInsufficient: false,
            recoveryInProgress: true,
            allowEarlyDiveWhenIncomplete: false,
            sessionTotalSeconds: 300,
            totalUnderwaterSeconds: 90,
            sessionMaxDepthMeters: 12,
            bestDiveDurationSeconds: 90,
            averageDiveDurationSeconds: 90,
            sessionWarnings: [],
            dataQualityDegraded: false,
            activeOverlay: nil,
            runtimeLayout: .freeTrainingCompact,
            sensorQualityLabels: [],
            maxRepetitions: nil,
            averageRecoverySeconds: 0,
            dataQualityLevel: .good
        )
        let output = ApneaWatchPresentation.make(input)
        XCTAssertFalse(output.startEnabled)
        XCTAssertEqual(output.startDisabledReason, String(localized: "apnea.ready.recovery_incomplete"))
    }

    func testFixedDurationRecoveryPolicy() {
        let policy = ApneaRecoveryPolicy(
            mode: .fixedDuration,
            minimumSurfaceSeconds: 30,
            recommendedSurfaceSeconds: 60,
            allowEarlyDiveWhenIncomplete: false,
            fixedDurationSeconds: 45
        )
        XCTAssertEqual(
            ApneaRecoveryComputation.requiredRecoverySeconds(policy: policy, lastDiveDurationSeconds: 120),
            45,
            accuracy: 0.01
        )
    }

    func testCustomRatioRecoveryPolicy() {
        let policy = ApneaRecoveryPolicy(
            mode: .customRatio,
            minimumSurfaceSeconds: 30,
            recommendedSurfaceSeconds: 60,
            allowEarlyDiveWhenIncomplete: false,
            customRatio: 1.5
        )
        XCTAssertEqual(
            ApneaRecoveryComputation.requiredRecoverySeconds(policy: policy, lastDiveDurationSeconds: 80),
            120,
            accuracy: 0.01
        )
    }

    func testRatio1to1RecoveryControlsLifecycleCompletion() {
        var engine = ApneaSessionEngine(
            configuration: testConfiguration(),
            recoveryPolicy: .init(mode: .ratio1to1, minimumSurfaceSeconds: 2, recommendedSurfaceSeconds: 120),
            sessionStart: startDate
        )
        engine.armSession(at: startDate)
        let diveEnd = replayDepths(&engine, depths: [0, 2, 6, 8, 4, 0, 0, 0, 0], interval: 1)
        let lastDiveDuration = engine.snapshot.session.dives.last?.durationSeconds ?? 0
        XCTAssertEqual(
            engine.snapshot.requiredRecoverySeconds,
            ApneaRecoveryComputation.requiredRecoverySeconds(
                policy: .init(mode: .ratio1to1, minimumSurfaceSeconds: 2, recommendedSurfaceSeconds: 120),
                lastDiveDurationSeconds: lastDiveDuration
            ),
            accuracy: 1.0
        )
        keepAliveSurface(&engine, from: diveEnd, seconds: engine.snapshot.requiredRecoverySeconds - 1)
        XCTAssertEqual(engine.snapshot.phase, ApneaLifecyclePhase.recovery)
        keepAliveSurface(&engine, from: diveEnd + engine.snapshot.requiredRecoverySeconds - 1, seconds: 2)
        XCTAssertTrue([ApneaLifecyclePhase.surface, ApneaLifecyclePhase.ready].contains(engine.snapshot.phase))
    }

    func testRatio2to1RecoveryLongerThanLifecycleMinimum() {
        var config = testConfiguration()
        config.recoveryMinimumSeconds = 5
        var engine = ApneaSessionEngine(
            configuration: config,
            recoveryPolicy: .init(mode: .ratio2to1, minimumSurfaceSeconds: 2, recommendedSurfaceSeconds: 120),
            sessionStart: startDate
        )
        engine.armSession(at: startDate)
        let diveEnd = replayDepths(&engine, depths: [0, 2, 8, 6, 0, 0, 0, 0], interval: 1)
        let required = engine.snapshot.requiredRecoverySeconds
        XCTAssertGreaterThan(required, config.recoveryMinimumSeconds)
        keepAliveSurface(&engine, from: diveEnd, seconds: config.recoveryMinimumSeconds + 1)
        XCTAssertEqual(engine.snapshot.phase, ApneaLifecyclePhase.recovery)
    }

    func testRecoveryExactlyCompleteAllowsReadyState() {
        var engine = fixedRecoveryEngine(seconds: 20)
        engine.armSession(at: startDate)
        let diveEnd = replayDepths(&engine, depths: [0, 2, 6, 0, 0, 0, 0], interval: 1)
        keepAliveSurface(&engine, from: diveEnd, seconds: 20)
        engine.tick(now: startDate.addingTimeInterval(diveEnd + 20))
        XCTAssertTrue([ApneaLifecyclePhase.surface, ApneaLifecyclePhase.ready].contains(engine.snapshot.phase))
        XCTAssertEqual(engine.snapshot.recoveryRemainingSeconds ?? 0, 0, accuracy: 0.01)
    }

    func testRecoveryOneSecondBeforeCompletionRemainsInRecovery() {
        var engine = fixedRecoveryEngine(seconds: 25)
        engine.armSession(at: startDate)
        let diveEnd = replayDepths(&engine, depths: [0, 2, 6, 8, 4, 0, 0, 0, 0], interval: 1)
        XCTAssertEqual(engine.snapshot.phase, ApneaLifecyclePhase.recovery)
        let required = engine.snapshot.requiredRecoverySeconds
        keepAliveSurface(&engine, from: diveEnd, seconds: max(0, required - 2))
        XCTAssertEqual(engine.snapshot.phase, ApneaLifecyclePhase.recovery)
        XCTAssertGreaterThan(engine.snapshot.recoveryRemainingSeconds ?? 0, 0)
    }

    func testRecoveryOneSecondAfterCompletionLeavesRecovery() {
        var engine = fixedRecoveryEngine(seconds: 25)
        engine.armSession(at: startDate)
        let diveEnd = replayDepths(&engine, depths: [0, 2, 6, 0, 0, 0, 0], interval: 1)
        keepAliveSurface(&engine, from: diveEnd, seconds: 26)
        engine.tick(now: startDate.addingTimeInterval(diveEnd + 26))
        XCTAssertTrue([ApneaLifecyclePhase.surface, ApneaLifecyclePhase.ready].contains(engine.snapshot.phase))
    }

    func testZeroDurationDiveUsesPolicyMinimumSurface() {
        let policy = ApneaRecoveryPolicy(
            mode: .ratio2to1,
            minimumSurfaceSeconds: 45,
            recommendedSurfaceSeconds: 90,
            allowEarlyDiveWhenIncomplete: false
        )
        XCTAssertEqual(
            ApneaRecoveryComputation.requiredRecoverySeconds(policy: policy, lastDiveDurationSeconds: 0),
            45,
            accuracy: 0.01
        )
    }

    func testVeryLongDiveRecoveryScalesWithPolicy() {
        let diveDuration: TimeInterval = 360
        let policy = ApneaRecoveryPolicy(mode: .ratio2to1, minimumSurfaceSeconds: 30, recommendedSurfaceSeconds: 120)
        XCTAssertEqual(
            ApneaRecoveryComputation.requiredRecoverySeconds(policy: policy, lastDiveDurationSeconds: diveDuration),
            diveDuration * 2,
            accuracy: 0.01
        )
    }

    func testWatchPresentationAllowsStartWhenEarlyDiveEnabled() {
        let input = ApneaWatchPresentationInput(
            isSessionStarted: true,
            showSessionSummary: false,
            currentDepthMeters: 0,
            maxDepthMeters: 12,
            temperatureCelsius: 24,
            diveElapsedSeconds: 0,
            diveCount: 1,
            verticalSpeedMetersPerSecond: 0,
            targetDepthMeters: 20,
            recoveryPolicyLabel: "2:1",
            activeAlarmCount: 0,
            configuredAlarmLabels: [],
            buddyReminderEnabled: true,
            sensorDegraded: false,
            hapticsEnabled: true,
            missionModeEnabled: false,
            surfaceElapsedSeconds: 30,
            lastDiveDurationSeconds: 90,
            lastDiveMaxDepthMeters: 12,
            requiredRecoverySeconds: 180,
            recoveryElapsedSeconds: 30,
            recoveryRemainingSeconds: 150,
            recoveryInsufficient: false,
            recoveryInProgress: true,
            allowEarlyDiveWhenIncomplete: true,
            sessionTotalSeconds: 300,
            totalUnderwaterSeconds: 90,
            sessionMaxDepthMeters: 12,
            bestDiveDurationSeconds: 90,
            averageDiveDurationSeconds: 90,
            sessionWarnings: [],
            dataQualityDegraded: false,
            activeOverlay: nil,
            runtimeLayout: .freeTrainingCompact,
            sensorQualityLabels: [],
            maxRepetitions: nil,
            averageRecoverySeconds: 0,
            dataQualityLevel: .good
        )
        let output = ApneaWatchPresentation.make(input)
        XCTAssertTrue(output.startEnabled)
    }

    func testRepeatedManualStartRequestDoesNotDuplicateDive() {
        var engine = fixedRecoveryEngine(seconds: 40, allowEarly: false)
        engine.armSession(at: startDate)
        let diveEnd = replayDepths(&engine, depths: [0, 2, 6, 8, 4, 0, 0, 0, 0], interval: 1)
        XCTAssertEqual(engine.snapshot.phase, ApneaLifecyclePhase.recovery)
        keepAliveSurface(&engine, from: diveEnd, seconds: 5)
        XCTAssertEqual(engine.snapshot.phase, ApneaLifecyclePhase.recovery)
        let diveCountBefore = engine.snapshot.session.dives.count
        engine.enableManualFallback()
        engine.triggerManualDescent(at: startDate.addingTimeInterval(diveEnd + 5))
        engine.triggerManualDescent(at: startDate.addingTimeInterval(diveEnd + 6))
        XCTAssertEqual(engine.snapshot.session.dives.count, diveCountBefore)
        XCTAssertEqual(engine.snapshot.phase, ApneaLifecyclePhase.recovery)
    }

    func testCheckpointRestorePreservesActiveRecovery() throws {
        var engine = fixedRecoveryEngine(seconds: 60)
        engine.armSession(at: startDate)
        let diveEnd = replayDepths(&engine, depths: [0, 2, 8, 4, 0, 0, 0, 0], interval: 1)
        keepAliveSurface(&engine, from: diveEnd, seconds: 10)
        let required = engine.snapshot.requiredRecoverySeconds
        let envelope = try engine.exportCheckpoint(now: startDate.addingTimeInterval(diveEnd + 10))
        let restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertEqual(restored.snapshot.requiredRecoverySeconds, required)
        XCTAssertEqual(restored.snapshot.phase, ApneaLifecyclePhase.recovery)
    }

    private func fixedRecoveryEngine(seconds: TimeInterval, allowEarly: Bool = false) -> ApneaSessionEngine {
        ApneaSessionEngine(
            configuration: testConfiguration(),
            recoveryPolicy: .init(
                mode: .fixedDuration,
                minimumSurfaceSeconds: 2,
                recommendedSurfaceSeconds: 120,
                allowEarlyDiveWhenIncomplete: allowEarly,
                fixedDurationSeconds: seconds
            ),
            sessionStart: startDate
        )
    }

    // MARK: - Helpers

    private func testConfiguration() -> ApneaLifecycleConfiguration {
        var config = ApneaLifecycleConfiguration.default
        config.immersionDebounceSeconds = 1
        config.surfaceStableDwellSeconds = 3
        config.recoveryMinimumSeconds = 3
        config.minimumDiveDurationSeconds = 1
        return config
    }

    private func ingest(_ engine: inout ApneaSessionEngine, depth: Double, offset: TimeInterval) {
        let timestamp = startDate.addingTimeInterval(offset)
        _ = engine.ingest(
            raw: DepthMeasurementRaw(depthMeters: depth, sensorTimestamp: timestamp, receivedAt: timestamp),
            wallClock: timestamp
        )
    }

    @discardableResult
    private func replayDepths(
        _ engine: inout ApneaSessionEngine,
        depths: [Double],
        interval: TimeInterval,
        startOffset: TimeInterval = 0
    ) -> TimeInterval {
        var offset = startOffset
        for depth in depths {
            ingest(&engine, depth: depth, offset: offset)
            offset += interval
        }
        engine.tick(now: startDate.addingTimeInterval(offset))
        return offset
    }

    private func keepAliveSurface(_ engine: inout ApneaSessionEngine, from startOffset: TimeInterval, seconds: TimeInterval) {
        var offset = startOffset
        let end = startOffset + seconds
        while offset <= end {
            ingest(&engine, depth: 0, offset: offset)
            offset += 1
        }
    }
}
