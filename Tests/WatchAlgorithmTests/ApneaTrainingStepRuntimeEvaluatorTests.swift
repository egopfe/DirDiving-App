import XCTest

final class ApneaTrainingStepRuntimeEvaluatorTests: XCTestCase {
    func testCoachingAdvanceFromHoldToRecovery() {
        let table = ApneaTrainingTableBuilder.buildCO2Table(
            .init(initialHoldSeconds: 60, initialRecoverySeconds: 90, recoveryDecrementSeconds: 0, repetitions: 2)
        )
        var state = ApneaTrainingStepRuntimeEvaluator.initialState(for: table)
        state = ApneaTrainingStepRuntimeEvaluator.advance(state: state, table: table, holdElapsed: 60, recoveryElapsed: 0)
        XCTAssertEqual(state.phase, .recovery)
    }

    func testTableCompletedAfterFinalRecovery() {
        let table = ApneaTrainingTableBuilder.buildO2Table(
            .init(initialHoldSeconds: 30, holdIncrementSeconds: 0, fixedRecoverySeconds: 30, repetitions: 1)
        )
        var state = ApneaTrainingStepRuntimeEvaluator.initialState(for: table)
        state = ApneaTrainingStepRuntimeEvaluator.advance(state: state, table: table, holdElapsed: 30, recoveryElapsed: 0)
        XCTAssertEqual(state.phase, .recovery)
        state = ApneaTrainingStepRuntimeEvaluator.advance(state: state, table: table, holdElapsed: 30, recoveryElapsed: 30)
        XCTAssertTrue(state.isTableComplete)
    }
}
