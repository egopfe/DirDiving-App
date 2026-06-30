import Foundation

/// Explicit schema migration for persisted snorkeling sessions.
enum SnorkelingSchemaMigration {
    static func migrateSession(
        from container: KeyedDecodingContainer<SnorkelingSession.CodingKeys>,
        schemaVersion: Int
    ) throws -> SnorkelingSession {
        switch schemaVersion {
        case 0:
            return try decodeV1(from: container, markSchemaMigrated: true)
        case 1:
            return try decodeV1(from: container, markSchemaMigrated: false)
        default:
            var session = try decodeV1(from: container, markSchemaMigrated: true)
            session.schemaVersion = SnorkelingSession.currentSchemaVersion
            if !session.warnings.contains(.schemaMigrated) {
                session.warnings.append(.schemaMigrated)
            }
            return session
        }
    }

    private static func decodeV1(
        from container: KeyedDecodingContainer<SnorkelingSession.CodingKeys>,
        markSchemaMigrated: Bool
    ) throws -> SnorkelingSession {
        let id = try container.decode(UUID.self, forKey: .id)
        let startMode = try container.decode(SnorkelingSessionStartMode.self, forKey: .startMode)
        let state = try container.decode(SnorkelingSessionState.self, forKey: .state)
        let createdAt = try container.decode(Date.self, forKey: .createdAt)
        let startedAtMonotonicSeconds = try container.decodeIfPresent(TimeInterval.self, forKey: .startedAtMonotonicSeconds)
        let endedAtMonotonicSeconds = try container.decodeIfPresent(TimeInterval.self, forKey: .endedAtMonotonicSeconds)
        let entryPoint = try container.decodeIfPresent(SnorkelingTrackPoint.self, forKey: .entryPoint)
        let trackPoints = try container.decodeIfPresent([SnorkelingTrackPoint].self, forKey: .trackPoints) ?? []
        let dips = try container.decodeIfPresent([SnorkelingDip].self, forKey: .dips) ?? []
        let markers = try container.decodeIfPresent([SnorkelingMarker].self, forKey: .markers) ?? []
        let alarms = try container.decodeIfPresent([SnorkelingAlarm].self, forKey: .alarms) ?? []
        let events = try container.decodeIfPresent([SnorkelingEvent].self, forKey: .events) ?? []
        let routePlans = try container.decodeIfPresent([SnorkelingRoutePlan].self, forKey: .routePlans) ?? []
        let activeRoutePlanID = try container.decodeIfPresent(UUID.self, forKey: .activeRoutePlanID)
        let statistics = try container.decodeIfPresent(SnorkelingSessionStatistics.self, forKey: .statistics)
        let profile = try container.decodeIfPresent(SnorkelingProfile.self, forKey: .profile)
        let equipment = try container.decodeIfPresent(SnorkelingEquipmentProfile.self, forKey: .equipment)
        let buddy = try container.decodeIfPresent(SnorkelingBuddyInfo.self, forKey: .buddy)
        var warnings = try container.decodeIfPresent([SnorkelingSessionWarning].self, forKey: .warnings) ?? []
        let depthSampleSource = try container.decodeIfPresent(String.self, forKey: .depthSampleSource)
        let depthCapabilityMode = try container.decodeIfPresent(String.self, forKey: .depthCapabilityMode)
        let runtimeSummary = try container.decodeIfPresent(SnorkelingSessionRuntimeSummary.self, forKey: .runtimeSummary)
        if markSchemaMigrated, !warnings.contains(.schemaMigrated) {
            warnings.append(.schemaMigrated)
        }

        return SnorkelingSession(
            id: id,
            schemaVersion: SnorkelingSession.currentSchemaVersion,
            startMode: startMode,
            state: state,
            createdAt: createdAt,
            startedAtMonotonicSeconds: startedAtMonotonicSeconds,
            endedAtMonotonicSeconds: endedAtMonotonicSeconds,
            entryPoint: entryPoint,
            trackPoints: trackPoints,
            dips: dips,
            markers: markers,
            alarms: alarms,
            events: events,
            routePlans: routePlans,
            activeRoutePlanID: activeRoutePlanID,
            statistics: statistics,
            profile: profile,
            equipment: equipment,
            buddy: buddy,
            warnings: warnings,
            depthSampleSource: depthSampleSource,
            depthCapabilityMode: depthCapabilityMode,
            runtimeSummary: runtimeSummary
        )
    }
}
