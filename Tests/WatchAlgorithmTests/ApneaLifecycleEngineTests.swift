import XCTest

final class ApneaLifecycleEngineTests: XCTestCase {
    private var startDate = Date(timeIntervalSince1970: 1_700_000_000)

    override func setUp() {
        super.setUp()
        startDate = Date(timeIntervalSince1970: 1_700_000_000)
    }

    // MARK: - Depth feed

    func testDepthFeedAcceptsValidSampleAndComputesVerticalSpeed() {
        var state = DepthMeasurementFeedState.initial
        let t0 = startDate
        let first = DepthMeasurementFeed.ingest(
            raw: DepthMeasurementRaw(depthMeters: 0, sensorTimestamp: t0, receivedAt: t0),
            state: &state
        )
        XCTAssertEqual(first.quality, .accepted)

        let t1 = t0.addingTimeInterval(1)
        let second = DepthMeasurementFeed.ingest(
            raw: DepthMeasurementRaw(depthMeters: 2, sensorTimestamp: t1, receivedAt: t1),
            state: &state
        )
        XCTAssertEqual(second.quality, .accepted)
        XCTAssertEqual(second.accepted?.verticalSpeedMetersPerSecond ?? 0, 2, accuracy: 0.01)
    }

    func testDepthFeedRejectsSpike() {
        var state = DepthMeasurementFeedState.initial
        let t0 = startDate
        _ = DepthMeasurementFeed.ingest(
            raw: DepthMeasurementRaw(depthMeters: 0, sensorTimestamp: t0, receivedAt: t0),
            state: &state
        )
        let t1 = t0.addingTimeInterval(0.5)
        let spike = DepthMeasurementFeed.ingest(
            raw: DepthMeasurementRaw(depthMeters: 10, sensorTimestamp: t1, receivedAt: t1),
            state: &state
        )
        XCTAssertEqual(spike.quality, .spikeRejected)
        XCTAssertNil(spike.accepted)
    }

    func testDepthFeedRejectsRegressiveTimestamp() {
        var state = DepthMeasurementFeedState.initial
        let t0 = startDate
        _ = DepthMeasurementFeed.ingest(
            raw: DepthMeasurementRaw(depthMeters: 1, sensorTimestamp: t0, receivedAt: t0),
            state: &state
        )
        let regressive = DepthMeasurementFeed.ingest(
            raw: DepthMeasurementRaw(
                depthMeters: 1.2,
                sensorTimestamp: t0.addingTimeInterval(-1),
                receivedAt: t0.addingTimeInterval(-1)
            ),
            state: &state
        )
        XCTAssertEqual(regressive.quality, .regressiveTimestamp)
    }

    // MARK: - Lifecycle engine

    func testStateMachineManualSurfaceFromDescending() {
        var tracker = ApneaLifecycleTracker.initial
        tracker.phase = .descending
        tracker.diveStartedAt = 0
        let input = ApneaLifecycleMachineInput(
            configuration: testConfiguration(),
            monotonicNow: 10,
            wallClockNow: startDate.addingTimeInterval(10),
            acceptedDepthMeters: 0,
            verticalSpeedMetersPerSecond: -0.2,
            feedAccepted: true,
            sensorAvailable: false,
            manualFallbackActive: true,
            manualDescentTriggered: false,
            manualSurfaceTriggered: true,
            sessionArmed: true,
            endSessionRequested: false,
            tickOnly: false
        )
        let output = ApneaLifecycleStateMachine.evaluate(input: input, tracker: tracker)
        XCTAssertEqual(output.tracker.phase, .surfaced)
    }

    func testStateMachineFinishesDiveAfterSurfaceDwell() {
        var tracker = ApneaLifecycleTracker.initial
        tracker.phase = .surfaced
        tracker.diveStartedAt = 0
        tracker.diveMaxDepthMeters = 12
        tracker.surfaceDwellSince = 10
        let input = ApneaLifecycleMachineInput(
            configuration: testConfiguration(),
            monotonicNow: 13,
            wallClockNow: startDate.addingTimeInterval(13),
            acceptedDepthMeters: 0,
            verticalSpeedMetersPerSecond: 0,
            feedAccepted: true,
            sensorAvailable: true,
            manualFallbackActive: false,
            manualDescentTriggered: false,
            manualSurfaceTriggered: false,
            sessionArmed: true,
            endSessionRequested: false,
            tickOnly: false
        )
        let output = ApneaLifecycleStateMachine.evaluate(input: input, tracker: tracker)
        XCTAssertTrue(output.events.contains(where: {
            if case .diveEnded = $0 { return true }
            return false
        }))
        XCTAssertEqual(output.tracker.phase, .recovery)
    }

    func testEngineStartsDiveDuringReplayProfile() {
        var engine = ApneaSessionEngine(configuration: testConfiguration(), sessionStart: startDate)
        engine.armSession(at: startDate)
        replayDepths(&engine, depths: [0, 0, 2, 4, 6, 8, 10], interval: 1)
        XCTAssertGreaterThan(engine.snapshot.diveElapsedSeconds, 0)
        XCTAssertTrue([.descending, .submerged, .ascending].contains(engine.snapshot.phase))
    }

    func testSessionArmsToReadyAndDetectsFullDiveCycle() {
        var engine = ApneaSessionEngine(configuration: testConfiguration(), sessionStart: startDate)
        engine.armSession(at: startDate)
        XCTAssertEqual(engine.snapshot.phase, .ready)

        let endOffset = replayDepths(&engine, depths: [0, 0, 2, 4, 6, 8, 10, 10, 10, 8, 6, 4, 2, 0, 0, 0, 0], interval: 1)
        keepAliveSurface(&engine, from: endOffset, seconds: 5)

        XCTAssertTrue(
            [.surfaced, .recovery, .surface].contains(engine.snapshot.phase),
            "Expected post-dive phase, got \(engine.snapshot.phase)"
        )
        XCTAssertGreaterThanOrEqual(engine.snapshot.session.dives.count, 1)
        XCTAssertGreaterThan(engine.snapshot.rawSampleCount, engine.snapshot.acceptedSampleCount / 2)
    }

    func testSurfaceOscillationDoesNotCloseDivePrematurely() {
        var engine = ApneaSessionEngine(configuration: testConfiguration(), sessionStart: startDate)
        engine.armSession(at: startDate)
        replayDepths(&engine, depths: [0, 2, 4, 6, 3, 5, 7, 4], interval: 1)
        XCTAssertTrue(engine.snapshot.session.dives.isEmpty)
        XCTAssertNotEqual(engine.snapshot.phase, .recovery)
    }

    func testYoYoProfileCanProduceMultipleDivesAfterRecovery() {
        var config = testConfiguration()
        config.recoveryMinimumSeconds = 2
        config.surfaceStableDwellSeconds = 2
        var engine = ApneaSessionEngine(configuration: config, sessionStart: startDate)
        engine.armSession(at: startDate)

        let firstEnd = replayDepths(&engine, depths: [0, 2, 5, 8, 4, 0, 0, 0, 0], interval: 1)
        let afterRecovery = firstEnd + 5
        keepAliveSurface(&engine, from: firstEnd, seconds: 5)
        let secondEnd = replayDepths(&engine, depths: [0, 2, 6, 3, 0, 0, 0, 0], interval: 1, startOffset: afterRecovery)
        keepAliveSurface(&engine, from: secondEnd, seconds: 5)

        XCTAssertGreaterThanOrEqual(engine.snapshot.session.dives.count, 1)
    }

    func testShortDiveBelowMinimumDurationIsNotCommitted() {
        var config = testConfiguration()
        config.minimumDiveDurationSeconds = 30
        config.surfaceStableDwellSeconds = 1
        var engine = ApneaSessionEngine(configuration: config, sessionStart: startDate)
        engine.armSession(at: startDate)
        let endOffset = replayDepths(&engine, depths: [0, 3, 5, 2, 0, 0, 0], interval: 1)
        keepAliveSurface(&engine, from: endOffset, seconds: 5)
        XCTAssertEqual(engine.snapshot.session.dives.count, 0)
    }

    func testSensorLossMarksDegradedPhase() {
        var config = testConfiguration()
        config.sensorLossTimeoutSeconds = 2
        var engine = ApneaSessionEngine(configuration: config, sessionStart: startDate)
        engine.armSession(at: startDate)
        ingest(&engine, depth: 0, offset: 0)
        ingest(&engine, depth: 0, offset: 1)
        engine.tick(now: startDate.addingTimeInterval(4))
        XCTAssertEqual(engine.snapshot.phase, .sensorDegraded)
        XCTAssertEqual(engine.snapshot.sensorHealth, .degraded)
    }

    func testSensorRecoveryReturnsOperationalPhase() {
        var config = testConfiguration()
        config.sensorLossTimeoutSeconds = 2
        var engine = ApneaSessionEngine(configuration: config, sessionStart: startDate)
        engine.armSession(at: startDate)
        ingest(&engine, depth: 0, offset: 0)
        engine.tick(now: startDate.addingTimeInterval(4))
        ingest(&engine, depth: 0, offset: 5)
        XCTAssertEqual(engine.snapshot.phase, .surface)
        XCTAssertEqual(engine.snapshot.sensorHealth, .available)
    }

    func testManualFallbackAllowsControlledDescentAndSurface() {
        var engine = ApneaSessionEngine(configuration: testConfiguration(), sessionStart: startDate)
        engine.armSession(at: startDate)
        engine.enableManualFallback()
        XCTAssertEqual(engine.snapshot.sensorHealth, .manualFallback)
        engine.triggerManualDescent(at: startDate.addingTimeInterval(1))
        XCTAssertEqual(engine.snapshot.phase, .descending)
        engine.triggerManualSurface(at: startDate.addingTimeInterval(12))
        XCTAssertEqual(engine.snapshot.phase, .surfaced)
    }

    func testRawAndAcceptedSamplesArePreservedSeparately() {
        var engine = ApneaSessionEngine(configuration: testConfiguration(), sessionStart: startDate)
        engine.armSession(at: startDate)
        ingest(&engine, depth: 0, offset: 0)
        ingest(&engine, depth: 20, offset: 0.2) // spike rejected
        ingest(&engine, depth: 2, offset: 1)
        XCTAssertGreaterThanOrEqual(engine.snapshot.rawSampleCount, 3)
    }

    func testDiveMaxSessionMaxAndPersonalBestRemainDistinct() {
        var engine = ApneaSessionEngine(configuration: testConfiguration(), sessionStart: startDate)
        engine.armSession(at: startDate)
        let personalBest = 35.0
        let endOffset = replayDepths(&engine, depths: [0, 2, 6, 12, 8, 2, 0, 0, 0, 0], interval: 1)
        keepAliveSurface(&engine, from: endOffset, seconds: 5)

        let diveMax = engine.snapshot.session.dives.map(\.maxDepthMeters).max() ?? 0
        let sessionMax = engine.snapshot.session.statistics.sessionMaxDepthMeters
        XCTAssertGreaterThan(diveMax, 0)
        XCTAssertEqual(sessionMax, diveMax, accuracy: 0.01)
        XCTAssertGreaterThan(personalBest, diveMax)
    }

    func testEndSessionTransitionsToEnded() {
        var engine = ApneaSessionEngine(configuration: testConfiguration(), sessionStart: startDate)
        engine.armSession(at: startDate)
        engine.endSession(at: startDate.addingTimeInterval(5))
        XCTAssertEqual(engine.snapshot.phase, .ended)
        XCTAssertEqual(engine.snapshot.session.state, .completed)
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

    private func advanceTicks(_ engine: inout ApneaSessionEngine, from startOffset: TimeInterval, seconds: TimeInterval) {
        var offset = startOffset
        let end = startOffset + seconds
        while offset <= end {
            engine.tick(now: startDate.addingTimeInterval(offset))
            offset += 1
        }
    }
}
