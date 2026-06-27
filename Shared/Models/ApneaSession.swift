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
    var bestDiveDurationSeconds: TimeInterval
    var cumulativeDepthMeters: Double
    var averageRecoverySeconds: TimeInterval
    var apneaRecoveryRatio: Double
    var eventCount: Int
    var sessionDurationSeconds: TimeInterval

    static let empty = ApneaSessionStatistics(
        diveCount: 0,
        totalUnderwaterSeconds: 0,
        sessionMaxDepthMeters: 0,
        averageDiveDurationSeconds: 0,
        totalRecoverySeconds: 0,
        bestDiveDurationSeconds: 0,
        cumulativeDepthMeters: 0,
        averageRecoverySeconds: 0,
        apneaRecoveryRatio: 0,
        eventCount: 0,
        sessionDurationSeconds: 0
    )

    enum CodingKeys: String, CodingKey {
        case diveCount
        case totalUnderwaterSeconds
        case sessionMaxDepthMeters
        case averageDiveDurationSeconds
        case totalRecoverySeconds
        case bestDiveDurationSeconds
        case cumulativeDepthMeters
        case averageRecoverySeconds
        case apneaRecoveryRatio
        case eventCount
        case sessionDurationSeconds
    }

    init(
        diveCount: Int,
        totalUnderwaterSeconds: TimeInterval,
        sessionMaxDepthMeters: Double,
        averageDiveDurationSeconds: TimeInterval,
        totalRecoverySeconds: TimeInterval,
        bestDiveDurationSeconds: TimeInterval = 0,
        cumulativeDepthMeters: Double = 0,
        averageRecoverySeconds: TimeInterval = 0,
        apneaRecoveryRatio: Double = 0,
        eventCount: Int = 0,
        sessionDurationSeconds: TimeInterval = 0
    ) {
        self.diveCount = diveCount
        self.totalUnderwaterSeconds = totalUnderwaterSeconds
        self.sessionMaxDepthMeters = sessionMaxDepthMeters
        self.averageDiveDurationSeconds = averageDiveDurationSeconds
        self.totalRecoverySeconds = totalRecoverySeconds
        self.bestDiveDurationSeconds = bestDiveDurationSeconds
        self.cumulativeDepthMeters = cumulativeDepthMeters
        self.averageRecoverySeconds = averageRecoverySeconds
        self.apneaRecoveryRatio = apneaRecoveryRatio
        self.eventCount = eventCount
        self.sessionDurationSeconds = sessionDurationSeconds
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        diveCount = try container.decode(Int.self, forKey: .diveCount)
        totalUnderwaterSeconds = try container.decode(TimeInterval.self, forKey: .totalUnderwaterSeconds)
        sessionMaxDepthMeters = try container.decode(Double.self, forKey: .sessionMaxDepthMeters)
        averageDiveDurationSeconds = try container.decode(TimeInterval.self, forKey: .averageDiveDurationSeconds)
        totalRecoverySeconds = try container.decode(TimeInterval.self, forKey: .totalRecoverySeconds)
        bestDiveDurationSeconds = try container.decodeIfPresent(TimeInterval.self, forKey: .bestDiveDurationSeconds) ?? 0
        cumulativeDepthMeters = try container.decodeIfPresent(Double.self, forKey: .cumulativeDepthMeters) ?? 0
        averageRecoverySeconds = try container.decodeIfPresent(TimeInterval.self, forKey: .averageRecoverySeconds) ?? 0
        apneaRecoveryRatio = try container.decodeIfPresent(Double.self, forKey: .apneaRecoveryRatio) ?? 0
        eventCount = try container.decodeIfPresent(Int.self, forKey: .eventCount) ?? 0
        sessionDurationSeconds = try container.decodeIfPresent(TimeInterval.self, forKey: .sessionDurationSeconds) ?? 0
    }

    static func aggregate(from dives: [ApneaDive], sessionDurationSeconds: TimeInterval = 0) -> ApneaSessionStatistics {
        guard !dives.isEmpty else { return .empty }
        let diveCount = dives.count
        let totalUnderwater = dives.reduce(0) { $0 + max(0, $1.durationSeconds) }
        let sessionMax = dives.map(\.maxDepthMeters).max() ?? 0
        let bestDuration = dives.map(\.durationSeconds).max() ?? 0
        let averageDuration = totalUnderwater / Double(diveCount)
        let totalRecovery = dives.reduce(0) { partial, dive in
            let before = dive.recoveryBefore?.completedSeconds ?? dive.recoveryBefore?.plannedSeconds ?? 0
            let after = dive.recoveryAfter?.completedSeconds ?? dive.recoveryAfter?.plannedSeconds ?? 0
            return partial + before + after
        }
        let averageRecovery = totalRecovery / Double(diveCount)
        let cumulativeDepth = dives.reduce(0.0) { partial, dive in
            let averageDepth = dive.averageDepthMeters > 0
                ? dive.averageDepthMeters
                : (dive.samples.isEmpty ? dive.maxDepthMeters * 0.5 : dive.recomputedDepthMetrics().averageDepthMeters)
            return partial + averageDepth * max(0, dive.durationSeconds)
        }
        let eventCount = dives.reduce(0) { $0 + $1.events.count }
        let ratio = totalRecovery > 0 ? totalUnderwater / totalRecovery : 0
        let resolvedSessionDuration = sessionDurationSeconds > 0 ? sessionDurationSeconds : totalUnderwater + totalRecovery
        return ApneaSessionStatistics(
            diveCount: diveCount,
            totalUnderwaterSeconds: totalUnderwater,
            sessionMaxDepthMeters: sessionMax,
            averageDiveDurationSeconds: averageDuration,
            totalRecoverySeconds: totalRecovery,
            bestDiveDurationSeconds: bestDuration,
            cumulativeDepthMeters: cumulativeDepth,
            averageRecoverySeconds: averageRecovery,
            apneaRecoveryRatio: ratio,
            eventCount: eventCount,
            sessionDurationSeconds: resolvedSessionDuration
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
    var depthSampleSource: String?
    var depthCapabilityMode: String?

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
        warnings: [ApneaSessionWarning] = [],
        depthSampleSource: String? = nil,
        depthCapabilityMode: String? = nil
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
        self.depthSampleSource = depthSampleSource
        self.depthCapabilityMode = depthCapabilityMode
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
        case depthSampleSource
        case depthCapabilityMode
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
        try container.encodeIfPresent(depthSampleSource, forKey: .depthSampleSource)
        try container.encodeIfPresent(depthCapabilityMode, forKey: .depthCapabilityMode)
    }

    func refreshedStatistics() -> ApneaSessionStatistics {
        let duration: TimeInterval
        if let start = startedAtMonotonicSeconds, let end = endedAtMonotonicSeconds, end >= start {
            duration = end - start
        } else {
            duration = 0
        }
        return ApneaSessionStatistics.aggregate(from: dives, sessionDurationSeconds: duration)
    }
}
