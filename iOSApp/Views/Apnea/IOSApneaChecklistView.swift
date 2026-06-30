import SwiftUI

struct IOSApneaChecklistView: View {
    @EnvironmentObject private var buddyStore: IOSApneaBuddySafetyStore
    @State private var items: [ApneaChecklistItem] = ApneaChecklistCatalog.defaultItems()

    var body: some View {
        DIRScreenContainer {
            List {
                Section(DIRIOSLocalizer.string("apnea.checklist.title")) {
                    ForEach($items) { $item in
                        Toggle(DIRIOSLocalizer.string(item.localizationKey), isOn: $item.isChecked)
                            .tint(DIRTheme.cyan)
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
        .onAppear {
            syncFromBuddyStoreIfNeeded()
        }
    }

    private func syncFromBuddyStoreIfNeeded() {
        let catalog = ApneaChecklistCatalog.defaultItems()
        if buddyStore.profile.checklist.count == catalog.count {
            for index in items.indices {
                if index < buddyStore.profile.checklist.count {
                    items[index].isChecked = buddyStore.profile.checklist[index].isCompleted
                }
            }
        }
    }
}
