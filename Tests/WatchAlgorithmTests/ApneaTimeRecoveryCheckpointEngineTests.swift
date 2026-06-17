import XCTest

final class ApneaTimeRecoveryCheckpointEngineTests: XCTestCase {
    private var startDate = Date(timeIntervalSince1970: 1_700_000_000)

    override func setUp() {
        super.setUp()
        startDate = Date(timeIntervalSince1970: 1_700_000_000)
    }

    func testRecoveryPolicyModesComputeExpectedDurations() {
        let dive: TimeInterval = 50
        XCTAssertEqual(ApneaRecoveryComputation.requiredRecoverySeconds(policy: .init(mode: .informationalOnly, minimumSurfaceSeconds: 0, recommendedSurfaceSeconds: 0), lastDiveDurationSeconds: dive), 0)
        XCTAssertEqual(ApneaRecoveryComputation.requiredRecoverySeconds(policy: .init(mode: .ratio1to1, minimumSurfaceSeconds: 0, recommendedSurfaceSeconds: 0), lastDiveDurationSeconds: dive), 50)
        XCTAssertEqual(ApneaRecoveryComputation.requiredRecoverySeconds(policy: .init(mode: .ratio2to1, minimumSurfaceSeconds: 0, recommendedSurfaceSeconds: 0), lastDiveDurationSeconds: dive), 100)
        XCTAssertEqual(ApneaRecoveryComputation.requiredRecoverySeconds(policy: .init(mode: .fixedDuration, minimumSurfaceSeconds: 10, recommendedSurfaceSeconds: 0, fixedDurationSeconds: 90), lastDiveDurationSeconds: dive), 90)
        XCTAssertEqual(ApneaRecoveryComputation.requiredRecoverySeconds(policy: .init(mode: .customRatio, minimumSurfaceSeconds: 0, recommendedSurfaceSeconds: 0, customRatio: 1.5), lastDiveDurationSeconds: dive), 75)
    }

    func testMonotonicClockSurvivesWallClockRegression() {
        var clock = MonotonicElapsedClock()
        clock.reset(anchorDate: startDate, uptime: 100)
        _ = clock.elapsed(now: startDate.addingTimeInterval(10), uptime: 110)
        let regressed = clock.elapsed(now: startDate.addingTimeInterval(2), uptime: 112)
        XCTAssertGreaterThanOrEqual(regressed, 10)
    }

    func testCheckpointRoundTripAndEngineRestore() throws {
        var engine = makeEngine()
        let endOffset = replayDive(&engine)
        keepRecoveryAlive(&engine, from: endOffset, seconds: 4)

        let envelope = try engine.exportCheckpoint(now: startDate.addingTimeInterval(20))
        let restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertEqual(restored.snapshot.session.id, engine.snapshot.session.id)
        XCTAssertEqual(restored.snapshot.phase, engine.snapshot.phase)
        XCTAssertEqual(restored.snapshot.requiredRecoverySeconds, engine.snapshot.requiredRecoverySeconds)
    }

    func testAtomicCheckpointFileAndCorruptionDetection() throws {
        var engine = makeEngine()
        let envelope = try engine.exportCheckpoint(now: startDate)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("apnea-checkpoint-test.json")
        defer { try? FileManager.default.removeItem(at: url) }

        try ApneaSessionCheckpointStore.write(envelope, to: url)
        let loaded = try ApneaSessionCheckpointStore.read(from: url)
        XCTAssertEqual(try ApneaSessionCheckpointIntegrity.payload(from: loaded).sessionID, try ApneaSessionCheckpointIntegrity.payload(from: envelope).sessionID)

        var corrupted = loaded
        corrupted.checksum = "bad"
        try Data(try JSONEncoder().encode(corrupted)).write(to: url, options: .atomic)
        XCTAssertThrowsError(try ApneaSessionCheckpointStore.read(from: url))
    }

    func testRecoveryComputationFixedDurationRemainsConservative() {
        let policy = ApneaRecoveryPolicy(mode: .fixedDuration, minimumSurfaceSeconds: 0, recommendedSurfaceSeconds: 0, fixedDurationSeconds: 90)
        XCTAssertEqual(ApneaRecoveryComputation.requiredRecoverySeconds(policy: policy, lastDiveDurationSeconds: 12), 90)
    }

    func testIrregularDeltaAdvancesSessionAndRecovery() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        _ = engine.ingest(raw: .init(depthMeters: 0, sensorTimestamp: startDate, receivedAt: startDate), wallClock: startDate)
        _ = engine.ingest(raw: .init(depthMeters: 3, sensorTimestamp: startDate.addingTimeInterval(1), receivedAt: startDate.addingTimeInterval(1)), wallClock: startDate.addingTimeInterval(1))
        _ = engine.ingest(raw: .init(depthMeters: 0, sensorTimestamp: startDate.addingTimeInterval(11), receivedAt: startDate.addingTimeInterval(11)), wallClock: startDate.addingTimeInterval(11))
        engine.tick(now: startDate.addingTimeInterval(25))
        XCTAssertGreaterThan(engine.snapshot.sessionElapsedSeconds, 20)
    }

    func testManualFallbackDescentDoesNotResetSessionState() {
        var engine = makeEngine()
        _ = replayDive(&engine)
        let previousSessionID = engine.snapshot.session.id
        engine.enableManualFallback()
        engine.triggerManualDescent(at: startDate.addingTimeInterval(20))
        XCTAssertEqual(engine.snapshot.session.id, previousSessionID)
    }

    // MARK: helpers

    private func makeEngine() -> ApneaSessionEngine {
        var config = ApneaLifecycleConfiguration.default
        config.immersionDebounceSeconds = 1
        config.surfaceStableDwellSeconds = 2
        config.recoveryMinimumSeconds = 5
        return ApneaSessionEngine(
            configuration: config,
            recoveryPolicy: .init(mode: .ratio2to1, minimumSurfaceSeconds: 2, recommendedSurfaceSeconds: 5),
            sessionStart: startDate
        )
    }

    @discardableResult
    private func replayDive(_ engine: inout ApneaSessionEngine) -> TimeInterval {
        engine.armSession(at: startDate)
        let depths: [Double] = [0, 0, 2, 5, 8, 5, 2, 0, 0, 0]
        var offset: TimeInterval = 0
        for d in depths {
            let t = startDate.addingTimeInterval(offset)
            _ = engine.ingest(raw: .init(depthMeters: d, sensorTimestamp: t, receivedAt: t), wallClock: t)
            offset += 1
        }
        return offset
    }

    private func keepRecoveryAlive(_ engine: inout ApneaSessionEngine, from startOffset: TimeInterval, seconds: TimeInterval) {
        var offset = startOffset
        while offset <= startOffset + seconds {
            let t = startDate.addingTimeInterval(offset)
            _ = engine.ingest(raw: .init(depthMeters: 0, sensorTimestamp: t, receivedAt: t), wallClock: t)
            offset += 1
        }
    }
}
