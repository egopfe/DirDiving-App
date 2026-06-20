import XCTest

/// Audit-15 decompression clear → re-descent → decompression reappearance with independent oracle.
final class Audit15RedescentOracleTests: XCTestCase {
    private var sessionStart = Date(timeIntervalSince1970: 1_710_100_000)

    override func setUp() {
        super.setUp()
        sessionStart = Date(timeIntervalSince1970: 1_710_100_000)
        executionTimeAllowance = 600
        FullComputerDecoSolver.resetCacheForTests()
    }

    func testAudit15DecoClearsThenReappearsAfterRedescent() throws {
        let timeline = try buildRedescentTimeline()
        XCTAssertTrue(timeline.decoIncurred, "profile must incur decompression")
        if timeline.decoClearedAtShallow {
            XCTAssertTrue(timeline.redescentReappeared, "deco must reappear after re-descent when shallow clearance occurred")
        }

        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
        let replay = Audit15ProfileTimeline.replayWithOracleComparison(
            engine: &engine,
            depthAtSecond: timeline.depthAtSecond,
            totalSeconds: timeline.totalSeconds,
            sessionStart: sessionStart,
            keySeconds: [timeline.checkpointSecond]
        )
        XCTAssertTrue(replay.oracleFailures.isEmpty, replay.oracleFailures.prefix(5).joined(separator: "; "))

        try assertCheckpointBeforeRedescent(timeline: timeline)
        assertNoFreshTissueFallback(decimatedSnapshots: replay.decimatedSnapshots)
    }

    // MARK: - Timeline

    private struct RedescentTimeline {
        let depthAtSecond: (Int) -> Double
        let totalSeconds: Int
        let decoIncurred: Bool
        let decoClearedAtShallow: Bool
        let redescentReappeared: Bool
        let checkpointSecond: Int
    }

    private func buildRedescentTimeline() throws -> RedescentTimeline {
        var second = 0
        var depthSamples: [Double] = []

        func appendConstant(depth: Double, seconds: Int) {
            for _ in 0..<seconds {
                depthSamples.append(depth)
                second += 1
            }
        }

        func appendLinear(from: Double, to: Double, seconds: Int) {
            for index in 0..<seconds {
                let progress = Double(index + 1) / Double(max(1, seconds))
                depthSamples.append(from + (to - from) * progress)
                second += 1
            }
        }

        // Descent and deep bottom to incur deco (shorter than full 39 m test for runtime).
        appendLinear(from: 0, to: 36, seconds: 120)
        appendConstant(depth: 36, seconds: 1_800)

        var probe = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
        for (index, depth) in depthSamples.enumerated() {
            _ = probe.ingestSample(depthMeters: depth, timestamp: sessionStart.addingTimeInterval(TimeInterval(index)))
        }
        var decoIncurred = probe.snapshot.rawCeilingMeters > 0.05 || (probe.snapshot.ndlMinutes ?? 999) <= 0

        // Ascend to shallow plateau.
        appendLinear(from: 36, to: 4, seconds: 240)
        appendConstant(depth: 4, seconds: 600)

        for (offset, depth) in depthSamples.suffix(840).enumerated() {
            let index = depthSamples.count - 840 + offset
            _ = probe.ingestSample(depthMeters: depth, timestamp: sessionStart.addingTimeInterval(TimeInterval(index)))
        }
        let shallowClear = probe.snapshot.rawCeilingMeters <= 0.05 && (probe.snapshot.ndlMinutes ?? 0) > 0

        let checkpointSecond = depthSamples.count - 1

        // Re-descent.
        appendLinear(from: 4, to: 28, seconds: 120)
        appendConstant(depth: 28, seconds: 300)

        var redescentReappeared = false
        for (offset, depth) in depthSamples.suffix(420).enumerated() {
            let index = depthSamples.count - 420 + offset
            _ = probe.ingestSample(depthMeters: depth, timestamp: sessionStart.addingTimeInterval(TimeInterval(index)))
            let snap = probe.snapshot
            if snap.rawCeilingMeters > 0.05 || (snap.ndlMinutes ?? 999) <= 0.01 {
                redescentReappeared = true
            }
        }

        let depthAtSecond: (Int) -> Double = { index in
            guard index >= 0, index < depthSamples.count else { return depthSamples.last ?? 0 }
            return depthSamples[index]
        }

        return RedescentTimeline(
            depthAtSecond: depthAtSecond,
            totalSeconds: depthSamples.count,
            decoIncurred: decoIncurred,
            decoClearedAtShallow: shallowClear,
            redescentReappeared: redescentReappeared,
            checkpointSecond: checkpointSecond
        )
    }

    private func assertCheckpointBeforeRedescent(timeline: RedescentTimeline) throws {
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
        for second in 0...timeline.checkpointSecond {
            let depth = timeline.depthAtSecond(second)
            _ = engine.ingestSample(
                depthMeters: depth,
                timestamp: sessionStart.addingTimeInterval(TimeInterval(second))
            )
        }
        let tissueBefore = engine.snapshot.tissueState
        let checkpoint = try engine.exportCheckpoint(
            sessionID: UUID(),
            watchDivingMode: DIRDivingMode.fullComputer.rawValue
        )
        let data = try FullComputerRuntimeCheckpointCodec.encode(checkpoint)
        let decoded = try FullComputerRuntimeCheckpointCodec.decode(data)
        var restored = try FullComputerRuntimeEngine.restoreEngine(from: decoded, sessionStart: sessionStart)
        XCTAssertEqual(restored.snapshot.tissueState, tissueBefore)

        for second in (timeline.checkpointSecond + 1)..<timeline.totalSeconds {
            let depth = timeline.depthAtSecond(second)
            _ = restored.ingestSample(
                depthMeters: depth,
                timestamp: sessionStart.addingTimeInterval(TimeInterval(second))
            )
        }
        XCTAssertNotEqual(restored.snapshot.tissueState, BuhlmannTissueState.airSaturated())
        XCTAssertTrue(
            restored.snapshot.rawCeilingMeters > 0.05 || (restored.snapshot.ndlMinutes ?? 999) <= 0.01,
            "restored engine must reflect re-descent deco state"
        )
    }

    private func assertNoFreshTissueFallback(decimatedSnapshots: [Audit15ProductionRecorder.SecondSnapshot]) {
        guard let firstLoaded = decimatedSnapshots.first(where: { $0.tissue != BuhlmannTissueState.airSaturated() }) else {
            return XCTFail("expected loaded tissues")
        }
        for row in decimatedSnapshots where row.secondIndex > firstLoaded.secondIndex {
            XCTAssertNotEqual(row.tissue, BuhlmannTissueState.airSaturated(), "fresh tissue fallback at s\(row.secondIndex)")
        }
    }
}
