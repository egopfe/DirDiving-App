import SwiftUI

struct EquipmentTemplateEditorView: View {
    @EnvironmentObject private var equipment: EquipmentStore
    @Environment(\.dismiss) private var dismiss

    let templateID: UUID
    @State private var name: String
    @State private var items: [EquipmentChecklistItem]

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
                        DIRCard(DIRIOSLocalizer.string("equipment.card.checklist"), icon: "checklist", accent: DIRTheme.green) {
                            ForEach($items) { $item in
                                VStack(alignment: .leading, spacing: 6) {
                                    TextField(DIRIOSLocalizer.string("equipment.checklist.new_item"), text: $item.title)
                                        .foregroundStyle(.white)
                                    Toggle(DIRIOSLocalizer.string("equipment.checklist.gas_flag"), isOn: $item.usesGas).tint(DIRTheme.yellow)
                                    EquipmentChecklistGasSection(item: $item)
                                    Button(role: .destructive) {
                                        items.removeAll { $0.id == item.id }
                                    } label: {
                                        Text(DIRIOSLocalizer.string("equipment.checklist.remove"))
                                            .font(.caption.weight(.semibold))
                                    }
                                    .buttonStyle(.plain)
                                }
                                Divider().overlay(DIRTheme.hairline)
                            }
                            Button {
                                items.append(EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.checklist.new_item")))
                            } label: {
                                Text(DIRIOSLocalizer.string("equipment.checklist.add"))
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(DIRTheme.cyan)
                            }
                            .buttonStyle(.plain)
                        }
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

    private func save() {
        equipment.updateTemplate(id: templateID, name: name, checklistItems: items)
        dismiss()
    }
}
