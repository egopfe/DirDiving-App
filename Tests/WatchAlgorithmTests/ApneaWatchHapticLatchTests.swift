import XCTest

final class ApneaWatchHapticLatchTests: XCTestCase {
    func testRecoveryAlertFiresOnce() {
        var latch = ApneaWatchHapticLatch()
        let cycle = UUID()
        latch.resetForNewHold(cycleID: cycle)
        XCTAssertTrue(latch.shouldFireRecoveryHaptic(targetReached: true))
        latch.markRecoveryTargetReached()
        XCTAssertFalse(latch.shouldFireRecoveryHaptic(targetReached: true))
    }

    func testLatchResetsOnNextHold() {
        var latch = ApneaWatchHapticLatch()
        latch.resetForNewHold(cycleID: UUID())
        latch.markRecoveryTargetReached()
        latch.resetForNewHold(cycleID: UUID())
        XCTAssertTrue(latch.shouldFireRecoveryHaptic(targetReached: true))
    }
}
