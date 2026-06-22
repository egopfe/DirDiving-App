import Foundation

enum CompanionActivityCopy {
    static func title(for mode: DIRActivityMode) -> String {
        switch mode {
        case .diving: return DIRIOSLocalizer.string("companion.activity.diving.title")
        case .apnea: return DIRIOSLocalizer.string("companion.activity.apnea.title")
        case .snorkeling: return DIRIOSLocalizer.string("companion.activity.snorkeling.title")
        }
    }

    static func subtitle(for mode: DIRActivityMode) -> String {
        switch mode {
        case .diving: return DIRIOSLocalizer.string("companion.activity.diving.subtitle")
        case .apnea: return DIRIOSLocalizer.string("companion.activity.apnea.subtitle")
        case .snorkeling: return DIRIOSLocalizer.string("companion.activity.snorkeling.subtitle")
        }
    }

    static func features(for mode: DIRActivityMode) -> [String] {
        switch mode {
        case .diving:
            return [
                DIRIOSLocalizer.string("companion.activity.diving.feature.planner"),
                DIRIOSLocalizer.string("companion.activity.diving.feature.decompression"),
                DIRIOSLocalizer.string("companion.activity.diving.feature.logbook"),
            ]
        case .apnea:
            return [
                DIRIOSLocalizer.string("companion.activity.apnea.feature.time"),
                DIRIOSLocalizer.string("companion.activity.apnea.feature.recovery"),
                DIRIOSLocalizer.string("companion.activity.apnea.feature.statistics"),
            ]
        case .snorkeling:
            return [
                DIRIOSLocalizer.string("companion.activity.snorkeling.feature.navigation"),
                DIRIOSLocalizer.string("companion.activity.snorkeling.feature.waypoints"),
                DIRIOSLocalizer.string("companion.activity.snorkeling.feature.return"),
            ]
        }
    }

    static func accessibilitySummary(for mode: DIRActivityMode, isLastUsed: Bool = false) -> String {
        let features = features(for: mode).joined(separator: ", ")
        let summary = String(
            format: DIRIOSLocalizer.string("companion.activity.card.a11y.summary"),
            title(for: mode),
            subtitle(for: mode),
            features
        )
        guard isLastUsed else { return summary }
        return "\(summary) \(lastUsedBadge())"
    }

    static func lastUsedBadge() -> String {
        DIRIOSLocalizer.string("companion.activitySelection.lastUsed")
    }

    static func accessibilityHint(for mode: DIRActivityMode, isAvailable: Bool) -> String {
        if isAvailable {
            return String(
                format: DIRIOSLocalizer.string("companion.activity.card.a11y.hint"),
                title(for: mode)
            )
        }
        return DIRIOSLocalizer.string("companion.activitySelection.unavailable")
    }
}
