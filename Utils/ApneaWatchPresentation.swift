import Foundation

enum ApneaWatchStage: String, Equatable {
    case ready
    case dive
    case ascent
    case surfaceRecovery
    case sessionSummary
}

enum ApneaRecoveryPresentationState: String, Equatable {
    case inProgress
    case completed
    case insufficient
}

struct ApneaWatchOverlayPresentation: Equatable {
    var kind: ApneaOperationalOverlay.Kind
    var title: String
    var subtitle: String
    var depthMeters: Double?
    var dismissSafe: Bool
}

struct ApneaWatchPresentationInput: Equatable {
    var isSessionStarted: Bool
    var showSessionSummary: Bool
    var currentDepthMeters: Double
    var maxDepthMeters: Double
    var temperatureCelsius: Double?
    var diveElapsedSeconds: TimeInterval
    var diveCount: Int
    var verticalSpeedMetersPerSecond: Double
    var targetDepthMeters: Double
    var recoveryPolicyLabel: String
    var activeAlarmCount: Int
    var configuredAlarmLabels: [String]
    var buddyReminderEnabled: Bool
    var sensorDegraded: Bool
    var hapticsEnabled: Bool
    var missionModeEnabled: Bool
    var surfaceElapsedSeconds: TimeInterval
    var lastDiveDurationSeconds: TimeInterval
    var lastDiveMaxDepthMeters: Double
    var requiredRecoverySeconds: TimeInterval
    var recoveryElapsedSeconds: TimeInterval
    var recoveryRemainingSeconds: TimeInterval
    var recoveryInsufficient: Bool
    var sessionTotalSeconds: TimeInterval
    var totalUnderwaterSeconds: TimeInterval
    var sessionMaxDepthMeters: Double
    var bestDiveDurationSeconds: TimeInterval
    var averageDiveDurationSeconds: TimeInterval
    var sessionWarnings: [String]
    var dataQualityDegraded: Bool
    var activeOverlay: ApneaWatchOverlayPresentation?
}

struct ApneaWatchPresentationOutput: Equatable {
    var stage: ApneaWatchStage
    var startEnabled: Bool
    var startDisabledReason: String?
    var verticalSpeedText: String
    var verticalDirectionText: String
    var sensorLabel: String
    var alarmLabel: String
    var missionLabel: String
    var surfaceElapsedText: String
    var lastDiveDurationText: String
    var lastDiveMaxDepthText: String
    var recoveryRequiredText: String
    var recoveryRemainingText: String?
    var recoveryState: ApneaRecoveryPresentationState
    var recoveryStateText: String
    var recoveryCompleteHapticEligible: Bool
    var summaryDiveCountText: String
    var summaryMaxDepthText: String
    var summaryBestTimeText: String
    var summaryAverageTimeText: String
    var summaryTotalUnderwaterText: String
    var summarySessionDurationText: String
    var summaryWarningsText: String?
    var activeOverlay: ApneaWatchOverlayPresentation?
    var configuredAlarms: [String]
}

enum ApneaWatchPresentation {
    static func make(_ input: ApneaWatchPresentationInput) -> ApneaWatchPresentationOutput {
        let stage = resolveStage(input)
        let startEnabled = !input.sensorDegraded
        let startDisabledReason: String? = startEnabled ? nil : String(localized: "apnea.ready.sensor_unavailable")

        let verticalDirectionText: String
        if input.verticalSpeedMetersPerSecond > 0.05 {
            verticalDirectionText = String(localized: "apnea.vertical.ascent")
        } else if input.verticalSpeedMetersPerSecond < -0.05 {
            verticalDirectionText = String(localized: "apnea.vertical.descent")
        } else {
            verticalDirectionText = String(localized: "apnea.vertical.stable")
        }

        let arrow = input.verticalSpeedMetersPerSecond > 0.05 ? "↑" : (input.verticalSpeedMetersPerSecond < -0.05 ? "↓" : "→")
        let speedAbs = abs(input.verticalSpeedMetersPerSecond)
        let verticalSpeedText = "\(arrow) \(Formatters.one(speedAbs)) m/s"

        let sensorLabel = input.sensorDegraded ? String(localized: "apnea.sensor.degraded") : String(localized: "apnea.sensor.ok")
        let alarmLabel = input.activeAlarmCount > 0
            ? String(format: String(localized: "apnea.ready.alarms_count"), input.activeAlarmCount)
            : String(localized: "apnea.ready.alarms_off")
        let missionLabel = input.missionModeEnabled ? String(localized: "mission_mode.a11y.active") : String(localized: "mission_mode.a11y.inactive")

        let recoveryState = resolveRecoveryState(input)
        let recoveryStateText: String
        switch recoveryState {
        case .inProgress:
            recoveryStateText = String(localized: "apnea.recovery.state.in_progress")
        case .completed:
            recoveryStateText = String(localized: "apnea.recovery.state.completed")
        case .insufficient:
            recoveryStateText = String(localized: "apnea.recovery.state.insufficient")
        }

        let recoveryRemainingText: String? = input.recoveryRemainingSeconds > 0
            ? Formatters.time(input.recoveryRemainingSeconds)
            : nil

        let warnings = input.sessionWarnings + (input.dataQualityDegraded ? [String(localized: "apnea.summary.warning.data_quality")] : [])
        let summaryWarningsText = warnings.isEmpty ? nil : warnings.joined(separator: ", ")

        return ApneaWatchPresentationOutput(
            stage: stage,
            startEnabled: startEnabled,
            startDisabledReason: startDisabledReason,
            verticalSpeedText: verticalSpeedText,
            verticalDirectionText: verticalDirectionText,
            sensorLabel: sensorLabel,
            alarmLabel: alarmLabel,
            missionLabel: missionLabel,
            surfaceElapsedText: Formatters.time(input.surfaceElapsedSeconds),
            lastDiveDurationText: Formatters.time(input.lastDiveDurationSeconds),
            lastDiveMaxDepthText: "\(Formatters.one(input.lastDiveMaxDepthMeters)) m",
            recoveryRequiredText: Formatters.time(input.requiredRecoverySeconds),
            recoveryRemainingText: recoveryRemainingText,
            recoveryState: recoveryState,
            recoveryStateText: recoveryStateText,
            recoveryCompleteHapticEligible: recoveryState == .completed && input.hapticsEnabled,
            summaryDiveCountText: "\(input.diveCount)",
            summaryMaxDepthText: "\(Formatters.one(input.sessionMaxDepthMeters)) m",
            summaryBestTimeText: input.diveCount == 0 ? "--" : Formatters.time(input.bestDiveDurationSeconds),
            summaryAverageTimeText: input.diveCount == 0 ? "--" : Formatters.time(input.averageDiveDurationSeconds),
            summaryTotalUnderwaterText: Formatters.time(input.totalUnderwaterSeconds),
            summarySessionDurationText: Formatters.time(input.sessionTotalSeconds),
            summaryWarningsText: summaryWarningsText,
            activeOverlay: input.activeOverlay,
            configuredAlarms: input.configuredAlarmLabels
        )
    }

    private static func resolveStage(_ input: ApneaWatchPresentationInput) -> ApneaWatchStage {
        if input.showSessionSummary {
            return .sessionSummary
        }
        if !input.isSessionStarted {
            return .ready
        }
        if input.currentDepthMeters < 0.5 && input.recoveryRemainingSeconds > 0 {
            return .surfaceRecovery
        }
        if input.currentDepthMeters < 0.5 && input.verticalSpeedMetersPerSecond <= 0.05 && input.lastDiveDurationSeconds > 0 {
            return .surfaceRecovery
        }
        if input.verticalSpeedMetersPerSecond > 0.05 {
            return .ascent
        }
        if input.currentDepthMeters >= 0.5 {
            return .dive
        }
        return .surfaceRecovery
    }

    private static func resolveRecoveryState(_ input: ApneaWatchPresentationInput) -> ApneaRecoveryPresentationState {
        if input.requiredRecoverySeconds <= 0 {
            return .completed
        }
        if input.recoveryInsufficient {
            return .insufficient
        }
        if input.recoveryRemainingSeconds > 0 {
            return .inProgress
        }
        return .completed
    }
}
