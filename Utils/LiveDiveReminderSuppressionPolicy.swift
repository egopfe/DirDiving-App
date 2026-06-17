import Foundation

/// Aligns dive-reminder overlay suppression with live safety banner priority.
enum LiveDiveReminderSuppressionPolicy {
    struct Input: Equatable {
        var alarmWarningMessage: String?
        var depthSafetyState: DepthSafetyState
        var showAscentAlarmBanner: Bool
        var ascentAlarmEnabled: Bool
        var ascentIsOverLimit: Bool
        var isDepthDataStale: Bool
        var isManualNoDepthSession: Bool
    }

    static func shouldSuppressReminders(_ input: Input) -> Bool {
        if input.alarmWarningMessage != nil { return true }
        if input.depthSafetyState == .exceeded { return true }
        if input.depthSafetyState == .critical { return true }
        if input.depthSafetyState == .caution { return true }
        if input.showAscentAlarmBanner { return true }
        if input.ascentAlarmEnabled, input.ascentIsOverLimit { return true }
        if input.isDepthDataStale { return true }
        return false
    }

    static func shouldSuppressReminders(
        bannerInput: LiveDiveBannerPresentationPolicy.Input,
        alarmWarningMessage: String?,
        ascentAlarmEnabled: Bool,
        ascentIsOverLimit: Bool
    ) -> Bool {
        shouldSuppressReminders(
            Input(
                alarmWarningMessage: alarmWarningMessage,
                depthSafetyState: bannerInput.depthSafetyState,
                showAscentAlarmBanner: bannerInput.showAscentAlarmBanner,
                ascentAlarmEnabled: ascentAlarmEnabled,
                ascentIsOverLimit: ascentIsOverLimit,
                isDepthDataStale: bannerInput.isDepthDataStale,
                isManualNoDepthSession: bannerInput.isManualNoDepthSession
            )
        )
    }
}
