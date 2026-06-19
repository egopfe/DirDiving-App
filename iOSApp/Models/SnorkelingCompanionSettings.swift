import Foundation

struct SnorkelingCompanionSettings: Codable, Hashable, Sendable {
    static let currentSchemaVersion = 1
    static let storageNamespace = "dirdiving.settings.snorkeling.v1"

    var schemaVersion: Int
    var autoWaterDetectionEnabled: Bool
    var dipThresholdMeters: Double
    var surfaceDebounceSeconds: TimeInterval
    var gpsTrackingEnabled: Bool
    var returnToEntryDistanceMeters: Double
    var sessionDurationAlertMinutes: Int
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
        hapticsEnabled: true,
        missionModeEnabled: false
    )
}
