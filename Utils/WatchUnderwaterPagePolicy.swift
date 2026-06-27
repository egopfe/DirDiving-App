import Foundation

/// Pages reachable via Digital Crown vertical paging during an active underwater session.
enum WatchUnderwaterPagePolicy {
    static func allowedPages(
        activity: DIRActivityMode,
        divingMode: DIRDivingMode,
        isSessionActive: Bool,
        hasUserImages: Bool,
        includeModeSelection: Bool = false
    ) -> Set<AppPage> {
        guard isSessionActive else {
            return WatchActivityPagePolicy.pages(for: activity, includeModeSelection: includeModeSelection)
        }

        switch activity {
        case .diving:
            var pages: Set<AppPage> = [.live, .compass]
            if hasUserImages {
                pages.insert(.userImages)
            }
            return pages
        case .apnea, .snorkeling:
            return [.live]
        }
    }

    static func isPageAllowedDuringSession(
        _ page: AppPage,
        activity: DIRActivityMode,
        divingMode: DIRDivingMode,
        hasUserImages: Bool
    ) -> Bool {
        allowedPages(
            activity: activity,
            divingMode: divingMode,
            isSessionActive: true,
            hasUserImages: hasUserImages
        ).contains(page)
    }
}
