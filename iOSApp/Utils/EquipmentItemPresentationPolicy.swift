import Foundation

enum EquipmentPresentationSection: Equatable {
    case equipment
    case gasAndCylinders
}

/// UI-only classification for checklist equipment vs gas/cylinder items.
/// Does not alter persistence or planner algorithms.
enum EquipmentItemPresentationPolicy {
    /// Section kind used when grouping checklist rows in the UI.
    static func sectionKind(for item: EquipmentChecklistItem) -> ChecklistItemKind {
        if item.usesGas && item.kind == .equipment {
            return .gas
        }
        return item.kind
    }

    static func presentationSection(for item: EquipmentChecklistItem) -> EquipmentPresentationSection {
        sectionKind(for: item) == .gas ? .gasAndCylinders : .equipment
    }

    static func shouldShowGasEditor(for item: EquipmentChecklistItem) -> Bool {
        item.usesGas
    }

    /// Generic GAS toggle is never shown; type is chosen at creation time.
    static func shouldShowGasToggle(for item: EquipmentChecklistItem) -> Bool {
        false
    }
}
