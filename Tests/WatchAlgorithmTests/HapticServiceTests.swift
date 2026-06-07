import XCTest
@testable import DIRDivingWatchApp

@MainActor
final class HapticServiceTests: XCTestCase {
    private var haptics: HapticService!
    private var now: Date!

    override func setUp() async throws {
        try await super.setUp()
        haptics = HapticService.shared
        haptics.resetThrottleStateForTests()
        now = Date()
        haptics.testHook_now = { [unowned self] in self.now }
        haptics.testHook_playHandler = { _ in }
        UserDefaults.standard.set(true, forKey: HapticService.hapticsEnabledKey)
    }

    override func tearDown() async throws {
        haptics.testHook_playHandler = nil
        haptics.resetThrottleStateForTests()
        try await super.tearDown()
    }

    func testWarnIfNeededThrottlesWithinTwoSeconds() {
        var count = 0
        haptics.testHook_playHandler = { _ in count += 1 }
        haptics.warnIfNeeded()
        haptics.warnIfNeeded()
        XCTAssertEqual(count, 1)
        now = now.addingTimeInterval(2.1)
        haptics.warnIfNeeded()
        XCTAssertEqual(count, 2)
    }

    func testHapticsDisabledPreventsPlayback() {
        UserDefaults.standard.set(false, forKey: HapticService.hapticsEnabledKey)
        var count = 0
        haptics.testHook_playHandler = { _ in count += 1 }
        haptics.warnIfNeeded()
        haptics.ascentAlarmTriggered()
        XCTAssertEqual(count, 0)
    }

    func testAscentAlarmRepeatHonorsInterval() {
        var count = 0
        haptics.testHook_playHandler = { _ in count += 1 }
        haptics.ascentAlarmTriggered()
        let afterTrigger = count
        haptics.ascentAlarmRepeatIfNeeded()
        XCTAssertEqual(count, afterTrigger)
        now = now.addingTimeInterval(HapticService.ascentAlarmRepeatInterval + 0.1)
        haptics.ascentAlarmRepeatIfNeeded()
        XCTAssertEqual(count, afterTrigger + 1)
    }
}
