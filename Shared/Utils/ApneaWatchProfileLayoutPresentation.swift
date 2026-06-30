import Foundation

/// One-shot haptic latch per recovery cycle; resets when a new hold starts.
struct ApneaWatchHapticLatch: Equatable, Sendable {
    private(set) var recoveryTargetReachedFired = false
    private(set) var lastRecoveryCycleID: UUID?

    mutating func resetForNewHold(cycleID: UUID) {
        if lastRecoveryCycleID != cycleID {
            recoveryTargetReachedFired = false
            lastRecoveryCycleID = cycleID
        }
    }

    mutating func markRecoveryTargetReached() {
        recoveryTargetReachedFired = true
    }

    func shouldFireRecoveryHaptic(targetReached: Bool) -> Bool {
        targetReached && !recoveryTargetReachedFired
    }
}

struct ApneaWatchProfileLayoutMetrics: Equatable, Sendable {
    var primaryLabelKey: String
    var primaryValue: String
    var secondaryLabelKey: String?
    var secondaryValue: String?
    var tertiaryLabelKey: String?
    var tertiaryValue: String?
    var repetitionText: String?
    var sensorLabels: [String]
}

enum ApneaWatchProfileLayoutPresentation {
    static func make(
        layout: ApneaWatchRuntimeLayout,
        holdSeconds: TimeInterval,
        recoveryElapsed: TimeInterval,
        recoveryTarget: TimeInterval,
        recoveryRemaining: TimeInterval,
        currentDepthMeters: Double,
        maxDepthMeters: Double,
        repetitionCount: Int,
        maxRepetitions: Int?,
        sensorLabels: [String]
    ) -> ApneaWatchProfileLayoutMetrics {
        let holdText = formatTime(holdSeconds)
        let recoveryProgress = recoveryTarget > 0
            ? "\(formatTime(recoveryRemaining)) / \(formatTime(recoveryTarget))"
            : formatTime(recoveryElapsed)
        let repText: String? = {
            if let maxRepetitions { return "\(repetitionCount)/\(maxRepetitions)" }
            if repetitionCount > 0 { return "\(repetitionCount)" }
            return nil
        }()

        switch layout {
        case .staticHoldRecovery:
            return ApneaWatchProfileLayoutMetrics(
                primaryLabelKey: "apnea.watch.layout.hold",
                primaryValue: holdText,
                secondaryLabelKey: "apnea.recovery.title",
                secondaryValue: recoveryProgress,
                tertiaryLabelKey: "apnea.summary.reps",
                tertiaryValue: repText,
                repetitionText: repText,
                sensorLabels: sensorLabels
            )
        case .dynamicHoldReps:
            return ApneaWatchProfileLayoutMetrics(
                primaryLabelKey: "apnea.watch.layout.hold",
                primaryValue: holdText,
                secondaryLabelKey: "apnea.summary.reps",
                secondaryValue: repText,
                tertiaryLabelKey: "apnea.recovery.title",
                tertiaryValue: formatTime(recoveryElapsed),
                repetitionText: repText,
                sensorLabels: sensorLabels
            )
        case .depthMetrics:
            return ApneaWatchProfileLayoutMetrics(
                primaryLabelKey: "apnea.watch.layout.depth",
                primaryValue: String(format: "%.1f m", currentDepthMeters),
                secondaryLabelKey: "apnea.summary.max_depth",
                secondaryValue: String(format: "%.1f m", maxDepthMeters),
                tertiaryLabelKey: "apnea.watch.layout.time",
                tertiaryValue: holdText,
                repetitionText: recoveryProgress,
                sensorLabels: sensorLabels
            )
        case .freeTrainingCompact:
            return ApneaWatchProfileLayoutMetrics(
                primaryLabelKey: "apnea.watch.layout.hold",
                primaryValue: holdText,
                secondaryLabelKey: "apnea.recovery.title",
                secondaryValue: recoveryProgress,
                tertiaryLabelKey: "apnea.sensor_quality.title",
                tertiaryValue: sensorLabels.first,
                repetitionText: nil,
                sensorLabels: sensorLabels
            )
        case .trainingTableCoaching:
            return ApneaWatchProfileLayoutMetrics(
                primaryLabelKey: "apnea.training.coaching.next_hold",
                primaryValue: holdText,
                secondaryLabelKey: "apnea.recovery.title",
                secondaryValue: recoveryProgress,
                tertiaryLabelKey: "apnea.summary.reps",
                tertiaryValue: repText,
                repetitionText: repText,
                sensorLabels: sensorLabels
            )
        }
    }

    static func sessionSummary(
        bestHoldSeconds: TimeInterval,
        maxDepthMeters: Double,
        reps: Int,
        averageRecoverySeconds: TimeInterval,
        quality: ApneaDataQualityLevel
    ) -> ApneaSessionSummaryMetrics {
        ApneaSessionSummaryMetrics(
            bestHoldSeconds: bestHoldSeconds,
            maxDepthMeters: maxDepthMeters,
            repetitionCount: reps,
            averageRecoverySeconds: averageRecoverySeconds,
            dataQuality: quality,
            lastHoldSeconds: bestHoldSeconds,
            averageHoldSeconds: bestHoldSeconds
        )
    }

    private static func formatTime(_ seconds: TimeInterval) -> String {
        let total = Int(max(0, seconds.rounded()))
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
