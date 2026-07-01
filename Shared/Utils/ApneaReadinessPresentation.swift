import Foundation

enum ApneaReadinessPresentation {
    static func checklistSummary(completed: Int, total: Int) -> String {
        String(format: "apnea.checklist.completed_format", completed, total)
    }

    static func sessionCheckStatusKey(for status: ApneaSessionCheckStatus) -> String {
        switch status {
        case .ready: return "apnea.session_check.ready"
        case .warning: return "apnea.session_check.warning"
        case .incomplete, .blocked: return "apnea.session_check.incomplete"
        }
    }

    static func watchPrecheckLabel(completed: Int, total: Int) -> String {
        guard total > 0 else {
            return "apnea.watch.precheck.reminder"
        }
        return String(format: "apnea.watch.precheck.count_format", completed, total)
    }

    static func plannerSessionCheck(
        profile: ApneaSessionProfile?,
        recoveryPolicy: ApneaRecoveryPolicy,
        recoveryAlertsEnabled: Bool,
        buddyChecklistConfirmed: Bool
    ) -> ApneaSessionCheckResult {
        ApneaSessionCheckEvaluator.evaluate(
            ApneaSessionCheckEvaluator.Input(
                profile: profile,
                recoveryPolicy: recoveryPolicy,
                recoveryAlertsEnabled: recoveryAlertsEnabled,
                buddyReminderShown: true,
                buddyChecklistConfirmed: buddyChecklistConfirmed,
                watchBatteryLow: nil,
                depthSensorAvailable: nil,
                heartRateAvailable: nil
            )
        )
    }

    static func canSendToWatch(
        plannerValid: Bool,
        sessionCheck: ApneaSessionCheckResult
    ) -> Bool {
        plannerValid && sessionCheck.isReadyForTraining
    }
}
