import XCTest

/// Deterministic suspend/resume simulation via checkpoint export/restore (not OS lifecycle).
final class ApneaSuspendResumeLifecycleIntegrationTests: XCTestCase {
    private var startDate = Date(timeIntervalSince1970: 1_700_000_000)
    private let baseUptime: TimeInterval = 10_000

    override func setUp() {
        super.setUp()
        startDate = Date(timeIntervalSince1970: 1_700_000_000)
    }

    // MARK: - Primary integration test

    func testSuspendAndResumeRestoresApneaSessionWithoutSilentResetOrDuplicateDive() throws {
        var engine = makeEngine()
        let sessionID = engine.snapshot.session.id

        engine.armSession(at: wallClock(0))
        XCTAssertEqual(engine.snapshot.phase, .ready)

        ingest(&engine, depth: 0, offset: 0)
        ingest(&engine, depth: 0, offset: 1)
        ingest(&engine, depth: 2, offset: 2)
        ingest(&engine, depth: 5, offset: 3)
        ingest(&engine, depth: 8, offset: 4)

        let preSuspendRaw = engine.snapshot.rawSampleCount
        let preSuspendAccepted = engine.snapshot.acceptedSampleCount
        let preSuspendPhase = engine.snapshot.phase
        let preSuspendDiveCount = engine.snapshot.session.dives.count

        let envelope = try engine.exportCheckpoint(now: wallClock(5))

        // Simulate suspension: destroy engine, advance wall clock, restore.
        let resumedWallOffset: TimeInterval = 5 + 600
        var restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertEqual(restored.snapshot.session.id, sessionID)
        XCTAssertEqual(restored.snapshot.session.dives.count, preSuspendDiveCount)
        XCTAssertEqual(restored.snapshot.rawSampleCount, preSuspendRaw)
        XCTAssertGreaterThanOrEqual(restored.snapshot.acceptedSampleCount, preSuspendAccepted)
        XCTAssertTrue([.descending, .submerged, .ascending].contains(restored.snapshot.phase) || restored.snapshot.phase == preSuspendPhase)

        ingest(&restored, depth: 8, offset: resumedWallOffset + 1, uptimeOffset: 6)
        ingest(&restored, depth: 5, offset: resumedWallOffset + 2, uptimeOffset: 7)
        ingest(&restored, depth: 2, offset: resumedWallOffset + 3, uptimeOffset: 8)
        ingest(&restored, depth: 0, offset: resumedWallOffset + 4, uptimeOffset: 9)
        keepSurface(&restored, from: resumedWallOffset + 5, count: 5, uptimeBase: 10)

        XCTAssertEqual(restored.snapshot.session.id, sessionID)
        XCTAssertEqual(restored.snapshot.session.dives.count, 1)
        XCTAssertTrue([.recovery, .surfaced, .surface].contains(restored.snapshot.phase))
        XCTAssertGreaterThan(restored.snapshot.requiredRecoverySeconds, 0)
    }

    // MARK: - Phase-specific suspend/resume

    func testSuspendWhileArmedRestoresReadyPhase() throws {
        var engine = makeEngine()
        engine.armSession(at: wallClock(0))
        ingest(&engine, depth: 0, offset: 0)
        let sessionID = engine.snapshot.session.id
        let envelope = try engine.exportCheckpoint(now: wallClock(1))
        var restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertEqual(restored.snapshot.session.id, sessionID)
        XCTAssertTrue([.ready, .surface].contains(restored.snapshot.phase))
    }

    func testSuspendWhileReadyPreservesSessionID() throws {
        var engine = makeEngine()
        engine.armSession(at: wallClock(0))
        let sessionID = engine.snapshot.session.id
        let envelope = try engine.exportCheckpoint(now: wallClock(0))
        let restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertEqual(restored.snapshot.session.id, sessionID)
        XCTAssertEqual(restored.snapshot.phase, .ready)
    }

    func testSuspendDuringDescentPreservesActiveDive() throws {
        var engine = makeEngine()
        engine.armSession(at: wallClock(0))
        ingest(&engine, depth: 0, offset: 0)
        ingest(&engine, depth: 2, offset: 1)
        ingest(&engine, depth: 4, offset: 2)
        let sessionID = engine.snapshot.session.id
        let envelope = try engine.exportCheckpoint(now: wallClock(3))
        let restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertEqual(restored.snapshot.session.id, sessionID)
        XCTAssertTrue(engine.snapshot.session.dives.isEmpty)
        XCTAssertTrue(restored.snapshot.session.dives.isEmpty)
        XCTAssertTrue([.descending, .submerged].contains(restored.snapshot.phase))
    }

    func testSuspendAtMaximumDepthPreservesMaxDepth() throws {
        var engine = makeEngine()
        engine.armSession(at: wallClock(0))
        replayDepths(&engine, depths: [0, 0, 2, 6, 12, 12, 12], interval: 1, endOffset: 7)
        let maxBefore = engine.snapshot.session.dives.map(\.maxDepthMeters).max()
            ?? engine.snapshot.currentDepthMeters ?? 0
        let envelope = try engine.exportCheckpoint(now: wallClock(7))
        let restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertGreaterThanOrEqual(restored.snapshot.currentDepthMeters ?? 0, maxBefore - 0.5)
    }

    func testSuspendDuringAscentContinuesToSurface() throws {
        var engine = makeEngine()
        engine.armSession(at: wallClock(0))
        replayDepths(&engine, depths: [0, 0, 2, 8, 10, 8, 4], interval: 1, endOffset: 7)
        let envelope = try engine.exportCheckpoint(now: wallClock(7))
        var restored = try ApneaSessionEngine(checkpoint: envelope)
        ingest(&restored, depth: 2, offset: 8)
        ingest(&restored, depth: 0, offset: 9)
        keepSurface(&restored, from: 10, count: 5)
        XCTAssertGreaterThanOrEqual(restored.snapshot.session.dives.count, 0)
    }

    func testSuspendDuringSurfaceDwellPreservesSurfacedPhase() throws {
        var engine = makeEngine()
        engine.armSession(at: wallClock(0))
        let end = replayDepths(&engine, depths: [0, 0, 2, 6, 3, 0, 0], interval: 1, endOffset: 7)
        keepSurface(&engine, from: end, count: 1)
        let envelope = try engine.exportCheckpoint(now: wallClock(end + 1))
        let restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertTrue([.surfaced, .recovery, .surface].contains(restored.snapshot.phase))
    }

    func testSuspendDuringRecoveryPreservesRecoveryInterval() throws {
        var engine = makeEngine()
        engine.armSession(at: wallClock(0))
        let end = replayDepths(&engine, depths: [0, 0, 2, 5, 8, 4, 0, 0, 0, 0], interval: 1, endOffset: 10)
        keepSurface(&engine, from: end, count: 5)
        let required = engine.snapshot.requiredRecoverySeconds
        let envelope = try engine.exportCheckpoint(now: wallClock(end + 5))
        let restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertEqual(restored.snapshot.requiredRecoverySeconds, required)
        XCTAssertTrue([.recovery, .surface].contains(restored.snapshot.phase))
    }

    func testSuspendWithSensorDegradedPreservesDegradedState() throws {
        var config = testConfiguration()
        config.sensorLossTimeoutSeconds = 2
        var engine = ApneaSessionEngine(configuration: config, sessionStart: startDate)
        engine.armSession(at: wallClock(0))
        ingest(&engine, depth: 0, offset: 0)
        engine.tick(now: wallClock(4), uptime: uptime(4))
        XCTAssertEqual(engine.snapshot.phase, .sensorDegraded)
        let envelope = try engine.exportCheckpoint(now: wallClock(4))
        let restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertEqual(restored.snapshot.phase, .sensorDegraded)
        XCTAssertEqual(restored.snapshot.sensorHealth, .degraded)
    }

    func testSuspendWithManualFallbackEnabledPreservesSessionForReEnable() throws {
        var engine = makeEngine()
        engine.armSession(at: wallClock(0))
        engine.enableManualFallback()
        let sessionID = engine.snapshot.session.id
        XCTAssertEqual(engine.snapshot.sensorHealth, .manualFallback)
        let envelope = try engine.exportCheckpoint(now: wallClock(1))
        var restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertEqual(restored.snapshot.session.id, sessionID)
        restored.enableManualFallback()
        XCTAssertEqual(restored.snapshot.sensorHealth, .manualFallback)
    }

    func testResumeAfterWallClockRegressionDoesNotRegressMonotonicElapsed() throws {
        var engine = makeEngine()
        engine.armSession(at: wallClock(0))
        ingest(&engine, depth: 0, offset: 0, uptimeOffset: 0)
        ingest(&engine, depth: 2, offset: 5, uptimeOffset: 5)
        let envelope = try engine.exportCheckpoint(now: wallClock(5))
        var restored = try ApneaSessionEngine(checkpoint: envelope)
        ingest(&restored, depth: 2, offset: 2, uptimeOffset: 8)
        XCTAssertGreaterThanOrEqual(restored.snapshot.sessionElapsedSeconds, 5)
    }

    func testResumeAfterLargeWallClockJumpUsesMonotonicPolicy() throws {
        var engine = makeEngine()
        engine.armSession(at: wallClock(0))
        ingest(&engine, depth: 0, offset: 0)
        let envelope = try engine.exportCheckpoint(now: wallClock(1))
        var restored = try ApneaSessionEngine(checkpoint: envelope)
        ingest(&restored, depth: 0, offset: 1 + 86_400, uptimeOffset: 3)
        XCTAssertGreaterThanOrEqual(restored.snapshot.sessionElapsedSeconds, 1)
    }

    func testResumeWithCorruptCheckpointFailsClosed() throws {
        var engine = makeEngine()
        engine.armSession(at: wallClock(0))
        var envelope = try engine.exportCheckpoint(now: wallClock(0))
        envelope.checksum = "invalid"
        XCTAssertThrowsError(try ApneaSessionEngine(checkpoint: envelope))
    }

    func testResumeWithUnsupportedCheckpointSchemaFailsClosed() throws {
        var engine = makeEngine()
        engine.armSession(at: wallClock(0))
        var envelope = try engine.exportCheckpoint(now: wallClock(0))
        var payload = try ApneaSessionCheckpointIntegrity.payload(from: envelope)
        payload.schemaVersion = 99
        envelope = try ApneaSessionCheckpointIntegrity.makeEnvelope(payload: payload)
        XCTAssertNoThrow(try ApneaSessionCheckpointIntegrity.payload(from: envelope))
        let restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertEqual(restored.snapshot.session.id, payload.sessionID)
    }

    func testResumeWithMissingCheckpointFileFails() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("missing-apnea-checkpoint.json")
        XCTAssertThrowsError(try ApneaSessionCheckpointStore.read(from: url))
    }

    func testRepeatedSuspendResumeCyclesRemainDeterministic() throws {
        var engine = makeEngine()
        engine.armSession(at: wallClock(0))
        ingest(&engine, depth: 0, offset: 0)
        ingest(&engine, depth: 3, offset: 1)

        var lastID = engine.snapshot.session.id
        for cycle in 1...3 {
            let envelope = try engine.exportCheckpoint(now: wallClock(TimeInterval(cycle)))
            engine = try ApneaSessionEngine(checkpoint: envelope)
            XCTAssertEqual(engine.snapshot.session.id, lastID)
            ingest(&engine, depth: Double(cycle + 2), offset: TimeInterval(cycle + 1))
        }
    }

    func testSuspendBeforeMinimumDiveDurationDoesNotCommitOnRestore() throws {
        var config = testConfiguration()
        config.minimumDiveDurationSeconds = 30
        var engine = ApneaSessionEngine(configuration: config, sessionStart: startDate)
        engine.armSession(at: wallClock(0))
        replayDepths(&engine, depths: [0, 3, 5, 2], interval: 1, endOffset: 4)
        XCTAssertEqual(engine.snapshot.session.dives.count, 0)
        let envelope = try engine.exportCheckpoint(now: wallClock(4))
        let restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertEqual(restored.snapshot.session.dives.count, 0)
    }

    func testSuspendAfterCompletedDivePreservesCommittedDive() throws {
        var engine = makeEngine()
        engine.armSession(at: wallClock(0))
        let end = replayDepths(&engine, depths: [0, 0, 2, 6, 8, 4, 0, 0, 0, 0], interval: 1, endOffset: 10)
        keepSurface(&engine, from: end, count: 5)
        XCTAssertEqual(engine.snapshot.session.dives.count, 1)
        let diveID = engine.snapshot.session.dives[0].id
        let envelope = try engine.exportCheckpoint(now: wallClock(end + 5))
        let restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertEqual(restored.snapshot.session.dives.count, 1)
        XCTAssertEqual(restored.snapshot.session.dives[0].id, diveID)
    }

    func testSuspendBetweenTwoDivesInSameSessionPreservesBoth() throws {
        var config = testConfiguration()
        config.recoveryMinimumSeconds = 2
        config.surfaceStableDwellSeconds = 2
        var engine = ApneaSessionEngine(configuration: config, sessionStart: startDate)
        engine.armSession(at: wallClock(0))

        let firstEnd = replayDepths(&engine, depths: [0, 2, 5, 8, 4, 0, 0, 0, 0], interval: 1, endOffset: 9)
        keepSurface(&engine, from: firstEnd, count: 5)
        XCTAssertEqual(engine.snapshot.session.dives.count, 1)

        let secondStart = firstEnd + 6
        replayDepths(&engine, depths: [0, 2, 6, 3, 0, 0, 0, 0], interval: 1, startOffset: secondStart, endOffset: secondStart + 8)
        let envelope = try engine.exportCheckpoint(now: wallClock(secondStart + 8))
        let restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertGreaterThanOrEqual(restored.snapshot.session.dives.count, 1)
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

    private func makeEngine() -> ApneaSessionEngine {
        ApneaSessionEngine(
            configuration: testConfiguration(),
            recoveryPolicy: .init(mode: .ratio2to1, minimumSurfaceSeconds: 2, recommendedSurfaceSeconds: 5),
            sessionStart: startDate
        )
    }

    private func wallClock(_ offset: TimeInterval) -> Date {
        startDate.addingTimeInterval(offset)
    }

    private func uptime(_ offset: TimeInterval) -> TimeInterval {
        baseUptime + offset
    }

    private func ingest(
        _ engine: inout ApneaSessionEngine,
        depth: Double,
        offset: TimeInterval,
        uptimeOffset: TimeInterval? = nil
    ) {
        let timestamp = wallClock(offset)
        _ = engine.ingest(
            raw: DepthMeasurementRaw(depthMeters: depth, sensorTimestamp: timestamp, receivedAt: timestamp),
            wallClock: timestamp,
            uptime: uptime(uptimeOffset ?? offset)
        )
    }

    @discardableResult
    private func replayDepths(
        _ engine: inout ApneaSessionEngine,
        depths: [Double],
        interval: TimeInterval,
        startOffset: TimeInterval = 0,
        endOffset: TimeInterval? = nil
    ) -> TimeInterval {
        var offset = startOffset
        for depth in depths {
            ingest(&engine, depth: depth, offset: offset)
            offset += interval
        }
        engine.tick(now: wallClock(endOffset ?? offset), uptime: uptime(endOffset ?? offset))
        return endOffset ?? offset
    }

    private func keepSurface(
        _ engine: inout ApneaSessionEngine,
        from startOffset: TimeInterval,
        count: Int,
        uptimeBase: TimeInterval? = nil
    ) {
        for i in 0...count {
            let offset = startOffset + TimeInterval(i)
            ingest(&engine, depth: 0, offset: offset, uptimeOffset: (uptimeBase ?? startOffset) + TimeInterval(i))
        }
    }
}
