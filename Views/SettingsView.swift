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
    @State private var showClearSyncQueueConfirmation = false

    var body: some View {
        ZStack {
            DiveScreenBackground()

            ScrollView {
                VStack(spacing: 7) {
                    header

                    Text(String(localized: "IMPOSTAZIONI"))
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
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

                    NavigationLink {
                        AscentRateSettingsView()
                    } label: {
                        settingsRow(
                            icon: "gauge",
                            iconColor: DiveUI.green,
                            title: String(localized: "Velocità risalita"),
                            subtitle: String(localized: "Limiti m/min persistenti"),
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
                            title: String(localized: "Allarmi"),
                            subtitle: String(localized: "Stato soglie e promemoria"),
                            showsChevron: true
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(dive.isDiveActive)

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
                            showsChevron: true
                        )
                    }
                    .buttonStyle(.plain)
                    settingsRow(
                        icon: "iphone.slash",
                        iconColor: DiveUI.yellow,
                        title: String(localized: "Sync impostazioni"),
                        subtitle: String(localized: "settings.sync.settings_scope"),
                        informational: true
                    )
                    statusRow(
                        icon: "location.fill",
                        iconColor: gps.authorizationStatus == .denied ? DiveUI.red : DiveUI.green,
                        title: String(localized: "GPS superficie"),
                        subtitle: gpsStatusText
                    )
                    settingsRow(
                        icon: "mappin.and.ellipse",
                        iconColor: DiveUI.cyan,
                        title: String(localized: "Comportamento GPS"),
                        subtitle: String(localized: "Solo in superficie; in acqua il segnale GPS non e attendibile. Coordinate mancanti = ultimo fix noto o non disponibile (etichettato)."),
                        informational: true
                    )
                    statusRow(
                        icon: "drop.fill",
                        iconColor: dive.lastErrorMessage == nil ? DiveUI.green : DiveUI.yellow,
                        title: String(localized: "Sensore profondità"),
                        subtitle: dive.lastErrorMessage ?? String(localized: "settings.depth.ready")
                    )
                    statusRow(
                        icon: "applewatch.radiowaves.left.and.right",
                        iconColor: watchSync.isSupported ? DiveUI.green : DiveUI.orange,
                        title: String(localized: "Sync companion"),
                        subtitle: watchSync.isSupported ? watchSync.lastSyncStatus : String(localized: "settings.sync.open_ios")
                    )
                    statusRow(
                        icon: "tray.and.arrow.up",
                        iconColor: watchSync.pendingTransferCount == 0 ? DiveUI.green : DiveUI.yellow,
                        title: String(localized: "Sync pending"),
                        subtitle: String(format: String(localized: "%lld in attesa ack"), watchSync.pendingTransferCount)
                    )
                    statusRow(
                        icon: "paperplane.fill",
                        iconColor: watchSync.sentTransferCount == 0 ? DiveUI.secondaryText : DiveUI.cyan,
                        title: String(localized: "Sync sent"),
                        subtitle: String(format: String(localized: "%lld inviati o in transito"), watchSync.sentTransferCount)
                    )
                    statusRow(
                        icon: "checkmark.seal.fill",
                        iconColor: watchSync.acknowledgedTransferCount == 0 ? DiveUI.secondaryText : DiveUI.green,
                        title: String(localized: "Sync acknowledged"),
                        subtitle: String(format: String(localized: "%lld confermati da iPhone"), watchSync.acknowledgedTransferCount)
                    )
                    if !watchSync.recentActivity.isEmpty {
                        syncActivityPanel
                    }
                    Button {
                        navigation.selectedPage = .diveLog
                        HapticService.shared.confirm()
                    } label: {
                        settingsRow(
                            icon: "square.and.arrow.up",
                            iconColor: DiveUI.green,
                            title: String(localized: "Export"),
                            subtitle: String(localized: "settings.export.from_logbook"),
                            showsChevron: true
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(dive.isDiveActive)
                    settingsRow(
                        icon: "function",
                        iconColor: DiveUI.green,
                        title: String(localized: "TTV live"),
                        subtitle: String(localized: "settings.ttv.info"),
                        informational: true
                    )
                    statusRow(
                        icon: "exclamationmark.arrow.triangle.2.circlepath",
                        iconColor: watchSync.failedTransferCount == 0 ? DiveUI.green : DiveUI.red,
                        title: String(localized: "Errori sync"),
                        subtitle: String(format: String(localized: "%lld falliti · retry %@"), watchSync.failedTransferCount, lastRetryText)
                    )
                    if watchSync.pendingTransferCount > 0 || watchSync.activationState != .activated {
                        Button {
                            watchSync.retryPendingTransfers()
                            HapticService.shared.confirm()
                        } label: {
                            settingsRow(
                                icon: "arrow.triangle.2.circlepath",
                                iconColor: DiveUI.cyan,
                                title: String(localized: "Riprova sync"),
                                subtitle: String(localized: "settings.sync.retry.subtitle"),
                                showsChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    if watchSync.pendingTransferCount > 0 || watchSync.failedTransferCount > 0 {
                        Button {
                            showClearSyncQueueConfirmation = true
                            HapticService.shared.notify()
                        } label: {
                            settingsRow(
                                icon: "trash",
                                iconColor: DiveUI.red,
                                title: String(localized: "Cancella coda fallita"),
                                subtitle: String(localized: "settings.sync.clear.subtitle"),
                                showsChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    settingsRow(
                        icon: "sun.max",
                        iconColor: DiveUI.yellow,
                        title: String(localized: "Schermo"),
                        subtitle: String(localized: "settings.display.watchos"),
                        informational: true
                    )
                    settingsRow(
                        icon: "speaker.slash",
                        iconColor: DiveUI.yellow,
                        title: String(localized: "Toni audio"),
                        subtitle: String(localized: "settings.audio.info"),
                        informational: true
                    )
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
                    settingsRow(
                        icon: "hand.tap",
                        iconColor: dive.isDepthAutomationAvailable ? DiveUI.green : DiveUI.yellow,
                        title: String(localized: "Avvio manuale"),
                        subtitle: dive.isDepthAutomationAvailable ? String(localized: "settings.manual.fallback") : String(localized: "settings.manual.live"),
                        informational: true
                    )
                    missionModeControl
                        .disabled(dive.isDiveActive)
                    Toggle(isOn: $hapticsEnabled) {
                        settingsRow(
                            icon: "iphone.radiowaves.left.and.right",
                            iconColor: hapticsEnabled ? DiveUI.blue : .white.opacity(0.5),
                            title: String(localized: "Vibrazione"),
                            subtitle: hapticsEnabled ? String(localized: "settings.haptics.on") : String(localized: "settings.haptics.off")
                        )
                    }
                    .toggleStyle(.switch)
                    .tint(DiveUI.green)

                    NavigationLink {
                        InfoView()
                    } label: {
                        settingsRow(
                            icon: "info.circle",
                            iconColor: DiveUI.blue,
                            title: String(localized: "Info"),
                            subtitle: String(localized: "Info, sync, device"),
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
        .confirmationDialog(String(localized: "settings.sync.clear.confirm.title"), isPresented: $showClearSyncQueueConfirmation, titleVisibility: .visible) {
            Button(String(localized: "settings.sync.clear.confirm.action"), role: .destructive) {
                watchSync.clearFailedQueue()
                HapticService.shared.confirm()
            }
            Button(String(localized: "log.delete.cancel"), role: .cancel) {
                HapticService.shared.confirm()
            }
        } message: {
            Text(String(localized: "settings.sync.clear.confirm.message"))
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

    private var languagePreferenceControl: some View {
        let selectedLanguage = DIRAppLanguage.fromStorage(appLanguage)

        return VStack(alignment: .leading, spacing: 6) {
            settingsRow(
                icon: "globe",
                iconColor: DiveUI.cyan,
                title: String(localized: "Lingua"),
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
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(DiveUI.yellow)
                .fixedSize(horizontal: false, vertical: true)
            Text(String(localized: "settings.language.scope_note"))
                .font(.system(size: 9, weight: .semibold, design: .rounded))
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
                title: String(localized: "Unità di misura"),
                subtitle: preference == .metric
                    ? String(localized: "Display Watch: metrico")
                    : String(localized: "Display Watch: imperiale"),
                informational: true
            )
            Picker("Unità", selection: $watchUnits) {
                Text("Metrico (m)").tag(DIRUnitPreference.metric.rawValue)
                Text("Imperial (ft)").tag(DIRUnitPreference.imperial.rawValue)
            }
            .pickerStyle(.wheel)
            .tint(DiveUI.cyan)
            Text(String(localized: "settings.units.sync_note"))
                .font(.system(size: 9, weight: .semibold, design: .rounded))
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

    private var lastRetryText: String {
        guard let date = watchSync.lastRetryDate else { return String(localized: "mai") }
        return Self.retryFormatter.string(from: date)
    }

    private static let retryFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private var syncActivityPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(String(localized: "sync.activity.section_title"))
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(DiveUI.secondaryText)
            ForEach(Array(watchSync.recentActivity.prefix(4))) { activity in
                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.title)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(activity.detail)
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(DiveUI.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 2)
            }
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(0.38))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(.white.opacity(0.24), lineWidth: 1)
                )
        )
    }

    private var missionModeControl: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 9) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(DiveUI.yellow)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 1) {
                    Text(String(localized: "settings.mission_mode.title"))
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(String(localized: "settings.mission_mode.toggle"))
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(DiveUI.secondaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                }

                Spacer(minLength: 0)

                Toggle("", isOn: $missionModeAutoEnableOnDiveStart)
                    .labelsHidden()
                    .tint(DiveUI.green)
            }

            Text(String(localized: "settings.mission_mode.footnote"))
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(DiveUI.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(0.52))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(.white.opacity(0.24), lineWidth: 1)
                )
        )
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

    private func settingsRow(icon: String, iconColor: Color, title: String, subtitle: String, showsChevron: Bool = false, informational: Bool = false) -> some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.system(size: 10, weight: informational ? .medium : .regular, design: .rounded))
                    .foregroundStyle(informational ? DiveUI.secondaryText : .white)
                    .lineLimit(informational ? 3 : 1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 0)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.42))
            }
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .frame(minHeight: informational ? 38 : 35)
        .opacity(informational ? 0.92 : 1)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(informational ? 0.38 : 0.52))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(.white.opacity(0.24), lineWidth: 1)
                )
        )
    }

    private func statusRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        settingsRow(icon: icon, iconColor: iconColor, title: title, subtitle: subtitle, informational: true)
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
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
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
