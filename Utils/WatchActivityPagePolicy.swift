import Foundation

/// Activity-scoped Watch vertical page inventory (Command 7 logbook routing remediation).
enum WatchActivityPagePolicy {
    static func pages(
        for activity: DIRActivityMode,
        includeModeSelection: Bool
    ) -> Set<AppPage> {
        var pages: Set<AppPage> = [.live, .compass, .settings, .userImages]
        if includeModeSelection {
            pages.insert(.modeSelection)
        }
        if activity == .diving {
            pages.insert(.diveLog)
        }
        return pages
    }

    static func isPageAllowed(
        _ page: AppPage,
        for activity: DIRActivityMode,
        includeModeSelection: Bool
    ) -> Bool {
        pages(for: activity, includeModeSelection: includeModeSelection).contains(page)
    }

    static func normalizedPage(
        _ page: AppPage,
        for activity: DIRActivityMode,
        includeModeSelection: Bool
    ) -> AppPage {
        isPageAllowed(page, for: activity, includeModeSelection: includeModeSelection) ? page : .live
    }

    /// Pages that must never appear in a non-owning activity root.
    static func forbiddenCrossActivityPages(
        from source: DIRActivityMode,
        to targetLogbookActivity: DIRActivityMode
    ) -> Set<AppPage> {
        guard source != targetLogbookActivity else { return [] }
        switch targetLogbookActivity {
        case .diving:
            return source == .diving ? [] : [.diveLog]
        case .apnea, .snorkeling:
            // Watch has no Apnea/Snorkeling logbook browse tabs today.
            return []
        }
    }
}
