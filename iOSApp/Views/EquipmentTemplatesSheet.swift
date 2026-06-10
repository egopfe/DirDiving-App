import SwiftUI

struct EquipmentTemplatesSheet: View {
    @EnvironmentObject private var equipment: EquipmentStore
    @Environment(\.dismiss) private var dismiss
    @State private var newTemplateName = ""
    @State private var editingTemplate: EquipmentTemplate?

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(equipment.templates) { template in
                            DIRCard(template.name, icon: "shippingbox", accent: DIRTheme.cyan) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(DIRIOSLocalizer.formatted("equipment.template.items_count", template.checklistItems.count))
                                        .font(.caption)
                                        .foregroundStyle(DIRTheme.muted)
                                    HStack(spacing: 8) {
                                        Button(DIRIOSLocalizer.string("equipment.template.apply")) {
                                            equipment.applyTemplate(template)
                                            dismiss()
                                        }
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(DIRTheme.cyan)
                                        .buttonStyle(.plain)
                                        Button(DIRIOSLocalizer.string("equipment.template.edit")) {
                                            editingTemplate = template
                                        }
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .buttonStyle(.plain)
                                        Button(DIRIOSLocalizer.string("equipment.template.delete"), role: .destructive) {
                                            equipment.deleteTemplate(id: template.id)
                                        }
                                        .font(.caption.weight(.semibold))
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        DIRCard(DIRIOSLocalizer.string("equipment.template.save_current"), icon: "square.and.arrow.down", accent: DIRTheme.green) {
                            VStack(spacing: 8) {
                                TextField(DIRIOSLocalizer.string("equipment.template.name_placeholder"), text: $newTemplateName)
                                    .foregroundStyle(.white)
                                Button(DIRIOSLocalizer.string("equipment.template.save")) {
                                    equipment.saveTemplate(named: newTemplateName, fromCurrentChecklist: true)
                                    newTemplateName = ""
                                }
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(DIRTheme.cyan)
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(16)
                }
                .dirCompanionScrollSurface()
            }
            .navigationTitle(DIRIOSLocalizer.string("equipment.my_equipment.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(DIRIOSLocalizer.string("equipment.template.done")) { dismiss() }
                        .foregroundStyle(DIRTheme.cyan)
                }
            }
            .sheet(item: $editingTemplate) { template in
                EquipmentTemplateEditorView(template: template)
                    .environmentObject(equipment)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
