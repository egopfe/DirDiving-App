import Foundation

/// Diver profile metadata for Apnea sessions. Personal bests are distinct from dive/session maxima.
struct ApneaProfile: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var displayName: String
    var preferredRecoveryPolicy: ApneaRecoveryPolicy
    /// Personal record depth (not the same as a single dive or session maximum).
    var personalBestMaxDepthMeters: Double?
    var personalBestDurationSeconds: TimeInterval?
    var notes: String?

    init(
        id: UUID = UUID(),
        displayName: String,
        preferredRecoveryPolicy: ApneaRecoveryPolicy = .default,
        personalBestMaxDepthMeters: Double? = nil,
        personalBestDurationSeconds: TimeInterval? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.preferredRecoveryPolicy = preferredRecoveryPolicy
        self.personalBestMaxDepthMeters = personalBestMaxDepthMeters
        self.personalBestDurationSeconds = personalBestDurationSeconds
        self.notes = notes
    }
}

struct ApneaEquipmentProfile: Codable, Hashable, Sendable {
    var weightKilograms: Double?
    var ballastKilograms: Double?
    var suitNotes: String?
    var lanyardDescription: String?
    var notes: String?

    init(
        weightKilograms: Double? = nil,
        ballastKilograms: Double? = nil,
        suitNotes: String? = nil,
        lanyardDescription: String? = nil,
        notes: String? = nil
    ) {
        self.weightKilograms = weightKilograms
        self.ballastKilograms = ballastKilograms
        self.suitNotes = suitNotes
        self.lanyardDescription = lanyardDescription
        self.notes = notes
    }
}

struct ApneaBuddyInfo: Codable, Hashable, Sendable {
    var name: String?
    var contactNotes: String?
    var isSafetyDiverPresent: Bool

    init(name: String? = nil, contactNotes: String? = nil, isSafetyDiverPresent: Bool = false) {
        self.name = name
        self.contactNotes = contactNotes
        self.isSafetyDiverPresent = isSafetyDiverPresent
    }
}
