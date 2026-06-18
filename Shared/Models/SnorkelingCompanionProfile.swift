import Foundation

enum SnorkelingCompanionDiscipline: String, Codable, CaseIterable, Hashable, Sendable, Identifiable {
    case recreational
    case photographic
    case reef
    case coastal
    case boat
    case children
    case fauna
    case custom

    var id: String { rawValue }
}

/// Reusable Snorkeling iOS companion profile (preset or user-edited copy).
struct SnorkelingCompanionProfile: Identifiable, Codable, Hashable, Sendable {
    static let currentSchemaVersion = 1

    let id: UUID
    var schemaVersion: Int
    var displayName: String
    var discipline: SnorkelingCompanionDiscipline
    var isPreset: Bool
    var targetDurationSeconds: TimeInterval?
    var maxDistanceMeters: Double?
    var maxDepthMeters: Double?
    var missionModeEnabled: Bool
    var alarms: [SnorkelingAlarm]
    var notes: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        schemaVersion: Int = SnorkelingCompanionProfile.currentSchemaVersion,
        displayName: String,
        discipline: SnorkelingCompanionDiscipline,
        isPreset: Bool = false,
        targetDurationSeconds: TimeInterval? = nil,
        maxDistanceMeters: Double? = nil,
        maxDepthMeters: Double? = nil,
        missionModeEnabled: Bool = false,
        alarms: [SnorkelingAlarm] = [],
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.displayName = displayName
        self.discipline = discipline
        self.isPreset = isPreset
        self.targetDurationSeconds = targetDurationSeconds
        self.maxDistanceMeters = maxDistanceMeters
        self.maxDepthMeters = maxDepthMeters
        self.missionModeEnabled = missionModeEnabled
        self.alarms = alarms
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func editableCopy(newID: UUID = UUID()) -> SnorkelingCompanionProfile {
        SnorkelingCompanionProfile(
            id: newID,
            displayName: displayName,
            discipline: .custom,
            isPreset: false,
            targetDurationSeconds: targetDurationSeconds,
            maxDistanceMeters: maxDistanceMeters,
            maxDepthMeters: maxDepthMeters,
            missionModeEnabled: missionModeEnabled,
            alarms: alarms,
            notes: notes
        )
    }
}
