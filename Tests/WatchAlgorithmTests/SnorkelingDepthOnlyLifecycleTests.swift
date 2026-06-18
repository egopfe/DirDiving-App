import XCTest

final class SnorkelingDepthOnlyLifecycleTests: XCTestCase {
    private var startDate = Date(timeIntervalSince1970: 1_700_000_000)

    override func setUp() {
        super.setUp()
        startDate = Date(timeIntervalSince1970: 1_700_000_000)
    }

    func testEngineDepthOnlySessionWithoutGPS() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        replayDepths(&engine, depths: [0.2, 0.6, 1.0, 1.5, 1.2, 0.3, 0.1, 0.1], interval: 2, gps: nil)
        engine.endSession(at: startDate.addingTimeInterval(20))

        XCTAssertEqual(engine.snapshot.dipCount, 1)
        XCTAssertGreaterThan(engine.snapshot.sessionMaxDepthMeters, 1)
        XCTAssertEqual(engine.snapshot.accumulatedDistanceMeters, 0)
        XCTAssertEqual(engine.snapshot.gpsPresentationState, .unavailable)
        XCTAssertTrue(engine.snapshot.session.trackPoints.isEmpty)
        XCTAssertFalse(engine.snapshot.session.trackPoints.contains { $0.latitude != nil && $0.isUnderwater })
        XCTAssertGreaterThan(engine.snapshot.session.dips.first?.samples.count ?? 0, 0)
        var auditProbe = engine
        XCTAssertGreaterThan(auditProbe.exportCheckpoint().depthFeedState.rawAuditTrail.count, 0)
        XCTAssertNoThrow(try validateSession(engine.snapshot.session))
    }

    func testMultipleDipsWithoutGPS() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        replayDepths(
            &engine,
            depths: [0.2, 0.8, 1.4, 0.2, 0.1, 0.2, 0.9, 1.3, 0.2, 0.1],
            interval: 3,
            gps: nil
        )
        XCTAssertGreaterThanOrEqual(engine.snapshot.dipCount, 2)
        XCTAssertEqual(engine.snapshot.accumulatedDistanceMeters, 0)
    }

    func testSensorDegradedDepthOnlySessionDoesNotFabricateGPS() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.2, offset: 0)
        ingest(&engine, depth: 1.0, offset: 2)
        engine.tick(now: startDate.addingTimeInterval(20))
        XCTAssertEqual(engine.snapshot.phase, .sensorDegraded)
        XCTAssertTrue(engine.snapshot.session.trackPoints.isEmpty)
        XCTAssertEqual(engine.snapshot.accumulatedDistanceMeters, 0)
    }

    func testNoGPSSessionDistanceRemainsZero() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        replayDepths(&engine, depths: [0.2, 0.8, 1.2, 0.2, 0.1], interval: 2, gps: nil)
        XCTAssertEqual(engine.snapshot.accumulatedDistanceMeters, 0)
        XCTAssertEqual(engine.snapshot.session.statistics.totalDistanceMeters, 0)
    }

    func testNoGPSSessionCheckpointRoundTrip() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        replayDepths(&engine, depths: [0.2, 0.8, 1.2], interval: 2, gps: nil)
        let checkpoint = engine.exportCheckpoint(now: startDate.addingTimeInterval(6))
        var restored = SnorkelingSessionEngine(checkpoint: checkpoint)
        XCTAssertEqual(restored.snapshot.phase, .dipping)
        XCTAssertEqual(restored.snapshot.accumulatedDistanceMeters, 0)
        XCTAssertTrue(restored.snapshot.session.trackPoints.isEmpty)
    }

    func testGPSMayResumeLaterWithoutRewritingEarlierUnderwaterTrack() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        replayDepths(&engine, depths: [0.2, 1.0, 1.2, 0.2, 0.1], interval: 2, gps: nil)
        let underwaterTrackCount = engine.snapshot.session.trackPoints.filter(\.isUnderwater).count
        ingest(
            &engine,
            depth: 0.1,
            offset: 12,
            gps: gpsFix(offset: 12)
        )
        XCTAssertEqual(underwaterTrackCount, 0)
        XCTAssertGreaterThan(engine.snapshot.session.trackPoints.count, 0)
        XCTAssertEqual(engine.snapshot.session.trackPoints.last?.gpsQuality, .measured)
    }

    // MARK: - Helpers

    private func makeEngine() -> SnorkelingSessionEngine {
        var config = SnorkelingLifecycleConfiguration.default
        config.dipStartDebounceSeconds = 0.8
        config.surfaceStableDwellSeconds = 2
        config.minimumDipDurationSeconds = 2
        return SnorkelingSessionEngine(configuration: config, sessionStart: startDate)
    }

    private func replayDepths(
        _ engine: inout SnorkelingSessionEngine,
        depths: [Double],
        interval: TimeInterval,
        gps: SnorkelingGPSRawFix? = nil
    ) {
        for (index, depth) in depths.enumerated() {
            ingest(&engine, depth: depth, offset: TimeInterval(index) * interval, gps: gps)
        }
        if let last = depths.indices.last {
            engine.tick(now: startDate.addingTimeInterval(TimeInterval(last) * interval + interval))
        }
    }

    private func ingest(
        _ engine: inout SnorkelingSessionEngine,
        depth: Double,
        offset: TimeInterval,
        gps: SnorkelingGPSRawFix? = nil
    ) {
        let timestamp = startDate.addingTimeInterval(offset)
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

    private func gpsFix(offset: TimeInterval) -> SnorkelingGPSRawFix {
        SnorkelingGPSRawFix(
            latitude: 44.40012,
            longitude: 8.94012,
            horizontalAccuracyMeters: 8,
            sensorTimestamp: startDate.addingTimeInterval(offset),
            receivedAt: startDate.addingTimeInterval(offset),
            source: .replay
        )
    }
}

private func validateSession(_ session: SnorkelingSession) throws {
    let issues = SnorkelingDomainValidator.validate(session: session)
    if !issues.isEmpty {
        throw NSError(domain: "SnorkelingDomainValidator", code: 1, userInfo: [
            NSLocalizedDescriptionKey: issues.map { String(describing: $0) }.joined(separator: ", ")
        ])
    }
}
