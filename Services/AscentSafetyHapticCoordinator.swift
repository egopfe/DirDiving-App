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

    func clear() {
        repeatTask?.cancel()
        repeatTask = nil
        if isAlarmActive {
            HapticService.shared.ascentAlarmCleared()
        }
        isAlarmActive = false
    }

    private func startIfNeeded() {
        guard !isAlarmActive else { return }
        isAlarmActive = true
        HapticService.shared.ascentAlarmTriggered()
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
