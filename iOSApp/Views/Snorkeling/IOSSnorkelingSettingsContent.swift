import SwiftUI

/// Embeddable Snorkeling-owned settings content for unified Settings scroll surfaces.
struct IOSSnorkelingSettingsContent: View {
    @EnvironmentObject private var settingsStore: IOSSnorkelingSettingsStore
    @EnvironmentObject private var demoLogbookSettings: IOSActivityDemoLogbookSettingsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            IOSCompanionSharedSettingsEmbeddedContent()

            DIRCard(DIRIOSLocalizer.string("snorkeling.ios.settings.detection"), icon: "drop.fill", accent: DIRTheme.cyan) {
                IOSCompanionSettingsToggleRow(
                    title: DIRIOSLocalizer.string("snorkeling.ios.settings.auto_water"),
                    isOn: autoWaterBinding,
                    identifier: "snorkeling.settings.auto_water"
                )
                IOSCompanionSettingsStepperRow(
                    title: DIRIOSLocalizer.string("snorkeling.ios.settings.dip_threshold_label"),
                    value: dipThresholdBinding,
                    range: 0.3...3,
                    step: 0.1,
                    formattedValue: String(format: DIRIOSLocalizer.string("snorkeling.ios.settings.dip_threshold"), settingsStore.settings.dipThresholdMeters),
                    identifier: "snorkeling.settings.dip_threshold"
                )
                IOSCompanionSettingsIntStepperRow(
                    title: DIRIOSLocalizer.string("snorkeling.ios.settings.surface_debounce_label"),
                    value: surfaceDebounceBinding,
                    range: 1...10,
                    step: 1,
                    formattedValue: String(format: DIRIOSLocalizer.string("snorkeling.ios.settings.surface_debounce"), Int(settingsStore.settings.surfaceDebounceSeconds)),
                    identifier: "snorkeling.settings.surface_debounce"
                )
            }

            DIRCard(DIRIOSLocalizer.string("snorkeling.ios.settings.gps"), icon: "location.fill", accent: DIRTheme.green) {
                IOSCompanionSettingsToggleRow(
                    title: DIRIOSLocalizer.string("snorkeling.ios.settings.gps_tracking"),
                    isOn: gpsTrackingBinding,
                    identifier: "snorkeling.settings.gps_tracking"
                )
                IOSCompanionSettingsIntStepperRow(
                    title: DIRIOSLocalizer.string("snorkeling.ios.settings.return_distance_label"),
                    value: returnDistanceBinding,
                    range: 10...500,
                    step: 10,
                    formattedValue: String(format: DIRIOSLocalizer.string("snorkeling.ios.settings.return_distance"), Int(settingsStore.settings.returnToEntryDistanceMeters)),
                    identifier: "snorkeling.settings.return_distance"
                )
                IOSCompanionSettingsIntStepperRow(
                    title: DIRIOSLocalizer.string("snorkeling.settings.max_distance"),
                    value: maxDistanceBinding,
                    range: 100...3_000,
                    step: 50,
                    formattedValue: String(format: "%.0f m", settingsStore.settings.maxDistanceMeters),
                    identifier: "snorkeling.settings.max_distance"
                )
                IOSCompanionSettingsIntStepperRow(
                    title: DIRIOSLocalizer.string("snorkeling.settings.off_route_threshold"),
                    value: offRouteThresholdBinding,
                    range: 10...200,
                    step: 5,
                    formattedValue: String(format: "%.0f m", settingsStore.settings.offRouteThresholdMeters),
                    identifier: "snorkeling.settings.off_route_threshold"
                )
                IOSCompanionSettingsIntStepperRow(
                    title: DIRIOSLocalizer.string("snorkeling.settings.gps_quality_threshold"),
                    value: gpsQualityThresholdBinding,
                    range: 15...100,
                    step: 5,
                    formattedValue: String(format: "±%.0f m", settingsStore.settings.gpsQualityWarningAccuracyMeters),
                    identifier: "snorkeling.settings.gps_quality_threshold"
                )
            }

            DIRCard(DIRIOSLocalizer.string("snorkeling.map_type.title"), icon: "map.fill", accent: DIRTheme.cyan) {
                Picker(DIRIOSLocalizer.string("snorkeling.map_type.title"), selection: mapTypeBinding) {
                    ForEach(SnorkelingMapType.allCases) { type in
                        Text(DIRIOSLocalizer.string(type.displayNameKey)).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("snorkeling.settings.map_type")

                Text(DIRIOSLocalizer.string(settingsStore.mapType.descriptionKey))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)

                Text(String(format: DIRIOSLocalizer.string("snorkeling.settings.map_type.current"), DIRIOSLocalizer.string(settingsStore.mapType.displayNameKey)))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
            }

            DIRCard(DIRIOSLocalizer.string("snorkeling.ios.settings.alerts"), icon: "bell.fill", accent: DIRTheme.yellow) {
                IOSCompanionSettingsIntStepperRow(
                    title: DIRIOSLocalizer.string("snorkeling.ios.settings.session_duration_alert_label"),
                    value: sessionDurationBinding,
                    range: 15...240,
                    step: 15,
                    formattedValue: String(format: DIRIOSLocalizer.string("snorkeling.ios.settings.session_duration_alert"), settingsStore.settings.sessionDurationAlertMinutes),
                    identifier: "snorkeling.settings.session_duration_alert"
                )
                IOSCompanionSettingsIntStepperRow(
                    title: DIRIOSLocalizer.string("snorkeling.settings.max_duration"),
                    value: maxSessionDurationBinding,
                    range: 30...360,
                    step: 15,
                    formattedValue: String(format: DIRIOSLocalizer.string("snorkeling.ios.settings.session_duration_alert"), settingsStore.settings.maxSessionDurationMinutes),
                    identifier: "snorkeling.settings.max_duration"
                )
                Picker(DIRIOSLocalizer.string("snorkeling.settings.return_alert"), selection: returnAlertPolicyBinding) {
                    Text(DIRIOSLocalizer.string("snorkeling.alert.return.off")).tag(SnorkelingReturnAlertPolicy.off)
                    Text(DIRIOSLocalizer.string("snorkeling.alert.return.time_50")).tag(SnorkelingReturnAlertPolicy.halfPlannedTime)
                    Text(DIRIOSLocalizer.string("snorkeling.alert.return.distance_50")).tag(SnorkelingReturnAlertPolicy.halfPlannedDistance)
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("snorkeling.settings.return_alert")
            }

            DIRCard(DIRIOSLocalizer.string("snorkeling.ios.settings.companion"), icon: "person.2.fill", accent: DIRTheme.cyan) {
                IOSCompanionSettingsNavigationRow(
                    title: DIRIOSLocalizer.string("snorkeling.ios.equipment.title"),
                    systemImage: "bag.fill",
                    identifier: "snorkeling.settings.equipment"
                ) {
                    IOSSnorkelingEquipmentView()
                }
                IOSCompanionSettingsNavigationRow(
                    title: DIRIOSLocalizer.string("snorkeling.ios.buddy.nav_title"),
                    systemImage: "figure.2",
                    identifier: "snorkeling.settings.buddy"
                ) {
                    IOSSnorkelingBuddySafetyView()
                }
            }

            DIRCard(DIRIOSLocalizer.string("snorkeling.ios.settings.feedback"), icon: "hand.tap.fill", accent: DIRTheme.yellow) {
                IOSCompanionSettingsToggleRow(
                    title: DIRIOSLocalizer.string("snorkeling.ios.settings.haptics"),
                    isOn: hapticsBinding,
                    identifier: "snorkeling.settings.haptics"
                )
                IOSCompanionSettingsToggleRow(
                    title: DIRIOSLocalizer.string("snorkeling.ios.settings.mission_mode"),
                    isOn: missionModeBinding,
                    identifier: "snorkeling.settings.mission_mode"
                )
                IOSCompanionSettingsToggleRow(
                    title: DIRIOSLocalizer.string("snorkeling.ios.buddy.nav_title"),
                    isOn: buddyReminderBinding,
                    identifier: "snorkeling.settings.buddy_reminder"
                )
            }

            DIRCard(DIRIOSLocalizer.string("snorkeling.ios.settings.privacy"), icon: "lock.shield.fill", accent: DIRTheme.muted) {
                IOSCompanionSettingsFootnoteText(text: DIRIOSLocalizer.string("snorkeling.ios.settings.privacy_note"))
            }

            DIRCard(DIRIOSLocalizer.string("settings.demo_logbook.title"), icon: "doc.text.magnifyingglass", accent: DIRTheme.orange) {
                IOSCompanionSettingsToggleRow(
                    title: DIRIOSLocalizer.string("settings.snorkeling.fake_logbook.title"),
                    isOn: snorkelingFakeLogbookBinding,
                    identifier: "snorkeling.settings.fake_logbook"
                )
                IOSCompanionSettingsFootnoteText(text: DIRIOSLocalizer.string("settings.snorkeling.fake_logbook.description"))
            }

            IOSActivityLogbookVisibilitySettingsSection(activity: .snorkeling)

            DIRCard(nil, icon: nil, accent: DIRTheme.orange) {
                IOSCompanionSettingsResetButton(
                    title: DIRIOSLocalizer.string("snorkeling.ios.settings.reset"),
                    action: { settingsStore.resetToDefaults() },
                    identifier: "snorkeling.settings.reset"
                )
            }
        }
        .onChange(of: settingsStore.settings) { _, _ in
            settingsStore.persist()
        }
    }

    private var autoWaterBinding: Binding<Bool> {
        Binding(
            get: { settingsStore.settings.autoWaterDetectionEnabled },
            set: { settingsStore.settings.autoWaterDetectionEnabled = $0 }
        )
    }

    private var dipThresholdBinding: Binding<Double> {
        Binding(
            get: { settingsStore.settings.dipThresholdMeters },
            set: { settingsStore.settings.dipThresholdMeters = $0 }
        )
    }

    private var surfaceDebounceBinding: Binding<Int> {
        Binding(
            get: { Int(settingsStore.settings.surfaceDebounceSeconds) },
            set: { settingsStore.settings.surfaceDebounceSeconds = Double($0) }
        )
    }

    private var gpsTrackingBinding: Binding<Bool> {
        Binding(
            get: { settingsStore.settings.gpsTrackingEnabled },
            set: { settingsStore.settings.gpsTrackingEnabled = $0 }
        )
    }

    private var returnDistanceBinding: Binding<Int> {
        Binding(
            get: { Int(settingsStore.settings.returnToEntryDistanceMeters) },
            set: { settingsStore.settings.returnToEntryDistanceMeters = Double($0) }
        )
    }

    private var maxDistanceBinding: Binding<Int> {
        Binding(
            get: { Int(settingsStore.settings.maxDistanceMeters) },
            set: { settingsStore.settings.maxDistanceMeters = Double($0) }
        )
    }

    private var offRouteThresholdBinding: Binding<Int> {
        Binding(
            get: { Int(settingsStore.settings.offRouteThresholdMeters) },
            set: { settingsStore.settings.offRouteThresholdMeters = Double($0) }
        )
    }

    private var gpsQualityThresholdBinding: Binding<Int> {
        Binding(
            get: { Int(settingsStore.settings.gpsQualityWarningAccuracyMeters) },
            set: { settingsStore.settings.gpsQualityWarningAccuracyMeters = Double($0) }
        )
    }

    private var maxSessionDurationBinding: Binding<Int> {
        Binding(
            get: { settingsStore.settings.maxSessionDurationMinutes },
            set: { settingsStore.settings.maxSessionDurationMinutes = $0 }
        )
    }

    private var returnAlertPolicyBinding: Binding<SnorkelingReturnAlertPolicy> {
        Binding(
            get: { settingsStore.settings.defaultReturnAlertPolicy },
            set: { settingsStore.settings.defaultReturnAlertPolicy = $0 }
        )
    }

    private var buddyReminderBinding: Binding<Bool> {
        Binding(
            get: { settingsStore.settings.buddyReminderEnabled },
            set: { settingsStore.settings.buddyReminderEnabled = $0 }
        )
    }

    private var sessionDurationBinding: Binding<Int> {
        Binding(
            get: { settingsStore.settings.sessionDurationAlertMinutes },
            set: { settingsStore.settings.sessionDurationAlertMinutes = $0 }
        )
    }

    private var hapticsBinding: Binding<Bool> {
        Binding(
            get: { settingsStore.settings.hapticsEnabled },
            set: { settingsStore.settings.hapticsEnabled = $0 }
        )
    }

    private var missionModeBinding: Binding<Bool> {
        Binding(
            get: { settingsStore.settings.missionModeEnabled },
            set: { settingsStore.settings.missionModeEnabled = $0 }
        )
    }

    private var mapTypeBinding: Binding<SnorkelingMapType> {
        Binding(
            get: { settingsStore.mapType },
            set: { settingsStore.setMapType($0) }
        )
    }

    private var snorkelingFakeLogbookBinding: Binding<Bool> {
        Binding(
            get: { demoLogbookSettings.isSnorkelingFakeLogbookEnabled },
            set: { demoLogbookSettings.setSnorkelingFakeLogbookEnabled($0) }
        )
    }
}
