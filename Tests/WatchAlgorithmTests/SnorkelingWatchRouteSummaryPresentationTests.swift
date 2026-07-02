import XCTest

final class SnorkelingWatchRouteSummaryPresentationTests: XCTestCase {
    func testCompactSummaryIncludesRouteMetrics() {
        let route = SnorkelingWatchImportedRoutePresentation(
            status: .ready,
            routeName: "Reef loop",
            revision: 2,
            plannedDistanceMeters: 420,
            plannedDurationSeconds: 1_800,
            waypointCount: 3,
            returnAlertConfigured: true,
            offRouteThresholdMeters: 40,
            isPendingWhileSessionActive: false,
            staleRevisionRejected: false,
            lastImportErrorCode: nil
        )
        let summary = SnorkelingWatchRouteSummaryPresentationPolicy.compactSummary(for: route)
        XCTAssertTrue(summary.contains("Reef loop"))
        XCTAssertTrue(summary.contains("420"))
        XCTAssertTrue(summary.contains("3"))
        XCTAssertTrue(summary.contains(DIRWatchLocalizer.string("snorkeling.watch.route_summary.return_alert_on")))
    }

    func testMissingRouteShowsNoRouteSelected() {
        XCTAssertEqual(
            SnorkelingWatchRouteSummaryPresentationPolicy.compactSummary(for: .missing),
            DIRWatchLocalizer.string("snorkeling.watch.route_no_route")
        )
    }
}
