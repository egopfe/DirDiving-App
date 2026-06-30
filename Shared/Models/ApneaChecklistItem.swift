import Foundation

/// Localized pre-apnea checklist item (training aid, not safety certification).
struct ApneaChecklistItem: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var localizationKey: String
    var isChecked: Bool
    var sortIndex: Int

    init(id: UUID = UUID(), localizationKey: String, isChecked: Bool = false, sortIndex: Int = 0) {
        self.id = id
        self.localizationKey = localizationKey
        self.isChecked = isChecked
        self.sortIndex = sortIndex
    }
}

enum ApneaChecklistCatalog {
    static func defaultItems() -> [ApneaChecklistItem] {
        [
            ApneaChecklistItem(localizationKey: "apnea.checklist.buddy", sortIndex: 0),
            ApneaChecklistItem(localizationKey: "apnea.checklist.recovery", sortIndex: 1),
            ApneaChecklistItem(localizationKey: "apnea.checklist.safe_area", sortIndex: 2),
            ApneaChecklistItem(localizationKey: "apnea.checklist.no_hyperventilation", sortIndex: 3),
            ApneaChecklistItem(localizationKey: "apnea.checklist.stop_signal", sortIndex: 4),
            ApneaChecklistItem(localizationKey: "apnea.checklist.watch_charged", sortIndex: 5),
            ApneaChecklistItem(localizationKey: "apnea.checklist.not_alone", sortIndex: 6),
        ]
    }

    static func toSafetyItems(_ items: [ApneaChecklistItem], titleResolver: (String) -> String) -> [ApneaSafetyChecklistItem] {
        items.enumerated().map { index, item in
            ApneaSafetyChecklistItem(
                id: item.id,
                title: titleResolver(item.localizationKey),
                isCompleted: item.isChecked,
                sortIndex: index
            )
        }
    }

    static func fromSafetyItems(_ items: [ApneaSafetyChecklistItem], keyResolver: (String) -> String?) -> [ApneaChecklistItem] {
        items.enumerated().compactMap { index, item in
            guard let key = keyResolver(item.title) else { return nil }
            return ApneaChecklistItem(id: item.id, localizationKey: key, isChecked: item.isCompleted, sortIndex: index)
        }
    }
}
