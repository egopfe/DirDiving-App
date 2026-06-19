import SwiftUI

/// Shared activity-selection controls for all iOS Companion settings surfaces.
struct IOSCompanionActivitySettingsSection: View {
    @EnvironmentObject private var companionActivity: CompanionActivityPreferenceStore

    var body: some View {
        Section(DIRIOSLocalizer.string("companion.settings.activity.title")) {
            LabeledContent(
                DIRIOSLocalizer.string("companion.settings.activity.current"),
                value: companionActivity.localizedCurrentActivityTitle()
            )
            if let note = companionActivity.watchActiveSessionNote {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(DIRTheme.yellow)
            }
            Button {
                companionActivity.requestActivitySelectionFromSettings()
            } label: {
                Label(
                    DIRIOSLocalizer.string("companion.settings.activity.change"),
                    systemImage: "arrow.triangle.2.circlepath"
                )
            }
            Toggle(
                DIRIOSLocalizer.string("companion.settings.activity.showAtLaunch"),
                isOn: Binding(
                    get: { companionActivity.preference.showActivitySelectionAtLaunch },
                    set: { companionActivity.setShowActivitySelectionAtLaunch($0) }
                )
            )
        }
    }
}

/// Card-style variant used in Diving `MoreView`.
struct IOSCompanionActivitySettingsCard: View {
    @EnvironmentObject private var companionActivity: CompanionActivityPreferenceStore

    var body: some View {
        DIRCard(DIRIOSLocalizer.string("companion.settings.activity.title"), icon: "figure.water.fitness", accent: DIRTheme.cyan) {
            HStack {
                Text(DIRIOSLocalizer.string("companion.settings.activity.current"))
                    .foregroundStyle(DIRTheme.muted)
                Spacer()
                Text(companionActivity.localizedCurrentActivityTitle())
                    .foregroundStyle(.white)
            }
            .font(.callout)
            if let note = companionActivity.watchActiveSessionNote {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(DIRTheme.yellow)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button {
                companionActivity.requestActivitySelectionFromSettings()
            } label: {
                Label(
                    DIRIOSLocalizer.string("companion.settings.activity.change"),
                    systemImage: "arrow.triangle.2.circlepath"
                )
                .font(.callout.weight(.semibold))
                .foregroundStyle(DIRTheme.cyan)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            Toggle(
                DIRIOSLocalizer.string("companion.settings.activity.showAtLaunch"),
                isOn: Binding(
                    get: { companionActivity.preference.showActivitySelectionAtLaunch },
                    set: { companionActivity.setShowActivitySelectionAtLaunch($0) }
                )
            )
            .tint(DIRTheme.cyan)
        }
    }
}
