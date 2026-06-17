import Foundation

/// Explicit schema migration for persisted Apnea sessions.
enum ApneaSchemaMigration {
    static func migrateSession(
        from container: KeyedDecodingContainer<ApneaSession.CodingKeys>,
        schemaVersion: Int
    ) throws -> ApneaSession {
        switch schemaVersion {
        case 0:
            return try decodeV1(from: container, markSchemaMigrated: true)
        case 1:
            return try decodeV1(from: container, markSchemaMigrated: false)
        default:
            var session = try decodeV1(from: container, markSchemaMigrated: true)
            session.schemaVersion = ApneaSession.currentSchemaVersion
            if !session.warnings.contains(.schemaMigrated) {
                session.warnings.append(.schemaMigrated)
            }
            return session
        }
    }

    /// Maps the experimental `ApneaDiveRecord` shape without importing excluded exploration models.
    static func migrateLegacyDiveRecord(
        id: UUID = UUID(),
        durationSeconds: TimeInterval,
        maxDepthMeters: Double,
        recoverySeconds: TimeInterval
    ) -> ApneaDive {
        ApneaDive(
            id: id,
            startedAtMonotonicSeconds: 0,
            endedAtMonotonicSeconds: durationSeconds,
            durationSeconds: durationSeconds,
            maxDepthMeters: maxDepthMeters,
            averageDepthMeters: maxDepthMeters,
            recoveryAfter: ApneaRecoveryInterval(
                plannedSeconds: recoverySeconds,
                completedSeconds: recoverySeconds
            )
        )
    }

    private static func decodeV1(
        from container: KeyedDecodingContainer<ApneaSession.CodingKeys>,
        markSchemaMigrated: Bool
    ) throws -> ApneaSession {
        let id = try container.decode(UUID.self, forKey: .id)
        let startMode = try container.decode(ApneaSessionStartMode.self, forKey: .startMode)
        let state = try container.decode(ApneaSessionState.self, forKey: .state)
        let createdAt = try container.decode(Date.self, forKey: .createdAt)
        let startedAtMonotonicSeconds = try container.decodeIfPresent(TimeInterval.self, forKey: .startedAtMonotonicSeconds)
        let endedAtMonotonicSeconds = try container.decodeIfPresent(TimeInterval.self, forKey: .endedAtMonotonicSeconds)
        let dives = try container.decodeIfPresent([ApneaDive].self, forKey: .dives) ?? []
        let statistics = try container.decodeIfPresent(ApneaSessionStatistics.self, forKey: .statistics)
            ?? ApneaSessionStatistics.aggregate(from: dives)
        let surfaceGPSPoints = try container.decodeIfPresent([ApneaSurfaceGPSPoint].self, forKey: .surfaceGPSPoints) ?? []
        let buddy = try container.decodeIfPresent(ApneaBuddyInfo.self, forKey: .buddy)
        let equipment = try container.decodeIfPresent(ApneaEquipmentProfile.self, forKey: .equipment)
        let profile = try container.decodeIfPresent(ApneaProfile.self, forKey: .profile)
        var warnings = try container.decodeIfPresent([ApneaSessionWarning].self, forKey: .warnings) ?? []
        if markSchemaMigrated, !warnings.contains(.schemaMigrated) {
            warnings.append(.schemaMigrated)
        }

        return ApneaSession(
            id: id,
            schemaVersion: ApneaSession.currentSchemaVersion,
            startMode: startMode,
            state: state,
            createdAt: createdAt,
            startedAtMonotonicSeconds: startedAtMonotonicSeconds,
            endedAtMonotonicSeconds: endedAtMonotonicSeconds,
            dives: dives,
            statistics: statistics,
            surfaceGPSPoints: surfaceGPSPoints,
            buddy: buddy,
            equipment: equipment,
            profile: profile,
            warnings: warnings
        )
    }
}
