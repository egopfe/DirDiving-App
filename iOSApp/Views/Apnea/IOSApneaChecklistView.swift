import SwiftUI

struct IOSApneaChecklistView: View {
    @EnvironmentObject private var settingsStore: IOSApneaSettingsStore
    @State private var isResetConfirmationPresented = false

    var body: some View {
        DIRScreenContainer {
            List {
                Section {
                    Text(DIRIOSLocalizer.string("apnea.checklist.operational_reminder"))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                }

                Section(DIRIOSLocalizer.string("apnea.checklist.title")) {
                    ForEach(settingsStore.settings.preApneaChecklist.sorted { $0.sortIndex < $1.sortIndex }) { item in
                        Toggle(
                            DIRIOSLocalizer.string(item.localizationKey),
                            isOn: Binding(
                                get: { settingsStore.settings.preApneaChecklist.first(where: { $0.id == item.id })?.isChecked ?? false },
                                set: { settingsStore.setChecklistItem(id: item.id, isChecked: $0) }
                            )
                        )
                        .tint(DIRTheme.cyan)
                    }

                    Text(
                        String(
                            format: DIRIOSLocalizer.string("apnea.checklist.completed_format"),
                            settingsStore.checklistCompletedCount,
                            settingsStore.checklistTotalCount
                        )
                    )
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)

                    Button(role: .destructive) {
                        isResetConfirmationPresented = true
                    } label: {
                        Text(DIRIOSLocalizer.string("apnea.checklist.reset"))
                    }
                }

                Section {
                    Text(DIRIOSLocalizer.string("apnea.disclaimer.training_aid"))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(DIRIOSLocalizer.string("apnea.checklist.title"))
        .alert(
            DIRIOSLocalizer.string("apnea.checklist.reset.confirm_title"),
            isPresented: $isResetConfirmationPresented
        ) {
            Button(DIRIOSLocalizer.string("common.cancel"), role: .cancel) {}
            Button(DIRIOSLocalizer.string("apnea.checklist.reset"), role: .destructive) {
                settingsStore.resetChecklist()
            }
        } message: {
            Text(DIRIOSLocalizer.string("apnea.checklist.reset.confirm_message"))
        }
    }
}
