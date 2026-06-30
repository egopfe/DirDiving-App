import XCTest

final class ApneaDataQualityEvaluatorTests: XCTestCase {
    func testGoodQualityForCompleteSession() {
        let dive = ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 90, maxDepthMeters: 12, averageDepthMeters: 8)
        let session = ApneaSession(startMode: .watch, state: .completed, dives: [dive])
        let report = ApneaDataQualityEvaluator.evaluate(session: session)
        XCTAssertTrue([ApneaDataQualityLevel.good, .medium].contains(report.overall))
        XCTAssertEqual(report.validHoldCount, 1)
    }

    func testUnavailableWhenNoHolds() {
        let session = ApneaSession(startMode: .watch, state: .completed, dives: [])
        let report = ApneaDataQualityEvaluator.evaluate(session: session)
        XCTAssertEqual(report.sessionCompleteness, .unavailable)
    }
}
