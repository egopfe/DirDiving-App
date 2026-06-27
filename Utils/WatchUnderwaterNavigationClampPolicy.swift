import Foundation

enum WatchUnderwaterNavigationClampPolicy {
    struct ClampResult: Equatable, Sendable {
        var page: AppPage
        var wasBlocked: Bool
        var blockedPage: AppPage?
    }

    static func clampIfNeeded(
        selectedPage: AppPage,
        activity: DIRActivityMode,
        divingMode: DIRDivingMode,
        isSessionActive: Bool,
        hasUserImages: Bool,
        includeModeSelection: Bool
    ) -> ClampResult {
        guard isSessionActive else {
            return ClampResult(page: selectedPage, wasBlocked: false, blockedPage: nil)
        }

        let allowed = WatchUnderwaterPagePolicy.allowedPages(
            activity: activity,
            divingMode: divingMode,
            isSessionActive: true,
            hasUserImages: hasUserImages,
            includeModeSelection: includeModeSelection
        )

        if allowed.contains(selectedPage) {
            return ClampResult(page: selectedPage, wasBlocked: false, blockedPage: nil)
        }

        return ClampResult(page: .live, wasBlocked: true, blockedPage: selectedPage)
    }

    static func blockedMessageKey(activity: DIRActivityMode) -> String {
        switch activity {
        case .diving:
            return "nav.underwater.blocked.diving"
        case .apnea:
            return "nav.underwater.blocked.apnea"
        case .snorkeling:
            return "nav.underwater.blocked.snorkeling"
        }
    }

    static func blockedAccessibilityKey(activity: DIRActivityMode) -> String {
        switch activity {
        case .diving:
            return "nav.underwater.blocked.diving.a11y"
        case .apnea:
            return "nav.underwater.blocked.apnea.a11y"
        case .snorkeling:
            return "nav.underwater.blocked.snorkeling.a11y"
        }
    }
}
