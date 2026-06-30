import Foundation

enum ApneaTrainingTableBuilder {
    struct CO2Options: Equatable, Sendable {
        var initialHoldSeconds: TimeInterval
        var initialRecoverySeconds: TimeInterval
        var recoveryDecrementSeconds: TimeInterval
        var repetitions: Int
    }

    struct O2Options: Equatable, Sendable {
        var initialHoldSeconds: TimeInterval
        var holdIncrementSeconds: TimeInterval
        var fixedRecoverySeconds: TimeInterval
        var repetitions: Int
    }

    static func buildCO2Table(_ options: CO2Options, displayName: String = "CO2 Table") -> ApneaTrainingTable {
        var steps: [ApneaTrainingStep] = []
        var recovery = options.initialRecoverySeconds
        for index in 0..<max(1, options.repetitions) {
            steps.append(
                ApneaTrainingStep(
                    orderIndex: index,
                    holdSeconds: options.initialHoldSeconds,
                    recoverySeconds: max(0, recovery)
                )
            )
            recovery = max(0, recovery - options.recoveryDecrementSeconds)
        }
        return ApneaTrainingTable(kind: .co2, displayName: displayName, repetitions: steps.count, steps: steps)
    }

    static func buildO2Table(_ options: O2Options, displayName: String = "O2 Table") -> ApneaTrainingTable {
        var steps: [ApneaTrainingStep] = []
        var hold = options.initialHoldSeconds
        for index in 0..<max(1, options.repetitions) {
            steps.append(
                ApneaTrainingStep(
                    orderIndex: index,
                    holdSeconds: hold,
                    recoverySeconds: options.fixedRecoverySeconds
                )
            )
            hold += options.holdIncrementSeconds
        }
        return ApneaTrainingTable(kind: .o2, displayName: displayName, repetitions: steps.count, steps: steps)
    }
}

enum ApneaTrainingStepRuntimeEvaluator {
    struct RuntimeState: Equatable, Sendable {
        var currentStepIndex: Int
        var phase: Phase
        var holdElapsedSeconds: TimeInterval
        var recoveryElapsedSeconds: TimeInterval
        var isTableComplete: Bool
    }

    enum Phase: String, Equatable, Sendable {
        case hold
        case recovery
        case complete
    }

    static func initialState(for table: ApneaTrainingTable) -> RuntimeState {
        RuntimeState(currentStepIndex: 0, phase: table.steps.isEmpty ? .complete : .hold, holdElapsedSeconds: 0, recoveryElapsedSeconds: 0, isTableComplete: table.steps.isEmpty)
    }

    static func advance(
        state: RuntimeState,
        table: ApneaTrainingTable,
        holdElapsed: TimeInterval,
        recoveryElapsed: TimeInterval
    ) -> RuntimeState {
        guard !table.steps.isEmpty, state.currentStepIndex < table.steps.count else {
            return RuntimeState(currentStepIndex: state.currentStepIndex, phase: .complete, holdElapsedSeconds: holdElapsed, recoveryElapsedSeconds: recoveryElapsed, isTableComplete: true)
        }
        let step = table.steps[state.currentStepIndex]
        if state.phase == .hold, holdElapsed >= step.holdSeconds {
            return RuntimeState(currentStepIndex: state.currentStepIndex, phase: .recovery, holdElapsedSeconds: holdElapsed, recoveryElapsedSeconds: 0, isTableComplete: false)
        }
        if state.phase == .recovery, recoveryElapsed >= step.recoverySeconds {
            let nextIndex = state.currentStepIndex + 1
            if nextIndex >= table.steps.count {
                return RuntimeState(currentStepIndex: nextIndex, phase: .complete, holdElapsedSeconds: 0, recoveryElapsedSeconds: recoveryElapsed, isTableComplete: true)
            }
            return RuntimeState(currentStepIndex: nextIndex, phase: .hold, holdElapsedSeconds: 0, recoveryElapsedSeconds: recoveryElapsed, isTableComplete: false)
        }
        return RuntimeState(
            currentStepIndex: state.currentStepIndex,
            phase: state.phase,
            holdElapsedSeconds: holdElapsed,
            recoveryElapsedSeconds: recoveryElapsed,
            isTableComplete: false
        )
    }

    static func currentStep(in table: ApneaTrainingTable, state: RuntimeState) -> ApneaTrainingStep? {
        guard state.currentStepIndex < table.steps.count else { return nil }
        return table.steps[state.currentStepIndex]
    }
}
