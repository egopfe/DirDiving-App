import Foundation

enum SnorkelingAlarmKind: String, Codable, CaseIterable, Hashable, Sendable {
    case maxDepth
    case maxDuration
    case maxDistance
    case batteryLow
    case custom
}

struct SnorkelingAlarm: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var kind: SnorkelingAlarmKind
    var label: String
    var thresholdDepthMeters: Double?
    var thresholdDurationSeconds: TimeInterval?
    var thresholdDistanceMeters: Double?
    var thresholdBatteryPercent: Double?
    var isEnabled: Bool
    var minimumRepeatSeconds: TimeInterval

    init(
        id: UUID = UUID(),
        kind: SnorkelingAlarmKind,
        label: String,
        thresholdDepthMeters: Double? = nil,
        thresholdDurationSeconds: TimeInterval? = nil,
        thresholdDistanceMeters: Double? = nil,
        thresholdBatteryPercent: Double? = nil,
        isEnabled: Bool = true,
        minimumRepeatSeconds: TimeInterval = 3
    ) {
        self.id = id
        self.kind = kind
        self.label = label
        self.thresholdDepthMeters = thresholdDepthMeters
        self.thresholdDurationSeconds = thresholdDurationSeconds
        self.thresholdDistanceMeters = thresholdDistanceMeters
        self.thresholdBatteryPercent = thresholdBatteryPercent
        self.isEnabled = isEnabled
        self.minimumRepeatSeconds = minimumRepeatSeconds
    }
}
