import XCTest

final class ApneaWatchSessionSummaryTests: XCTestCase {
    func testSummaryOmitsUnavailableDepth() {
        let summary = ApneaWatchProfileLayoutPresentation.sessionSummary(
            bestHoldSeconds: 134,
            maxDepthMeters: 0,
            reps: 4,
            averageRecoverySeconds: 150,
            quality: .good
        )
        XCTAssertEqual(summary.bestHoldSeconds, 134)
        XCTAssertEqual(summary.repetitionCount, 4)
    }
}
