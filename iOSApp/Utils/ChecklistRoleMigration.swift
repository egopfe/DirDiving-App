import Foundation

/// Stable gas-role resolution for checklist items — title inference is migration-only.
enum ChecklistRoleMigration {
    /// Applies one-time legacy title inference and persists `gasRole` on the item.
    @discardableResult
    static func migrateLegacyRoles(in checklist: inout [EquipmentChecklistItem]) -> Int {
        var migrated = 0
        for index in checklist.indices where checklist[index].usesGas && checklist[index].gasRole == nil {
            if let inferred = legacyInferRole(from: checklist[index].title) {
                checklist[index].gasRole = inferred
                migrated += 1
            }
        }
        return migrated
    }

    /// Resolves role from typed metadata only; returns nil when role is unknown.
    static func resolvedRole(for item: EquipmentChecklistItem) -> GasRole? {
        item.gasRole
    }

    /// Explicit migration fallback — documented, deterministic, localization-independent.
    static func legacyInferRole(from title: String) -> GasRole? {
        ChecklistPlannerSyncMapper.legacyInferRole(from: title)
    }
}
