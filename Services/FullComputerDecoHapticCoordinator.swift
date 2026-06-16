import Foundation

@MainActor
final class FullComputerDecoHapticCoordinator {
    static let shared = FullComputerDecoHapticCoordinator()

    private var lastState: FullComputerDecoStopState?
    private var lastCeilingViolation = false

    var testHook_playCount = 0

    private init() {}

    func resetForTests() {
        lastState = nil
        lastCeilingViolation = false
        testHook_playCount = 0
    }

    func handlePresentationChange(_ presentation: FullComputerDecoPresentation?) {
        guard let presentation, presentation.mode == .decompression else {
            lastState = nil
            lastCeilingViolation = false
            return
        }

        if presentation.ceilingViolation, !lastCeilingViolation {
            HapticService.shared.warnIfNeeded()
            testHook_playCount += 1
        }
        lastCeilingViolation = presentation.ceilingViolation

        guard let state = presentation.stopState else { return }
        if state == .ceilingViolation, state != lastState {
            HapticService.shared.criticalConfirm()
            testHook_playCount += 1
        } else if state == .stopRecalculation, state != lastState {
            HapticService.shared.notify()
            testHook_playCount += 1
        }
        lastState = state
    }
}
