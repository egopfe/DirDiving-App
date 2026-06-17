import Foundation

enum ApneaWatchStage: String, Equatable {
    case ready
    case dive
    case ascent
}

struct ApneaWatchPresentationInput: Equatable {
    var isSessionStarted: Bool
    var currentDepthMeters: Double
    var maxDepthMeters: Double
    var temperatureCelsius: Double?
    var diveElapsedSeconds: TimeInterval
    var diveCount: Int
    var verticalSpeedMetersPerSecond: Double
    var targetDepthMeters: Double
    var recoveryPolicyLabel: String
    var activeAlarmCount: Int
    var buddyReminderEnabled: Bool
    var sensorDegraded: Bool
    var hapticsEnabled: Bool
    var missionModeEnabled: Bool
    var markerIndicatorActive: Bool
    var targetIndicatorActive: Bool
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
}

enum ApneaWatchPresentation {
    static func make(_ input: ApneaWatchPresentationInput) -> ApneaWatchPresentationOutput {
        let stage: ApneaWatchStage
        if !input.isSessionStarted {
            stage = .ready
        } else if input.verticalSpeedMetersPerSecond > 0.05 {
            stage = .ascent
        } else {
            stage = .dive
        }

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

        return ApneaWatchPresentationOutput(
            stage: stage,
            startEnabled: startEnabled,
            startDisabledReason: startDisabledReason,
            verticalSpeedText: verticalSpeedText,
            verticalDirectionText: verticalDirectionText,
            sensorLabel: sensorLabel,
            alarmLabel: alarmLabel,
            missionLabel: missionLabel
        )
    }
}
