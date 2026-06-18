import Foundation

enum SnorkelingEquipmentCategory: String, Codable, CaseIterable, Hashable, Sendable, Identifiable {
    case mask
    case snorkel
    case fins
    case wetsuit
    case weights
    case buoy
    case actionCam

    var id: String { rawValue }
}

struct SnorkelingEquipmentItem: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var category: SnorkelingEquipmentCategory
    var label: String
    var notes: String
    var sortIndex: Int

    init(
        id: UUID = UUID(),
        category: SnorkelingEquipmentCategory,
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

struct SnorkelingReusableEquipmentProfile: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var displayName: String
    var items: [SnorkelingEquipmentItem]
    var isActive: Bool
    var notes: String

    init(
        id: UUID = UUID(),
        displayName: String,
        items: [SnorkelingEquipmentItem] = [],
        isActive: Bool = false,
        notes: String = ""
    ) {
        self.id = id
        self.displayName = displayName
        self.items = items
        self.isActive = isActive
        self.notes = notes
    }

    func items(for category: SnorkelingEquipmentCategory) -> [SnorkelingEquipmentItem] {
        items
            .filter { $0.category == category }
            .sorted { $0.sortIndex < $1.sortIndex }
    }

    func sessionSnapshot() -> SnorkelingEquipmentProfile {
        func joinedLabels(for category: SnorkelingEquipmentCategory) -> String? {
            let joined = items(for: category).map(\.label).filter { !$0.isEmpty }.joined(separator: ", ")
            return joined.isEmpty ? nil : joined
        }
        var extra: [String] = []
        if let snorkel = joinedLabels(for: .snorkel) { extra.append(snorkel) }
        if let buoy = joinedLabels(for: .buoy) { extra.append(buoy) }
        if let cam = joinedLabels(for: .actionCam) { extra.append(cam) }
        if !notes.isEmpty { extra.append(notes) }
        return SnorkelingEquipmentProfile(
            maskNotes: joinedLabels(for: .mask),
            finsNotes: joinedLabels(for: .fins),
            suitNotes: joinedLabels(for: .wetsuit),
            weightKilograms: nil,
            notes: extra.isEmpty ? nil : extra.joined(separator: " · ")
        )
    }
}

enum SnorkelingEquipmentCatalogPresets {
    static func defaultProfile() -> SnorkelingReusableEquipmentProfile {
        SnorkelingReusableEquipmentProfile(
            displayName: "Default setup",
            items: [
                SnorkelingEquipmentItem(category: .mask, label: "Mask", sortIndex: 0),
                SnorkelingEquipmentItem(category: .snorkel, label: "Snorkel", sortIndex: 1),
                SnorkelingEquipmentItem(category: .fins, label: "Fins", sortIndex: 2),
                SnorkelingEquipmentItem(category: .wetsuit, label: "Shorty wetsuit", sortIndex: 3),
                SnorkelingEquipmentItem(category: .weights, label: "2 kg", sortIndex: 4),
                SnorkelingEquipmentItem(category: .buoy, label: "Surface marker", sortIndex: 5),
                SnorkelingEquipmentItem(category: .actionCam, label: "Action cam", sortIndex: 6),
            ],
            isActive: true
        )
    }
}
