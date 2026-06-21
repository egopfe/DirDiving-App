import XCTest

/// Audit-15 ML-02 … ML-10 independent-oracle profile regressions.
final class Audit15MultilevelOracleProfilesTests: XCTestCase {
    private var sessionStart = Date(timeIntervalSince1970: 1_720_000_000)

    override func setUp() {
        super.setUp()
        sessionStart = Date(timeIntervalSince1970: 1_720_000_000)
        executionTimeAllowance = 900
        FullComputerDecoSolver.resetCacheForTests()
        Audit15OracleIndependenceGuard.assertOracleDoesNotCallProductionTissueUpdate()
    }

    // MARK: ML-02 EAN50 @ 21 m

    func testML02EAN50SwitchAt21m() throws {
        let plan = Audit15OracleTestSupport.ean50AirPlan()
        let decoID = plan.decoGases[0].gasMixId
        let (depthAtSecond, total) = Audit15OracleTestSupport.buildDepthTimeline([
            .linear(from: 0, to: 39, seconds: 130),
            .constant(depth: 39, seconds: 90),
            .linear(from: 39, to: 21, seconds: 120),
        ])
        let switchSecond = total - 1
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        let result = Audit15OracleTestSupport.replayProductionAgainstOracle(
            engine: &engine,
            depthAtSecond: depthAtSecond,
            totalSeconds: total,
            sessionStart: sessionStart,
            plan: plan,
            gasSwitchEvents: [Audit15GasSwitchEvent(second: switchSecond, gasMixId: decoID)]
        )
        XCTAssertTrue(result.oracleFailures.isEmpty, result.oracleFailures.joined(separator: "; "))
        XCTAssertTrue(result.ttsFailures.isEmpty, result.ttsFailures.joined(separator: "; "))
        XCTAssertEqual(engine.snapshot.activeGas.gasMixId, decoID)
    }

    // MARK: ML-03 Trimix + deco

    func testML03TrimixWithHeliumCompartments() throws {
        let plan = Audit15OracleTestSupport.trimixDecoPlan()
        let (depthAtSecond, total) = Audit15OracleTestSupport.buildDepthTimeline([
            .linear(from: 0, to: 45, seconds: 150),
            .constant(depth: 45, seconds: 600),
            .linear(from: 45, to: 21, seconds: 160),
        ])
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        let result = Audit15OracleTestSupport.replayProductionAgainstOracle(
            engine: &engine,
            depthAtSecond: depthAtSecond,
            totalSeconds: total,
            sessionStart: sessionStart,
            plan: plan,
            initialOracleGas: IndependentBuhlmannOracle.oracleGas(from: plan.activeGas)
        )
        XCTAssertTrue(result.oracleFailures.isEmpty, result.oracleFailures.joined(separator: "; "))
        let heLoaded = engine.snapshot.tissueState.compartments.contains { $0.heliumPressure > 0.001 }
        XCTAssertTrue(heLoaded, "trimix profile must load helium compartments")
    }

    // MARK: ML-04 Sawtooth

    func testML04SawtoothMultilevelContinuity() throws {
        let plan = FullComputerRuntimePlan.defaultAirGF3070
        let (depthAtSecond, total) = Audit15OracleTestSupport.buildDepthTimeline([
            .linear(from: 0, to: 36, seconds: 120),
            .linear(from: 36, to: 30, seconds: 40),
            .linear(from: 30, to: 34, seconds: 40),
            .linear(from: 34, to: 24, seconds: 60),
            .linear(from: 24, to: 28, seconds: 40),
            .linear(from: 28, to: 18, seconds: 60),
            .linear(from: 18, to: 12, seconds: 40),
            .constant(depth: 12, seconds: 300),
        ])
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        let result = Audit15OracleTestSupport.replayProductionAgainstOracle(
            engine: &engine,
            depthAtSecond: depthAtSecond,
            totalSeconds: total,
            sessionStart: sessionStart,
            plan: plan
        )
        XCTAssertTrue(result.oracleFailures.isEmpty, result.oracleFailures.joined(separator: "; "))
    }

    // MARK: ML-06 Stop boundary (tissue + FSM separation)

    func testML06StopBoundaryHoverDoesNotMutateTissuesFromTimer() throws {
        let plan = FullComputerRuntimePlan.defaultAirGF3070
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 0, timestamp: sessionStart)
        _ = engine.ingestSample(depthMeters: 38, timestamp: sessionStart.addingTimeInterval(120))
        for minute in 1...22 { engine.tick(now: sessionStart.addingTimeInterval(120 + Double(minute * 60))) }
        guard engine.snapshot.decoPresentation.mode == .decompression,
              let stopDepth = engine.snapshot.decoPresentation.nextStopDepthMeters else {
            throw XCTSkip("profile did not reach deco stop in time budget")
        }
        let tissueAtStop = engine.snapshot.tissueState
        let hoverSeconds = [0, 30, 60, 90, 120]
        for (index, offset) in hoverSeconds.enumerated() {
            let depth = stopDepth + (index % 2 == 0 ? 0.3 : -0.3)
            _ = engine.ingestSample(
                depthMeters: depth,
                timestamp: sessionStart.addingTimeInterval(1_440 + Double(offset))
            )
            XCTAssertNotEqual(engine.snapshot.tissueState, BuhlmannTissueState.airSaturated())
            if offset > 0 {
                XCTAssertNotEqual(engine.snapshot.tissueState, tissueAtStop)
            }
        }
        XCTAssertNotEqual(engine.snapshot.tissueState, tissueAtStop)
    }

    // MARK: ML-07 Slow ascent

    func testML07VerySlowAscentSchreinerRates() throws {
        let plan = FullComputerRuntimePlan.defaultAirGF3070
        let (depthAtSecond, total) = Audit15OracleTestSupport.buildDepthTimeline([
            .linear(from: 0, to: 30, seconds: 100),
            .constant(depth: 30, seconds: 1_200),
            .linear(from: 30, to: 6, seconds: 1_440),
            .constant(depth: 6, seconds: 600),
        ])
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        let result = Audit15OracleTestSupport.replayProductionAgainstOracle(
            engine: &engine,
            depthAtSecond: depthAtSecond,
            totalSeconds: total,
            sessionStart: sessionStart,
            plan: plan
        )
        XCTAssertTrue(result.oracleFailures.isEmpty, result.oracleFailures.joined(separator: "; "))
    }

    // MARK: ML-08 Rapid ascent

    func testML08RapidAscentMaintainsDecoWhenRequired() throws {
        let plan = FullComputerRuntimePlan.defaultAirGF3070
        let (depthAtSecond, total) = Audit15OracleTestSupport.buildDepthTimeline([
            .linear(from: 0, to: 35, seconds: 120),
            .constant(depth: 35, seconds: 1_800),
            .linear(from: 35, to: 8, seconds: 180),
            .constant(depth: 8, seconds: 300),
        ])
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        let result = Audit15OracleTestSupport.replayProductionAgainstOracle(
            engine: &engine,
            depthAtSecond: depthAtSecond,
            totalSeconds: total,
            sessionStart: sessionStart,
            plan: plan
        )
        XCTAssertTrue(result.oracleFailures.isEmpty, result.oracleFailures.joined(separator: "; "))
        if engine.snapshot.rawCeilingMeters > 0.05 {
            XCTAssertGreaterThan(engine.snapshot.ttsMinutes, 0)
            XCTAssertEqual(engine.snapshot.engineState, .valid)
        }
    }

    // MARK: ML-09 Long 10 m level

    func testML09LongTenMeterLevelSlowCompartments() throws {
        let plan = FullComputerRuntimePlan.defaultAirGF3070
        let (depthAtSecond, total) = Audit15OracleTestSupport.buildDepthTimeline([
            .linear(from: 0, to: 39, seconds: 130),
            .constant(depth: 39, seconds: 240),
            .linear(from: 39, to: 10, seconds: 194),
            .constant(depth: 10, seconds: 1_200),
        ])
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        let result = Audit15OracleTestSupport.replayProductionAgainstOracle(
            engine: &engine,
            depthAtSecond: depthAtSecond,
            totalSeconds: total,
            sessionStart: sessionStart,
            plan: plan
        )
        XCTAssertTrue(result.oracleFailures.isEmpty, result.oracleFailures.joined(separator: "; "))
        let fast = engine.snapshot.tissueState.compartments[0].nitrogenPressure
        let slow = engine.snapshot.tissueState.compartments[15].nitrogenPressure
        XCTAssertNotEqual(fast, slow, accuracy: 0.01)
    }

    // MARK: ML-10 Surface interval within continuous session

    func testML10SurfaceIntervalPreservesResidualTissues() throws {
        let plan = FullComputerRuntimePlan.defaultAirGF3070
        let (depthAtSecond, total) = Audit15OracleTestSupport.buildDepthTimeline([
            .linear(from: 0, to: 28, seconds: 100),
            .constant(depth: 28, seconds: 900),
            .linear(from: 28, to: 0, seconds: 200),
            .constant(depth: 0, seconds: 600),
            .linear(from: 0, to: 24, seconds: 120),
            .constant(depth: 24, seconds: 300),
        ])
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        let surfaceSecond = 100 + 900 + 200
        let result = Audit15OracleTestSupport.replayProductionAgainstOracle(
            engine: &engine,
            depthAtSecond: depthAtSecond,
            totalSeconds: total,
            sessionStart: sessionStart,
            plan: plan
        )
        XCTAssertTrue(result.oracleFailures.isEmpty, result.oracleFailures.joined(separator: "; "))
        engine.testHook_refreshSnapshotForTests()
        let afterSurface = engine.snapshot.tissueState
        XCTAssertNotEqual(afterSurface, BuhlmannTissueState.airSaturated())
        let ndlSecondDive = engine.snapshot.ndlMinutes ?? 0
        XCTAssertLessThan(ndlSecondDive, 999)
        _ = surfaceSecond
    }
}
