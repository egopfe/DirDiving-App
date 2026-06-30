import Foundation

enum ApneaTrainingTableKind: String, Codable, CaseIterable, Hashable, Sendable {
    case co2
    case o2
}

struct ApneaTrainingStep: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var orderIndex: Int
    var holdSeconds: TimeInterval
    var recoverySeconds: TimeInterval

    init(id: UUID = UUID(), orderIndex: Int, holdSeconds: TimeInterval, recoverySeconds: TimeInterval) {
        self.id = id
        self.orderIndex = orderIndex
        self.holdSeconds = holdSeconds
        self.recoverySeconds = recoverySeconds
    }
}

struct ApneaTrainingTable: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var kind: ApneaTrainingTableKind
    var displayName: String
    var repetitions: Int
    var steps: [ApneaTrainingStep]
    var disclaimerAcknowledged: Bool

    init(
        id: UUID = UUID(),
        kind: ApneaTrainingTableKind,
        displayName: String,
        repetitions: Int,
        steps: [ApneaTrainingStep],
        disclaimerAcknowledged: Bool = false
    ) {
        self.id = id
        self.kind = kind
        self.displayName = displayName
        self.repetitions = repetitions
        self.steps = steps
        self.disclaimerAcknowledged = disclaimerAcknowledged
    }
}
