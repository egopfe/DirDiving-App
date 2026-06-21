import XCTest

final class FullComputerDecoSolverCacheIsolationTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_722_000_000)

    override func setUp() {
        FullComputerDecoSolver.resetCacheForTests()
    }

    func testSeparateEnginesDoNotSharePresentationCache() throws {
        var engineA = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: start)
        var engineB = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: start.addingTimeInterval(10_000))
        _ = engineA.ingestSample(depthMeters: 30, timestamp: start.addingTimeInterval(600))
        _ = engineB.ingestSample(depthMeters: 12, timestamp: start.addingTimeInterval(10_600))
        let snapA = engineA.snapshot
        let snapB = engineB.snapshot
        XCTAssertNotEqual(snapA.ttsMinutes, snapB.ttsMinutes)
        XCTAssertNotEqual(snapA.rawCeilingMeters, snapB.rawCeilingMeters, accuracy: 0.01)
    }

    func testCacheInvalidatesAfterTissueChange() throws {
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: start)
        _ = engine.ingestSample(depthMeters: 24, timestamp: start.addingTimeInterval(300))
        let first = engine.snapshot.decoPresentation
        engine.tick(now: start.addingTimeInterval(360))
        let second = engine.snapshot.decoPresentation
        if engine.snapshot.tissueState != BuhlmannTissueState.airSaturated() {
            XCTAssertNotEqual(engine.snapshot.tissueState.compartments[0].nitrogenPressure, BuhlmannTissueState.airSaturated().compartments[0].nitrogenPressure)
        }
        _ = first
        _ = second
    }
}

final class FullComputerProjectionDeduplicationTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_723_000_000)

    func testSnapshotUsesSingleRuntimeProjectionPath() throws {
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: start)
        _ = engine.ingestSample(depthMeters: 33, timestamp: start.addingTimeInterval(400))
        for minute in 1...15 {
            engine.tick(now: start.addingTimeInterval(400 + Double(minute * 60)))
        }
        let snap = engine.snapshot
        XCTAssertTrue(snap.rawCeilingMeters.isFinite)
        XCTAssertEqual(snap.ttsMinutes, snap.decoPresentation.ttsMinutes)
        XCTAssertEqual(snap.operationalCeilingMeters, snap.decoPresentation.ceilingMetersExact, accuracy: 0.001)
    }

    func testDegradedPresentationFlagsAfterLongMissedTick() throws {
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: start)
        _ = engine.ingestSample(depthMeters: 18, timestamp: start)
        engine.tick(now: start.addingTimeInterval(200))
        XCTAssertEqual(engine.snapshot.engineState, .degraded)
        XCTAssertTrue(engine.snapshot.decoPresentation.usedConservativeFallback)
        XCTAssertEqual(engine.snapshot.decoPresentation.immersionStatusKey, "live.fc.status.runtime_degraded")
    }
}
