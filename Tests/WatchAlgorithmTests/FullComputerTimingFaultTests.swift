import XCTest

/// Deterministic timing-fault coverage for Full Computer tissue integration.
final class FullComputerTimingFaultTests: XCTestCase {
    private var sessionStart = Date(timeIntervalSince1970: 1_713_000_000)

    override func setUp() {
        super.setUp()
        sessionStart = Date(timeIntervalSince1970: 1_713_000_000)
        FullComputerDecoSolver.resetCacheForTests()
    }

    func testTimingFaultMatrix() throws {
        let deltas: [TimeInterval] = [0.5, 1.0, 1.5, 2, 5, 10, 30]
        for delta in deltas {
            var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
            _ = engine.ingestSample(depthMeters: 22, timestamp: sessionStart)
            let before = engine.snapshot.tissueState.compartments[0].nitrogenPressure
            engine.tick(now: sessionStart.addingTimeInterval(delta))
            let after = engine.snapshot.tissueState.compartments[0].nitrogenPressure
            if delta > 0 {
                XCTAssertGreaterThan(after, before, "delta \(delta)s should load tissues")
            }
        }
    }

    func testDuplicateTimestampDoesNotDoubleIntegrate() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        let t = sessionStart.addingTimeInterval(10)
        XCTAssertTrue(engine.ingestSample(depthMeters: 12, timestamp: t))
        let tissueAfterFirst = engine.snapshot.tissueState
        XCTAssertTrue(engine.ingestSample(depthMeters: 13, timestamp: t))
        XCTAssertEqual(engine.snapshot.tissueState, tissueAfterFirst)
    }

    func testOutOfOrderTimestampRejected() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 12, timestamp: sessionStart.addingTimeInterval(20))
        XCTAssertFalse(engine.ingestSample(depthMeters: 11, timestamp: sessionStart.addingTimeInterval(10)))
    }

    func testMissedTickMarksDegradedWithoutTissueReset() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 24, timestamp: sessionStart)
        let loaded = engine.snapshot.tissueState
        engine.tick(now: sessionStart.addingTimeInterval(45))
        XCTAssertEqual(engine.snapshot.engineState, .degraded)
        XCTAssertNotEqual(engine.snapshot.tissueState, BuhlmannTissueState.airSaturated())
        XCTAssertGreaterThan(
            engine.snapshot.tissueState.compartments[0].nitrogenPressure,
            loaded.compartments[0].nitrogenPressure
        )
    }

    func testRestorePreservesTimingContinuity() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 18, timestamp: sessionStart.addingTimeInterval(300))
        let tissueBefore = engine.snapshot.tissueState
        let checkpoint = try engine.exportCheckpoint(sessionID: UUID(), watchDivingMode: DIRDivingMode.fullComputer.rawValue)
        let decoded = try FullComputerRuntimeCheckpointCodec.decode(try FullComputerRuntimeCheckpointCodec.encode(checkpoint))
        var restored = try FullComputerRuntimeEngine.restoreEngine(from: decoded, sessionStart: sessionStart)
        XCTAssertEqual(restored.snapshot.tissueState, tissueBefore)
        _ = restored.ingestSample(depthMeters: 18, timestamp: sessionStart.addingTimeInterval(301))
        XCTAssertGreaterThan(
            restored.snapshot.tissueState.compartments[0].nitrogenPressure,
            tissueBefore.compartments[0].nitrogenPressure
        )
    }
}
