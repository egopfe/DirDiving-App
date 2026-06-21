import XCTest

/// Mutation-resistance: correct oracle must match production; mutated formulas must diverge.
final class BuhlmannMutationResistanceTests: XCTestCase {
    private let sessionStart = Date(timeIntervalSince1970: 1_712_000_000)

    override func setUp() {
        super.setUp()
        FullComputerDecoSolver.resetCacheForTests()
    }

    func testReversedSchreinerRateMutationDivergesFromProduction() throws {
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 0, timestamp: sessionStart)
        _ = engine.ingestSample(depthMeters: 30, timestamp: sessionStart.addingTimeInterval(120))

        let productionN2 = engine.snapshot.tissueState.compartments[0].nitrogenPressure

        let correct = IndependentBuhlmannOracle.advanceLinear(
            state: .airSaturated(),
            fromDepthMeters: 0,
            toDepthMeters: 30,
            durationSeconds: 120,
            gas: .air
        ).compartments[0].pn2Bar

        let mutated = IndependentOracleMutationFixtures.advanceWithSecondsAsMinutes(
            state: .airSaturated(),
            fromDepthMeters: 0,
            toDepthMeters: 30,
            durationSeconds: 120
        ).compartments[0].pn2Bar

        XCTAssertEqual(correct, productionN2, accuracy: IndependentBuhlmannOracleTolerances.tissuePressureBar)
        XCTAssertNotEqual(mutated, productionN2, accuracy: 0.01)
    }

    func testSecondsAsMinutesMutationDetected() {
        let correct = IndependentBuhlmannOracle.advanceLinear(
            state: .airSaturated(),
            fromDepthMeters: 20,
            toDepthMeters: 20,
            durationSeconds: 60,
            gas: .air
        )
        let mutated = IndependentOracleMutationFixtures.advanceWithSecondsAsMinutes(
            state: .airSaturated(),
            fromDepthMeters: 20,
            toDepthMeters: 20,
            durationSeconds: 60
        )
        XCTAssertNotEqual(
            correct.compartments[0].pn2Bar,
            mutated.compartments[0].pn2Bar,
            accuracy: 0.001
        )
    }

    func testSwappedHalfTimeMutationDiverges() {
        let state = IndependentOracleTissueState.airSaturated()
        let correct = IndependentBuhlmannOracle.advanceLinear(
            state: state,
            fromDepthMeters: 10,
            toDepthMeters: 30,
            durationSeconds: 60,
            gas: .air
        )
        var swappedState = state
        let startN2 = IndependentBuhlmannOracle.inspiredPressure(depthMeters: 10, gas: .air, inert: .nitrogen)
        let endN2 = IndependentBuhlmannOracle.inspiredPressure(depthMeters: 30, gas: .air, inert: .nitrogen)
        let rate = (endN2 - startN2)
        let kWrong = log(2) / IndependentOracleConstants.halfTimesHe[0]
        swappedState.compartments[0].pn2Bar = IndependentBuhlmannOracle.schreiner(
            initial: state.compartments[0].pn2Bar,
            inspiredStart: startN2,
            inspiredRatePerMinute: rate,
            k: kWrong,
            minutes: 1
        )
        XCTAssertNotEqual(
            correct.compartments[0].pn2Bar,
            swappedState.compartments[0].pn2Bar,
            accuracy: 0.000_1
        )
    }

    func testStaleSolverCacheDoesNotMaskFreshTissueChange() throws {
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 28, timestamp: sessionStart.addingTimeInterval(600))
        let firstTTS = engine.snapshot.ttsMinutes
        _ = engine.ingestSample(depthMeters: 8, timestamp: sessionStart.addingTimeInterval(900))
        let secondTTS = engine.snapshot.ttsMinutes
        XCTAssertNotEqual(firstTTS, secondTTS)
    }

    func testCalculationFailureDoesNotPresentAsZeroDeco() throws {
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 28, timestamp: sessionStart.addingTimeInterval(600))
        let tissueBefore = engine.snapshot.tissueState
        let loadedCeiling = engine.snapshot.rawCeilingMeters
        XCTAssertFalse(engine.ingestSample(depthMeters: .nan, timestamp: sessionStart.addingTimeInterval(601)))
        XCTAssertEqual(engine.snapshot.engineState, .unavailable)
        XCTAssertEqual(engine.snapshot.tissueState, tissueBefore)
        XCTAssertGreaterThanOrEqual(engine.snapshot.rawCeilingMeters, loadedCeiling)
    }
}
