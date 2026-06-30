import Foundation

enum ApneaDiscipline: String, Codable, CaseIterable, Hashable, Sendable, Identifiable {
    case recreational
    case depthTraining
    case constantWeight
    case freeImmersion
    case dynamic
    case photo
    case custom

    var id: String { rawValue }
}

/// Reusable Apnea companion profile (preset or user-edited copy).
struct ApneaCompanionProfile: Identifiable, Codable, Hashable, Sendable {
    static let currentSchemaVersion = 1

    let id: UUID
    var schemaVersion: Int
    var displayName: String
    var discipline: ApneaDiscipline
    var isPreset: Bool
    var recoveryPolicy: ApneaRecoveryPolicy
    var targetDepthMeters: Double?
    var targetDurationSeconds: TimeInterval?
    var alarms: [ApneaAlarm]
    var markers: [ApneaDepthMarker]
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    /// Structured profile kind for P1/P2/P3 companion profiles (optional for legacy presets).
    var profileKind: ApneaProfileKind?

    init(
        id: UUID = UUID(),
        schemaVersion: Int = ApneaCompanionProfile.currentSchemaVersion,
        displayName: String,
        discipline: ApneaDiscipline,
        isPreset: Bool = false,
        recoveryPolicy: ApneaRecoveryPolicy = .default,
        targetDepthMeters: Double? = nil,
        targetDurationSeconds: TimeInterval? = nil,
        alarms: [ApneaAlarm] = [],
        markers: [ApneaDepthMarker] = [],
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        profileKind: ApneaProfileKind? = nil
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.displayName = displayName
        self.discipline = discipline
        self.isPreset = isPreset
        self.recoveryPolicy = recoveryPolicy
        self.targetDepthMeters = targetDepthMeters
        self.targetDurationSeconds = targetDurationSeconds
        self.alarms = alarms
        self.markers = markers
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.profileKind = profileKind
    }

    func editableCopy(newID: UUID = UUID()) -> ApneaCompanionProfile {
        ApneaCompanionProfile(
            id: newID,
            displayName: displayName,
            discipline: discipline == .custom ? .custom : .custom,
            isPreset: false,
            recoveryPolicy: recoveryPolicy,
            targetDepthMeters: targetDepthMeters,
            targetDurationSeconds: targetDurationSeconds,
            alarms: alarms,
            markers: markers,
            notes: notes
        )
    }
}
