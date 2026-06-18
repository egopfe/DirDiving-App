import XCTest

final class SnorkelingLifecycleEngineTests: XCTestCase {
    private var startDate = Date(timeIntervalSince1970: 1_700_000_000)

    override func setUp() {
        super.setUp()
        startDate = Date(timeIntervalSince1970: 1_700_000_000)
    }

    // MARK: - State machine

    func testStateMachineStartsDipAfterDebounce() {
        var tracker = SnorkelingLifecycleTracker.initial
        tracker.phase = .surfaceActive
        let config = testConfiguration()
        var now: TimeInterval = 0
        var output = SnorkelingLifecycleStateMachine.evaluate(
            input: machineInput(config: config, monotonicNow: now, depth: 0.2, feedAccepted: true),
            tracker: tracker
        )
        XCTAssertEqual(output.tracker.phase, .surfaceActive)
        now = 1.0
        output = SnorkelingLifecycleStateMachine.evaluate(
            input: machineInput(config: config, monotonicNow: now, depth: 0.8, feedAccepted: true),
            tracker: output.tracker
        )
        XCTAssertEqual(output.tracker.phase, .surfaceActive)
        now = 1.9
        output = SnorkelingLifecycleStateMachine.evaluate(
            input: machineInput(config: config, monotonicNow: now, depth: 0.9, feedAccepted: true),
            tracker: output.tracker
        )
        XCTAssertEqual(output.tracker.phase, .dipping)
        XCTAssertTrue(output.events.contains(where: {
            if case .dipStarted = $0 { return true }
            return false
        }))
    }

    func testStateMachineFinishesDipAfterSurfaceDwell() {
        var tracker = SnorkelingLifecycleTracker.initial
        tracker.phase = .resurfacing
        tracker.dipStartedAt = 0
        tracker.dipMaxDepthMeters = 3
        tracker.surfaceDwellSince = 8
        let output = SnorkelingLifecycleStateMachine.evaluate(
            input: machineInput(config: testConfiguration(), monotonicNow: 10.5, depth: 0.2, feedAccepted: true),
            tracker: tracker
        )
        XCTAssertEqual(output.tracker.phase, .surfaceActive)
        XCTAssertTrue(output.events.contains(where: {
            if case .dipEnded = $0 { return true }
            return false
        }))
    }

    func testStateMachineManualDipEndFromDipping() {
        var tracker = SnorkelingLifecycleTracker.initial
        tracker.phase = .dipping
        tracker.dipStartedAt = 0
        let input = machineInput(
            config: testConfiguration(),
            monotonicNow: 5,
            depth: 2,
            feedAccepted: true,
            manualFallback: true,
            manualDipEnd: true
        )
        let output = SnorkelingLifecycleStateMachine.evaluate(input: input, tracker: tracker)
        XCTAssertEqual(output.tracker.phase, .resurfacing)
    }

    // MARK: - Engine

    func testEngineShortSessionSingleDip() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        replayDepths(&engine, depths: [0.2, 0.6, 1.2, 1.8, 1.0, 0.2, 0.1], interval: 2)
        engine.endSession(at: startDate.addingTimeInterval(20))
        XCTAssertEqual(engine.snapshot.dipCount, 1)
        XCTAssertGreaterThan(engine.snapshot.sessionMaxDepthMeters, 1)
        XCTAssertEqual(engine.snapshot.session.state, .completed)
    }

    func testEngineMultipleDips() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        replayDepths(&engine, depths: [0.2, 0.8, 1.5, 0.2, 0.1, 0.2, 0.9, 1.4, 0.2, 0.1], interval: 3)
        XCTAssertGreaterThanOrEqual(engine.snapshot.dipCount, 2)
    }

    func testEngineSurfaceOscillationDoesNotPrematurelyCloseDip() {
        var config = testConfiguration()
        config.surfaceStableDwellSeconds = 3
        var engine = makeEngine(configuration: config)
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        replayDepths(&engine, depths: [0.2, 0.9, 1.4, 0.45, 1.2, 0.2], interval: 2)
        XCTAssertEqual(engine.snapshot.dipCount, 0)
        XCTAssertTrue([.dipping, .resurfacing].contains(engine.snapshot.phase))
    }

    func testEngineSensorLossEntersDegradedPhase() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.2, offset: 0)
        ingest(&engine, depth: 1.0, offset: 2)
        engine.tick(now: startDate.addingTimeInterval(20))
        XCTAssertEqual(engine.snapshot.phase, .sensorDegraded)
        XCTAssertEqual(engine.snapshot.sensorHealth, .degraded)
    }

    func testEngineManualFallbackDipControl() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        engine.enableManualFallback()
        engine.triggerManualDipStart(at: startDate.addingTimeInterval(1))
        XCTAssertEqual(engine.snapshot.phase, .dipping)
        engine.triggerManualDipEnd(at: startDate.addingTimeInterval(6))
        ingest(&engine, depth: 0.1, offset: 8)
        ingest(&engine, depth: 0.1, offset: 11)
        XCTAssertEqual(engine.snapshot.dipCount, 1)
        XCTAssertEqual(engine.snapshot.sensorHealth, .manualFallback)
    }

    func testEngineSuspendResumePreservesDipState() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        replayDepths(&engine, depths: [0.2, 0.8, 1.4], interval: 2)
        let checkpoint = engine.exportCheckpoint(now: startDate.addingTimeInterval(6))
        var restored = SnorkelingSessionEngine(checkpoint: checkpoint)
        XCTAssertEqual(restored.snapshot.phase, .dipping)
        ingest(&restored, depth: 1.2, offset: 8, base: startDate.addingTimeInterval(6))
        ingest(&restored, depth: 0.2, offset: 10, base: startDate.addingTimeInterval(6))
        ingest(&restored, depth: 0.1, offset: 13, base: startDate.addingTimeInterval(6))
        XCTAssertEqual(restored.snapshot.dipCount, 1)
    }

    func testEngineWaterDetectionStartsInDip() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        ingest(&engine, depth: 1.0, offset: 0)
        engine.startSession(at: startDate)
        XCTAssertEqual(engine.snapshot.phase, .dipping)
    }

    func testEngineNavigationAndReturnModes() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.2, offset: 0, gps: gpsFix(offset: 0))
        engine.enterNavigation(at: startDate.addingTimeInterval(1))
        XCTAssertEqual(engine.snapshot.phase, .navigation)
        XCTAssertEqual(engine.snapshot.session.state, .navigation)
        engine.enterReturnMode(at: startDate.addingTimeInterval(2))
        XCTAssertEqual(engine.snapshot.phase, .returnMode)
        engine.exitNavigationOrReturn(at: startDate.addingTimeInterval(3))
        XCTAssertEqual(engine.snapshot.phase, .surfaceActive)
    }

    func testEnginePauseAndResume() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.2, offset: 0)
        engine.pauseSession(at: startDate.addingTimeInterval(1))
        XCTAssertEqual(engine.snapshot.phase, .paused)
        engine.resumeSession(at: startDate.addingTimeInterval(2))
        XCTAssertEqual(engine.snapshot.phase, .surfaceActive)
    }

    func testEngineLongSessionAccumulatesWaterTime() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        replayDepths(&engine, depths: [0.2, 1.0, 1.6, 1.2, 0.2, 0.1, 0.2, 0.8, 1.1, 0.2, 0.1], interval: 4)
        XCTAssertGreaterThan(engine.snapshot.waterTimeSeconds, 5)
        XCTAssertGreaterThan(engine.snapshot.sessionElapsedSeconds, engine.snapshot.surfaceElapsedSeconds)
    }

    func testEngineGPSConcurrentIngestionBuildsTrack() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        for second in stride(from: 0, through: 10, by: 2) {
            ingest(
                &engine,
                depth: second < 6 ? 0.2 : 1.2,
                offset: TimeInterval(second),
                gps: gpsFix(offset: TimeInterval(second), latOffset: Double(second) * 0.00001)
            )
        }
        XCTAssertGreaterThan(engine.snapshot.session.trackPoints.count, 0)
        XCTAssertTrue(engine.snapshot.session.trackPoints.contains { $0.isUnderwater })
    }

    func testEngineAutoEndOutOfWater() {
        var config = testConfiguration()
        config.autoEndOutOfWaterSeconds = 10
        var engine = makeEngine(configuration: config)
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.2, offset: 0)
        ingest(&engine, depth: 0.2, offset: 8)
        engine.tick(now: startDate.addingTimeInterval(12))
        XCTAssertEqual(engine.snapshot.phase, .ended)
    }

    // MARK: - Helpers

    private func makeEngine(configuration: SnorkelingLifecycleConfiguration? = nil) -> SnorkelingSessionEngine {
        SnorkelingSessionEngine(configuration: configuration ?? testConfiguration(), sessionStart: startDate)
    }

    private func testConfiguration() -> SnorkelingLifecycleConfiguration {
        var config = SnorkelingLifecycleConfiguration.default
        config.dipStartDebounceSeconds = 0.8
        config.surfaceStableDwellSeconds = 2
        config.minimumDipDurationSeconds = 2
        config.sensorLossTimeoutSeconds = 8
        return config
    }

    private func machineInput(
        config: SnorkelingLifecycleConfiguration,
        monotonicNow: TimeInterval,
        depth: Double,
        feedAccepted: Bool,
        manualFallback: Bool = false,
        manualDipStart: Bool = false,
        manualDipEnd: Bool = false
    ) -> SnorkelingLifecycleMachineInput {
        SnorkelingLifecycleMachineInput(
            configuration: config,
            monotonicNow: monotonicNow,
            wallClockNow: startDate.addingTimeInterval(monotonicNow),
            acceptedDepthMeters: depth,
            verticalSpeedMetersPerSecond: 0,
            feedAccepted: feedAccepted,
            sensorAvailable: !manualFallback,
            manualFallbackActive: manualFallback,
            manualDipStartTriggered: manualDipStart,
            manualDipEndTriggered: manualDipEnd,
            sessionArmed: true,
            sessionStarted: true,
            navigationRequested: false,
            returnModeRequested: false,
            exitNavigationRequested: false,
            pauseRequested: false,
            resumeRequested: false,
            endSessionRequested: false,
            tickOnly: false
        )
    }

    private func replayDepths(_ engine: inout SnorkelingSessionEngine, depths: [Double], interval: TimeInterval) {
        for (index, depth) in depths.enumerated() {
            ingest(&engine, depth: depth, offset: TimeInterval(index) * interval)
        }
        if let lastOffset = depths.indices.last.map({ TimeInterval($0) * interval }) {
            engine.tick(now: startDate.addingTimeInterval(lastOffset + interval))
        }
    }

    private func ingest(
        _ engine: inout SnorkelingSessionEngine,
        depth: Double,
        offset: TimeInterval,
        gps: SnorkelingGPSRawFix? = nil,
        base: Date? = nil
    ) {
        let baseDate = base ?? startDate
        let timestamp = baseDate.addingTimeInterval(offset)
        engine.ingest(
            depthRaw: DepthMeasurementRaw(
                depthMeters: depth,
                sensorTimestamp: timestamp,
                receivedAt: timestamp,
                temperatureCelsius: 24
            ),
            gpsRaw: gps,
            wallClock: timestamp
        )
    }

    private func gpsFix(offset: TimeInterval, latOffset: Double = 0) -> SnorkelingGPSRawFix {
        SnorkelingGPSRawFix(
            latitude: 44.40000 + latOffset,
            longitude: 8.94000,
            horizontalAccuracyMeters: 8,
            sensorTimestamp: startDate.addingTimeInterval(offset),
            receivedAt: startDate.addingTimeInterval(offset),
            source: .replay
        )
    }
}
