import XCTest

final class ApneaSessionCheckEvaluatorTests: XCTestCase {
    func testReadyWithValidProfile() {
        let result = ApneaSessionCheckEvaluator.evaluate(
            .init(
                profile: .freeTrainingDefault,
                recoveryPolicy: .default,
                recoveryAlertsEnabled: true,
                buddyReminderShown: true,
                buddyChecklistConfirmed: true
            )
        )
        XCTAssertEqual(result.status, .ready)
    }

    func testWarningWhenBuddyNotConfirmed() {
        let result = ApneaSessionCheckEvaluator.evaluate(
            .init(
                profile: .freeTrainingDefault,
                recoveryPolicy: .default,
                recoveryAlertsEnabled: true,
                buddyReminderShown: true,
                buddyChecklistConfirmed: false
            )
        )
        XCTAssertEqual(result.status, .warning)
    }
}
