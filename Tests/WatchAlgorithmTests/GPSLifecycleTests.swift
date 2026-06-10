import XCTest

@MainActor
final class GPSLifecycleTests: XCTestCase {
    func testFreshManagerDoesNotMaintainLocationUpdates() {
        let manager = GPSManager()
        XCTAssertFalse(manager.maintainsLocationUpdates)
    }

    func testCaptureCompletesPreviousPendingCaptureBeforeReplacing() async {
        let manager = GPSManager()
        var firstCompleted = false
        var secondCompleted = false

        manager.captureBestEffortPoint(for: 0.05) { _ in
            firstCompleted = true
        }
        manager.captureBestEffortPoint(for: 0.05) { _ in
            secondCompleted = true
        }

        try? await Task.sleep(nanoseconds: 150_000_000)
        XCTAssertTrue(firstCompleted)
        XCTAssertTrue(secondCompleted)
    }

    func testOneShotModeStopsUpdatesWhenRequested() async {
        let manager = GPSManager()
        var completed = false
        manager.captureBestEffortPoint(for: 0.05, stopUpdatesWhenComplete: true) { _ in
            completed = true
        }
        try? await Task.sleep(nanoseconds: 150_000_000)
        XCTAssertTrue(completed)
    }

    func testNoFixCurrentBestPointIsUnavailable() {
        let manager = GPSManager()
        XCTAssertNil(manager.currentBestPoint())
        XCTAssertEqual(manager.fallbackQuality, .unavailable)
    }
}
