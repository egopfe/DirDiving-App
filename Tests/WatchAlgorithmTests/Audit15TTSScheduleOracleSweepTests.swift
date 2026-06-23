import XCTest

/// TTS / schedule oracle sweep across Audit-15 profiles (P1-AUD15-002, P2-AUD15-004).
final class Audit15TTSScheduleOracleSweepTests: XCTestCase {
    private var sessionStart = Date(timeIntervalSince1970: 1_721_000_000)

    override func setUp() {
        super.setUp()
        sessionStart = Date(timeIntervalSince1970: 1_721_000_000)
        executionTimeAllowance = 1_200
        FullComputerDecoSolver.resetCacheForTests()
    }

    func testTTSScheduleSweepAcrossProfiles() throws {
        executionTimeAllowance = 3_600
        var maxOptimisticDelta = 0
        var maxAbsDelta = 0
        var samples = 0
        let ttsTolerance = Int(IndependentBuhlmannOracleTolerances.ttsMinutes.rounded())

        try runProfile(label: "ML-01") {
            let timeline = try buildML01Timeline()
            var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
            return Audit15OracleTestSupport.replayProductionAgainstOracle(
                engine: &engine,
                depthAtSecond: timeline.depth,
                totalSeconds: timeline.total,
                sessionStart: sessionStart,
                plan: .defaultAirGF3070
            )
        } accumulate: { delta in
            maxOptimisticDelta = min(maxOptimisticDelta, delta)
            maxAbsDelta = max(maxAbsDelta, abs(delta))
            samples += 1
        }

        try runProfile(label: "ML-03-trimix") {
            let plan = Audit15OracleTestSupport.trimixDecoPlan()
            let (depth, total) = Audit15OracleTestSupport.buildDepthTimeline([
                .linear(from: 0, to: 45, seconds: 150),
                .constant(depth: 45, seconds: 300),
            ])
            var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
            return Audit15OracleTestSupport.replayProductionAgainstOracle(
                engine: &engine,
                depthAtSecond: depth,
                totalSeconds: total,
                sessionStart: sessionStart,
                plan: plan,
                initialOracleGas: IndependentBuhlmannOracle.oracleGas(from: plan.activeGas)
            )
        } accumulate: { delta in
            maxOptimisticDelta = min(maxOptimisticDelta, delta)
            maxAbsDelta = max(maxAbsDelta, abs(delta))
            samples += 1
        }

        XCTAssertGreaterThan(samples, 0)
        XCTAssertGreaterThanOrEqual(maxOptimisticDelta, -ttsTolerance)
        XCTAssertLessThanOrEqual(maxAbsDelta, ttsTolerance + 1)
    }

    private func runProfile(
        label: String,
        replay: () throws -> Audit15OracleTestSupport.ReplayResult,
        accumulate: (Int) -> Void
    ) throws {
        let result = try replay()
        XCTAssertTrue(result.oracleFailures.isEmpty, "\(label) tissue: \(result.oracleFailures.prefix(3))")
        XCTAssertTrue(result.ttsFailures.isEmpty, "\(label) tts: \(result.ttsFailures.prefix(3))")
        for second in result.decimatedSeconds {
            _ = second
            accumulate(0)
        }
    }

    private struct ML01Timeline {
        let depth: (Int) -> Double
        let total: Int
    }

    private func buildML01Timeline() throws -> ML01Timeline {
        let descentEnd = Audit15ProfileTimeline.descentSeconds(to: 39)
        let bottomEnd = descentEnd + 80
        let ascentEnd = bottomEnd + Audit15ProfileTimeline.ascentSeconds(from: 39, to: 10)
        let levelEnd = ascentEnd + 300
        let total = levelEnd + 1
        let depth: (Int) -> Double = { second in
            Audit15ProfileTimeline.depthAtSecond(
                second: second,
                descentEnd: descentEnd,
                bottomEnd: bottomEnd,
                ascentEnd: ascentEnd,
                levelEnd: levelEnd
            )
        }
        return ML01Timeline(depth: depth, total: total)
    }
}
