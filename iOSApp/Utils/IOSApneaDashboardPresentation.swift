import Foundation

struct IOSApneaDashboardPresentation: Equatable {
    var hasLastSession: Bool
    var lastSessionDateText: String
    var lastSessionDurationText: String
    var lastSessionMaxDepthText: String
    var lastSessionDiveCountText: String
    var maxDepthText: String
    var bestTimeText: String
    var diveCountText: String
    var sessionDurationText: String
    var totalRecoveryText: String
    var watchConnectivityText: String
    var watchConnectivityIsPositive: Bool
    var emptyStateText: String?
}

enum IOSApneaDashboardPresentationMapper {
    static func make(
        lastSession: ApneaSession?,
        aggregate: ApneaAggregateStatistics,
        watchConnectivityText: String,
        watchConnectivityIsPositive: Bool,
        locale: Locale = .current
    ) -> IOSApneaDashboardPresentation {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        if let lastSession {
            let stats = lastSession.refreshedStatistics()
            return IOSApneaDashboardPresentation(
                hasLastSession: true,
                lastSessionDateText: formatter.string(from: lastSession.createdAt),
                lastSessionDurationText: Formatters.time(stats.sessionDurationSeconds),
                lastSessionMaxDepthText: formatDepth(stats.sessionMaxDepthMeters),
                lastSessionDiveCountText: "\(stats.diveCount)",
                maxDepthText: formatDepth(stats.sessionMaxDepthMeters),
                bestTimeText: Formatters.time(stats.bestDiveDurationSeconds),
                diveCountText: "\(stats.diveCount)",
                sessionDurationText: Formatters.time(stats.sessionDurationSeconds),
                totalRecoveryText: Formatters.time(stats.totalRecoverySeconds),
                watchConnectivityText: watchConnectivityText,
                watchConnectivityIsPositive: watchConnectivityIsPositive,
                emptyStateText: nil
            )
        }

        return IOSApneaDashboardPresentation(
            hasLastSession: false,
            lastSessionDateText: "—",
            lastSessionDurationText: "—",
            lastSessionMaxDepthText: "—",
            lastSessionDiveCountText: "—",
            maxDepthText: aggregate.bestSessionMaxDepthMeters > 0 ? formatDepth(aggregate.bestSessionMaxDepthMeters) : "—",
            bestTimeText: aggregate.bestDiveDurationSeconds > 0 ? Formatters.time(aggregate.bestDiveDurationSeconds) : "—",
            diveCountText: aggregate.totalDiveCount > 0 ? "\(aggregate.totalDiveCount)" : "—",
            sessionDurationText: aggregate.totalUnderwaterSeconds > 0 ? Formatters.time(aggregate.totalUnderwaterSeconds) : "—",
            totalRecoveryText: "—",
            watchConnectivityText: watchConnectivityText,
            watchConnectivityIsPositive: watchConnectivityIsPositive,
            emptyStateText: "apnea.ios.dashboard.empty"
        )
    }

    private static func formatDepth(_ meters: Double) -> String {
        String(format: "%.1f m", meters)
    }
}

enum IOSApneaProfilePresentation {
    static func subtitle(for profile: ApneaCompanionProfile) -> String {
        var parts: [String] = []
        if let depth = profile.targetDepthMeters {
            parts.append(String(format: "%.0f m", depth))
        }
        if let duration = profile.targetDurationSeconds {
            parts.append(Formatters.time(duration))
        }
        let recovery = recoveryLabel(for: profile.recoveryPolicy)
        if !recovery.isEmpty { parts.append(recovery) }
        let alarmCount = profile.alarms.filter(\.isEnabled).count
        if alarmCount > 0 {
            parts.append("\(alarmCount) alarms")
        }
        return parts.joined(separator: " · ")
    }

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
}
