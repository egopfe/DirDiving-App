import SwiftUI

struct IOSSnorkelingProfilesView: View {
    @EnvironmentObject private var profileStore: IOSSnorkelingProfileStore
    @State private var editingProfile: SnorkelingCompanionProfile?

    var body: some View {
        DIRScreenContainer {
            List {
                ForEach(profileStore.allProfiles()) { profile in
                    Button {
                        if SnorkelingCompanionProfilePolicy.canEditInPlace(profile) {
                            editingProfile = profile
                        } else {
                            editingProfile = profileStore.duplicate(profile)
                        }
                    } label: {
                        profileRow(profile)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        if SnorkelingCompanionProfilePolicy.canDelete(profile) {
                            Button(role: .destructive) {
                                profileStore.delete(id: profile.id)
                            } label: {
                                Text(DIRIOSLocalizer.string("snorkeling.ios.profiles.delete"))
                            }
                        }
                        Button {
                            _ = profileStore.duplicate(profile)
                        } label: {
                            Text(DIRIOSLocalizer.string("snorkeling.ios.profiles.duplicate"))
                        }
                        .tint(DIRTheme.cyan)
                    }
                }

                Button {
                    editingProfile = SnorkelingCompanionProfile(
                        displayName: DIRIOSLocalizer.string("snorkeling.ios.profiles.new_default_name"),
                        discipline: .custom
                    )
                } label: {
                    Label(DIRIOSLocalizer.string("snorkeling.ios.profiles.new"), systemImage: "plus.circle.fill")
                        .foregroundStyle(DIRTheme.cyan)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .sheet(item: $editingProfile) { profile in
            NavigationStack {
                IOSSnorkelingProfileEditorView(profile: profile)
            }
        }
    }

    private func profileRow(_ profile: SnorkelingCompanionProfile) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon(for: profile.discipline))
                .font(.title3)
                .foregroundStyle(DIRTheme.cyan)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(displayName(for: profile))
                        .font(.headline)
                        .foregroundStyle(.white)
                    if profile.isPreset {
                        Text(DIRIOSLocalizer.string("snorkeling.ios.profiles.preset_badge"))
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(DIRTheme.cyan.opacity(0.2)))
                            .foregroundStyle(DIRTheme.cyan)
                    }
                }
                Text(IOSSnorkelingProfilePresentation.subtitle(for: profile))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
                    .lineLimit(2)
                if profile.missionModeEnabled {
                    Text(DIRIOSLocalizer.string("snorkeling.ios.profiles.mission_mode"))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(DIRTheme.green)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(DIRTheme.muted)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    private func displayName(for profile: SnorkelingCompanionProfile) -> String {
        profile.isPreset ? DIRIOSLocalizer.string(profile.displayName) : profile.displayName
    }

    private func icon(for discipline: SnorkelingCompanionDiscipline) -> String {
        switch discipline {
        case .recreational: return "figure.open.water.swim"
        case .photographic: return "camera.fill"
        case .reef: return "leaf.fill"
        case .coastal: return "water.waves"
        case .boat: return "sailboat.fill"
        case .children: return "figure.2.and.child.holdinghands"
        case .fauna: return "fish.fill"
        case .custom: return "slider.horizontal.3"
        }
    }
}

struct IOSSnorkelingProfileEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var profileStore: IOSSnorkelingProfileStore

    @State private var profile: SnorkelingCompanionProfile

    init(profile: SnorkelingCompanionProfile) {
        _profile = State(initialValue: profile)
    }

    var body: some View {
        Form {
            Section(DIRIOSLocalizer.string("snorkeling.ios.profiles.editor.name")) {
                TextField(DIRIOSLocalizer.string("snorkeling.ios.profiles.editor.name"), text: $profile.displayName)
            }
            Section(DIRIOSLocalizer.string("snorkeling.ios.profiles.editor.limits")) {
                TextField(DIRIOSLocalizer.string("snorkeling.ios.profiles.editor.max_depth"), value: $profile.maxDepthMeters, format: .number)
                    .keyboardType(.decimalPad)
                TextField(DIRIOSLocalizer.string("snorkeling.ios.profiles.editor.max_distance"), value: $profile.maxDistanceMeters, format: .number)
                    .keyboardType(.decimalPad)
                TextField(DIRIOSLocalizer.string("snorkeling.ios.profiles.editor.duration"), value: $profile.targetDurationSeconds, format: .number)
                    .keyboardType(.numberPad)
            }
            Section {
                Toggle(DIRIOSLocalizer.string("snorkeling.ios.profiles.editor.mission_mode"), isOn: $profile.missionModeEnabled)
            }
            Section(DIRIOSLocalizer.string("snorkeling.ios.profiles.editor.notes")) {
                TextField(DIRIOSLocalizer.string("snorkeling.ios.profiles.editor.notes"), text: Binding(
                    get: { profile.notes ?? "" },
                    set: { profile.notes = $0.isEmpty ? nil : $0 }
                ), axis: .vertical)
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle(DIRIOSLocalizer.string("snorkeling.ios.profiles.editor.title"))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(DIRIOSLocalizer.string("common.cancel")) { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(DIRIOSLocalizer.string("common.save")) { save() }
            }
        }
    }

    private func save() {
        if profileStore.profile(id: profile.id) == nil {
            profileStore.add(profile)
        } else {
            profileStore.update(profile)
        }
        dismiss()
    }
}
