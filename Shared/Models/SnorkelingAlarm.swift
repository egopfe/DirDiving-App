import Foundation

enum SnorkelingAlarmKind: String, Codable, CaseIterable, Hashable, Sendable {
    case maxDepth
    case maxDuration
    case maxDistance
    case maxDipDuration
    case maxAscentRate
    case batteryLow
    case temperatureOutOfRange
    case gpsDegraded
    case gpsLost
    case sensorDegraded
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
    var thresholdTemperatureCelsius: Double?
    var thresholdAscentRateMetersPerSecond: Double?
    var thresholdDipDurationSeconds: TimeInterval?
    var hysteresisMeters: Double?
    var hysteresisSeconds: TimeInterval?
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
        thresholdTemperatureCelsius: Double? = nil,
        thresholdAscentRateMetersPerSecond: Double? = nil,
        thresholdDipDurationSeconds: TimeInterval? = nil,
        hysteresisMeters: Double? = nil,
        hysteresisSeconds: TimeInterval? = nil,
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
        self.thresholdTemperatureCelsius = thresholdTemperatureCelsius
        self.thresholdAscentRateMetersPerSecond = thresholdAscentRateMetersPerSecond
        self.thresholdDipDurationSeconds = thresholdDipDurationSeconds
        self.hysteresisMeters = hysteresisMeters
        self.hysteresisSeconds = hysteresisSeconds
        self.isEnabled = isEnabled
        self.minimumRepeatSeconds = minimumRepeatSeconds
    }
}
