import Foundation

struct ApneaEmergencyContact: Codable, Hashable, Sendable {
    var name: String
    var phone: String
    var relationship: String

    init(name: String = "", phone: String = "", relationship: String = "") {
        self.name = name
        self.phone = phone
        self.relationship = relationship
    }

    var hasSensitiveData: Bool {
        !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct ApneaSafetyChecklistItem: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var sortIndex: Int

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, sortIndex: Int = 0) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.sortIndex = sortIndex
    }
}

struct ApneaPreSessionConfirmation: Codable, Hashable, Sendable {
    var isConfirmed: Bool
    var confirmedAt: Date?
    var note: String

    init(isConfirmed: Bool = false, confirmedAt: Date? = nil, note: String = "") {
        self.isConfirmed = isConfirmed
        self.confirmedAt = confirmedAt
        self.note = note
    }
}

struct ApneaBuddySafetyProfile: Codable, Hashable, Sendable {
    var buddyName: String
    var buddyContactNotes: String
    var isSafetyDiverPresent: Bool
    var emergencyContact: ApneaEmergencyContact
    var checklist: [ApneaSafetyChecklistItem]
    var preSessionConfirmation: ApneaPreSessionConfirmation
    var shareablePlanNote: String

    static let defaultChecklist: [ApneaSafetyChecklistItem] = [
        ApneaSafetyChecklistItem(title: "Buddy and surface cover confirmed", sortIndex: 0),
        ApneaSafetyChecklistItem(title: "Equipment checked", sortIndex: 1),
        ApneaSafetyChecklistItem(title: "Recovery plan agreed", sortIndex: 2),
        ApneaSafetyChecklistItem(title: "Emergency contact available", sortIndex: 3),
    ]

    static let `default` = ApneaBuddySafetyProfile(
        buddyName: "",
        buddyContactNotes: "",
        isSafetyDiverPresent: false,
        emergencyContact: ApneaEmergencyContact(),
        checklist: defaultChecklist,
        preSessionConfirmation: ApneaPreSessionConfirmation(),
        shareablePlanNote: ""
    )

    var hasSensitiveContactData: Bool {
        emergencyContact.hasSensitiveData
            || !buddyContactNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
