import SwiftUI

struct IOSApneaSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settingsStore: IOSApneaSettingsStore

    var body: some View {
        DIRScreenContainer {
            Form {
                Section(DIRIOSLocalizer.string("apnea.ios.settings.detection")) {
                    Stepper(value: $settingsStore.settings.descentDetectionDepthMeters, in: 0.3...3, step: 0.1) {
                        Text(String(format: DIRIOSLocalizer.string("apnea.ios.settings.descent"), settingsStore.settings.descentDetectionDepthMeters))
                    }
                    Stepper(value: $settingsStore.settings.surfaceDetectionDepthMeters, in: 0.2...2, step: 0.1) {
                        Text(String(format: DIRIOSLocalizer.string("apnea.ios.settings.surface"), settingsStore.settings.surfaceDetectionDepthMeters))
                    }
                    Text(DIRIOSLocalizer.string("apnea.ios.settings.detection.footnote"))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                }

                Section(DIRIOSLocalizer.string("apnea.ios.settings.recovery")) {
                    Stepper(value: $settingsStore.settings.minimumRecoverySeconds, in: 0...600, step: 15) {
                        Text(String(format: DIRIOSLocalizer.string("apnea.ios.settings.minimum_recovery"), Int(settingsStore.settings.minimumRecoverySeconds)))
                    }
                }

                Section(DIRIOSLocalizer.string("apnea.ios.settings.units")) {
                    Toggle(DIRIOSLocalizer.string("apnea.ios.settings.metric"), isOn: $settingsStore.settings.useMetricUnits)
                }

                Section(DIRIOSLocalizer.string("apnea.ios.settings.feedback")) {
                    Toggle(DIRIOSLocalizer.string("apnea.ios.settings.haptics"), isOn: $settingsStore.settings.hapticsEnabled)
                    Toggle(DIRIOSLocalizer.string("apnea.ios.settings.sounds"), isOn: $settingsStore.settings.soundsEnabled)
                    Toggle(DIRIOSLocalizer.string("apnea.ios.settings.mission_mode"), isOn: $settingsStore.settings.missionModeEnabled)
                }

                Section {
                    Button(DIRIOSLocalizer.string("apnea.ios.settings.reset"), role: .destructive) {
                        settingsStore.resetToDefaults()
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(DIRIOSLocalizer.string("apnea.ios.settings.title"))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(DIRIOSLocalizer.string("common.close")) {
                    settingsStore.persist()
                    dismiss()
                }
            }
        }
        .onChange(of: settingsStore.settings) { _, _ in
            settingsStore.persist()
        }
    }
}
