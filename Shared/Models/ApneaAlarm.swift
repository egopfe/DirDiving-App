import Foundation

enum ApneaAlarmKind: String, Codable, CaseIterable, Hashable, Sendable {
    case depth
    case duration
    case ascentRate
    case recovery
    case custom
}

struct ApneaAlarm: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var kind: ApneaAlarmKind
    var label: String
    var thresholdDepthMeters: Double?
    var thresholdDurationSeconds: TimeInterval?
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        kind: ApneaAlarmKind,
        label: String,
        thresholdDepthMeters: Double? = nil,
        thresholdDurationSeconds: TimeInterval? = nil,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.kind = kind
        self.label = label
        self.thresholdDepthMeters = thresholdDepthMeters
        self.thresholdDurationSeconds = thresholdDurationSeconds
        self.isEnabled = isEnabled
    }
}
