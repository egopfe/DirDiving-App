import SwiftUI

struct IOSSnorkelingEquipmentView: View {
    @EnvironmentObject private var equipmentStore: IOSSnorkelingEquipmentStore
    @State private var editingProfile: SnorkelingReusableEquipmentProfile?

    var body: some View {
        DIRScreenContainer {
            List {
                if let active = equipmentStore.activeProfile {
                    Section(DIRIOSLocalizer.string("snorkeling.ios.equipment.active")) {
                        Text(active.displayName)
                            .foregroundStyle(DIRTheme.cyan)
                    }
                }
                Section(DIRIOSLocalizer.string("snorkeling.ios.equipment.profiles")) {
                    ForEach(equipmentStore.profiles) { profile in
                        Button {
                            editingProfile = profile
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(profile.displayName)
                                        .foregroundStyle(.white)
                                    Text(String(format: DIRIOSLocalizer.string("snorkeling.ios.equipment.item_count"), profile.items.count))
                                        .font(.caption)
                                        .foregroundStyle(DIRTheme.muted)
                                }
                                Spacer()
                                if profile.isActive {
                                    Text(DIRIOSLocalizer.string("snorkeling.ios.equipment.active_badge"))
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(DIRTheme.green)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .swipeActions {
                            Button(DIRIOSLocalizer.string("snorkeling.ios.equipment.duplicate")) {
                                _ = equipmentStore.duplicate(profile)
                            }
                            .tint(DIRTheme.cyan)
                            if !profile.isActive {
                                Button(DIRIOSLocalizer.string("common.delete"), role: .destructive) {
                                    equipmentStore.delete(id: profile.id)
                                }
                            }
                        }
                    }
                }
                Section {
                    Button(DIRIOSLocalizer.string("snorkeling.ios.equipment.new")) {
                        let profile = SnorkelingReusableEquipmentProfile(displayName: DIRIOSLocalizer.string("snorkeling.ios.equipment.new_default"))
                        equipmentStore.add(profile)
                        editingProfile = profile
                    }
                    .foregroundStyle(DIRTheme.cyan)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(DIRIOSLocalizer.string("snorkeling.ios.equipment.title"))
        .sheet(item: $editingProfile) { profile in
            NavigationStack {
                IOSSnorkelingEquipmentEditorView(profile: profile)
            }
        }
    }
}

struct IOSSnorkelingEquipmentEditorView: View {
    @EnvironmentObject private var equipmentStore: IOSSnorkelingEquipmentStore
    @Environment(\.dismiss) private var dismiss
    @State private var profile: SnorkelingReusableEquipmentProfile

    init(profile: SnorkelingReusableEquipmentProfile) {
        _profile = State(initialValue: profile)
    }

    var body: some View {
        DIRScreenContainer {
            Form {
                Section {
                    TextField(DIRIOSLocalizer.string("snorkeling.ios.equipment.name"), text: $profile.displayName)
                    Toggle(DIRIOSLocalizer.string("snorkeling.ios.equipment.set_active"), isOn: Binding(
                        get: { profile.isActive },
                        set: { newValue in
                            profile.isActive = newValue
                            if newValue { equipmentStore.setActive(id: profile.id) }
                        }
                    ))
                    TextField(DIRIOSLocalizer.string("snorkeling.ios.equipment.notes"), text: $profile.notes, axis: .vertical)
                }
                ForEach(SnorkelingEquipmentCategory.allCases) { category in
                    Section(DIRIOSLocalizer.string("snorkeling.ios.equipment.category.\(category.rawValue)")) {
                        let items = profile.items(for: category)
                        if items.isEmpty {
                            Text(DIRIOSLocalizer.string("snorkeling.ios.equipment.empty_category"))
                                .foregroundStyle(DIRTheme.muted)
                        } else {
                            ForEach(items) { item in
                                if let index = profile.items.firstIndex(where: { $0.id == item.id }) {
                                    TextField(DIRIOSLocalizer.string("snorkeling.ios.equipment.item_label"), text: $profile.items[index].label)
                                    TextField(DIRIOSLocalizer.string("snorkeling.ios.equipment.item_notes"), text: $profile.items[index].notes)
                                }
                            }
                        }
                        Button(DIRIOSLocalizer.string("snorkeling.ios.equipment.add_item")) {
                            profile.items.append(
                                SnorkelingEquipmentItem(
                                    category: category,
                                    label: "",
                                    sortIndex: profile.items(for: category).count
                                )
                            )
                        }
                        .foregroundStyle(DIRTheme.cyan)
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(DIRIOSLocalizer.string("snorkeling.ios.equipment.editor.title"))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(DIRIOSLocalizer.string("common.save")) {
                    equipmentStore.update(profile)
                    dismiss()
                }
            }
        }
    }
}
