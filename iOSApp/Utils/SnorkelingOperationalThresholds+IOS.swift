import Foundation

extension SnorkelingOperationalThresholds {
    static func from(settings: SnorkelingCompanionSettings) -> SnorkelingOperationalThresholds {
        SnorkelingOperationalThresholds(
            maxSessionDurationMinutes: settings.maxSessionDurationMinutes,
            maxDistanceMeters: settings.maxDistanceMeters,
            returnAlertDistanceMeters: settings.returnToEntryDistanceMeters,
            returnAlertDurationMinutes: settings.sessionDurationAlertMinutes,
            defaultReturnAlertPolicy: settings.defaultReturnAlertPolicy,
            offRouteThresholdMeters: settings.offRouteThresholdMeters,
            gpsQualityWarningAccuracyMeters: settings.gpsQualityWarningAccuracyMeters,
            buddyReminderEnabled: settings.buddyReminderEnabled
        )
    }
}
