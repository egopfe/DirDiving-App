import Foundation

enum ApneaTargetKind: String, Codable, CaseIterable, Hashable, Sendable {
    case depth
    case duration
    case constantWeight
    case freeImmersion
    case dynamic
    case staticApnea
}

struct ApneaTarget: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var kind: ApneaTargetKind
    var label: String
    var targetDepthMeters: Double?
    var targetDurationSeconds: TimeInterval?
    var direction: ApneaEventDirection
    var isEnabled: Bool
    var wasReached: Bool
    var reachedMessage: String?
    var hysteresisMeters: Double

    init(
        id: UUID = UUID(),
        kind: ApneaTargetKind,
        label: String,
        targetDepthMeters: Double? = nil,
        targetDurationSeconds: TimeInterval? = nil,
        direction: ApneaEventDirection = .descending,
        isEnabled: Bool = true,
        wasReached: Bool = false,
        reachedMessage: String? = nil,
        hysteresisMeters: Double = 0.4
    ) {
        self.id = id
        self.kind = kind
        self.label = label
        self.targetDepthMeters = targetDepthMeters
        self.targetDurationSeconds = targetDurationSeconds
        self.direction = direction
        self.isEnabled = isEnabled
        self.wasReached = wasReached
        self.reachedMessage = reachedMessage
        self.hysteresisMeters = hysteresisMeters
    }
}
