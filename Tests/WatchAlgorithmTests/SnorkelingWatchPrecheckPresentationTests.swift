import XCTest

final class SnorkelingWatchPrecheckPresentationTests: XCTestCase {
    func testPrecheckIncludesRouteBuddyAndSensors() {
        let route = SnorkelingWatchImportedRoutePresentation(
            status: .ready,
            routeName: "Bay",
            revision: 1,
            plannedDistanceMeters: 300,
            plannedDurationSeconds: 900,
            isPendingWhileSessionActive: false,
            staleRevisionRejected: false,
            lastImportErrorCode: nil
        )
        let summary = SnorkelingWatchReadyPresentationPolicy.precheckSummary(
            gpsStatusText: "GPS Good",
            gpsIsHealthy: true,
            depthSensorHealthy: true,
            entryCaptured: true,
            route: route,
            buddyEnabled: true
        )
        XCTAssertTrue(summary.contains(DIRWatchLocalizer.string("snorkeling.watch.ready.precheck_gps")))
        XCTAssertTrue(summary.contains(DIRWatchLocalizer.string("snorkeling.watch.ready.precheck_depth")))
        XCTAssertTrue(summary.contains(DIRWatchLocalizer.string("snorkeling.watch.ready.route")))
        XCTAssertTrue(summary.contains(DIRWatchLocalizer.string("snorkeling.watch.ready.precheck_buddy")))
    }

    func testPresentationOutputIncludesPrecheckSummary() {
        var input = SnorkelingWatchPresentationInput.idle
        input.gpsPresentationState = .tracking
        input.depthPresentationState = .valid
        input.importedRoutePresentation = SnorkelingWatchImportedRoutePresentation(
            status: .missing,
            routeName: nil,
            revision: nil,
            plannedDistanceMeters: nil,
            plannedDurationSeconds: nil,
            isPendingWhileSessionActive: false,
            staleRevisionRejected: false,
            lastImportErrorCode: nil
        )
        let output = SnorkelingWatchPresentation.make(input)
        XCTAssertFalse(output.precheckSummaryText.isEmpty)
    }
}
