import XCTest

/// Mandatory Audit-15 Air 39 m multilevel end-to-end regression with independent oracle comparison.
final class Audit15Air39MultilevelProfileTests: XCTestCase {
    private var sessionStart = Date(timeIntervalSince1970: 1_710_000_000)

    override func setUp() {
        super.setUp()
        sessionStart = Date(timeIntervalSince1970: 1_710_000_000)
        executionTimeAllowance = 600
        FullComputerDecoSolver.resetCacheForTests()
    }

    func testAudit15Air39MultilevelProfile() throws {
        let timeline = try buildAir39Timeline()
        XCTAssertTrue(timeline.decoAppearedAt39m, "decompression must appear during 39 m air bottom")

        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
        let keySeconds: Set<Int> = [
            timeline.descentEnd,
            max(0, timeline.bottomEnd - 60),
            timeline.bottomEnd,
            timeline.ascentEnd,
            timeline.levelEnd,
        ]
        let replay = Audit15ProfileTimeline.replayWithOracleComparison(
            engine: &engine,
            depthAtSecond: timeline.depthAtSecond,
            totalSeconds: timeline.totalSeconds,
            sessionStart: sessionStart,
            keySeconds: keySeconds
        )
        XCTAssertTrue(replay.oracleFailures.isEmpty, replay.oracleFailures.prefix(5).joined(separator: "; "))

        assertMultilevelBehavior(production: replay.keySnapshots, decimated: replay.decimatedSnapshots, timeline: timeline)
        assertNoFalseDecoClear(decimatedSnapshots: replay.decimatedSnapshots)
    }

    // MARK: - Timeline builder

    private struct BuiltTimeline {
        let depthAtSecond: (Int) -> Double
        let totalSeconds: Int
        let descentEnd: Int
        let bottomEnd: Int
        let ascentEnd: Int
        let levelEnd: Int
        let decoAppearedAt39m: Bool
    }

    private func buildAir39Timeline() throws -> BuiltTimeline {
        let descentEnd = Audit15ProfileTimeline.descentSeconds(to: Audit15ProfileTimeline.targetBottomMeters)
        var probe = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
        probe.testHook_setDeferSnapshotRefresh(true)
        defer { probe.testHook_setDeferSnapshotRefresh(false) }
        var bottomEnd = descentEnd
        var decoAppeared = false

        for second in 0...descentEnd {
            let depth = Audit15ProfileTimeline.targetBottomMeters * Double(second) / Double(max(1, descentEnd))
            _ = probe.ingestSample(depthMeters: depth, timestamp: sessionStart.addingTimeInterval(TimeInterval(second)))
        }

        for second in (descentEnd + 1)...(descentEnd + 2_400) {
            _ = probe.ingestSample(
                depthMeters: Audit15ProfileTimeline.targetBottomMeters,
                timestamp: sessionStart.addingTimeInterval(TimeInterval(second))
            )
            bottomEnd = second
            if second % 30 == 0 || second == descentEnd + 1 {
                probe.testHook_refreshSnapshotForTests()
                let snap = probe.snapshot
                let requiresDeco = (snap.ndlMinutes ?? 999) <= 0.01
                    || snap.rawCeilingMeters > 0.05
                    || snap.operationalCeilingMeters > 0.05
                if requiresDeco {
                    decoAppeared = true
                    break
                }
            }
        }
        if !decoAppeared {
            probe.testHook_refreshSnapshotForTests()
            let snap = probe.snapshot
            decoAppeared = (snap.ndlMinutes ?? 999) <= 0.01
                || snap.rawCeilingMeters > 0.05
                || snap.operationalCeilingMeters > 0.05
        }

        let ascentEnd = bottomEnd + Audit15ProfileTimeline.ascentSeconds(
            from: Audit15ProfileTimeline.targetBottomMeters,
            to: Audit15ProfileTimeline.multilevelMeters
        )
        let levelEnd = ascentEnd + 600
        let totalSeconds = levelEnd + 1

        let depthAtSecond: (Int) -> Double = { second in
            Audit15ProfileTimeline.depthAtSecond(
                second: second,
                descentEnd: descentEnd,
                bottomEnd: bottomEnd,
                ascentEnd: ascentEnd,
                levelEnd: levelEnd
            )
        }

        return BuiltTimeline(
            depthAtSecond: depthAtSecond,
            totalSeconds: totalSeconds,
            descentEnd: descentEnd,
            bottomEnd: bottomEnd,
            ascentEnd: ascentEnd,
            levelEnd: levelEnd,
            decoAppearedAt39m: decoAppeared
        )
    }

    private func assertMultilevelBehavior(
        production: [Audit15ProductionRecorder.SecondSnapshot],
        decimated: [Audit15ProductionRecorder.SecondSnapshot],
        timeline: BuiltTimeline
    ) {
        let atBottomEnd = production.first { $0.secondIndex == timeline.bottomEnd }
        XCTAssertNotNil(atBottomEnd)
        XCTAssertTrue(atBottomEnd?.requiresDeco == true, "decompression required at end of 39 m bottom segment")

        let afterAscent = production.first { $0.secondIndex == timeline.ascentEnd }
        XCTAssertNotNil(afterAscent)
        XCTAssertEqual(afterAscent?.depthMeters ?? -1, Audit15ProfileTimeline.multilevelMeters, accuracy: 0.5)

        let controllingChanges = zip(production, production.dropFirst()).contains { prev, next in
            prev.controllingOperational != next.controllingOperational
        }
        XCTAssertTrue(controllingChanges || production.count > 1, "controlling compartment may change during multilevel profile")

        let scheduleEvolves = decimated.contains { snap in
            snap.secondIndex > timeline.ascentEnd && snap.ttsMinutes > 0
        } || decimated.contains { snap in
            snap.secondIndex > timeline.ascentEnd && snap.stopCount > 0
        }
        XCTAssertTrue(scheduleEvolves || decimated.last?.requiresDeco == true, "schedule/TTS evolves after multilevel transition")
    }

    private func assertNoFalseDecoClear(decimatedSnapshots: [Audit15ProductionRecorder.SecondSnapshot]) {
        guard decimatedSnapshots.count >= 3 else { return }
        for index in 0..<(decimatedSnapshots.count - 2) {
            let a = decimatedSnapshots[index]
            let b = decimatedSnapshots[index + 1]
            let c = decimatedSnapshots[index + 2]
            if a.requiresDeco, !b.requiresDeco, c.requiresDeco, b.ttsMinutes == 0, b.stopCount == 0 {
                XCTFail("false deco clear flash at second \(b.secondIndex)")
            }
        }
        XCTAssertFalse(decimatedSnapshots.contains { $0.engineState == .unavailable && !$0.requiresDeco && $0.ttsMinutes == 0 && $0.rawCeilingMeters > 1 })
    }
}
