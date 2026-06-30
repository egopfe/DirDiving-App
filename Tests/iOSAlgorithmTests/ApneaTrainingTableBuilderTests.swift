import XCTest

final class ApneaTrainingTableBuilderTests: XCTestCase {
    func testCO2TableRecoveryDecreases() {
        let table = ApneaTrainingTableBuilder.buildCO2Table(
            .init(initialHoldSeconds: 90, initialRecoverySeconds: 120, recoveryDecrementSeconds: 15, repetitions: 4)
        )
        let recoveries = table.steps.sorted { $0.orderIndex < $1.orderIndex }.map(\.recoverySeconds)
        XCTAssertEqual(recoveries, [120, 105, 90, 75])
    }

    func testO2TableHoldIncreases() {
        let table = ApneaTrainingTableBuilder.buildO2Table(
            .init(initialHoldSeconds: 60, holdIncrementSeconds: 15, fixedRecoverySeconds: 120, repetitions: 3)
        )
        let holds = table.steps.sorted { $0.orderIndex < $1.orderIndex }.map(\.holdSeconds)
        XCTAssertEqual(holds, [60, 75, 90])
    }
}
