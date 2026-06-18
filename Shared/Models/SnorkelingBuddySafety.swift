import Foundation

struct SnorkelingEmergencyContact: Codable, Hashable, Sendable {
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

struct SnorkelingGroupMember: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var name: String
    var role: String
    var contactNotes: String

    init(id: UUID = UUID(), name: String = "", role: String = "", contactNotes: String = "") {
        self.id = id
        self.name = name
        self.role = role
        self.contactNotes = contactNotes
    }
}

struct SnorkelingSafetyChecklistItem: Identifiable, Codable, Hashable, Sendable {
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

struct SnorkelingPreSessionConfirmation: Codable, Hashable, Sendable {
    var isConfirmed: Bool
    var confirmedAt: Date?
    var note: String

    init(isConfirmed: Bool = false, confirmedAt: Date? = nil, note: String = "") {
        self.isConfirmed = isConfirmed
        self.confirmedAt = confirmedAt
        self.note = note
    }
}

struct SnorkelingBuddySafetyProfile: Codable, Hashable, Sendable {
    var buddyName: String
    var buddyContactNotes: String
    var isBuddyPresent: Bool
    var groupMembers: [SnorkelingGroupMember]
    var meetingPointNotes: String
    var expectedReturnAt: Date?
    var emergencyContact: SnorkelingEmergencyContact
    var checklist: [SnorkelingSafetyChecklistItem]
    var preSessionConfirmation: SnorkelingPreSessionConfirmation
    var shareablePlanNote: String

    static let defaultChecklist: [SnorkelingSafetyChecklistItem] = [
        SnorkelingSafetyChecklistItem(title: "Buddy and surface cover confirmed", sortIndex: 0),
        SnorkelingSafetyChecklistItem(title: "Equipment checked", sortIndex: 1),
        SnorkelingSafetyChecklistItem(title: "Meeting point agreed", sortIndex: 2),
        SnorkelingSafetyChecklistItem(title: "Expected return time set", sortIndex: 3),
        SnorkelingSafetyChecklistItem(title: "Emergency contact available", sortIndex: 4),
    ]

    static let `default` = SnorkelingBuddySafetyProfile(
        buddyName: "",
        buddyContactNotes: "",
        isBuddyPresent: false,
        groupMembers: [],
        meetingPointNotes: "",
        expectedReturnAt: nil,
        emergencyContact: SnorkelingEmergencyContact(),
        checklist: defaultChecklist,
        preSessionConfirmation: SnorkelingPreSessionConfirmation(),
        shareablePlanNote: ""
    )

    var hasSensitiveContactData: Bool {
        emergencyContact.hasSensitiveData
            || !buddyContactNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || groupMembers.contains { !$0.contactNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
}
