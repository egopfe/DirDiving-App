import SwiftUI

struct IOSApneaProfilesView: View {
    @EnvironmentObject private var profileStore: IOSApneaProfileStore
    @State private var editingProfile: ApneaCompanionProfile?

    var body: some View {
        DIRScreenContainer {
            List {
                ForEach(profileStore.allProfiles()) { profile in
                    Button {
                        if ApneaCompanionProfilePolicy.canEditInPlace(profile) {
                            editingProfile = profile
                        }
                    } label: {
                        profileRow(profile)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        if ApneaCompanionProfilePolicy.canDelete(profile) {
                            Button(role: .destructive) {
                                profileStore.delete(id: profile.id)
                            } label: {
                                Text(DIRIOSLocalizer.string("apnea.ios.profiles.delete"))
                            }
                        }
                        Button {
                            _ = profileStore.duplicate(profile)
                        } label: {
                            Text(DIRIOSLocalizer.string("apnea.ios.profiles.duplicate"))
                        }
                        .tint(DIRTheme.cyan)
                    }
                }

                Button {
                    editingProfile = ApneaCompanionProfile(displayName: DIRIOSLocalizer.string("apnea.ios.profiles.new_default_name"), discipline: .custom)
                } label: {
                    Label(DIRIOSLocalizer.string("apnea.ios.profiles.new"), systemImage: "plus.circle.fill")
                        .foregroundStyle(DIRTheme.cyan)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle(DIRIOSLocalizer.string("apnea.ios.profiles.title"))
        }
        .sheet(item: $editingProfile) { profile in
            NavigationStack {
                IOSApneaProfileEditorView(profile: profile)
            }
        }
    }

    private func profileRow(_ profile: ApneaCompanionProfile) -> some View {
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
                        Text(DIRIOSLocalizer.string("apnea.ios.profiles.preset_badge"))
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(DIRTheme.cyan.opacity(0.2)))
                            .foregroundStyle(DIRTheme.cyan)
                    }
                }
                Text(IOSApneaProfilePresentation.subtitle(for: profile))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(DIRTheme.muted)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    private func displayName(for profile: ApneaCompanionProfile) -> String {
        profile.isPreset ? DIRIOSLocalizer.string(profile.displayName) : profile.displayName
    }

    private func icon(for discipline: ApneaDiscipline) -> String {
        switch discipline {
        case .recreational: return "lungs.fill"
        case .depthTraining: return "arrow.down.circle.fill"
        case .constantWeight: return "figure.pool.swim"
        case .freeImmersion: return "line.diagonal"
        case .dynamic: return "figure.walk"
        case .photo: return "camera.fill"
        case .custom: return "slider.horizontal.3"
        }
    }
}

struct IOSApneaProfileEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var profileStore: IOSApneaProfileStore

    @State private var profile: ApneaCompanionProfile

    init(profile: ApneaCompanionProfile) {
        _profile = State(initialValue: profile)
    }

    var body: some View {
        Form {
            Section(DIRIOSLocalizer.string("apnea.ios.profiles.editor.name")) {
                TextField(DIRIOSLocalizer.string("apnea.ios.profiles.editor.name"), text: $profile.displayName)
            }
            Section(DIRIOSLocalizer.string("apnea.ios.profiles.editor.target")) {
                TextField("m", value: $profile.targetDepthMeters, format: .number)
                    .keyboardType(.decimalPad)
                TextField(DIRIOSLocalizer.string("apnea.ios.profiles.editor.duration"), value: $profile.targetDurationSeconds, format: .number)
                    .keyboardType(.numberPad)
            }
            Section(DIRIOSLocalizer.string("apnea.ios.profiles.editor.notes")) {
                TextField(DIRIOSLocalizer.string("apnea.ios.profiles.editor.notes"), text: Binding(
                    get: { profile.notes ?? "" },
                    set: { profile.notes = $0.isEmpty ? nil : $0 }
                ), axis: .vertical)
            }
            Section {
                Text(DIRIOSLocalizer.string("apnea.ios.profiles.editor.disclaimer"))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
            }
        }
        .navigationTitle(DIRIOSLocalizer.string("apnea.ios.profiles.editor.title"))
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
