import XCTest

final class ApneaRecoveryTargetCalculatorTests: XCTestCase {
    func testFixedRecoverySeconds() {
        let policy = ApneaRecoveryPolicy(
            mode: .fixedDuration,
            minimumSurfaceSeconds: 30,
            recommendedSurfaceSeconds: 60,
            fixedDurationSeconds: 120
        )
        XCTAssertEqual(ApneaRecoveryTargetCalculator.targetSeconds(policy: policy, lastHoldSeconds: 45), 120, accuracy: 0.01)
    }

    func testRatio2xLastHold() {
        let policy = ApneaRecoveryPolicy.default
        XCTAssertEqual(ApneaRecoveryTargetCalculator.targetSeconds(policy: policy, lastHoldSeconds: 105), 210, accuracy: 0.01)
    }

    func testZeroHoldDoesNotCrash() {
        XCTAssertEqual(ApneaRecoveryTargetCalculator.targetSeconds(policy: .default, lastHoldSeconds: 0), 60, accuracy: 0.01)
    }

    func testTargetReached() {
        XCTAssertTrue(ApneaRecoveryTargetCalculator.isTargetReached(targetSeconds: 120, elapsedSeconds: 120))
        XCTAssertFalse(ApneaRecoveryTargetCalculator.isTargetReached(targetSeconds: 120, elapsedSeconds: 60))
    }
}
