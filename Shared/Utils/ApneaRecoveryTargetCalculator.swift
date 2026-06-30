import Foundation

enum ApneaRecoveryTargetCalculator {
    static func targetSeconds(
        policy: ApneaRecoveryPolicy,
        lastHoldSeconds: TimeInterval
    ) -> TimeInterval {
        ApneaRecoveryComputation.requiredRecoverySeconds(
            policy: policy,
            lastDiveDurationSeconds: max(0, lastHoldSeconds)
        )
    }

    static func remainingSeconds(
        targetSeconds: TimeInterval,
        elapsedSeconds: TimeInterval
    ) -> TimeInterval {
        max(0, targetSeconds - max(0, elapsedSeconds))
    }

    static func isTargetReached(targetSeconds: TimeInterval, elapsedSeconds: TimeInterval) -> Bool {
        guard targetSeconds > 0 else { return true }
        return elapsedSeconds >= targetSeconds
    }
}
