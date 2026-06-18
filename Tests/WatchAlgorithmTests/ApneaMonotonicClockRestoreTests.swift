import XCTest

/// Deterministic monotonic elapsed-time and checkpoint clock restoration (Audit 08 remediation).
final class ApneaMonotonicClockRestoreTests: XCTestCase {
    private var startDate = Date(timeIntervalSince1970: 1_700_000_000)
    private let baseUptime: TimeInterval = 10_000

    override func setUp() {
        super.setUp()
        startDate = Date(timeIntervalSince1970: 1_700_000_000)
    }

    func testWallClockForwardJumpDoesNotChangeCanonicalElapsedTime() {
        var clock = MonotonicElapsedClock()
        clock.reset(anchorDate: wallClock(0), uptime: uptime(0))
        let before = clock.elapsed(now: wallClock(5), uptime: uptime(5))
        let after = clock.elapsed(now: wallClock(5 + 86_400), uptime: uptime(6))
        XCTAssertEqual(after, before + 1, accuracy: 0.001)
    }

    func testWallClockBackwardJumpDoesNotChangeCanonicalElapsedTime() {
        var clock = MonotonicElapsedClock()
        clock.reset(anchorDate: wallClock(0), uptime: uptime(0))
        _ = clock.elapsed(now: wallClock(10), uptime: uptime(10))
        let regressed = clock.elapsed(now: wallClock(2), uptime: uptime(12))
        XCTAssertGreaterThanOrEqual(regressed, 10)
    }

    func testRestorePreservesPersistedElapsedDuration() throws {
        var engine = makeEngine()
        armSession(&engine, offset: 0)
        ingest(&engine, depth: 0, offset: 0)
        ingest(&engine, depth: 2, offset: 4)
        let elapsedBefore = engine.snapshot.sessionElapsedSeconds
        let envelope = try exportCheckpoint(&engine, offset: 4)
        let restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertEqual(restored.snapshot.sessionElapsedSeconds, elapsedBefore, accuracy: 0.001)
    }

    func testElapsedTimeRemainsMonotonicAfterRestore() throws {
        var engine = makeEngine()
        armSession(&engine, offset: 0)
        ingest(&engine, depth: 0, offset: 0)
        let envelope = try exportCheckpoint(&engine, offset: 2)
        var restored = try ApneaSessionEngine(checkpoint: envelope)
        let first = restored.snapshot.sessionElapsedSeconds
        ingest(&restored, depth: 0, offset: 3)
        XCTAssertGreaterThanOrEqual(restored.snapshot.sessionElapsedSeconds, first)
    }

    func testRepeatedRestoreDoesNotResetElapsedTime() throws {
        var engine = makeEngine()
        armSession(&engine, offset: 0)
        ingest(&engine, depth: 0, offset: 0)
        ingest(&engine, depth: 2, offset: 3)
        var envelope = try exportCheckpoint(&engine, offset: 3)
        var lastElapsed: TimeInterval = 0
        for _ in 0..<3 {
            let restored = try ApneaSessionEngine(checkpoint: envelope)
            XCTAssertGreaterThanOrEqual(restored.snapshot.sessionElapsedSeconds, lastElapsed)
            lastElapsed = restored.snapshot.sessionElapsedSeconds
            envelope = try exportCheckpoint(from: restored, offset: 4)
        }
    }

    func testRecoveryElapsedDoesNotCompleteFromWallClockJump() throws {
        var config = testConfiguration()
        config.recoveryMinimumSeconds = 60
        var engine = ApneaSessionEngine(configuration: config, sessionStart: startDate)
        armSession(&engine, offset: 0)
        let end = replayDepths(&engine, depths: [0, 0, 2, 6, 8, 4, 0, 0, 0, 0], interval: 1, endOffset: 10)
        keepSurface(&engine, from: end, count: 5)
        XCTAssertEqual(engine.snapshot.session.dives.count, 1)
        let envelope = try exportCheckpoint(&engine, offset: end + 5)
        var restored = try ApneaSessionEngine(checkpoint: envelope)
        ingest(&restored, depth: 0, offset: end + 5 + 86_400, uptimeOffset: end + 8)
        XCTAssertLessThan(restored.snapshot.recoveryElapsedSeconds, restored.snapshot.requiredRecoverySeconds)
    }

    func testSurfaceDwellDoesNotCompleteFromWallClockJump() throws {
        var config = testConfiguration()
        config.surfaceStableDwellSeconds = 5
        var engine = ApneaSessionEngine(configuration: config, sessionStart: startDate)
        armSession(&engine, offset: 0)
        let end = replayDepths(&engine, depths: [0, 0, 2, 6, 3, 0, 0], interval: 1, endOffset: 7)
        ingest(&engine, depth: 0, offset: end)
        let envelope = try exportCheckpoint(&engine, offset: end)
        var restored = try ApneaSessionEngine(checkpoint: envelope)
        ingest(&restored, depth: 0, offset: end + 86_400, uptimeOffset: end + 1)
        XCTAssertEqual(restored.snapshot.session.dives.count, 0)
    }

    func testSessionElapsedAdvancesFromInjectedMonotonicClock() throws {
        var engine = makeEngine()
        armSession(&engine, offset: 0)
        ingest(&engine, depth: 0, offset: 0)
        let envelope = try exportCheckpoint(&engine, offset: 1)
        var restored = try ApneaSessionEngine(checkpoint: envelope)
        ingest(&restored, depth: 0, offset: 1 + 86_400, uptimeOffset: 3)
        XCTAssertGreaterThanOrEqual(restored.snapshot.sessionElapsedSeconds, 1)
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

    private func armSession(_ engine: inout ApneaSessionEngine, offset: TimeInterval = 0) {
        engine.armSession(at: wallClock(offset), uptime: uptime(offset))
    }

    private func exportCheckpoint(
        from engine: ApneaSessionEngine,
        offset: TimeInterval
    ) throws -> ApneaSessionCheckpointEnvelope {
        var copy = engine
        return try copy.exportCheckpoint(now: wallClock(offset), uptime: uptime(offset))
    }

    private func exportCheckpoint(
        _ engine: inout ApneaSessionEngine,
        offset: TimeInterval
    ) throws -> ApneaSessionCheckpointEnvelope {
        try engine.exportCheckpoint(now: wallClock(offset), uptime: uptime(offset))
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
