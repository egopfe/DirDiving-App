import XCTest

final class SnorkelingWatchReadyRoutePresentationTests: XCTestCase {
    func testRouteReadyWhenActiveRouteExists() {
        let route = SnorkelingWatchImportedRoutePresentation(
            status: .ready,
            routeName: "Reef loop",
            revision: 3,
            plannedDistanceMeters: 420,
            plannedDurationSeconds: 1_800,
            waypointCount: 4,
            returnAlertConfigured: true,
            offRouteThresholdMeters: 40,
            isPendingWhileSessionActive: false,
            staleRevisionRejected: false,
            lastImportErrorCode: nil
        )
        XCTAssertEqual(
            SnorkelingWatchReadyPresentationPolicy.routeStatusText(for: route),
            DIRWatchLocalizer.string("snorkeling.watch.ready.route_ready")
        )
        XCTAssertNil(SnorkelingWatchReadyPresentationPolicy.routePendingBannerText(for: route))
    }

    func testRouteMissingWhenNoRouteExists() {
        XCTAssertEqual(
            SnorkelingWatchReadyPresentationPolicy.routeStatusText(for: .missing),
            DIRWatchLocalizer.string("snorkeling.watch.ready.route_missing")
        )
    }

    func testPendingRouteDuringActiveSessionShowsPendingBanner() {
        let route = SnorkelingWatchImportedRoutePresentation(
            status: .pending,
            routeName: "Stage route",
            revision: 4,
            plannedDistanceMeters: nil,
            plannedDurationSeconds: nil,
            waypointCount: nil,
            returnAlertConfigured: false,
            offRouteThresholdMeters: nil,
            isPendingWhileSessionActive: true,
            staleRevisionRejected: false,
            lastImportErrorCode: nil
        )
        XCTAssertEqual(
            SnorkelingWatchReadyPresentationPolicy.routeStatusText(for: route),
            DIRWatchLocalizer.string("snorkeling.route_sync.pending")
        )
        XCTAssertNotNil(SnorkelingWatchReadyPresentationPolicy.routePendingBannerText(for: route))
    }

    func testStaleRevisionRejectedShowsRejectedStatus() {
        var route = SnorkelingWatchImportedRoutePresentation.missing
        route.staleRevisionRejected = true
        XCTAssertEqual(
            SnorkelingWatchReadyPresentationPolicy.routeStatusText(for: route),
            DIRWatchLocalizer.string("snorkeling.route_sync.rejected")
        )
    }
}
