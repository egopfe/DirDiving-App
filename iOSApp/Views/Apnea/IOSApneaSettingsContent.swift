import SwiftUI

/// Embeddable Apnea-owned settings content for unified Settings scroll surfaces.
struct IOSApneaSettingsContent: View {
    @EnvironmentObject private var settingsStore: IOSApneaSettingsStore
    @EnvironmentObject private var sharedSettings: SharedIOSSettingsStore
    @EnvironmentObject private var demoLogbookSettings: IOSActivityDemoLogbookSettingsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            IOSCompanionSharedSettingsEmbeddedContent()

            DIRCard(DIRIOSLocalizer.string("apnea.ios.settings.detection"), icon: "waveform.path.ecg", accent: DIRTheme.cyan) {
                IOSCompanionSettingsStepperRow(
                    title: DIRIOSLocalizer.string("apnea.ios.settings.descent_label"),
                    value: descentBinding,
                    range: 0.3...3,
                    step: 0.1,
                    formattedValue: String(format: DIRIOSLocalizer.string("apnea.ios.settings.descent"), settingsStore.settings.descentDetectionDepthMeters),
                    identifier: "apnea.settings.descent"
                )
                IOSCompanionSettingsStepperRow(
                    title: DIRIOSLocalizer.string("apnea.ios.settings.surface_label"),
                    value: surfaceBinding,
                    range: 0.2...2,
                    step: 0.1,
                    formattedValue: String(format: DIRIOSLocalizer.string("apnea.ios.settings.surface"), settingsStore.settings.surfaceDetectionDepthMeters),
                    identifier: "apnea.settings.surface"
                )
                IOSCompanionSettingsFootnoteText(text: DIRIOSLocalizer.string("apnea.ios.settings.detection.footnote"))
            }

            DIRCard(DIRIOSLocalizer.string("apnea.ios.settings.recovery"), icon: "timer", accent: DIRTheme.green) {
                IOSCompanionSettingsIntStepperRow(
                    title: DIRIOSLocalizer.string("apnea.ios.settings.minimum_recovery_label"),
                    value: recoveryBinding,
                    range: 0...600,
                    step: 15,
                    formattedValue: String(format: DIRIOSLocalizer.string("apnea.ios.settings.minimum_recovery"), Int(settingsStore.settings.minimumRecoverySeconds)),
                    identifier: "apnea.settings.minimum_recovery"
                )
            }

            DIRCard(DIRIOSLocalizer.string("apnea.ios.settings.companion"), icon: "person.2.fill", accent: DIRTheme.cyan) {
                IOSCompanionSettingsNavigationRow(
                    title: DIRIOSLocalizer.string("apnea.ios.equipment.title"),
                    systemImage: "bag.fill",
                    identifier: "apnea.settings.equipment"
                ) {
                    IOSApneaEquipmentView()
                }
                IOSCompanionSettingsNavigationRow(
                    title: DIRIOSLocalizer.string("apnea.ios.buddy.nav_title"),
                    systemImage: "figure.2",
                    identifier: "apnea.settings.buddy"
                ) {
                    IOSApneaBuddySafetyView()
                }
            }

            DIRCard(DIRIOSLocalizer.string("apnea.ios.settings.feedback"), icon: "hand.tap.fill", accent: DIRTheme.yellow) {
                IOSCompanionSettingsToggleRow(
                    title: DIRIOSLocalizer.string("apnea.ios.settings.haptics"),
                    isOn: hapticsBinding,
                    identifier: "apnea.settings.haptics"
                )
                IOSCompanionSettingsToggleRow(
                    title: DIRIOSLocalizer.string("apnea.ios.settings.sounds"),
                    isOn: soundsBinding,
                    identifier: "apnea.settings.sounds"
                )
                IOSCompanionSettingsToggleRow(
                    title: DIRIOSLocalizer.string("apnea.ios.settings.mission_mode"),
                    isOn: missionModeBinding,
                    identifier: "apnea.settings.mission_mode"
                )
            }

            DIRCard(DIRIOSLocalizer.string("settings.demo_logbook.title"), icon: "doc.text.magnifyingglass", accent: DIRTheme.orange) {
                IOSCompanionSettingsToggleRow(
                    title: DIRIOSLocalizer.string("settings.apnea.fake_logbook.title"),
                    isOn: apneaFakeLogbookBinding,
                    identifier: "apnea.settings.fake_logbook"
                )
                IOSCompanionSettingsFootnoteText(text: DIRIOSLocalizer.string("settings.apnea.fake_logbook.description"))
            }

            DIRCard(nil, icon: nil, accent: DIRTheme.orange) {
                IOSCompanionSettingsResetButton(
                    title: DIRIOSLocalizer.string("apnea.ios.settings.reset"),
                    action: { settingsStore.resetToDefaults() },
                    identifier: "apnea.settings.reset"
                )
            }
        }
        .onChange(of: settingsStore.settings) { _, newValue in
            var synced = newValue
            synced.useMetricUnits = sharedSettings.units == .metric
            if synced != settingsStore.settings {
                settingsStore.settings = synced
            }
            settingsStore.persist()
        }
        .onChange(of: sharedSettings.units) { _, units in
            settingsStore.settings.useMetricUnits = units == .metric
            settingsStore.persist()
        }
        .onAppear {
            settingsStore.settings.useMetricUnits = sharedSettings.units == .metric
        }
    }

    private var descentBinding: Binding<Double> {
        Binding(
            get: { settingsStore.settings.descentDetectionDepthMeters },
            set: { settingsStore.settings.descentDetectionDepthMeters = $0 }
        )
    }

    private var surfaceBinding: Binding<Double> {
        Binding(
            get: { settingsStore.settings.surfaceDetectionDepthMeters },
            set: { settingsStore.settings.surfaceDetectionDepthMeters = $0 }
        )
    }

    private var recoveryBinding: Binding<Int> {
        Binding(
            get: { Int(settingsStore.settings.minimumRecoverySeconds) },
            set: { settingsStore.settings.minimumRecoverySeconds = Double($0) }
        )
    }

    private var hapticsBinding: Binding<Bool> {
        Binding(
            get: { settingsStore.settings.hapticsEnabled },
            set: { settingsStore.settings.hapticsEnabled = $0 }
        )
    }

    private var soundsBinding: Binding<Bool> {
        Binding(
            get: { settingsStore.settings.soundsEnabled },
            set: { settingsStore.settings.soundsEnabled = $0 }
        )
    }

    private var missionModeBinding: Binding<Bool> {
        Binding(
            get: { settingsStore.settings.missionModeEnabled },
            set: { settingsStore.settings.missionModeEnabled = $0 }
        )
    }

    private var apneaFakeLogbookBinding: Binding<Bool> {
        Binding(
            get: { demoLogbookSettings.isApneaFakeLogbookEnabled },
            set: { demoLogbookSettings.setApneaFakeLogbookEnabled($0) }
        )
    }
}
