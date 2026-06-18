import XCTest

final class SnorkelingCheckpointFoundationTests: XCTestCase {
    private let startDate = Date(timeIntervalSince1970: 1_700_000_000)

    func testCheckpointRoundTripPreservesDepthOnlySession() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.2, offset: 0)
        ingest(&engine, depth: 0.8, offset: 2)
        ingest(&engine, depth: 1.0, offset: 4)
        let checkpoint = engine.exportCheckpoint(now: startDate.addingTimeInterval(6))
        var restored = SnorkelingSessionEngine(checkpoint: checkpoint)
        XCTAssertEqual(restored.snapshot.session.id, checkpoint.session.id)
        XCTAssertEqual(restored.snapshot.phase, .dipping)
        XCTAssertEqual(restored.snapshot.accumulatedDistanceMeters, 0)
    }

    func testCheckpointRoundTripPreservesActiveDip() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.2, offset: 0)
        ingest(&engine, depth: 1.2, offset: 2)
        ingest(&engine, depth: 1.4, offset: 4)
        let checkpoint = engine.exportCheckpoint(now: startDate.addingTimeInterval(4))
        var restored = SnorkelingSessionEngine(checkpoint: checkpoint)
        XCTAssertEqual(restored.snapshot.phase, .dipping)
        XCTAssertGreaterThan(restored.snapshot.activeDipSampleCount, 0)
    }

    func testCheckpointRoundTripPreservesMultipleDips() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        replay(&engine, depths: [0.2, 0.8, 1.4, 0.2, 0.1, 0.2, 0.9, 1.3, 0.2, 0.1], interval: 3)
        XCTAssertGreaterThanOrEqual(engine.snapshot.dipCount, 2)
        let checkpoint = engine.exportCheckpoint(now: startDate.addingTimeInterval(35))
        let restored = SnorkelingSessionEngine(checkpoint: checkpoint)
        XCTAssertEqual(restored.snapshot.dipCount, engine.snapshot.dipCount)
    }

    func testCheckpointRoundTripPreservesGPSBridgeState() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.2, offset: 0, gps: gps(offset: 0))
        ingest(&engine, depth: 0.2, offset: 5, gps: gps(offset: 5, lat: 44.40012))
        let checkpoint = engine.exportCheckpoint(now: startDate.addingTimeInterval(5))
        var restored = SnorkelingSessionEngine(checkpoint: checkpoint)
        XCTAssertGreaterThan(restored.snapshot.accumulatedDistanceMeters, 0)
        XCTAssertNotNil(restored.exportCheckpoint().gpsFeedState.lastAcceptedFix)
    }

    func testCheckpointRoundTripPreservesSensorDegradedState() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.2, offset: 0)
        engine.tick(now: startDate.addingTimeInterval(20))
        XCTAssertEqual(engine.snapshot.phase, .sensorDegraded)
        let checkpoint = engine.exportCheckpoint(now: startDate.addingTimeInterval(20))
        var restored = SnorkelingSessionEngine(checkpoint: checkpoint)
        XCTAssertEqual(restored.snapshot.phase, .sensorDegraded)
        XCTAssertEqual(restored.exportCheckpoint().manualFallbackActive, false)
    }

    func testRepeatedCheckpointRestoreIsDeterministic() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.8, offset: 0)
        ingest(&engine, depth: 1.2, offset: 2)
        let checkpointTime = startDate.addingTimeInterval(4)
        let first = engine.exportCheckpoint(now: checkpointTime)
        var restoredA = SnorkelingSessionEngine(checkpoint: first)
        var restoredB = SnorkelingSessionEngine(checkpoint: first)
        XCTAssertEqual(
            restoredA.exportCheckpoint(now: checkpointTime),
            restoredB.exportCheckpoint(now: checkpointTime)
        )
    }

    func testCheckpointDoesNotIntroduceForeignRuntimeState() throws {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 1.0, offset: 0)
        let checkpoint = engine.exportCheckpoint(now: startDate.addingTimeInterval(2))
        let encoded = try JSONEncoder().encode(checkpoint)
        let json = String(data: encoded, encoding: .utf8) ?? ""
        XCTAssertFalse(json.contains("DiveManager"))
        XCTAssertFalse(json.contains("ApneaSessionEngine"))
        XCTAssertFalse(json.contains("ExplorationStore"))
    }

    // MARK: - Helpers

    private func makeEngine() -> SnorkelingSessionEngine {
        var config = SnorkelingLifecycleConfiguration.default
        config.dipStartDebounceSeconds = 0.8
        config.surfaceStableDwellSeconds = 2
        config.minimumDipDurationSeconds = 2
        config.sensorLossTimeoutSeconds = 8
        return SnorkelingSessionEngine(configuration: config, sessionStart: startDate)
    }

    private func replay(_ engine: inout SnorkelingSessionEngine, depths: [Double], interval: TimeInterval) {
        for (index, depth) in depths.enumerated() {
            ingest(&engine, depth: depth, offset: TimeInterval(index) * interval)
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
            depthRaw: DepthMeasurementRaw(depthMeters: depth, sensorTimestamp: timestamp, receivedAt: timestamp),
            gpsRaw: gps,
            wallClock: timestamp
        )
    }

    private func gps(offset: TimeInterval, lat: Double = 44.40000) -> SnorkelingGPSRawFix {
        SnorkelingGPSRawFix(
            latitude: lat,
            longitude: 8.94000,
            horizontalAccuracyMeters: 8,
            sensorTimestamp: startDate.addingTimeInterval(offset),
            receivedAt: startDate.addingTimeInterval(offset),
            source: .replay
        )
    }
}
