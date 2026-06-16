import Foundation

enum FullComputerGasSwitchAuditKind: String, Codable, Hashable {
    case confirmed
    case ignored
    case unavailable
    case offPlan
}

struct FullComputerGasSwitchAuditEvent: Codable, Hashable, Identifiable {
    let id: UUID
    let timestamp: Date
    let kind: FullComputerGasSwitchAuditKind
    let depthMeters: Double
    let fromGasMixId: UUID
    let toGasMixId: UUID?
    let note: String?

    init(
        id: UUID = UUID(),
        timestamp: Date,
        kind: FullComputerGasSwitchAuditKind,
        depthMeters: Double,
        fromGasMixId: UUID,
        toGasMixId: UUID?,
        note: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.kind = kind
        self.depthMeters = depthMeters
        self.fromGasMixId = fromGasMixId
        self.toGasMixId = toGasMixId
        self.note = note
    }
}

struct FullComputerGasSwitchTracker: Codable, Hashable {
    var confirmedGasMixIds: Set<UUID>
    var ignoredOpportunityKeys: Set<String>
    var unavailableGasMixIds: Set<UUID>
    var events: [FullComputerGasSwitchAuditEvent]
    var activeMissedGasMixId: UUID?

    static var initial: FullComputerGasSwitchTracker {
        FullComputerGasSwitchTracker(
            confirmedGasMixIds: [],
            ignoredOpportunityKeys: [],
            unavailableGasMixIds: [],
            events: [],
            activeMissedGasMixId: nil
        )
    }

    mutating func bootstrap(bottomGasMixId: UUID) {
        confirmedGasMixIds.insert(bottomGasMixId)
    }

    static func opportunityKey(gasMixId: UUID, switchDepthMeters: Double) -> String {
        "\(gasMixId.uuidString)|\(Int((switchDepthMeters * 10).rounded()))"
    }
}

enum FullComputerGasSwitchSurface: Equatable, Hashable, Codable {
    case none
    case available(FullComputerGasSwitchPrompt)
    case missed(FullComputerGasSwitchMissedPrompt)
}

struct FullComputerGasSwitchPrompt: Equatable, Hashable, Codable {
    let activeGasLabel: String
    let suggestedGasLabel: String
    let suggestedGasMixId: UUID
    let switchDepthMeters: Double
    let currentDepthMeters: Double
    let currentPPO2: Double
    let isBreathable: Bool
    let isOffPlan: Bool
    let verifyCylinderNoteKey: String
}

struct FullComputerGasSwitchMissedPrompt: Equatable, Hashable, Codable {
    let activeGasLabel: String
    let suggestedGasLabel: String
    let suggestedGasMixId: UUID
    let switchDepthMeters: Double
    let canStillSwitch: Bool
    let ttsUsesActiveGasOnly: Bool
}

struct FullComputerRuntimeGasRow: Identifiable, Hashable, Codable {
    let id: UUID
    let label: String
    let switchDepthMeters: Double?
    let status: Status
    let currentPPO2: Double?
    let isSelectable: Bool

    enum Status: String, Codable, Hashable {
        case active
        case available
        case unavailable
        case unsafe
        case disabled
    }
}
