import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var navigation: AppNavigationStore
    @EnvironmentObject private var gps: GPSManager
    @EnvironmentObject private var dive: DiveManager
    @EnvironmentObject private var watchSync: WatchSyncService
    @AppStorage(MissionModeSettings.autoEnableOnDiveStartKey) private var missionModeAutoEnableOnDiveStart = false
    @AppStorage("dirdiving_watch_haptics_enabled") private var hapticsEnabled = true
    @AppStorage("dirdiving_watch_units") private var watchUnits = "metric"
    @AppStorage(DIRAppLanguage.storageKey) private var appLanguage = DIRAppLanguage.system.rawValue

    var body: some View {
        ZStack {
            DiveScreenBackground()

            ScrollView {
                VStack(spacing: 10) {
                    header

                    Text(String(localized: "settings.header.title"))
                        .font(DiveUI.Typography.screenTitle)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)

                    if dive.isDiveActive {
                        settingsRow(
                            icon: "water.waves",
                            iconColor: DiveUI.yellow,
                            title: String(localized: "settings.underwater.title"),
                            subtitle: String(localized: "settings.underwater.body"),
                            informational: true
                        )
                    }

                    WatchSettingsSectionHeader(title: String(localized: "settings.section.safety"))

                    NavigationLink {
                        AscentRateSettingsView()
                    } label: {
                        settingsRow(
                            icon: "gauge",
                            iconColor: DiveUI.green,
                            title: String(localized: "settings.row.ascent_rate.title"),
                            subtitle: String(localized: "settings.row.ascent_rate.subtitle"),
                            showsChevron: true
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(dive.isDiveActive)

                    NavigationLink {
                        AlarmSettingsView()
                    } label: {
                        settingsRow(
                            icon: "bell",
                            iconColor: DiveUI.yellow,
                            title: String(localized: "settings.row.alarms.title"),
                            subtitle: String(localized: "settings.row.alarms.subtitle"),
                            showsChevron: true
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(dive.isDiveActive)

                    WatchSettingsSectionHeader(title: String(localized: "settings.section.units_language"))

                    unitPreferenceControl
                        .disabled(dive.isDiveActive)
                    languagePreferenceControl
                        .disabled(dive.isDiveActive)
                    NavigationLink {
                        WatchLegalSafetyView()
                    } label: {
                        settingsRow(
                            icon: "checkmark.shield",
                            iconColor: DiveUI.red,
                            title: String(localized: "Legal & Safety"),
                            subtitle: String(localized: "NOT A DIVE COMPUTER"),
                            showsChevron: true,
                            legal: true
                        )
                    }
                    .buttonStyle(.plain)

                    WatchSettingsSectionHeader(title: String(localized: "settings.section.sync"))

                    settingsRow(
                        icon: "iphone.slash",
                        iconColor: DiveUI.yellow,
                        title: String(localized: "Sync impostazioni"),
                        subtitle: String(localized: "settings.sync.settings_scope"),
                        informational: true
                    )

                    NavigationLink {
                        WatchSyncDiagnosticsView()
                    } label: {
                        settingsRow(
                            icon: "waveform.path.ecg.rectangle",
                            iconColor: DiveUI.cyan,
                            title: String(localized: "settings.row.sync_diagnostics.title"),
                            subtitle: String(localized: "settings.row.sync_diagnostics.subtitle"),
                            showsChevron: true
                        )
                    }
                    .buttonStyle(.plain)

                    WatchSettingsSectionHeader(title: String(localized: "settings.section.hardware"))

                    statusRow(
                        icon: "location.fill",
                        iconColor: gps.authorizationStatus == .denied ? DiveUI.red : DiveUI.green,
                        title: String(localized: "settings.row.gps_surface.title"),
                        subtitle: gpsStatusText
                    )
                    statusRow(
                        icon: "drop.fill",
                        iconColor: dive.lastErrorMessage == nil ? DiveUI.green : DiveUI.yellow,
                        title: String(localized: "settings.row.depth_sensor.title"),
                        subtitle: diveDepthSensorStatusText
                    )
                    statusRow(
                        icon: "applewatch.radiowaves.left.and.right",
                        iconColor: watchSync.isSupported ? DiveUI.green : DiveUI.orange,
                        title: String(localized: "settings.row.sync_companion.title"),
                        subtitle: watchSync.isSupported ? watchSync.lastSyncStatus : String(localized: "settings.sync.open_ios")
                    )
                    Button {
                        navigation.selectedPage = .diveLog
                        HapticService.shared.confirm()
                    } label: {
                        settingsRow(
                            icon: "square.and.arrow.up",
                            iconColor: DiveUI.green,
                            title: String(localized: "settings.row.export_logbook.title"),
                            subtitle: String(localized: "settings.row.export_logbook.subtitle"),
                            showsChevron: true
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(dive.isDiveActive)
                    .accessibilityLabel(String(localized: "settings.a11y.export_logbook"))
                    .accessibilityHint(String(localized: "settings.row.export_logbook.subtitle"))

                    WatchSettingsSectionHeader(title: String(localized: "settings.section.mission"))

                    missionModeControl

                    WatchSettingsSectionHeader(title: String(localized: "settings.section.advanced"))

                    NavigationLink {
                        WatchShortcutHelpView()
                    } label: {
                        settingsRow(
                            icon: "button.programmable",
                            iconColor: DiveUI.cyan,
                            title: String(localized: "settings.shortcuts.action_title"),
                            subtitle: String(localized: "settings.shortcuts.action_subtitle"),
                            showsChevron: true
                        )
                    }
                    .buttonStyle(.plain)

                    Toggle(isOn: $hapticsEnabled) {
                        settingsRow(
                            icon: "iphone.radiowaves.left.and.right",
                            iconColor: hapticsEnabled ? DiveUI.blue : .white.opacity(0.5),
                            title: String(localized: "settings.row.haptics.title"),
                            subtitle: hapticsEnabled ? String(localized: "settings.haptics.on") : String(localized: "settings.haptics.off")
                        )
                    }
                    .toggleStyle(.switch)
                    .tint(DiveUI.green)

                    if DeveloperSettings.isDeveloperSectionVisible {
                        NavigationLink {
                            DeveloperSettingsView()
                        } label: {
                            settingsRow(
                                icon: "hammer.fill",
                                iconColor: DiveUI.yellow,
                                title: String(localized: "developer.section.title"),
                                subtitle: String(localized: "developer.section.subtitle"),
                                showsChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    NavigationLink {
                        InfoView()
                    } label: {
                        settingsRow(
                            icon: "info.circle",
                            iconColor: DiveUI.blue,
                            title: String(localized: "settings.row.info.title"),
                            subtitle: String(localized: "settings.row.info.subtitle"),
                            showsChevron: true
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 11)
                .padding(.top, 9)
                .padding(.bottom, 8)
            }
        }
    }

    private var gpsStatusText: String {
        switch gps.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return gps.lastPoint == nil
                ? String(localized: "Autorizzato, in attesa fix")
                : String(localized: "Fix disponibile")
        case .denied, .restricted:
            return String(localized: "Permesso negato: abilita da iPhone")
        case .notDetermined:
            return String(localized: "Richiesto al primo uso")
        @unknown default:
            return String(localized: "Stato permesso sconosciuto")
        }
    }

    private var diveDepthSensorStatusText: String {
        if dive.isDepthAutomationMockFallbackActive {
            return String(localized: "live.depth_mock_fallback.badge")
        }
        if dive.lastErrorMessage != nil {
            return dive.lastErrorMessage ?? String(localized: "settings.depth.ready")
        }
        return dive.depthSensorSourceResolution.localizedLabel
    }

    private var languagePreferenceControl: some View {
        let selectedLanguage = DIRAppLanguage.fromStorage(appLanguage)

        return VStack(alignment: .leading, spacing: 6) {
            settingsRow(
                icon: "globe",
                iconColor: DiveUI.cyan,
                title: String(localized: "settings.row.language.title"),
                subtitle: String(localized: "settings.language.subtitle"),
                informational: true
            )
            Picker("Lingua", selection: $appLanguage) {
                ForEach(DIRAppLanguage.allCases) { language in
                    Text(language.title).tag(language.rawValue)
                }
            }
            .pickerStyle(.wheel)
            .tint(DiveUI.cyan)
            Text(selectedLanguage.watchDetail)
                .font(DiveUI.Typography.statusValue)
                .foregroundStyle(DiveUI.yellow)
                .fixedSize(horizontal: false, vertical: true)
            Text(String(localized: "settings.language.scope_note"))
                .font(DiveUI.Typography.rowSubtitle)
                .foregroundStyle(DiveUI.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(0.52))
                .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous).stroke(.white.opacity(0.24), lineWidth: 1))
        )
    }

    private var unitPreferenceControl: some View {
        let preference = DIRUnitPreference.fromStorage(watchUnits)

        return VStack(alignment: .leading, spacing: 6) {
            settingsRow(
                icon: "ruler",
                iconColor: .white,
                title: String(localized: "settings.row.units.title"),
                subtitle: preference == .metric
                    ? String(localized: "settings.row.units.metric")
                    : String(localized: "settings.row.units.imperial"),
                informational: true
            )
            Picker("Unità", selection: $watchUnits) {
                Text(String(localized: "settings.row.units.metric")).tag(DIRUnitPreference.metric.rawValue)
                Text(String(localized: "settings.row.units.imperial")).tag(DIRUnitPreference.imperial.rawValue)
            }
            .pickerStyle(.wheel)
            .tint(DiveUI.cyan)
            Text(String(localized: "settings.units.sync_note"))
                .font(DiveUI.Typography.rowSubtitle)
                .foregroundStyle(DiveUI.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(0.52))
                .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous).stroke(.white.opacity(0.24), lineWidth: 1))
        )
        .onChange(of: watchUnits) { _, newValue in
            watchSync.publishUnitsPreference(newValue)
        }
    }

    private var missionModeStatusText: String {
        if dive.isDiveActive {
            return dive.isMissionModeActive
                ? String(localized: "settings.mission_mode.status.active")
                : String(localized: "settings.mission_mode.status.inactive")
        }
        if dive.missionModeWillActivateOnNextDive {
            return String(localized: "settings.mission_mode.status.will_auto")
        }
        return String(localized: "settings.mission_mode.status.inactive")
    }

    private var missionModeControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(DiveUI.yellow)
                    .frame(width: 26)

                VStack(alignment: .leading, spacing: 3) {
                    Text(String(localized: "settings.mission_mode.title"))
                        .font(DiveUI.Typography.rowTitle)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    Text(String(localized: "settings.mission_mode.toggle"))
                        .font(DiveUI.Typography.rowSubtitle)
                        .foregroundStyle(DiveUI.secondaryText)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Toggle("", isOn: $missionModeAutoEnableOnDiveStart)
                    .labelsHidden()
                    .tint(DiveUI.green)
                    .disabled(dive.isDiveActive)
                    .accessibilityLabel(String(localized: "settings.a11y.mission_mode"))
            }
            .frame(minHeight: DiveUI.Layout.settingsRowInteractiveMinHeight)

            settingsRow(
                icon: "circle.fill",
                iconColor: dive.isMissionModeActive ? DiveUI.green : DiveUI.secondaryText,
                title: String(localized: "settings.mission_mode.status.title"),
                subtitle: missionModeStatusText,
                informational: true,
                statusEmphasis: true
            )

            if dive.isDiveActive {
                Text(String(localized: "settings.mission_mode.live_hint"))
                    .font(DiveUI.Typography.rowSubtitle)
                    .foregroundStyle(DiveUI.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                HStack(spacing: 6) {
                    if dive.isMissionModeActive || dive.missionModeManualPendingForSession {
                        missionModeActionButton(
                            title: String(localized: "settings.mission_mode.disable_now"),
                            tint: DiveUI.red
                        ) {
                            dive.disableMissionModeManually()
                        }
                    } else {
                        missionModeActionButton(
                            title: String(localized: "settings.mission_mode.enable_now"),
                            tint: DiveUI.green
                        ) {
                            dive.enableMissionModeManually()
                        }
                    }
                }
            }

            Text(String(localized: "settings.mission_mode.effects"))
                .font(DiveUI.Typography.rowSubtitle)
                .foregroundStyle(DiveUI.secondaryText)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Text(String(localized: "settings.mission_mode.safety_note"))
                .font(DiveUI.Typography.rowSubtitle)
                .foregroundStyle(DiveUI.secondaryText)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Text(String(localized: "settings.mission_mode.apple_lpm_disclaimer"))
                .font(DiveUI.Typography.rowSubtitle)
                .foregroundStyle(DiveUI.secondaryText)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.black.opacity(0.52))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(0.24), lineWidth: 1)
                )
        )
    }

    private func missionModeActionButton(title: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(DiveUI.Typography.secondaryLabel)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: DiveUI.Layout.commandButtonMinHeight)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(tint.opacity(0.35))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(tint.opacity(0.65), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }

    private var header: some View {
        HStack(alignment: .center) {
            HStack(spacing: 5) {
                DiveOctopusLogo(accent: DiveUI.yellow)
                    .frame(width: 23, height: 22, alignment: .leading)
                    .scaleEffect(0.68)
                Text("DIR DIVING")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .lineLimit(1)
            }

            Spacer()

            DiveClockText(size: 14)
        }
    }

    private func settingsRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        showsChevron: Bool = false,
        informational: Bool = false,
        legal: Bool = false,
        statusEmphasis: Bool = false
    ) -> some View {
        WatchSettingsRow(
            icon: icon,
            iconColor: iconColor,
            title: title,
            subtitle: subtitle,
            showsChevron: showsChevron,
            informational: informational,
            legal: legal,
            statusEmphasis: statusEmphasis
        )
        .accessibilityHint(informational ? String(localized: "settings.informational.a11y.hint") : "")
    }

    private func statusRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        settingsRow(icon: icon, iconColor: iconColor, title: title, subtitle: subtitle, informational: true, statusEmphasis: true)
    }
}

private struct WatchShortcutHelpView: View {
    var body: some View {
        ZStack {
            DiveScreenBackground()
            ScrollView {
                VStack(spacing: 8) {
                    header
                    Text("SHORTCUT")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    helpPanel(
                        icon: "digitalcrown.arrow.clockwise",
                        title: String(localized: "shortcuts.help.crown.title"),
                        body: String(localized: "shortcuts.help.crown.body")
                    )
                    helpPanel(
                        icon: "water.waves",
                        title: String(localized: "shortcuts.help.mode_selection.title"),
                        body: String(localized: "shortcuts.help.mode_selection.body")
                    )
                    helpPanel(
                        icon: "hand.tap",
                        title: String(localized: "shortcuts.help.touch.title"),
                        body: String(localized: "shortcuts.help.touch.body")
                    )
                    helpPanel(
                        icon: "water.waves",
                        title: String(localized: "shortcuts.help.underwater.title"),
                        body: String(localized: "shortcuts.help.underwater.body")
                    )
                    helpPanel(
                        icon: "stopwatch",
                        title: String(localized: "shortcuts.help.stopwatch.title"),
                        body: String(localized: "shortcuts.help.stopwatch.body")
                    )
                    helpPanel(
                        icon: "arrow.clockwise",
                        title: String(localized: "shortcuts.help.reset.title"),
                        body: String(localized: "shortcuts.help.reset.body")
                    )
                    helpPanel(
                        icon: "location.north.line",
                        title: String(localized: "shortcuts.help.bearing.title"),
                        body: String(localized: "shortcuts.help.bearing.body")
                    )
                    helpPanel(
                        icon: "bell.slash",
                        title: String(localized: "shortcuts.help.alarm.title"),
                        body: String(localized: "shortcuts.help.alarm.body")
                    )
                    helpPanel(
                        icon: "exclamationmark.triangle",
                        title: String(localized: "shortcuts.help.side_button.title"),
                        body: String(localized: "shortcuts.help.side_button.body")
                    )
                    helpPanel(
                        icon: "hand.tap",
                        title: String(localized: "shortcuts.help.on_screen.title"),
                        body: String(localized: "shortcuts.help.on_screen.body")
                    )
                }
                .padding(.horizontal, 11)
                .padding(.top, 9)
                .padding(.bottom, 8)
            }
        }
        .watchSubscreenBackToolbar()
    }

    private var header: some View {
        HStack(alignment: .center) {
            HStack(spacing: 5) {
                DiveOctopusLogo(accent: DiveUI.yellow)
                    .frame(width: 23, height: 22, alignment: .leading)
                    .scaleEffect(0.68)
                Text("DIR DIVING")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .lineLimit(1)
            }
            Spacer()
            DiveClockText(size: 14)
        }
    }

    private func helpPanel(icon: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(DiveUI.cyan)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text(body)
                    .font(DiveUI.Typography.rowSubtitle)
                    .foregroundStyle(DiveUI.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.black.opacity(0.52))
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(DiveUI.cyan.opacity(0.35), lineWidth: 1))
        )
    }
}
