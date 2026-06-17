import Foundation

enum ApneaSessionStartMode: String, Codable, CaseIterable, Hashable, Sendable {
    case manual
    case watch
    case imported
}

enum ApneaSessionState: String, Codable, CaseIterable, Hashable, Sendable {
    case planned
    case active
    case paused
    case completed
    case aborted
}

enum ApneaSessionWarning: String, Codable, CaseIterable, Hashable, Sendable {
    case incompleteRecovery
    case sparseSamples
    case gpsUnavailable
    case dataQualityDegraded
    case schemaMigrated
}

struct ApneaSessionStatistics: Codable, Hashable, Sendable {
    var diveCount: Int
    var totalUnderwaterSeconds: TimeInterval
    /// Maximum depth across all dives in this session (distinct from dive max and personal best).
    var sessionMaxDepthMeters: Double
    var averageDiveDurationSeconds: TimeInterval
    var totalRecoverySeconds: TimeInterval

    static let empty = ApneaSessionStatistics(
        diveCount: 0,
        totalUnderwaterSeconds: 0,
        sessionMaxDepthMeters: 0,
        averageDiveDurationSeconds: 0,
        totalRecoverySeconds: 0
    )

    static func aggregate(from dives: [ApneaDive]) -> ApneaSessionStatistics {
        guard !dives.isEmpty else { return .empty }
        let diveCount = dives.count
        let totalUnderwater = dives.reduce(0) { $0 + max(0, $1.durationSeconds) }
        let sessionMax = dives.map(\.maxDepthMeters).max() ?? 0
        let averageDuration = totalUnderwater / Double(diveCount)
        let totalRecovery = dives.reduce(0) { partial, dive in
            let before = dive.recoveryBefore?.completedSeconds ?? 0
            let after = dive.recoveryAfter?.completedSeconds ?? 0
            return partial + before + after
        }
        return ApneaSessionStatistics(
            diveCount: diveCount,
            totalUnderwaterSeconds: totalUnderwater,
            sessionMaxDepthMeters: sessionMax,
            averageDiveDurationSeconds: averageDuration,
            totalRecoverySeconds: totalRecovery
        )
    }
}

/// Root persisted Apnea session container with explicit schema versioning.
struct ApneaSession: Identifiable, Codable, Hashable, Sendable {
    static let currentSchemaVersion = 1

    let id: UUID
    var schemaVersion: Int
    var startMode: ApneaSessionStartMode
    var state: ApneaSessionState
    var createdAt: Date
    var startedAtMonotonicSeconds: TimeInterval?
    var endedAtMonotonicSeconds: TimeInterval?
    var dives: [ApneaDive]
    var statistics: ApneaSessionStatistics
    var surfaceGPSPoints: [ApneaSurfaceGPSPoint]
    var buddy: ApneaBuddyInfo?
    var equipment: ApneaEquipmentProfile?
    var profile: ApneaProfile?
    var warnings: [ApneaSessionWarning]

    init(
        id: UUID = UUID(),
        schemaVersion: Int = ApneaSession.currentSchemaVersion,
        startMode: ApneaSessionStartMode,
        state: ApneaSessionState,
        createdAt: Date = Date(),
        startedAtMonotonicSeconds: TimeInterval? = nil,
        endedAtMonotonicSeconds: TimeInterval? = nil,
        dives: [ApneaDive] = [],
        statistics: ApneaSessionStatistics? = nil,
        surfaceGPSPoints: [ApneaSurfaceGPSPoint] = [],
        buddy: ApneaBuddyInfo? = nil,
        equipment: ApneaEquipmentProfile? = nil,
        profile: ApneaProfile? = nil,
        warnings: [ApneaSessionWarning] = []
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.startMode = startMode
        self.state = state
        self.createdAt = createdAt
        self.startedAtMonotonicSeconds = startedAtMonotonicSeconds
        self.endedAtMonotonicSeconds = endedAtMonotonicSeconds
        self.dives = dives
        self.statistics = statistics ?? ApneaSessionStatistics.aggregate(from: dives)
        self.surfaceGPSPoints = surfaceGPSPoints
        self.buddy = buddy
        self.equipment = equipment
        self.profile = profile
        self.warnings = warnings
    }

    enum CodingKeys: String, CodingKey {
        case id
        case schemaVersion
        case startMode
        case state
        case createdAt
        case startedAtMonotonicSeconds
        case endedAtMonotonicSeconds
        case dives
        case statistics
        case surfaceGPSPoints
        case buddy
        case equipment
        case profile
        case warnings
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? 0
        let migrated = try ApneaSchemaMigration.migrateSession(from: container, schemaVersion: decodedVersion)
        self = migrated
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(ApneaSession.currentSchemaVersion, forKey: .schemaVersion)
        try container.encode(startMode, forKey: .startMode)
        try container.encode(state, forKey: .state)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(startedAtMonotonicSeconds, forKey: .startedAtMonotonicSeconds)
        try container.encodeIfPresent(endedAtMonotonicSeconds, forKey: .endedAtMonotonicSeconds)
        try container.encode(dives, forKey: .dives)
        try container.encode(statistics, forKey: .statistics)
        try container.encode(surfaceGPSPoints, forKey: .surfaceGPSPoints)
        try container.encodeIfPresent(buddy, forKey: .buddy)
        try container.encodeIfPresent(equipment, forKey: .equipment)
        try container.encodeIfPresent(profile, forKey: .profile)
        try container.encode(warnings, forKey: .warnings)
    }

    func refreshedStatistics() -> ApneaSessionStatistics {
        ApneaSessionStatistics.aggregate(from: dives)
    }
}
