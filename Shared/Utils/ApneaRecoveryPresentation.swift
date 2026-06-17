import Foundation

enum ApneaRecoveryPresentation {
    static func recoveryLabel(for policy: ApneaRecoveryPolicy) -> String {
        switch policy.mode {
        case .informationalOnly: return "info"
        case .ratio1to1: return "1:1"
        case .ratio2to1: return "2:1"
        case .fixedDuration: return Formatters.time(policy.fixedDurationSeconds ?? 0)
        case .customRatio:
            if let ratio = policy.customRatio { return String(format: "%.1f:1", ratio) }
            return "custom"
        }
    }

    static func enabledAlarmLabels(from alarms: [ApneaAlarm]) -> [String] {
        alarms.filter(\.isEnabled).map(\.label)
    }
}
