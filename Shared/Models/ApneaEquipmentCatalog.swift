import Foundation

enum ApneaEquipmentCategory: String, Codable, CaseIterable, Hashable, Sendable, Identifiable {
    case fins
    case monofin
    case mask
    case suit
    case ballast
    case buoy
    case line
    case lanyard

    var id: String { rawValue }
}

struct ApneaEquipmentItem: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var category: ApneaEquipmentCategory
    var label: String
    var notes: String
    var sortIndex: Int

    init(
        id: UUID = UUID(),
        category: ApneaEquipmentCategory,
        label: String,
        notes: String = "",
        sortIndex: Int = 0
    ) {
        self.id = id
        self.category = category
        self.label = label
        self.notes = notes
        self.sortIndex = sortIndex
    }
}

struct ApneaReusableEquipmentProfile: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var displayName: String
    var items: [ApneaEquipmentItem]
    var isActive: Bool
    var notes: String

    init(
        id: UUID = UUID(),
        displayName: String,
        items: [ApneaEquipmentItem] = [],
        isActive: Bool = false,
        notes: String = ""
    ) {
        self.id = id
        self.displayName = displayName
        self.items = items
        self.isActive = isActive
        self.notes = notes
    }

    func items(for category: ApneaEquipmentCategory) -> [ApneaEquipmentItem] {
        items
            .filter { $0.category == category }
            .sorted { $0.sortIndex < $1.sortIndex }
    }
}

enum ApneaEquipmentCatalogPresets {
    static func defaultProfile() -> ApneaReusableEquipmentProfile {
        ApneaReusableEquipmentProfile(
            displayName: "Default setup",
            items: [
                ApneaEquipmentItem(category: .fins, label: "Bi-fins", sortIndex: 0),
                ApneaEquipmentItem(category: .mask, label: "Low-volume mask", sortIndex: 1),
                ApneaEquipmentItem(category: .suit, label: "Open-cell suit", sortIndex: 2),
                ApneaEquipmentItem(category: .ballast, label: "Neck weight", sortIndex: 3),
                ApneaEquipmentItem(category: .buoy, label: "Surface buoy", sortIndex: 4),
                ApneaEquipmentItem(category: .line, label: "Guide line", sortIndex: 5),
                ApneaEquipmentItem(category: .lanyard, label: "Lanyard", sortIndex: 6),
            ],
            isActive: true
        )
    }
}
