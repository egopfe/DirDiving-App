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
            ZStack {
                DIRBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        DIRCard(String(localized: "equipment.template.edit"), icon: "pencil", accent: DIRTheme.cyan) {
                            TextField(String(localized: "equipment.template.name_placeholder"), text: $name)
                                .foregroundStyle(.white)
                        }
                        DIRCard(String(localized: "equipment.card.checklist"), icon: "checklist", accent: DIRTheme.green) {
                            ForEach($items) { $item in
                                VStack(alignment: .leading, spacing: 6) {
                                    TextField(String(localized: "equipment.checklist.new_item"), text: $item.title)
                                        .foregroundStyle(.white)
                                    Toggle(String(localized: "equipment.checklist.gas_flag"), isOn: $item.usesGas).tint(DIRTheme.yellow)
                                    if item.usesGas {
                                        HStack {
                                            Text(String(localized: "equipment.checklist.tank_size"))
                                                .foregroundStyle(DIRTheme.muted)
                                            Spacer()
                                            Picker("", selection: $item.tankSize) {
                                                ForEach(TankSize.allCases) { size in
                                                    Text(size.rawValue).tag(size)
                                                }
                                            }
                                            .labelsHidden()
                                            .tint(DIRTheme.cyan)
                                        }
                                        .font(.callout)
                                        TextField(String(localized: "equipment.checklist.pressure"), text: $item.pressureText)
                                            .foregroundStyle(.white)
                                    } else {
                                        TextField(String(localized: "equipment.checklist.gas"), text: $item.gasText)
                                            .foregroundStyle(.white)
                                        TextField(String(localized: "equipment.checklist.pressure"), text: $item.pressureText)
                                            .foregroundStyle(.white)
                                    }
                                    Button(role: .destructive) {
                                        items.removeAll { $0.id == item.id }
                                    } label: {
                                        Text(String(localized: "equipment.checklist.remove"))
                                            .font(.caption.weight(.semibold))
                                    }
                                    .buttonStyle(.plain)
                                }
                                Divider().overlay(DIRTheme.hairline)
                            }
                            Button {
                                items.append(EquipmentChecklistItem(title: String(localized: "equipment.checklist.new_item")))
                            } label: {
                                Text(String(localized: "equipment.checklist.add"))
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(DIRTheme.cyan)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle(String(localized: "equipment.template.edit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "equipment.template.cancel")) { dismiss() }
                        .foregroundStyle(DIRTheme.muted)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "equipment.template.save")) { save() }
                        .foregroundStyle(DIRTheme.cyan)
                }
            }
        }
    }

    private func save() {
        equipment.updateTemplate(id: templateID, name: name, checklistItems: items)
        dismiss()
    }
}
