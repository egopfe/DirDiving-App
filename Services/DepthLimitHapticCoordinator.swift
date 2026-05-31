import Foundation
import WatchKit

/// Throttled depth-limit haptics for Apple Watch (no-op on simulator when haptics unavailable).
@MainActor
final class DepthLimitHapticCoordinator {
    private var lastState: DepthSafetyState = .normal
    private var lastHapticDate: Date?

    func reset() {
        lastState = .normal
        lastHapticDate = nil
    }

    func handle(depthMeters: Double, hapticsEnabled: Bool) {
        let state = DepthSafetyState.from(depthMeters: depthMeters)
        guard hapticsEnabled else {
            lastState = state
            return
        }

        let now = Date()
        let interval = throttleInterval(for: state)
        let stateChanged = state != lastState
        if stateChanged {
            lastState = state
            if state != .normal {
                lastHapticDate = nil
            }
        }

        guard state != .normal else { return }

        if let lastHapticDate, !stateChanged, now.timeIntervalSince(lastHapticDate) < interval {
            return
        }

        lastHapticDate = now
        playHaptic(for: state, isInitialTransition: stateChanged)
    }

    private func throttleInterval(for state: DepthSafetyState) -> TimeInterval {
        switch state {
        case .normal: return .infinity
        case .caution: return 30
        case .critical: return 15
        case .exceeded: return 10
        }
    }

    private func playHaptic(for state: DepthSafetyState, isInitialTransition: Bool) {
        let device = WKInterfaceDevice.current()
        switch state {
        case .normal:
            break
        case .caution:
            device.play(.notification)
        case .critical:
            device.play(.failure)
            if isInitialTransition {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    device.play(.retry)
                }
            }
        case .exceeded:
            device.play(.failure)
            if isInitialTransition {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    device.play(.failure)
                }
            } else {
                device.play(.retry)
            }
        }
    }
}
