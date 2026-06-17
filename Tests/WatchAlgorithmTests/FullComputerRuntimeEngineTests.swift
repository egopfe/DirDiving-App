import XCTest

final class FullComputerRuntimeEngineTests: XCTestCase {
    private var sessionStart = Date(timeIntervalSince1970: 1_700_000_000)

    override func setUp() {
        super.setUp()
        sessionStart = Date(timeIntervalSince1970: 1_700_000_000)
    }

    func testStartupRequiresValidPlanAndSelfCheck() {
        let readiness = FullComputerRuntimeEngine.canStart()
        XCTAssertTrue(readiness.ready, readiness.diagnostics.joined(separator: ", "))
        XCTAssertThrowsError(try FullComputerRuntimeEngine(
            plan: FullComputerRuntimePlan(
                activeGas: BuhlmannGas(
                    name: "Bad",
                    role: .bottom,
                    oxygenFraction: 0,
                    heliumFraction: 0,
                    maxPPO2Bar: 1.4,
                    switchDepthMeters: 0
                ),
                gfLow: 30,
                gfHigh: 70,
                plannerEnvironment: .seaLevelSaltWater,
                travelGases: [],
                decoGases: [],
                ascentRateMetersPerMinute: 9,
                stopIntervalMeters: 3
            ),
            sessionStart: sessionStart
        ))
    }

    func testOneSecondTickAdvancesTissuesAtConstantDepth() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 20, timestamp: sessionStart)
        let before = engine.snapshot.tissueState.compartments[0].nitrogenPressure
        engine.tick(now: sessionStart.addingTimeInterval(1))
        let after = engine.snapshot.tissueState.compartments[0].nitrogenPressure
        XCTAssertGreaterThan(after, before)
        XCTAssertEqual(engine.snapshot.engineState, .valid)
    }

    func testIrregularDeltaUsesRealElapsedTime() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 18, timestamp: sessionStart)
        engine.tick(now: sessionStart.addingTimeInterval(2.7))
        XCTAssertEqual(engine.snapshot.engineState, .degraded)
        XCTAssertTrue(engine.snapshot.diagnostics.contains(where: { $0.hasPrefix("missed_tick:") }))
    }

    func testMultiLevelProfileUpdatesTissues() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 0, timestamp: sessionStart)
        _ = engine.ingestSample(depthMeters: 10, timestamp: sessionStart.addingTimeInterval(60))
        _ = engine.ingestSample(depthMeters: 30, timestamp: sessionStart.addingTimeInterval(180))
        XCTAssertNotNil(engine.snapshot.ndlMinutes)
        XCTAssertLessThan(engine.snapshot.ndlMinutes ?? 999, 60)
        XCTAssertGreaterThan(
            engine.snapshot.tissueState.compartments[0].nitrogenPressure,
            BuhlmannTissueState.airSaturated().compartments[0].nitrogenPressure
        )
    }

    func testDescentAndAscentProfile() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        var t = sessionStart
        for depth in stride(from: 0, through: 30, by: 3) {
            _ = engine.ingestSample(depthMeters: Double(depth), timestamp: t)
            t = t.addingTimeInterval(10)
        }
        for _ in 0..<120 {
            engine.tick(now: t)
            t = t.addingTimeInterval(1)
        }
        for depth in stride(from: 30, through: 0, by: -3) {
            _ = engine.ingestSample(depthMeters: Double(depth), timestamp: t)
            t = t.addingTimeInterval(12)
        }
        XCTAssertGreaterThanOrEqual(engine.snapshot.ttsMinutes, 0)
    }

    func testMissedTicksStayConservativeWithoutResettingTissues() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 25, timestamp: sessionStart)
        let loaded = engine.snapshot.tissueState
        engine.tick(now: sessionStart.addingTimeInterval(90))
        XCTAssertNotEqual(engine.snapshot.tissueState, BuhlmannTissueState.airSaturated())
        XCTAssertGreaterThan(
            engine.snapshot.tissueState.compartments[0].nitrogenPressure,
            loaded.compartments[0].nitrogenPressure
        )
    }

    func testTimestampedGasSwitchRecalculatesImmediately() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 21, timestamp: sessionStart.addingTimeInterval(600))
        let ean32 = BuhlmannGas(
            name: "EAN32",
            role: .bottom,
            oxygenFraction: 0.32,
            heliumFraction: 0,
            maxPPO2Bar: 1.4,
            switchDepthMeters: 0
        )
        engine.changeGas(ean32, at: sessionStart.addingTimeInterval(601))
        XCTAssertEqual(engine.snapshot.activeGas.name, "EAN32")
        XCTAssertTrue(engine.snapshot.diagnostics.contains(where: { $0.hasPrefix("gas_switch:") }))
    }

    func testRecoveryReplayMatchesContinuousIngest() throws {
        let samples = sampleProfileConstantBottom()
        var continuous = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        for sample in samples {
            _ = continuous.ingestSample(depthMeters: sample.depthMeters, timestamp: sample.timestamp)
        }

        var replayed = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        replayed.replaySamples(samples)

        XCTAssertEqual(
            continuous.snapshot.tissueState.compartments[0].nitrogenPressure,
            replayed.snapshot.tissueState.compartments[0].nitrogenPressure,
            accuracy: 0.000_1
        )
        XCTAssertEqual(continuous.snapshot.ttsMinutes, replayed.snapshot.ttsMinutes)
    }

    func testRuntimeMatchesPlannerForConstantDepthProfile() throws {
        let bottomMinutes = 22.0
        let depthMeters = 32.0
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 0, timestamp: sessionStart)
        _ = engine.ingestSample(depthMeters: depthMeters, timestamp: sessionStart.addingTimeInterval(120))
        let bottomSeconds = bottomMinutes * 60.0
        var tickTime = sessionStart.addingTimeInterval(120)
        while tickTime.timeIntervalSince(sessionStart.addingTimeInterval(120)) < bottomSeconds {
            engine.tick(now: tickTime)
            tickTime = tickTime.addingTimeInterval(1)
        }

        let gas = FullComputerRuntimePlan.defaultAirGF3070.activeGas
        let planner = BuhlmannEngine.plan(
            BuhlmannPlanRequest(
                maxDepthMeters: depthMeters,
                bottomMinutes: bottomMinutes,
                bottomGas: gas,
                travelGases: [],
                decoGases: [],
                gfLow: 30,
                gfHigh: 70,
                descentRateMetersPerMinute: 18,
                initialTissueState: .airSaturated(),
                plannerEnvironment: .seaLevelSaltWater
            )
        )
        XCTAssertFalse(planner.hasBlockingIssues)
        XCTAssertEqual(
            Double(engine.snapshot.ttsMinutes),
            Double(planner.ttsMinutes),
            accuracy: 3.0
        )
    }

    func testNonMonotonicSampleRejectedWithoutResettingTissues() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 12, timestamp: sessionStart.addingTimeInterval(30))
        let before = engine.snapshot.tissueState
        XCTAssertFalse(engine.ingestSample(depthMeters: 13, timestamp: sessionStart.addingTimeInterval(20)))
        XCTAssertEqual(engine.snapshot.engineState, .degraded)
        XCTAssertEqual(engine.snapshot.tissueState, before)
    }

    func testProjectionPerformanceBudget() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 28, timestamp: sessionStart.addingTimeInterval(400))
        measure {
            for offset in 0..<60 {
                engine.tick(now: sessionStart.addingTimeInterval(400 + Double(offset)))
            }
        }
    }

    private func sampleProfileConstantBottom() -> [DiveSample] {
        var samples: [DiveSample] = []
        var t = sessionStart
        samples.append(DiveSample(timestamp: t, depthMeters: 0, temperatureCelsius: nil))
        t = t.addingTimeInterval(90)
        samples.append(DiveSample(timestamp: t, depthMeters: 24, temperatureCelsius: nil))
        for _ in 0..<10 {
            t = t.addingTimeInterval(60)
            samples.append(DiveSample(timestamp: t, depthMeters: 24, temperatureCelsius: nil))
        }
        return samples
    }
}
