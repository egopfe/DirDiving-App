import Foundation

enum PlannerBriefingFreshnessState: Equatable, Sendable {
    case current
    case old
    case superseded
    case sessionMismatch
    case incomplete
    case unsupported
}

enum PlannerBriefingFreshnessPolicy {
    /// Reference-only briefing cards older than this threshold show a non-blocking stale warning.
    static let staleAfterSeconds: TimeInterval = 7 * 24 * 60 * 60

    static func evaluate(
        manifest: PlannerBriefingCardManifest?,
        isPackageIncomplete: Bool,
        now: Date = Date(),
        activePlannerSessionId: UUID? = nil
    ) -> PlannerBriefingFreshnessState {
        guard let manifest else { return .unsupported }
        if isPackageIncomplete {
            return .incomplete
        }
        if !manifest.referenceOnly {
            return .unsupported
        }
        if let activePlannerSessionId,
           let manifestSession = manifest.plannerSessionId,
           manifestSession != activePlannerSessionId {
            return .sessionMismatch
        }
        let age = now.timeIntervalSince(manifest.generatedAt)
        if age > staleAfterSeconds {
            return .old
        }
        return .current
    }

    static func localizedWarning(for state: PlannerBriefingFreshnessState) -> String? {
        switch state {
        case .current, .superseded:
            return nil
        case .old:
            return String(localized: "watch.planner_briefing.freshness.old")
        case .sessionMismatch:
            return String(localized: "watch.planner_briefing.freshness.session_mismatch")
        case .incomplete:
            return String(localized: "watch.planner_briefing.freshness.incomplete")
        case .unsupported:
            return String(localized: "watch.planner_briefing.freshness.unsupported")
        }
    }

    static func accessibilityLabel(for state: PlannerBriefingFreshnessState) -> String? {
        guard let warning = localizedWarning(for: state) else { return nil }
        return String(format: String(localized: "watch.planner_briefing.freshness.a11y"), warning)
    }

    static func formattedGeneratedAt(_ date: Date, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
