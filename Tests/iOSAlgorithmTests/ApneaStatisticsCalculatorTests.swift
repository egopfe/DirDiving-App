import XCTest

final class ApneaStatisticsCalculatorTests: XCTestCase {
    func testFakeLogsExcludedFromRealStatistics() {
        let demo = FakeApneaLogbookProvider.entries().first!
        let real = makeSession(maxDepth: 20)
        let stats = ApneaStatisticsCalculator.compute(from: [demo, real])
        XCTAssertEqual(stats.sessionCount, 1)
    }

    func testPersonalBestExcludesDemo() {
        let demo = FakeApneaLogbookProvider.entries().first!
        let real = makeSession(maxDepth: 22, duration: 100)
        let bests = ApneaPersonalBestCalculator.compute(from: [demo, real]) { _ in .freeTraining }
        let best = bests.first { $0.profileKind == .freeTraining }
        XCTAssertEqual(best?.bestHoldSeconds ?? 0, 100, accuracy: 0.01)
    }

    private func makeSession(maxDepth: Double, duration: TimeInterval = 80) -> ApneaSession {
        let dive = ApneaDive(
            startedAtMonotonicSeconds: 0,
            durationSeconds: duration,
            maxDepthMeters: maxDepth,
            averageDepthMeters: maxDepth * 0.6,
            samples: [ApneaSample(monotonicRelativeTimestampSeconds: 0, depthMeters: maxDepth)]
        )
        return ApneaSession(startMode: .watch, state: .completed, dives: [dive])
    }
}
