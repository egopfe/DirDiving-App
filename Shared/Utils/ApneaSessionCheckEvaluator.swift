import Foundation

enum ApneaSessionCheckEvaluator {
    struct Input: Equatable, Sendable {
        var profile: ApneaSessionProfile?
        var recoveryPolicy: ApneaRecoveryPolicy
        var recoveryAlertsEnabled: Bool
        var buddyReminderShown: Bool
        var buddyChecklistConfirmed: Bool
        var watchBatteryLow: Bool?
        var depthSensorAvailable: Bool?
        var heartRateAvailable: Bool?
    }

    static func evaluate(_ input: Input) -> ApneaSessionCheckResult {
        var issues: [ApneaSessionCheckIssue] = []
        var status: ApneaSessionCheckStatus = .ready

        guard let profile = input.profile else {
            return ApneaSessionCheckResult(
                status: .incomplete,
                profileKind: .freeTraining,
                recoveryAlertsEnabled: input.recoveryAlertsEnabled,
                buddyReminderShown: input.buddyReminderShown,
                issues: [ApneaSessionCheckIssue(localizationKey: "apnea.session_check.missing_profile", severity: .incomplete)]
            )
        }

        if !input.buddyChecklistConfirmed {
            issues.append(ApneaSessionCheckIssue(localizationKey: "apnea.session_check.buddy_not_confirmed", severity: .warning))
            status = maxStatus(status, .warning)
        }

        if input.recoveryPolicy.minimumSurfaceSeconds < 30 {
            issues.append(ApneaSessionCheckIssue(localizationKey: "apnea.session_check.recovery_short", severity: .warning))
            status = maxStatus(status, .warning)
        }

        if input.depthSensorAvailable == false, profile.kind == .depthConstantWeight {
            issues.append(ApneaSessionCheckIssue(localizationKey: "apnea.session_check.depth_unavailable", severity: .warning))
            status = maxStatus(status, .warning)
        }

        if input.heartRateAvailable == false {
            issues.append(ApneaSessionCheckIssue(localizationKey: "apnea.session_check.sensor_incomplete", severity: .warning))
            status = maxStatus(status, .warning)
        }

        if input.watchBatteryLow == true {
            issues.append(ApneaSessionCheckIssue(localizationKey: "apnea.session_check.watch_battery_low", severity: .warning))
            status = maxStatus(status, .warning)
        }

        return ApneaSessionCheckResult(
            status: status,
            profileKind: profile.kind,
            recoveryAlertsEnabled: input.recoveryAlertsEnabled,
            buddyReminderShown: input.buddyReminderShown,
            issues: issues
        )
    }

    private static func maxStatus(_ lhs: ApneaSessionCheckStatus, _ rhs: ApneaSessionCheckStatus) -> ApneaSessionCheckStatus {
        let order: [ApneaSessionCheckStatus] = [.ready, .warning, .incomplete, .blocked]
        let li = order.firstIndex(of: lhs) ?? 0
        let ri = order.firstIndex(of: rhs) ?? 0
        return order[max(li, ri)]
    }
}
