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
            var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
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
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
        let t = sessionStart.addingTimeInterval(10)
        XCTAssertTrue(engine.ingestSample(depthMeters: 12, timestamp: t))
        let tissueAfterFirst = engine.snapshot.tissueState
        XCTAssertTrue(engine.ingestSample(depthMeters: 13, timestamp: t))
        XCTAssertEqual(engine.snapshot.tissueState, tissueAfterFirst)
    }

    func testOutOfOrderTimestampRejected() throws {
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 12, timestamp: sessionStart.addingTimeInterval(20))
        XCTAssertFalse(engine.ingestSample(depthMeters: 11, timestamp: sessionStart.addingTimeInterval(10)))
    }

    func testMissedTickMarksDegradedWithoutTissueReset() throws {
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
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
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
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

    func testLongSuspensionIntegratesFullElapsedAndMarksDegraded() throws {
        let gaps: [TimeInterval] = [121, 300, 600, 1_800]
        for gap in gaps {
            var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
            _ = engine.ingestSample(depthMeters: 20, timestamp: sessionStart)
            let before = engine.snapshot.tissueState.compartments[0].nitrogenPressure
            engine.tick(now: sessionStart.addingTimeInterval(gap))
            XCTAssertEqual(engine.snapshot.engineState, .degraded)
            XCTAssertTrue(engine.snapshot.diagnostics.contains(where: { $0.hasPrefix("missed_tick:") }))
            XCTAssertGreaterThan(engine.snapshot.tissueState.compartments[0].nitrogenPressure, before)
            if gap > 120 {
                XCTAssertTrue(engine.snapshot.decoPresentation.usedConservativeFallback)
            }
        }
    }

    func testLongSuspensionDoesNotFalseClearDeco() throws {
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 36, timestamp: sessionStart)
        for minute in 1...20 { engine.tick(now: sessionStart.addingTimeInterval(Double(minute * 60))) }
        let requiredDeco = engine.snapshot.rawCeilingMeters > 0.05 || (engine.snapshot.ndlMinutes ?? 999) <= 0
        guard requiredDeco else { throw XCTSkip("no deco in setup") }
        engine.tick(now: sessionStart.addingTimeInterval(1_500))
        let oracleCeiling = engine.snapshot.tissueState.ceiling(
            gf: 0.30,
            environment: engine.runtimePlan.plannerEnvironment
        ).depthMeters
        if oracleCeiling > 0.05 {
            XCTAssertGreaterThan(engine.snapshot.rawCeilingMeters, 0.01)
        }
    }
}
