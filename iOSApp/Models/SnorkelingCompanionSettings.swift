import Foundation

struct SnorkelingCompanionSettings: Codable, Hashable, Sendable {
    static let currentSchemaVersion = 2
    static let storageNamespace = "dirdiving.settings.snorkeling.v1"

    var schemaVersion: Int
    var autoWaterDetectionEnabled: Bool
    var dipThresholdMeters: Double
    var surfaceDebounceSeconds: TimeInterval
    var gpsTrackingEnabled: Bool
    var returnToEntryDistanceMeters: Double
    var sessionDurationAlertMinutes: Int
    var maxSessionDurationMinutes: Int
    var maxDistanceMeters: Double
    var offRouteThresholdMeters: Double
    var gpsQualityWarningAccuracyMeters: Double
    var buddyReminderEnabled: Bool
    var defaultReturnAlertPolicy: SnorkelingReturnAlertPolicy
    var hapticsEnabled: Bool
    var missionModeEnabled: Bool

    static let `default` = SnorkelingCompanionSettings(
        schemaVersion: currentSchemaVersion,
        autoWaterDetectionEnabled: true,
        dipThresholdMeters: 0.8,
        surfaceDebounceSeconds: 2,
        gpsTrackingEnabled: true,
        returnToEntryDistanceMeters: 50,
        sessionDurationAlertMinutes: 90,
        maxSessionDurationMinutes: 120,
        maxDistanceMeters: 1_500,
        offRouteThresholdMeters: SnorkelingOffRouteDetector.defaultThresholdMeters,
        gpsQualityWarningAccuracyMeters: 35,
        buddyReminderEnabled: false,
        defaultReturnAlertPolicy: .halfPlannedTime,
        hapticsEnabled: true,
        missionModeEnabled: false
    )

    init(
        schemaVersion: Int,
        autoWaterDetectionEnabled: Bool,
        dipThresholdMeters: Double,
        surfaceDebounceSeconds: TimeInterval,
        gpsTrackingEnabled: Bool,
        returnToEntryDistanceMeters: Double,
        sessionDurationAlertMinutes: Int,
        maxSessionDurationMinutes: Int,
        maxDistanceMeters: Double,
        offRouteThresholdMeters: Double,
        gpsQualityWarningAccuracyMeters: Double,
        buddyReminderEnabled: Bool,
        defaultReturnAlertPolicy: SnorkelingReturnAlertPolicy,
        hapticsEnabled: Bool,
        missionModeEnabled: Bool
    ) {
        self.schemaVersion = schemaVersion
        self.autoWaterDetectionEnabled = autoWaterDetectionEnabled
        self.dipThresholdMeters = dipThresholdMeters
        self.surfaceDebounceSeconds = surfaceDebounceSeconds
        self.gpsTrackingEnabled = gpsTrackingEnabled
        self.returnToEntryDistanceMeters = returnToEntryDistanceMeters
        self.sessionDurationAlertMinutes = sessionDurationAlertMinutes
        self.maxSessionDurationMinutes = maxSessionDurationMinutes
        self.maxDistanceMeters = maxDistanceMeters
        self.offRouteThresholdMeters = offRouteThresholdMeters
        self.gpsQualityWarningAccuracyMeters = gpsQualityWarningAccuracyMeters
        self.buddyReminderEnabled = buddyReminderEnabled
        self.defaultReturnAlertPolicy = defaultReturnAlertPolicy
        self.hapticsEnabled = hapticsEnabled
        self.missionModeEnabled = missionModeEnabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? 1
        schemaVersion = decodedVersion
        autoWaterDetectionEnabled = try container.decodeIfPresent(Bool.self, forKey: .autoWaterDetectionEnabled) ?? Self.default.autoWaterDetectionEnabled
        dipThresholdMeters = try container.decodeIfPresent(Double.self, forKey: .dipThresholdMeters) ?? Self.default.dipThresholdMeters
        surfaceDebounceSeconds = try container.decodeIfPresent(TimeInterval.self, forKey: .surfaceDebounceSeconds) ?? Self.default.surfaceDebounceSeconds
        gpsTrackingEnabled = try container.decodeIfPresent(Bool.self, forKey: .gpsTrackingEnabled) ?? Self.default.gpsTrackingEnabled
        returnToEntryDistanceMeters = try container.decodeIfPresent(Double.self, forKey: .returnToEntryDistanceMeters) ?? Self.default.returnToEntryDistanceMeters
        sessionDurationAlertMinutes = try container.decodeIfPresent(Int.self, forKey: .sessionDurationAlertMinutes) ?? Self.default.sessionDurationAlertMinutes
        maxSessionDurationMinutes = try container.decodeIfPresent(Int.self, forKey: .maxSessionDurationMinutes) ?? Self.default.maxSessionDurationMinutes
        maxDistanceMeters = try container.decodeIfPresent(Double.self, forKey: .maxDistanceMeters) ?? Self.default.maxDistanceMeters
        offRouteThresholdMeters = try container.decodeIfPresent(Double.self, forKey: .offRouteThresholdMeters) ?? Self.default.offRouteThresholdMeters
        gpsQualityWarningAccuracyMeters = try container.decodeIfPresent(Double.self, forKey: .gpsQualityWarningAccuracyMeters) ?? Self.default.gpsQualityWarningAccuracyMeters
        buddyReminderEnabled = try container.decodeIfPresent(Bool.self, forKey: .buddyReminderEnabled) ?? Self.default.buddyReminderEnabled
        defaultReturnAlertPolicy = try container.decodeIfPresent(SnorkelingReturnAlertPolicy.self, forKey: .defaultReturnAlertPolicy) ?? Self.default.defaultReturnAlertPolicy
        hapticsEnabled = try container.decodeIfPresent(Bool.self, forKey: .hapticsEnabled) ?? Self.default.hapticsEnabled
        missionModeEnabled = try container.decodeIfPresent(Bool.self, forKey: .missionModeEnabled) ?? Self.default.missionModeEnabled
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion
        case autoWaterDetectionEnabled
        case dipThresholdMeters
        case surfaceDebounceSeconds
        case gpsTrackingEnabled
        case returnToEntryDistanceMeters
        case sessionDurationAlertMinutes
        case maxSessionDurationMinutes
        case maxDistanceMeters
        case offRouteThresholdMeters
        case gpsQualityWarningAccuracyMeters
        case buddyReminderEnabled
        case defaultReturnAlertPolicy
        case hapticsEnabled
        case missionModeEnabled
    }
}
