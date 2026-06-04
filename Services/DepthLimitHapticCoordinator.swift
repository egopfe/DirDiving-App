import Foundation
import WatchKit

/// Throttled depth-limit haptics for Apple Watch (no-op on simulator when haptics unavailable).
@MainActor
final class DepthLimitHapticCoordinator {
    private var lastState: DepthSafetyState = .normal
    private var lastHapticDate: Date?
    private var transitionGeneration: UInt64 = 0

    enum DelayedHapticDecision: Equatable {
        case played
        case suppressed
    }

    var testHook_onDelayedHapticDecision: ((DelayedHapticDecision) -> Void)?

    func reset() {
        transitionGeneration &+= 1
        lastState = .normal
        lastHapticDate = nil
    }

    func handle(depthMeters: Double, hapticsEnabled: Bool) {
        let state = DepthSafetyState.from(depthMeters: depthMeters)
        guard hapticsEnabled else {
            if state != lastState {
                transitionGeneration &+= 1
            }
            lastState = state
            return
        }

        let now = Date()
        let interval = throttleInterval(for: state)
        let stateChanged = state != lastState
        if stateChanged {
            transitionGeneration &+= 1
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
        let token = transitionGeneration
        playHaptic(for: state, isInitialTransition: stateChanged, token: token)
    }

    private func throttleInterval(for state: DepthSafetyState) -> TimeInterval {
        switch state {
        case .normal: return .infinity
        case .caution: return 30
        case .critical: return 15
        case .exceeded: return 10
        }
    }

    private var hapticsEnabledNow: Bool {
        UserDefaults.standard.object(forKey: HapticService.hapticsEnabledKey) == nil
            ? true
            : UserDefaults.standard.bool(forKey: HapticService.hapticsEnabledKey)
    }

    private func playHaptic(for state: DepthSafetyState, isInitialTransition: Bool, token: UInt64) {
        let device = WKInterfaceDevice.current()
        switch state {
        case .normal:
            break
        case .caution:
            device.play(.notification)
        case .critical:
            device.play(.failure)
            if isInitialTransition {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                    self?.playDelayedSecondaryPulse(expectedState: .critical, token: token, haptic: .retry)
                }
            }
        case .exceeded:
            device.play(.failure)
            if isInitialTransition {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                    self?.playDelayedSecondaryPulse(expectedState: .exceeded, token: token, haptic: .failure)
                }
            } else {
                device.play(.retry)
            }
        }
    }

    private func playDelayedSecondaryPulse(expectedState: DepthSafetyState, token: UInt64, haptic: WKHapticType) {
        guard transitionGeneration == token,
              lastState == expectedState,
              hapticsEnabledNow else {
            testHook_onDelayedHapticDecision?(.suppressed)
            return
        }
        WKInterfaceDevice.current().play(haptic)
        testHook_onDelayedHapticDecision?(.played)
    }

    var testHook_transitionGeneration: UInt64 { transitionGeneration }

    var testHook_lastState: DepthSafetyState { lastState }
}
