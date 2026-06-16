import Foundation

enum FullComputerDecoStopState: String, Hashable, Codable {
    case approachingStop
    case holdingStop
    case tooShallow
    case tooDeep
    case ceilingViolation
    case stopRecalculation
    case stopCompleted
    case decoCompleted
}

enum FullComputerDecoStopDirection: String, Hashable, Codable {
    case ascend
    case descend
    case hold
    case none
}

enum FullComputerDecoStopPanelAccent: String, Hashable, Codable {
    case green
    case yellow
    case orange
    case red
}

struct FullComputerDecoStopTracker: Hashable, Codable {
    var engagedStopDepthMeters: Double?
    var lastModelRemainingMinutes: Int?
    var progressInvalidated: Bool
    var previousState: FullComputerDecoStopState?

    static let initial = FullComputerDecoStopTracker(
        engagedStopDepthMeters: nil,
        lastModelRemainingMinutes: nil,
        progressInvalidated: false,
        previousState: nil
    )
}

struct FullComputerDecoStopMachineInput: Hashable {
    let depthMeters: Double
    let stopDepthMeters: Double?
    let modelRemainingMinutes: Int?
    let remainingStopCount: Int
    let ceilingViolation: Bool
    let ceilingMetersExact: Double
    let decoRequired: Bool
    let deltaSeconds: TimeInterval
}

struct FullComputerDecoStopMachineOutput: Hashable {
    let tracker: FullComputerDecoStopTracker
    let state: FullComputerDecoStopState?
    let direction: FullComputerDecoStopDirection
    let panelAccent: FullComputerDecoStopPanelAccent
    let titleKey: String
    let instructionKey: String?
    let stopRemainingSeconds: Int?
    let showProgressPanel: Bool
    let hideManualStopwatch: Bool
    let timerAccruing: Bool
}

/// Operational stop state machine for Full Computer decompression UI.
enum FullComputerDecoStopStateMachine {
    static func evaluate(
        input: FullComputerDecoStopMachineInput,
        tracker: FullComputerDecoStopTracker
    ) -> FullComputerDecoStopMachineOutput {
        guard input.decoRequired else {
            return idleOutput(tracker: tracker)
        }

        if input.ceilingViolation {
            return output(
                tracker: tracker,
                state: .ceilingViolation,
                direction: correctiveDirection(
                    depth: input.depthMeters,
                    stopDepth: input.stopDepthMeters ?? input.ceilingMetersExact
                ),
                panelAccent: .red,
                titleKey: "live.fc.deco.hold.title",
                instructionKey: "live.fc.deco.instruction.ceiling_violation",
                stopRemainingSeconds: modelRemainingSeconds(input.modelRemainingMinutes),
                showProgressPanel: true,
                hideManualStopwatch: true,
                timerAccruing: false
            )
        }

        if input.remainingStopCount == 0, input.ceilingMetersExact <= FullComputerDecoSolver.decoCeilingEpsilonMeters {
            return output(
                tracker: tracker,
                state: .decoCompleted,
                direction: .none,
                panelAccent: .green,
                titleKey: "live.fc.deco.completed.title",
                instructionKey: "live.fc.deco.completed.instruction",
                stopRemainingSeconds: nil,
                showProgressPanel: true,
                hideManualStopwatch: true,
                timerAccruing: false
            )
        }

        guard let stopDepth = input.stopDepthMeters else {
            return idleOutput(tracker: tracker, hideManualStopwatch: false)
        }

        let depth = max(0, input.depthMeters)
        let engagement = stopEngagement(depth: depth, stopDepth: stopDepth, tracker: tracker)

        switch engagement {
        case .notYetReached:
            let direction: FullComputerDecoStopDirection = depth > stopDepth ? .ascend : .descend
            let instruction = direction == .ascend
                ? "live.fc.deco.instruction.ascend_to_stop"
                : "live.fc.deco.instruction.descend_to_stop"
            var nextTracker = tracker
            nextTracker.engagedStopDepthMeters = nil
            return output(
                tracker: nextTracker,
                state: .approachingStop,
                direction: direction,
                panelAccent: .yellow,
                titleKey: "live.fc.deco.approach.title",
                instructionKey: instruction,
                stopRemainingSeconds: modelRemainingSeconds(input.modelRemainingMinutes),
                showProgressPanel: true,
                hideManualStopwatch: true,
                timerAccruing: false
            )

        case .engaged:
            return evaluateEngagedStop(
                input: input,
                tracker: tracker,
                stopDepth: stopDepth,
                depth: depth
            )
        }
    }

    // MARK: - Zone evaluation

    private enum StopEngagement {
        case notYetReached
        case engaged
    }

    private static func stopEngagement(
        depth: Double,
        stopDepth: Double,
        tracker: FullComputerDecoStopTracker
    ) -> StopEngagement {
        if let engaged = tracker.engagedStopDepthMeters, abs(engaged - stopDepth) < 0.05 {
            return .engaged
        }
        let enterThreshold = stopDepth + FullComputerDecoStopConfiguration.deepMarginMeters
            + FullComputerDecoStopConfiguration.hysteresisMeters
        if depth <= enterThreshold {
            return .engaged
        }
        return .notYetReached
    }

    private static func evaluateEngagedStop(
        input: FullComputerDecoStopMachineInput,
        tracker: FullComputerDecoStopTracker,
        stopDepth: Double,
        depth: Double
    ) -> FullComputerDecoStopMachineOutput {
        var nextTracker = tracker
        nextTracker.engagedStopDepthMeters = stopDepth

        let shallowEdge = stopDepth - FullComputerDecoStopConfiguration.shallowMarginMeters
        let deepEdge = stopDepth + FullComputerDecoStopConfiguration.deepMarginMeters
        let resetEdge = stopDepth + FullComputerDecoStopConfiguration.resetDepthMarginMeters
        let h = FullComputerDecoStopConfiguration.hysteresisMeters

        if depth > resetEdge + h {
            nextTracker.progressInvalidated = true
            nextTracker.lastModelRemainingMinutes = input.modelRemainingMinutes
            return output(
                tracker: nextTracker,
                state: .stopRecalculation,
                direction: .ascend,
                panelAccent: .orange,
                titleKey: "live.fc.deco.recalc.title",
                instructionKey: "live.fc.deco.instruction.ascend_to_stop",
                stopRemainingSeconds: modelRemainingSeconds(input.modelRemainingMinutes),
                showProgressPanel: true,
                hideManualStopwatch: true,
                timerAccruing: false
            )
        }

        if depth > deepEdge + h {
            nextTracker.progressInvalidated = false
            return output(
                tracker: nextTracker,
                state: .tooDeep,
                direction: .ascend,
                panelAccent: .yellow,
                titleKey: "live.fc.deco.hold.title",
                instructionKey: "live.fc.deco.instruction.ascend_to_stop",
                stopRemainingSeconds: frozenRemainingSeconds(tracker: nextTracker, input: input),
                showProgressPanel: true,
                hideManualStopwatch: true,
                timerAccruing: false
            )
        }

        if depth < shallowEdge - h {
            nextTracker.progressInvalidated = false
            return output(
                tracker: nextTracker,
                state: .tooShallow,
                direction: .descend,
                panelAccent: .yellow,
                titleKey: "live.fc.deco.hold.title",
                instructionKey: "live.fc.deco.instruction.descend_to_stop",
                stopRemainingSeconds: frozenRemainingSeconds(tracker: nextTracker, input: input),
                showProgressPanel: true,
                hideManualStopwatch: true,
                timerAccruing: false
            )
        }

        let inValidWindow = depth >= shallowEdge - h && depth <= deepEdge + h
        if inValidWindow {
            nextTracker.progressInvalidated = false
            nextTracker.lastModelRemainingMinutes = input.modelRemainingMinutes
            let remaining = modelRemainingSeconds(input.modelRemainingMinutes)
            let completed = (input.modelRemainingMinutes ?? 1) <= 0
            if completed, input.remainingStopCount <= 1 {
                return output(
                    tracker: nextTracker,
                    state: .stopCompleted,
                    direction: .hold,
                    panelAccent: .green,
                    titleKey: "live.fc.deco.completed.title",
                    instructionKey: "live.fc.deco.completed.instruction",
                    stopRemainingSeconds: 0,
                    showProgressPanel: true,
                    hideManualStopwatch: true,
                    timerAccruing: false
                )
            }
            return output(
                tracker: nextTracker,
                state: .holdingStop,
                direction: .hold,
                panelAccent: .green,
                titleKey: "live.fc.deco.hold.title",
                instructionKey: "live.fc.deco.instruction.maintain_depth",
                stopRemainingSeconds: remaining,
                showProgressPanel: true,
                hideManualStopwatch: true,
                timerAccruing: true
            )
        }

        return output(
            tracker: nextTracker,
            state: .approachingStop,
            direction: depth > stopDepth ? .ascend : .descend,
            panelAccent: .yellow,
            titleKey: "live.fc.deco.approach.title",
            instructionKey: depth > stopDepth
                ? "live.fc.deco.instruction.ascend_to_stop"
                : "live.fc.deco.instruction.descend_to_stop",
            stopRemainingSeconds: modelRemainingSeconds(input.modelRemainingMinutes),
            showProgressPanel: true,
            hideManualStopwatch: true,
            timerAccruing: false
        )
    }

    private static func correctiveDirection(depth: Double, stopDepth: Double) -> FullComputerDecoStopDirection {
        depth < stopDepth ? .descend : .ascend
    }

    private static func modelRemainingSeconds(_ minutes: Int?) -> Int? {
        guard let minutes else { return nil }
        return max(0, minutes * 60)
    }

    private static func frozenRemainingSeconds(
        tracker: FullComputerDecoStopTracker,
        input: FullComputerDecoStopMachineInput
    ) -> Int? {
        if let frozen = tracker.lastModelRemainingMinutes {
            return max(0, frozen * 60)
        }
        return modelRemainingSeconds(input.modelRemainingMinutes)
    }

    private static func idleOutput(
        tracker: FullComputerDecoStopTracker,
        hideManualStopwatch: Bool = false
    ) -> FullComputerDecoStopMachineOutput {
        FullComputerDecoStopMachineOutput(
            tracker: tracker,
            state: nil,
            direction: .none,
            panelAccent: .green,
            titleKey: "",
            instructionKey: nil,
            stopRemainingSeconds: nil,
            showProgressPanel: false,
            hideManualStopwatch: hideManualStopwatch,
            timerAccruing: false
        )
    }

    private static func output(
        tracker: FullComputerDecoStopTracker,
        state: FullComputerDecoStopState,
        direction: FullComputerDecoStopDirection,
        panelAccent: FullComputerDecoStopPanelAccent,
        titleKey: String,
        instructionKey: String?,
        stopRemainingSeconds: Int?,
        showProgressPanel: Bool,
        hideManualStopwatch: Bool,
        timerAccruing: Bool
    ) -> FullComputerDecoStopMachineOutput {
        var nextTracker = tracker
        nextTracker.previousState = state
        return FullComputerDecoStopMachineOutput(
            tracker: nextTracker,
            state: state,
            direction: direction,
            panelAccent: panelAccent,
            titleKey: titleKey,
            instructionKey: instructionKey,
            stopRemainingSeconds: stopRemainingSeconds,
            showProgressPanel: showProgressPanel,
            hideManualStopwatch: hideManualStopwatch,
            timerAccruing: timerAccruing
        )
    }
}
