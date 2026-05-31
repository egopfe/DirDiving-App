import Foundation

@MainActor
final class AscentSafetyHapticCoordinator {
    private var repeatTask: Task<Void, Never>?
    private var isAlarmActive = false

    func update(isOverLimit: Bool) {
        if isOverLimit {
            startIfNeeded()
        } else {
            clear()
        }
    }

    func refreshHapticsAfterPreferenceChange() {
        guard isAlarmActive else { return }
        HapticService.shared.ascentAlarmTriggered()
        restartRepeatTaskIfNeeded()
    }

    func clear() {
        repeatTask?.cancel()
        repeatTask = nil
        if isAlarmActive {
            HapticService.shared.ascentAlarmCleared()
        }
        isAlarmActive = false
    }

    private func startIfNeeded() {
        let wasActive = isAlarmActive
        isAlarmActive = true
        if !wasActive {
            HapticService.shared.ascentAlarmTriggered()
        } else {
            HapticService.shared.ascentAlarmRepeatIfNeeded()
        }
        restartRepeatTaskIfNeeded()
    }

    private func restartRepeatTaskIfNeeded() {
        guard isAlarmActive else { return }
        repeatTask?.cancel()
        repeatTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(HapticService.ascentAlarmRepeatInterval * 1_000_000_000))
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    HapticService.shared.ascentAlarmRepeatIfNeeded()
                }
            }
        }
    }
}
