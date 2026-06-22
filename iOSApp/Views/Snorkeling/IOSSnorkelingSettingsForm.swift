import SwiftUI

/// Snorkeling-owned settings form — embeddable in unified Settings root or sheet.
struct IOSSnorkelingSettingsForm: View {
    @EnvironmentObject private var settingsStore: IOSSnorkelingSettingsStore

    var body: some View {
        Form {
            IOSCompanionSharedSettingsSection()

            Section(DIRIOSLocalizer.string("snorkeling.ios.settings.detection")) {
                Toggle(DIRIOSLocalizer.string("snorkeling.ios.settings.auto_water"), isOn: $settingsStore.settings.autoWaterDetectionEnabled)
                Stepper(value: $settingsStore.settings.dipThresholdMeters, in: 0.3...3, step: 0.1) {
                    Text(String(format: DIRIOSLocalizer.string("snorkeling.ios.settings.dip_threshold"), settingsStore.settings.dipThresholdMeters))
                }
                Stepper(value: $settingsStore.settings.surfaceDebounceSeconds, in: 1...10, step: 1) {
                    Text(String(format: DIRIOSLocalizer.string("snorkeling.ios.settings.surface_debounce"), Int(settingsStore.settings.surfaceDebounceSeconds)))
                }
            }

            Section(DIRIOSLocalizer.string("snorkeling.ios.settings.gps")) {
                Toggle(DIRIOSLocalizer.string("snorkeling.ios.settings.gps_tracking"), isOn: $settingsStore.settings.gpsTrackingEnabled)
                Stepper(value: $settingsStore.settings.returnToEntryDistanceMeters, in: 10...500, step: 10) {
                    Text(String(format: DIRIOSLocalizer.string("snorkeling.ios.settings.return_distance"), Int(settingsStore.settings.returnToEntryDistanceMeters)))
                }
            }

            Section(DIRIOSLocalizer.string("snorkeling.ios.settings.alerts")) {
                Stepper(value: $settingsStore.settings.sessionDurationAlertMinutes, in: 15...240, step: 15) {
                    Text(String(format: DIRIOSLocalizer.string("snorkeling.ios.settings.session_duration_alert"), settingsStore.settings.sessionDurationAlertMinutes))
                }
            }

            Section(DIRIOSLocalizer.string("snorkeling.ios.settings.companion")) {
                NavigationLink(DIRIOSLocalizer.string("snorkeling.ios.equipment.title")) {
                    IOSSnorkelingEquipmentView()
                }
                NavigationLink(DIRIOSLocalizer.string("snorkeling.ios.buddy.nav_title")) {
                    IOSSnorkelingBuddySafetyView()
                }
            }

            Section(DIRIOSLocalizer.string("snorkeling.ios.settings.feedback")) {
                Toggle(DIRIOSLocalizer.string("snorkeling.ios.settings.haptics"), isOn: $settingsStore.settings.hapticsEnabled)
                Toggle(DIRIOSLocalizer.string("snorkeling.ios.settings.mission_mode"), isOn: $settingsStore.settings.missionModeEnabled)
            }

            Section(DIRIOSLocalizer.string("snorkeling.ios.settings.privacy")) {
                Text(DIRIOSLocalizer.string("snorkeling.ios.settings.privacy_note"))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
            }

            Section {
                Button(DIRIOSLocalizer.string("snorkeling.ios.settings.reset"), role: .destructive) {
                    settingsStore.resetToDefaults()
                }
            }
        }
        .scrollContentBackground(.hidden)
        .onChange(of: settingsStore.settings) { _, _ in
            settingsStore.persist()
        }
    }
}
