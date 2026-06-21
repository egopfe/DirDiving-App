import XCTest

/// Schreiner analytic segment vs repeated 1 s integration vs production vs independent oracle.
final class SchreinerAnalyticParityTests: XCTestCase {
    private let representativeCompartments = [0, 3, 7, 11, 15]
    private let gas = IndependentOracleGas.air

    func testSchreinerAnalyticMatchesOneSecondStepsForDescentSegments() {
        let segments: [(from: Double, to: Double, seconds: Int)] = [
            (0, 39, 130),
            (39, 10, 194),
            (10, 3, 42),
            (3, 0, 20),
        ]
        for segment in segments {
            for compartment in representativeCompartments {
                tryCompareSegment(segment: segment, compartment: compartment)
            }
        }
    }

    func testProductionMatchesOracleOneSecondStepsAt39mDescent() throws {
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: Date(timeIntervalSince1970: 1_711_000_000))
        var oracleState = IndependentOracleTissueState.airSaturated()
        var previousDepth = 0.0
        let sessionStart = Date(timeIntervalSince1970: 1_711_000_000)

        for second in 1...130 {
            let depth = 39 * Double(second) / 130
            _ = engine.ingestSample(depthMeters: depth, timestamp: sessionStart.addingTimeInterval(TimeInterval(second)))
            oracleState = IndependentBuhlmannOracle.advanceLinear(
                state: oracleState,
                fromDepthMeters: previousDepth,
                toDepthMeters: depth,
                durationSeconds: 1,
                gas: gas
            )
            previousDepth = depth
            if second == 130 {
                for index in representativeCompartments {
                    let o = oracleState.compartments[index].pn2Bar
                    let p = engine.snapshot.tissueState.compartments[index].nitrogenPressure
                    XCTAssertEqual(o, p, accuracy: IndependentBuhlmannOracleTolerances.tissuePressureBar, "compartment \(index) @ \(second)s")
                }
            }
        }
    }

    private func tryCompareSegment(segment: (from: Double, to: Double, seconds: Int), compartment: Int) {
        let minutes = Double(segment.seconds) / 60
        let startN2 = IndependentBuhlmannOracle.inspiredPressure(depthMeters: segment.from, gas: gas, inert: .nitrogen)
        let endN2 = IndependentBuhlmannOracle.inspiredPressure(depthMeters: segment.to, gas: gas, inert: .nitrogen)
        let rate = (endN2 - startN2) / minutes
        let k = log(2) / IndependentOracleConstants.halfTimesN2[compartment]
        let saturated = IndependentOracleTissueState.airSaturated().compartments[compartment].pn2Bar

        let analytic = IndependentBuhlmannOracle.schreiner(
            initial: saturated,
            inspiredStart: startN2,
            inspiredRatePerMinute: rate,
            k: k,
            minutes: minutes
        )

        var stepped = saturated
        var depth = segment.from
        let stepDepth = (segment.to - segment.from) / Double(segment.seconds)
        for _ in 0..<segment.seconds {
            let next = depth + stepDepth
            let state = IndependentOracleTissueState(
                compartments: IndependentOracleTissueState.airSaturated().compartments.enumerated().map { index, comp in
                    guard index == compartment else { return comp }
                    return IndependentOracleCompartment(pn2Bar: stepped, pheBar: comp.pheBar)
                }
            )
            let updated = IndependentBuhlmannOracle.advanceLinear(
                state: state,
                fromDepthMeters: depth,
                toDepthMeters: next,
                durationSeconds: 1,
                gas: gas
            )
            stepped = updated.compartments[compartment].pn2Bar
            depth = next
        }

        XCTAssertEqual(
            analytic,
            stepped,
            accuracy: IndependentBuhlmannOracleTolerances.schreinerAnalyticSegmentBar,
            "segment \(segment.from)→\(segment.to) c\(compartment)"
        )
    }
}
