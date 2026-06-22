import SwiftUI

/// Shared language and units controls for embeddable activity Settings content.
struct IOSCompanionSharedSettingsEmbeddedContent: View {
    @EnvironmentObject private var sharedSettings: SharedIOSSettingsStore

    var body: some View {
        DIRCard(DIRIOSLocalizer.string("shared.settings.general.title"), icon: "globe", accent: DIRTheme.cyan) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(DIRIOSLocalizer.string("more.language.title"))
                            .foregroundStyle(DIRTheme.muted)
                        Spacer()
                        Text(sharedSettings.language.localizedTitle)
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                    }
                    .font(.callout)
                    Picker(DIRIOSLocalizer.string("more.language.title"), selection: $sharedSettings.language) {
                        ForEach(DIRIOSAppLanguage.allCases) { language in
                            Text(language.localizedTitle).tag(language)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel(DIRIOSLocalizer.string("more.language.title"))
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(DIRIOSLocalizer.string("settings.units.depth.title"))
                            .foregroundStyle(DIRTheme.muted)
                        Spacer()
                        Text(sharedSettings.units.shortLabel)
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                    }
                    .font(.callout)
                    Picker(DIRIOSLocalizer.string("settings.units.depth.title"), selection: $sharedSettings.units) {
                        ForEach(IOSUnitPreference.allCases) { option in
                            Text(option.shortLabel).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel(DIRIOSLocalizer.string("settings.units.depth.title"))
                }

                Text(DIRIOSLocalizer.string("settings.units.sync_note"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 4)
        }
    }
}
