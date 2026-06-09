import Foundation

/// Action seam for CCR planner → equipment checklist export (testable without SwiftUI).
enum CCRChecklistExportCoordinator {
    static func shouldPromptExport(input: CCRPlanInput, checklist: [EquipmentChecklistItem], planIsValid: Bool) -> Bool {
        planIsValid && ChecklistPlannerSyncMapper.hasCCRChecklistItemsMissing(input: input, checklist: checklist)
    }

    static func missingItems(input: CCRPlanInput, checklist: [EquipmentChecklistItem]) -> [EquipmentChecklistItem] {
        ChecklistPlannerSyncMapper.ccrItemsMissingFromChecklist(input: input, checklist: checklist)
    }

    static func exportAll(input: CCRPlanInput, to checklist: inout [EquipmentChecklistItem]) {
        ChecklistPlannerSyncMapper.applyCCRExport(input: input, to: &checklist)
    }

    static func exportSelected(candidates: [CCRChecklistExportCandidate], to checklist: inout [EquipmentChecklistItem]) {
        ChecklistPlannerSyncMapper.applyCCRExport(candidates: candidates, to: &checklist)
    }
}
