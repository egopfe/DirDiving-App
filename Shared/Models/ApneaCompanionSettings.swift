import Foundation

struct ApneaCompanionSettings: Codable, Hashable, Sendable {
    static let currentSchemaVersion = 1

    var schemaVersion: Int
    var descentDetectionDepthMeters: Double
    var surfaceDetectionDepthMeters: Double
    var minimumRecoverySeconds: TimeInterval
    var useMetricUnits: Bool
    var missionModeEnabled: Bool
    var hapticsEnabled: Bool
    var soundsEnabled: Bool

    static let `default` = ApneaCompanionSettings(
        schemaVersion: currentSchemaVersion,
        descentDetectionDepthMeters: 0.8,
        surfaceDetectionDepthMeters: 0.5,
        minimumRecoverySeconds: 60,
        useMetricUnits: true,
        missionModeEnabled: false,
        hapticsEnabled: true,
        soundsEnabled: true
    )
}
