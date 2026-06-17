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
    var wasReached: Bool

    init(
        id: UUID = UUID(),
        kind: ApneaTargetKind,
        label: String,
        targetDepthMeters: Double? = nil,
        targetDurationSeconds: TimeInterval? = nil,
        wasReached: Bool = false
    ) {
        self.id = id
        self.kind = kind
        self.label = label
        self.targetDepthMeters = targetDepthMeters
        self.targetDurationSeconds = targetDurationSeconds
        self.wasReached = wasReached
    }
}
