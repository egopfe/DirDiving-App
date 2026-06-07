import XCTest
@testable import DIRDivingWatchApp

@MainActor
final class AscentSafetyHapticCoordinatorTests: XCTestCase {
    private var haptics: HapticService!
    private var coordinator: AscentSafetyHapticCoordinator!

    override func setUp() async throws {
        try await super.setUp()
        haptics = HapticService.shared
        haptics.resetThrottleStateForTests()
        haptics.testHook_playHandler = { _ in }
        coordinator = AscentSafetyHapticCoordinator()
    }

    override func tearDown() async throws {
        coordinator.clear()
        haptics.testHook_playHandler = nil
        haptics.resetThrottleStateForTests()
        try await super.tearDown()
    }

    func testEnteringRedZoneStartsAscentAlarmSession() {
        coordinator.update(isOverLimit: true)
        XCTAssertTrue(haptics.isAscentAlarmSessionActive)
    }

    func testExitingRedZoneClearsAscentAlarmSession() {
        coordinator.update(isOverLimit: true)
        coordinator.update(isOverLimit: false)
        XCTAssertFalse(haptics.isAscentAlarmSessionActive)
    }

    func testClearEndsRepeatLoop() async {
        var playCount = 0
        haptics.testHook_playHandler = { _ in playCount += 1 }
        coordinator.update(isOverLimit: true)
        XCTAssertGreaterThanOrEqual(playCount, 1)
        coordinator.clear()
        let countAfterClear = playCount
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        XCTAssertEqual(playCount, countAfterClear)
    }

    func testMissionModeInvariantUsesSameCoordinatorBehavior() {
        coordinator.update(isOverLimit: true)
        XCTAssertTrue(haptics.isAscentAlarmSessionActive)
        coordinator.update(isOverLimit: false)
        coordinator.update(isOverLimit: true)
        XCTAssertTrue(haptics.isAscentAlarmSessionActive)
    }
}
