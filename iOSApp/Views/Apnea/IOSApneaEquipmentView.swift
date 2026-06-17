import SwiftUI

struct IOSApneaEquipmentView: View {
    @EnvironmentObject private var equipmentStore: IOSApneaEquipmentStore
    @State private var editingProfile: ApneaReusableEquipmentProfile?

    var body: some View {
        DIRScreenContainer {
            List {
                if let active = equipmentStore.activeProfile {
                    Section(DIRIOSLocalizer.string("apnea.ios.equipment.active")) {
                        Text(active.displayName)
                            .foregroundStyle(DIRTheme.cyan)
                    }
                }
                Section(DIRIOSLocalizer.string("apnea.ios.equipment.profiles")) {
                    ForEach(equipmentStore.profiles) { profile in
                        Button {
                            editingProfile = profile
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(profile.displayName)
                                        .foregroundStyle(.white)
                                    Text(String(format: DIRIOSLocalizer.string("apnea.ios.equipment.item_count"), profile.items.count))
                                        .font(.caption)
                                        .foregroundStyle(DIRTheme.muted)
                                }
                                Spacer()
                                if profile.isActive {
                                    Text(DIRIOSLocalizer.string("apnea.ios.equipment.active_badge"))
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(DIRTheme.green)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .swipeActions {
                            Button(DIRIOSLocalizer.string("apnea.ios.equipment.duplicate")) {
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
                    Button(DIRIOSLocalizer.string("apnea.ios.equipment.new")) {
                        let profile = ApneaReusableEquipmentProfile(displayName: DIRIOSLocalizer.string("apnea.ios.equipment.new_default"))
                        equipmentStore.add(profile)
                        editingProfile = profile
                    }
                    .foregroundStyle(DIRTheme.cyan)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(DIRIOSLocalizer.string("apnea.ios.equipment.title"))
        .sheet(item: $editingProfile) { profile in
            NavigationStack {
                IOSApneaEquipmentEditorView(profile: profile)
            }
        }
    }
}

struct IOSApneaEquipmentEditorView: View {
    @EnvironmentObject private var equipmentStore: IOSApneaEquipmentStore
    @Environment(\.dismiss) private var dismiss
    @State private var profile: ApneaReusableEquipmentProfile

    init(profile: ApneaReusableEquipmentProfile) {
        _profile = State(initialValue: profile)
    }

    var body: some View {
        DIRScreenContainer {
            Form {
                Section {
                    TextField(DIRIOSLocalizer.string("apnea.ios.equipment.name"), text: $profile.displayName)
                    Toggle(DIRIOSLocalizer.string("apnea.ios.equipment.set_active"), isOn: Binding(
                        get: { profile.isActive },
                        set: { newValue in
                            profile.isActive = newValue
                            if newValue { equipmentStore.setActive(id: profile.id) }
                        }
                    ))
                }
                ForEach(ApneaEquipmentCategory.allCases) { category in
                    Section(DIRIOSLocalizer.string("apnea.ios.equipment.category.\(category.rawValue)")) {
                        let items = profile.items(for: category)
                        if items.isEmpty {
                            Text(DIRIOSLocalizer.string("apnea.ios.equipment.empty_category"))
                                .foregroundStyle(DIRTheme.muted)
                        } else {
                            ForEach(items) { item in
                                VStack(alignment: .leading) {
                                    Text(item.label).foregroundStyle(.white)
                                    if !item.notes.isEmpty {
                                        Text(item.notes).font(.caption).foregroundStyle(DIRTheme.muted)
                                    }
                                }
                            }
                        }
                        Button(DIRIOSLocalizer.string("apnea.ios.equipment.add_item")) {
                            profile.items.append(
                                ApneaEquipmentItem(category: category, label: DIRIOSLocalizer.string("apnea.ios.equipment.new_item"), sortIndex: items.count)
                            )
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(DIRIOSLocalizer.string("apnea.ios.equipment.editor"))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(DIRIOSLocalizer.string("common.save")) {
                    equipmentStore.update(profile)
                    if profile.isActive { equipmentStore.setActive(id: profile.id) }
                    dismiss()
                }
            }
        }
    }
}
