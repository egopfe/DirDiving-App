import SwiftUI

enum ChecklistPlannerSyncFlow {
    case importFromChecklist
    case exportToChecklist
}

struct ChecklistPlannerSyncSheet: View {
    let flow: ChecklistPlannerSyncFlow
    @Binding var importCandidates: [ChecklistPlannerImportCandidate]
    @Binding var exportCandidates: [ChecklistPlannerExportCandidate]
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        switch flow {
                        case .importFromChecklist:
                            importList
                        case .exportToChecklist:
                            exportList
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
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var navigationTitle: String {
        switch flow {
        case .importFromChecklist:
            return String(localized: "checklist_planner.sync.choose_import")
        case .exportToChecklist:
            return String(localized: "checklist_planner.sync.choose_add")
        }
    }

    private var canConfirm: Bool {
        switch flow {
        case .importFromChecklist:
            return importCandidates.contains { candidate in
                guard candidate.isSelected else { return false }
                return (candidate.assignedRole ?? ChecklistPlannerSyncMapper.resolvedRole(for: candidate.checklistItem)) != nil
            }
        case .exportToChecklist:
            return exportCandidates.contains(where: \.isSelected)
        }
    }

    @ViewBuilder
    private var importList: some View {
        ForEach($importCandidates) { $candidate in
            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $candidate.isSelected) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(candidate.checklistItem.title)
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(importSummary(for: candidate.checklistItem))
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.muted)
                    }
                }
                .tint(DIRTheme.cyan)
                if candidate.isSelected {
                    rolePicker(assignedRole: $candidate.assignedRole, item: candidate.checklistItem)
                    if candidate.duplicatePlannerIndex != nil {
                        duplicatePicker(action: $candidate.duplicateAction)
                    }
                }
            }
            .padding(.vertical, 6)
            Divider().overlay(DIRTheme.hairline)
        }
    }

    @ViewBuilder
    private var exportList: some View {
        ForEach($exportCandidates) { $candidate in
            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $candidate.isSelected) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(candidate.cylinder.gas.label)
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(exportSummary(for: candidate.cylinder))
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.muted)
                    }
                }
                .tint(DIRTheme.cyan)
                if candidate.isSelected, candidate.duplicateChecklistIndex != nil {
                    duplicatePicker(action: $candidate.duplicateAction)
                }
            }
            .padding(.vertical, 6)
            Divider().overlay(DIRTheme.hairline)
        }
    }

    private func rolePicker(assignedRole: Binding<GasRole?>, item: EquipmentChecklistItem) -> some View {
        let needsExplicitRole = item.gasRole == nil && ChecklistPlannerSyncMapper.resolvedRole(for: item) == nil
        return VStack(alignment: .leading, spacing: 6) {
            Text(String(localized: needsExplicitRole ? "checklist_planner.sync.missing_gas_role" : "checklist_planner.sync.select_gas_role"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(needsExplicitRole ? DIRTheme.yellow : DIRTheme.muted)
            Picker(String(localized: "checklist_planner.sync.select_gas_role"), selection: Binding(
                get: { assignedRole.wrappedValue ?? ChecklistPlannerSyncMapper.resolvedRole(for: item) ?? .deco },
                set: { assignedRole.wrappedValue = $0 }
            )) {
                ForEach(GasRole.allCases) { role in
                    Text(role.localizedTitle).tag(role)
                }
            }
            .labelsHidden()
            .tint(DIRTheme.cyan)
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

    private func importSummary(for item: EquipmentChecklistItem) -> String {
        let pressureUnit = item.pressureUnit.rawValue
        let pressure = item.pressureText.isEmpty ? "—" : item.pressureText
        return "\(item.tankSize.rawValue) · \(item.gasMixKind.localizedTitle) · \(pressure) \(pressureUnit)"
    }

    private func exportSummary(for entry: PlannerCylinderEntry) -> String {
        "\(entry.role.localizedTitle) · \(entry.tankSize.rawValue) · \(Formatters.zero(entry.startPressure)) \(entry.pressureUnit.rawValue)"
    }
}
