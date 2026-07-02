import Foundation

struct SnorkelingOperationalThresholds: Codable, Hashable, Sendable {
    var maxSessionDurationMinutes: Int
    var maxDistanceMeters: Double
    var returnAlertDistanceMeters: Double
    var returnAlertDurationMinutes: Int
    var defaultReturnAlertPolicy: SnorkelingReturnAlertPolicy
    var offRouteThresholdMeters: Double
    var gpsQualityWarningAccuracyMeters: Double
    var buddyReminderEnabled: Bool

    static let `default` = SnorkelingOperationalThresholds(
        maxSessionDurationMinutes: 120,
        maxDistanceMeters: 1_500,
        returnAlertDistanceMeters: 50,
        returnAlertDurationMinutes: 90,
        defaultReturnAlertPolicy: .halfPlannedTime,
        offRouteThresholdMeters: SnorkelingOffRouteDetector.defaultThresholdMeters,
        gpsQualityWarningAccuracyMeters: 35,
        buddyReminderEnabled: false
    )

    var maxSessionDurationSeconds: TimeInterval {
        TimeInterval(max(1, maxSessionDurationMinutes) * 60)
    }

    var returnAlertDurationSeconds: TimeInterval {
        TimeInterval(max(1, returnAlertDurationMinutes) * 60)
    }

    var gpsQualityThresholds: SnorkelingGPSQualityThresholds {
        SnorkelingGPSQualityThresholds(
            goodAccuracyMeters: 15,
            mediumAccuracyMeters: max(15, gpsQualityWarningAccuracyMeters),
            goodFixAgeSeconds: 10,
            mediumFixAgeSeconds: 20,
            lostFixAgeSeconds: 60
        )
    }
}

enum SnorkelingOperationalConfigurationApplicator {
    static func apply(_ thresholds: SnorkelingOperationalThresholds, to engine: inout SnorkelingSessionEngine) {
        engine.applyOperationalThresholds(thresholds)
    }

    static func mergedMetadata(
        base: SnorkelingRoutePlanningMetadata,
        operational: SnorkelingOperationalThresholds,
        waypointCount: Int
    ) -> SnorkelingRoutePlanningMetadata {
        var metadata = base
        metadata.waypointCount = waypointCount
        metadata.offRouteThresholdMeters = operational.offRouteThresholdMeters
        metadata.maxSessionDurationSeconds = operational.maxSessionDurationSeconds
        metadata.maxDistanceMeters = operational.maxDistanceMeters
        metadata.gpsQualityWarningAccuracyMeters = operational.gpsQualityWarningAccuracyMeters
        metadata.buddyReminderEnabled = operational.buddyReminderEnabled
        if metadata.returnAlertPolicy == .off {
            metadata.returnAlertPolicy = operational.defaultReturnAlertPolicy
        }
        return metadata
    }
}
