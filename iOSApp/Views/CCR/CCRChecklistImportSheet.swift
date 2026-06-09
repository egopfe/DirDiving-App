import SwiftUI

struct CCRChecklistImportSheet: View {
    @Binding var candidates: [CCRChecklistImportCandidate]
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "ccr.checklist.import.disclaimer"))
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.yellow)
                            .fixedSize(horizontal: false, vertical: true)
                        ForEach($candidates) { $candidate in
                            VStack(alignment: .leading, spacing: 8) {
                                Toggle(isOn: $candidate.isSelected) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(candidate.checklistItem.title)
                                            .font(.callout.weight(.semibold))
                                            .foregroundStyle(.white)
                                        if let role = candidate.assignedRole {
                                            Text(role.localizedTitle)
                                                .font(.caption2)
                                                .foregroundStyle(DIRTheme.muted)
                                        }
                                        if !candidate.checklistItem.gasText.isEmpty {
                                            Text(candidate.checklistItem.gasText)
                                                .font(.caption2)
                                                .foregroundStyle(DIRTheme.cyan)
                                        }
                                    }
                                }
                                .tint(DIRTheme.cyan)
                                if candidate.isSelected,
                                   candidate.matchesExistingDiluent || candidate.matchesExistingBailoutIndex != nil {
                                    duplicatePicker(action: $candidate.duplicateAction)
                                }
                            }
                            .padding(.vertical, 4)
                            Divider().overlay(DIRTheme.hairline)
                        }
                    }
                    .padding(16)
                }
                .dirCompanionScrollSurface()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "checklist_planner.sync.cancel")) { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "checklist_planner.sync.confirm")) { onConfirm() }
                        .disabled(!canConfirm)
                }
            }
            .navigationTitle(String(localized: "checklist_planner.sync.choose_import"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var canConfirm: Bool {
        candidates.contains { candidate in
            guard candidate.isSelected else { return false }
            return (candidate.assignedRole ?? ChecklistPlannerSyncMapper.resolvedRole(for: candidate.checklistItem)) != nil
        }
    }

    private func duplicatePicker(action: Binding<ChecklistPlannerDuplicateAction>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(String(localized: "checklist_planner.sync.item_exists"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(DIRTheme.yellow)
            Picker("", selection: action) {
                Text(String(localized: "checklist_planner.sync.replace")).tag(ChecklistPlannerDuplicateAction.replace)
                Text(String(localized: "checklist_planner.sync.skip")).tag(ChecklistPlannerDuplicateAction.skip)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
    }
}
