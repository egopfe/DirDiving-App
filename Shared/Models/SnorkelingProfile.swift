import Foundation

struct SnorkelingProfile: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var displayName: String
    var personalBestMaxDepthMeters: Double?
    var personalBestDistanceMeters: Double?
    var notes: String?

    init(
        id: UUID = UUID(),
        displayName: String,
        personalBestMaxDepthMeters: Double? = nil,
        personalBestDistanceMeters: Double? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.personalBestMaxDepthMeters = personalBestMaxDepthMeters
        self.personalBestDistanceMeters = personalBestDistanceMeters
        self.notes = notes
    }
}

struct SnorkelingEquipmentProfile: Codable, Hashable, Sendable {
    var maskNotes: String?
    var finsNotes: String?
    var suitNotes: String?
    var weightKilograms: Double?
    var notes: String?

    init(
        maskNotes: String? = nil,
        finsNotes: String? = nil,
        suitNotes: String? = nil,
        weightKilograms: Double? = nil,
        notes: String? = nil
    ) {
        self.maskNotes = maskNotes
        self.finsNotes = finsNotes
        self.suitNotes = suitNotes
        self.weightKilograms = weightKilograms
        self.notes = notes
    }
}

struct SnorkelingBuddyInfo: Codable, Hashable, Sendable {
    var name: String?
    var contactNotes: String?
    var isBuddyPresent: Bool

    init(name: String? = nil, contactNotes: String? = nil, isBuddyPresent: Bool = false) {
        self.name = name
        self.contactNotes = contactNotes
        self.isBuddyPresent = isBuddyPresent
    }
}
