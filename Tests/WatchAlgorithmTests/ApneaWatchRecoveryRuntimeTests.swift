import XCTest

final class ApneaWatchRecoveryRuntimeTests: XCTestCase {
    func testRecoveryRatio2xFromEngineSnapshot() {
        let policy = ApneaRecoveryPolicy.default
        XCTAssertEqual(ApneaRecoveryTargetCalculator.targetSeconds(policy: policy, lastHoldSeconds: 90), 180, accuracy: 0.01)
    }
}
