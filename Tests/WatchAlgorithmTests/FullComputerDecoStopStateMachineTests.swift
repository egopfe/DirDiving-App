import XCTest

final class FullComputerDecoStopStateMachineTests: XCTestCase {
    private let stopDepth = 6.0

    func testApproachingStopWhenFarFromStopDepth() {
        let output = evaluate(depth: 21.4, remainingMinutes: 2, remainingStops: 3)
        XCTAssertEqual(output.state, .approachingStop)
        XCTAssertEqual(output.direction, .ascend)
        XCTAssertEqual(output.panelAccent, .yellow)
        XCTAssertFalse(output.timerAccruing)
        XCTAssertTrue(output.hideManualStopwatch)
    }

    func testHoldingStopWithinValidWindow() {
        var tracker = FullComputerDecoStopTracker.initial
        _ = evaluate(depth: stopDepth + 0.8, tracker: &tracker, remainingMinutes: 2, remainingStops: 2)
        let output = evaluate(depth: stopDepth, tracker: &tracker, remainingMinutes: 2, remainingStops: 2)
        XCTAssertEqual(output.state, .holdingStop)
        XCTAssertEqual(output.direction, .hold)
        XCTAssertEqual(output.panelAccent, .green)
        XCTAssertTrue(output.timerAccruing)
        XCTAssertEqual(output.stopRemainingSeconds, 120)
    }

    func testTooShallowSuspendsTimer() {
        var tracker = engagedTracker()
        let output = evaluate(depth: stopDepth - 1.0, tracker: &tracker, remainingMinutes: 2, remainingStops: 2)
        XCTAssertEqual(output.state, .tooShallow)
        XCTAssertEqual(output.titleKey, "live.fc.deco.too_shallow.title")
        XCTAssertEqual(output.direction, .descend)
        XCTAssertFalse(output.timerAccruing)
    }

    func testTooDeepSuspendsTimer() {
        var tracker = engagedTracker()
        let output = evaluate(depth: stopDepth + 1.5, tracker: &tracker, remainingMinutes: 2, remainingStops: 2)
        XCTAssertEqual(output.state, .tooDeep)
        XCTAssertEqual(output.titleKey, "live.fc.deco.too_deep.title")
        XCTAssertEqual(output.direction, .ascend)
        XCTAssertFalse(output.timerAccruing)
    }

    func testResetThresholdTriggersRecalculation() {
        var tracker = engagedTracker()
        let output = evaluate(depth: stopDepth + 2.5, tracker: &tracker, remainingMinutes: 2, remainingStops: 2)
        XCTAssertEqual(output.state, .stopRecalculation)
        XCTAssertTrue(tracker.progressInvalidated)
    }

    func testHysteresisReducesOscillationAtShallowEdge() {
        var tracker = engagedTracker()
        let shallow = evaluate(depth: stopDepth - 0.7, tracker: &tracker, remainingMinutes: 2, remainingStops: 2)
        XCTAssertEqual(shallow.state, .tooShallow)
        let recovered = evaluate(depth: stopDepth - 0.4, tracker: &tracker, remainingMinutes: 2, remainingStops: 2)
        XCTAssertEqual(recovered.state, .holdingStop)
    }

    func testCeilingViolationTakesPriority() {
        let output = evaluate(
            depth: 8,
            remainingMinutes: 2,
            remainingStops: 2,
            ceilingViolation: true,
            ceilingMeters: 9
        )
        XCTAssertEqual(output.state, .ceilingViolation)
        XCTAssertEqual(output.panelAccent, .red)
    }

    func testDecoCompletedWhenNoStopsRemain() {
        let output = evaluate(
            depth: stopDepth,
            remainingMinutes: nil,
            remainingStops: 0,
            ceilingMeters: 0
        )
        XCTAssertEqual(output.state, .decoCompleted)
        XCTAssertEqual(output.panelAccent, .green)
    }

    func testEngineIntegratesStopStateInSnapshot() throws {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        var engine = try FullComputerRuntimeEngine(sessionStart: start)
        _ = engine.ingestSample(depthMeters: 40, timestamp: start)
        for minute in 1...28 {
            engine.tick(now: start.addingTimeInterval(Double(minute * 60)))
        }
        let presentation = engine.snapshot.decoPresentation
        if presentation.mode == .decompression {
            XCTAssertNotNil(presentation.stopState)
            XCTAssertTrue(presentation.showDecoProgressPanel)
        }
    }

    @MainActor
    func testCeilingViolationHapticFiresOnce() {
        let coordinator = FullComputerDecoHapticCoordinator.shared
        coordinator.resetForTests()
        let base = decoPresentation(ceilingViolation: false, stopState: .holdingStop)
        coordinator.handlePresentationChange(base)
        XCTAssertEqual(coordinator.testHook_playCount, 0)
        coordinator.handlePresentationChange(decoPresentation(ceilingViolation: true, stopState: .ceilingViolation))
        XCTAssertGreaterThan(coordinator.testHook_playCount, 0)
        let prior = coordinator.testHook_playCount
        coordinator.handlePresentationChange(decoPresentation(ceilingViolation: true, stopState: .ceilingViolation))
        XCTAssertEqual(coordinator.testHook_playCount, prior)
    }

    // MARK: - Helpers

    private func engagedTracker() -> FullComputerDecoStopTracker {
        var tracker = FullComputerDecoStopTracker.initial
        _ = evaluate(depth: stopDepth, tracker: &tracker, remainingMinutes: 2, remainingStops: 2)
        return tracker
    }

    private func evaluate(
        depth: Double,
        tracker: inout FullComputerDecoStopTracker,
        remainingMinutes: Int?,
        remainingStops: Int,
        ceilingViolation: Bool = false,
        ceilingMeters: Double = 6
    ) -> FullComputerDecoStopMachineOutput {
        let output = FullComputerDecoStopStateMachine.evaluate(
            input: FullComputerDecoStopMachineInput(
                depthMeters: depth,
                stopDepthMeters: stopDepth,
                modelRemainingMinutes: remainingMinutes,
                remainingStopCount: remainingStops,
                ceilingViolation: ceilingViolation,
                ceilingMetersExact: ceilingMeters,
                decoRequired: true,
                deltaSeconds: 1
            ),
            tracker: tracker
        )
        tracker = output.tracker
        return output
    }

    private func evaluate(
        depth: Double,
        remainingMinutes: Int?,
        remainingStops: Int,
        ceilingViolation: Bool = false,
        ceilingMeters: Double = 6
    ) -> FullComputerDecoStopMachineOutput {
        var tracker = FullComputerDecoStopTracker.initial
        return evaluate(
            depth: depth,
            tracker: &tracker,
            remainingMinutes: remainingMinutes,
            remainingStops: remainingStops,
            ceilingViolation: ceilingViolation,
            ceilingMeters: ceilingMeters
        )
    }

    private func decoPresentation(
        ceilingViolation: Bool,
        stopState: FullComputerDecoStopState
    ) -> FullComputerDecoPresentation {
        FullComputerDecoPresentation(
            mode: .decompression,
            immersionAccent: ceilingViolation ? .ceilingViolation : .decompression,
            immersionStatusKey: "live.fc.status.in_deco",
            ndlDisplayMinutes: nil,
            ndlAccent: nil,
            ttsMinutes: 30,
            runtimeMinutes: 42,
            ceilingMetersExact: 6,
            ceilingMetersRounded: 6,
            nextStopDepthMeters: 6,
            nextStopMinutes: 2,
            remainingStopCount: 2,
            ceilingViolation: ceilingViolation,
            ascentAllowedBetweenStops: false,
            showDecoStopPanel: true,
            showCeilingViolationBanner: ceilingViolation,
            usedConservativeFallback: false,
            diagnostics: [],
            stopState: stopState,
            stopDirection: .hold,
            stopPanelAccent: .green,
            stopPanelTitleKey: "live.fc.deco.hold.title",
            stopInstructionKey: "live.fc.deco.instruction.maintain_depth",
            stopRemainingSeconds: 120,
            activeGasLabel: "Air",
            showDecoProgressPanel: true,
            hideManualStopwatch: true,
            timerAccruing: true
        )
    }
}
