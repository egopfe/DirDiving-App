import XCTest

/// Cross-target parity: Watch production vs independent oracle on identical timelines.
final class WatchMathCrossTargetParityTests: XCTestCase {
    func testWatchProductionMatchesIndependentOracleAt30mConstantLoad() throws {
        let sessionStart = Date(timeIntervalSince1970: 1_714_000_000)
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
        var oracle = IndependentOracleTissueState.airSaturated()

        for second in 1...1_200 {
            let depth: Double
            if second <= 120 {
                depth = 30 * Double(second) / 120
            } else {
                depth = 30
            }
            let t = sessionStart.addingTimeInterval(TimeInterval(second))
            if second == 1 || abs(depth - engine.snapshot.depthMeters) > 0.000_1 {
                _ = engine.ingestSample(depthMeters: depth, timestamp: t)
            } else {
                engine.tick(now: t)
            }
            if second > 1 {
                oracle = IndependentBuhlmannOracle.advanceLinear(
                    state: oracle,
                    fromDepthMeters: second <= 120 ? 30 * Double(second - 1) / 120 : 30,
                    toDepthMeters: depth,
                    durationSeconds: 1,
                    gas: .air
                )
            }
        }

        for index in 0..<16 {
            XCTAssertEqual(
                engine.snapshot.tissueState.compartments[index].nitrogenPressure,
                oracle.compartments[index].pn2Bar,
                accuracy: IndependentBuhlmannOracleTolerances.tissuePressureBar
            )
        }

        let bridged = oracle.buhlmannTissueState()
        let bridgedCeiling = bridged.ceiling(gf: 0.30, environment: .seaLevelSaltWater).depthMeters
        XCTAssertEqual(
            engine.snapshot.rawCeilingMeters,
            bridgedCeiling,
            accuracy: IndependentBuhlmannOracleTolerances.ceilingMeters
        )
    }

    func testGFBoundaryValidationRemainsConservative() throws {
        let invalidPlan = FullComputerRuntimePlan(
            activeGas: BuhlmannGas(
                name: "Air",
                role: .bottom,
                oxygenFraction: 0.21,
                heliumFraction: 0,
                maxPPO2Bar: 1.4,
                switchDepthMeters: 0
            ),
            gfLow: 80,
            gfHigh: 30,
            plannerEnvironment: .seaLevelSaltWater,
            travelGases: [],
            decoGases: [],
            ascentRateMetersPerMinute: 9,
            stopIntervalMeters: 3
        )
        let readiness = FullComputerRuntimeEngine.canStart(plan: invalidPlan)
        XCTAssertFalse(readiness.ready)
    }
}
