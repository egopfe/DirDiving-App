import Foundation

enum SnorkelingSessionStartMode: String, Codable, CaseIterable, Hashable, Sendable {
    case manual
    case watch
    case imported
}

enum SnorkelingSessionState: String, Codable, CaseIterable, Hashable, Sendable {
    case planned
    case active
    case paused
    case navigation
    case returnMode
    case completed
    case aborted
}

enum SnorkelingSessionWarning: String, Codable, CaseIterable, Hashable, Sendable {
    case incompleteGPS
    case sparseTrack
    case depthUnavailable
    case dataQualityDegraded
    case estimatedPositionUsed
    case schemaMigrated
}

struct SnorkelingSessionStatistics: Codable, Hashable, Sendable {
    var dipCount: Int
    var totalDipSeconds: TimeInterval
    var sessionMaxDepthMeters: Double
    var totalDistanceMeters: Double
    var averageSpeedMetersPerSecond: Double
    var markerCount: Int
    var eventCount: Int
    var sessionDurationSeconds: TimeInterval

    static let empty = SnorkelingSessionStatistics(
        dipCount: 0,
        totalDipSeconds: 0,
        sessionMaxDepthMeters: 0,
        totalDistanceMeters: 0,
        averageSpeedMetersPerSecond: 0,
        markerCount: 0,
        eventCount: 0,
        sessionDurationSeconds: 0
    )

    static func aggregate(
        from dips: [SnorkelingDip],
        trackPoints: [SnorkelingTrackPoint],
        markers: [SnorkelingMarker],
        events: [SnorkelingEvent],
        sessionDurationSeconds: TimeInterval = 0
    ) -> SnorkelingSessionStatistics {
        let dipCount = dips.count
        let totalDip = dips.reduce(0) { $0 + max(0, $1.durationSeconds) }
        let sessionMax = max(
            dips.map(\.maxDepthMeters).max() ?? 0,
            trackPoints.compactMap(\.depthMeters).filter { $0.isFinite && $0 >= 0 }.max() ?? 0
        )
        let distance = SnorkelingDomainSupport.trackDistanceMeters(trackPoints)
        let duration = sessionDurationSeconds > 0 ? sessionDurationSeconds : totalDip
        let averageSpeed = duration > 0 ? distance / duration : 0
        return SnorkelingSessionStatistics(
            dipCount: dipCount,
            totalDipSeconds: totalDip,
            sessionMaxDepthMeters: sessionMax,
            totalDistanceMeters: distance,
            averageSpeedMetersPerSecond: averageSpeed,
            markerCount: markers.count,
            eventCount: events.count,
            sessionDurationSeconds: duration
        )
    }
}

/// Root persisted snorkeling session container with explicit schema versioning.
struct SnorkelingSession: Identifiable, Codable, Hashable, Sendable {
    static let currentSchemaVersion = 1

    let id: UUID
    var schemaVersion: Int
    var startMode: SnorkelingSessionStartMode
    var state: SnorkelingSessionState
    var createdAt: Date
    var startedAtMonotonicSeconds: TimeInterval?
    var endedAtMonotonicSeconds: TimeInterval?
    var entryPoint: SnorkelingTrackPoint?
    var trackPoints: [SnorkelingTrackPoint]
    var dips: [SnorkelingDip]
    var markers: [SnorkelingMarker]
    var alarms: [SnorkelingAlarm]
    var events: [SnorkelingEvent]
    var routePlans: [SnorkelingRoutePlan]
    var activeRoutePlanID: UUID?
    var statistics: SnorkelingSessionStatistics
    var profile: SnorkelingProfile?
    var equipment: SnorkelingEquipmentProfile?
    var buddy: SnorkelingBuddyInfo?
    var warnings: [SnorkelingSessionWarning]
    var depthSampleSource: String?
    var depthCapabilityMode: String?
    var runtimeSummary: SnorkelingSessionRuntimeSummary?

    init(
        id: UUID = UUID(),
        schemaVersion: Int = SnorkelingSession.currentSchemaVersion,
        startMode: SnorkelingSessionStartMode,
        state: SnorkelingSessionState,
        createdAt: Date = Date(),
        startedAtMonotonicSeconds: TimeInterval? = nil,
        endedAtMonotonicSeconds: TimeInterval? = nil,
        entryPoint: SnorkelingTrackPoint? = nil,
        trackPoints: [SnorkelingTrackPoint] = [],
        dips: [SnorkelingDip] = [],
        markers: [SnorkelingMarker] = [],
        alarms: [SnorkelingAlarm] = [],
        events: [SnorkelingEvent] = [],
        routePlans: [SnorkelingRoutePlan] = [],
        activeRoutePlanID: UUID? = nil,
        statistics: SnorkelingSessionStatistics? = nil,
        profile: SnorkelingProfile? = nil,
        equipment: SnorkelingEquipmentProfile? = nil,
        buddy: SnorkelingBuddyInfo? = nil,
        warnings: [SnorkelingSessionWarning] = [],
        depthSampleSource: String? = nil,
        depthCapabilityMode: String? = nil,
        runtimeSummary: SnorkelingSessionRuntimeSummary? = nil
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.startMode = startMode
        self.state = state
        self.createdAt = createdAt
        self.startedAtMonotonicSeconds = startedAtMonotonicSeconds
        self.endedAtMonotonicSeconds = endedAtMonotonicSeconds
        self.entryPoint = entryPoint
        self.trackPoints = trackPoints
        self.dips = dips
        self.markers = markers
        self.alarms = alarms
        self.events = events
        self.routePlans = routePlans
        self.activeRoutePlanID = activeRoutePlanID
        self.statistics = statistics ?? SnorkelingSessionStatistics.aggregate(
            from: dips,
            trackPoints: trackPoints,
            markers: markers,
            events: events
        )
        self.profile = profile
        self.equipment = equipment
        self.buddy = buddy
        self.warnings = warnings
        self.depthSampleSource = depthSampleSource
        self.depthCapabilityMode = depthCapabilityMode
        self.runtimeSummary = runtimeSummary
    }

    enum CodingKeys: String, CodingKey {
        case id
        case schemaVersion
        case startMode
        case state
        case createdAt
        case startedAtMonotonicSeconds
        case endedAtMonotonicSeconds
        case entryPoint
        case trackPoints
        case dips
        case markers
        case alarms
        case events
        case routePlans
        case activeRoutePlanID
        case statistics
        case profile
        case equipment
        case buddy
        case warnings
        case depthSampleSource
        case depthCapabilityMode
        case runtimeSummary
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? 0
        self = try SnorkelingSchemaMigration.migrateSession(from: container, schemaVersion: decodedVersion)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(SnorkelingSession.currentSchemaVersion, forKey: .schemaVersion)
        try container.encode(startMode, forKey: .startMode)
        try container.encode(state, forKey: .state)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(startedAtMonotonicSeconds, forKey: .startedAtMonotonicSeconds)
        try container.encodeIfPresent(endedAtMonotonicSeconds, forKey: .endedAtMonotonicSeconds)
        try container.encodeIfPresent(entryPoint, forKey: .entryPoint)
        try container.encode(trackPoints, forKey: .trackPoints)
        try container.encode(dips, forKey: .dips)
        try container.encode(markers, forKey: .markers)
        try container.encode(alarms, forKey: .alarms)
        try container.encode(events, forKey: .events)
        try container.encode(routePlans, forKey: .routePlans)
        try container.encodeIfPresent(activeRoutePlanID, forKey: .activeRoutePlanID)
        try container.encode(statistics, forKey: .statistics)
        try container.encodeIfPresent(profile, forKey: .profile)
        try container.encodeIfPresent(equipment, forKey: .equipment)
        try container.encodeIfPresent(buddy, forKey: .buddy)
        try container.encode(warnings, forKey: .warnings)
        try container.encodeIfPresent(depthSampleSource, forKey: .depthSampleSource)
        try container.encodeIfPresent(depthCapabilityMode, forKey: .depthCapabilityMode)
        try container.encodeIfPresent(runtimeSummary, forKey: .runtimeSummary)
    }

    func refreshedStatistics() -> SnorkelingSessionStatistics {
        let duration: TimeInterval
        if let start = startedAtMonotonicSeconds, let end = endedAtMonotonicSeconds, end >= start {
            duration = end - start
        } else {
            duration = 0
        }
        return SnorkelingSessionStatistics.aggregate(
            from: dips,
            trackPoints: trackPoints,
            markers: markers,
            events: events,
            sessionDurationSeconds: duration
        )
    }
}
