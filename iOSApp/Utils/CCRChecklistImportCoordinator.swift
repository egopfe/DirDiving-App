import Foundation

/// Action seam for checklist → CCR planner import (testable without SwiftUI).
enum CCRChecklistImportCoordinator {
    static func importableItems(from checklist: [EquipmentChecklistItem]) -> [EquipmentChecklistItem] {
        ChecklistPlannerSyncMapper.ccrChecklistGasItems(from: checklist)
    }

    static func importAll(checklist: [EquipmentChecklistItem], to input: inout CCRPlanInput) {
        let candidates = ChecklistPlannerSyncMapper.ccrImportCandidates(checklist: checklist, input: input)
            .map { candidate in
                var updated = candidate
                updated.isSelected = true
                updated.duplicateAction = .replace
                return updated
            }
        ChecklistPlannerSyncMapper.applyCCRImport(candidates: candidates, to: &input)
    }

    static func importSelected(candidates: [CCRChecklistImportCandidate], to input: inout CCRPlanInput) {
        ChecklistPlannerSyncMapper.applyCCRImport(candidates: candidates, to: &input)
    }
}
