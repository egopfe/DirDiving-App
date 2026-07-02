import SwiftUI

struct EquipmentTemplateEditorView: View {
    @EnvironmentObject private var equipment: EquipmentStore
    @Environment(\.dismiss) private var dismiss

    let templateID: UUID
    @State private var name: String
    @State private var items: [EquipmentChecklistItem]
    @State private var newItemTitle = ""

    init(template: EquipmentTemplate) {
        templateID = template.id
        _name = State(initialValue: template.name)
        _items = State(initialValue: template.checklistItems)
    }

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        DIRCard(DIRIOSLocalizer.string("equipment.template.edit"), icon: "pencil", accent: DIRTheme.cyan) {
                            TextField(DIRIOSLocalizer.string("equipment.template.name_placeholder"), text: $name)
                                .foregroundStyle(.white)
                        }
                        templateChecklistSections
                        addTemplateItemCard
                    }
                    .padding(16)
                }
                .dirCompanionScrollSurface()
            }
            .navigationTitle(DIRIOSLocalizer.string("equipment.template.edit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(DIRIOSLocalizer.string("equipment.template.cancel")) { dismiss() }
                        .foregroundStyle(DIRTheme.muted)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(DIRIOSLocalizer.string("equipment.template.save")) { save() }
                        .foregroundStyle(DIRTheme.cyan)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var templateChecklistSections: some View {
        let grouped = ChecklistItemSupport.groupedIndices(in: items)
        return ForEach(ChecklistItemKind.sectionOrder, id: \.self) { kind in
            if let indices = grouped[kind], !indices.isEmpty {
                DIRCard(kind.localizedSectionTitle, icon: kind.sectionIcon, accent: sectionAccent(for: kind)) {
                    ForEach(indices, id: \.self) { index in
                        templateItemRow(binding: $items[index])
                        if index != indices.last {
                            Divider().overlay(DIRTheme.hairline)
                        }
                    }
                }
            }
        }
    }

    private var addTemplateItemCard: some View {
        DIRCard(DIRIOSLocalizer.string("equipment.checklist.new_item"), icon: "plus.circle", accent: DIRTheme.cyan) {
            VStack(alignment: .leading, spacing: 10) {
                Text(DIRIOSLocalizer.string("equipment.gas_separation_notice"))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)

                TextField(DIRIOSLocalizer.string("equipment.checklist.new_item"), text: $newItemTitle)
                    .foregroundStyle(.white)

                Button(DIRIOSLocalizer.string("equipment.add.generic_item")) {
                    addTemplateItem(usesGas: false)
                }
                .font(.callout.weight(.semibold))
                .foregroundStyle(DIRTheme.cyan)
                .buttonStyle(.plain)

                Button(DIRIOSLocalizer.string("equipment.add.gas_cylinder")) {
                    addTemplateItem(usesGas: true)
                }
                .font(.callout.weight(.semibold))
                .foregroundStyle(DIRTheme.yellow)
                .buttonStyle(.plain)
            }
        }
    }

    private func templateItemRow(binding: Binding<EquipmentChecklistItem>) -> some View {
        let item = binding.wrappedValue
        return VStack(alignment: .leading, spacing: 6) {
            TextField(DIRIOSLocalizer.string("equipment.checklist.new_item"), text: binding.title)
                .foregroundStyle(.white)
            if EquipmentItemPresentationPolicy.shouldShowGasEditor(for: item) {
                Text(DIRIOSLocalizer.string("equipment.item.gas_cylinder"))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(DIRTheme.yellow)
                EquipmentChecklistGasSection(item: binding)
            }
            Button(role: .destructive) {
                items.removeAll { $0.id == item.id }
            } label: {
                Text(DIRIOSLocalizer.string("equipment.checklist.remove"))
                    .font(.caption.weight(.semibold))
            }
            .buttonStyle(.plain)
        }
    }

    private func sectionAccent(for kind: ChecklistItemKind) -> Color {
        switch kind {
        case .equipment, .task, .custom: return DIRTheme.cyan
        case .gas: return DIRTheme.yellow
        case .safety: return DIRTheme.green
        case .document: return DIRTheme.muted
        }
    }

    private func addTemplateItem(usesGas: Bool) {
        let title = newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        items.append(
            EquipmentChecklistItem(
                title: title,
                isReady: false,
                usesGas: usesGas,
                kind: .equipment
            )
        )
        newItemTitle = ""
    }

    private func save() {
        equipment.updateTemplate(id: templateID, name: name, checklistItems: items)
        dismiss()
    }
}
