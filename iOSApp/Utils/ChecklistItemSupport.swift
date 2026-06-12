import Foundation

enum ChecklistItemKind: String, Codable, Hashable, CaseIterable {
    case equipment
    case gas
    case task
    case safety
    case document
    case custom

    static let sectionOrder: [ChecklistItemKind] = [
        .equipment, .gas, .task, .safety, .document, .custom,
    ]

    var kindLocalizationKey: String {
        switch self {
        case .equipment: return "checklist.kind.equipment"
        case .gas: return "checklist.kind.gas"
        case .task: return "checklist.kind.task"
        case .safety: return "checklist.kind.safety"
        case .document: return "checklist.kind.document"
        case .custom: return "checklist.kind.custom"
        }
    }

    var sectionLocalizationKey: String {
        switch self {
        case .equipment: return "checklist.section.equipment"
        case .gas: return "checklist.section.gas"
        case .task: return "checklist.section.task"
        case .safety: return "checklist.section.safety"
        case .document: return "checklist.section.document"
        case .custom: return "checklist.section.custom"
        }
    }

    var localizedKindTitle: String {
        DIRIOSLocalizer.string(kindLocalizationKey)
    }

    var localizedSectionTitle: String {
        DIRIOSLocalizer.string(sectionLocalizationKey)
    }

    var sectionIcon: String {
        switch self {
        case .equipment: return "shippingbox.fill"
        case .gas: return "gauge.with.dots.needle.bottom.50percent"
        case .task: return "checklist.checked"
        case .safety: return "shield.checkered"
        case .document: return "doc.text"
        case .custom: return "slider.horizontal.3"
        }
    }
}

enum ChecklistItemSupport {
    static func applyReadyChange(_ isReady: Bool, to item: inout EquipmentChecklistItem) {
        item.isReady = isReady
        item.completedAt = isReady ? Date() : nil
    }

    static func groupedIndices(
        in items: [EquipmentChecklistItem]
    ) -> [ChecklistItemKind: [Int]] {
        var grouped: [ChecklistItemKind: [Int]] = [:]
        for (index, item) in items.enumerated() {
            grouped[item.kind, default: []].append(index)
        }
        return grouped
    }

    static func completedAtLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return String(format: DIRIOSLocalizer.string("checklist.item.completed_at"), formatter.string(from: date))
    }
}

struct ChecklistQuickPreset: Identifiable, Hashable {
    let id: String
    let titleKey: String
    let kind: ChecklistItemKind
    let isRequired: Bool
    let usesGas: Bool

    var localizedTitle: String {
        DIRIOSLocalizer.string(titleKey)
    }

    static let all: [ChecklistQuickPreset] = [
        ChecklistQuickPreset(id: "analyze_gas", titleKey: "checklist.quick.analyze_gas", kind: .gas, isRequired: true, usesGas: false),
        ChecklistQuickPreset(id: "verify_mod", titleKey: "checklist.quick.verify_mod", kind: .gas, isRequired: true, usesGas: false),
        ChecklistQuickPreset(id: "check_pressure", titleKey: "checklist.quick.check_pressure", kind: .gas, isRequired: true, usesGas: false),
        ChecklistQuickPreset(id: "confirm_rock_bottom", titleKey: "checklist.quick.confirm_rock_bottom", kind: .task, isRequired: true, usesGas: false),
        ChecklistQuickPreset(id: "confirm_team_plan", titleKey: "checklist.quick.confirm_team_plan", kind: .task, isRequired: true, usesGas: false),
        ChecklistQuickPreset(id: "send_watch_briefing", titleKey: "checklist.quick.send_watch_briefing", kind: .task, isRequired: true, usesGas: false),
        ChecklistQuickPreset(id: "bubble_check", titleKey: "checklist.quick.bubble_check", kind: .safety, isRequired: true, usesGas: false),
        ChecklistQuickPreset(id: "valve_drill", titleKey: "checklist.quick.valve_drill", kind: .safety, isRequired: true, usesGas: false),
        ChecklistQuickPreset(id: "backup_computer", titleKey: "checklist.quick.backup_computer", kind: .safety, isRequired: true, usesGas: false),
    ]

    func makeItem() -> EquipmentChecklistItem {
        EquipmentChecklistItem(
            title: localizedTitle,
            isReady: false,
            usesGas: usesGas,
            kind: kind,
            isRequired: isRequired
        )
    }
}
