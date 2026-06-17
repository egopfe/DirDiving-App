import Foundation

enum ApneaEventDirection: String, Codable, CaseIterable, Hashable, Sendable {
    case descending
    case ascending
    case both

    func matches(verticalSpeedMetersPerSecond: Double) -> Bool {
        switch self {
        case .descending:
            return verticalSpeedMetersPerSecond > 0
        case .ascending:
            return verticalSpeedMetersPerSecond < 0
        case .both:
            return true
        }
    }
}

enum ApneaAlarmKind: String, Codable, CaseIterable, Hashable, Sendable {
    case depth
    case duration
    case descentRate
    case ascentRate
    case recoveryInsufficient
    case battery
    case sensorDegraded
    case sessionProlonged
    case custom
}

struct ApneaAlarm: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var kind: ApneaAlarmKind
    var label: String
    var thresholdDepthMeters: Double?
    var thresholdDurationSeconds: TimeInterval?
    var thresholdVerticalSpeedMetersPerSecond: Double?
    var thresholdBatteryPercent: Double?
    var direction: ApneaEventDirection
    var isEnabled: Bool
    var hysteresisMeters: Double
    var minimumRepeatSeconds: TimeInterval

    init(
        id: UUID = UUID(),
        kind: ApneaAlarmKind,
        label: String,
        thresholdDepthMeters: Double? = nil,
        thresholdDurationSeconds: TimeInterval? = nil,
        thresholdVerticalSpeedMetersPerSecond: Double? = nil,
        thresholdBatteryPercent: Double? = nil,
        direction: ApneaEventDirection = .both,
        isEnabled: Bool = true,
        hysteresisMeters: Double = 0.4,
        minimumRepeatSeconds: TimeInterval = 3
    ) {
        self.id = id
        self.kind = kind
        self.label = label
        self.thresholdDepthMeters = thresholdDepthMeters
        self.thresholdDurationSeconds = thresholdDurationSeconds
        self.thresholdVerticalSpeedMetersPerSecond = thresholdVerticalSpeedMetersPerSecond
        self.thresholdBatteryPercent = thresholdBatteryPercent
        self.direction = direction
        self.isEnabled = isEnabled
        self.hysteresisMeters = hysteresisMeters
        self.minimumRepeatSeconds = minimumRepeatSeconds
    }
}
