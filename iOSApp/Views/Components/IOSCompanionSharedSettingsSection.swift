import SwiftUI

/// Language and units shared across Diving, Apnea and Snorkeling Companion sections.
struct IOSCompanionSharedSettingsSection: View {
    @EnvironmentObject private var sharedSettings: SharedIOSSettingsStore
    var includePressureUnit: Bool = false

    var body: some View {
        Section(DIRIOSLocalizer.string("shared.settings.general.title")) {
            Picker(DIRIOSLocalizer.string("more.language.title"), selection: $sharedSettings.language) {
                ForEach(DIRIOSAppLanguage.allCases) { option in
                    Text(option.localizedTitle).tag(option)
                }
            }
            Picker(DIRIOSLocalizer.string("settings.units.depth.title"), selection: $sharedSettings.units) {
                ForEach(IOSUnitPreference.allCases) { option in
                    Text(option.shortLabel).tag(option)
                }
            }
            if includePressureUnit {
                Picker(DIRIOSLocalizer.string("settings.units.pressure.title"), selection: $sharedSettings.pressureUnit) {
                    ForEach(PressureUnit.allCases) { unit in
                        Text(unit == .bar
                             ? DIRIOSLocalizer.string("settings.units.pressure.bar")
                             : DIRIOSLocalizer.string("settings.units.pressure.psi")
                        ).tag(unit)
                    }
                }
            }
        }
    }
}
