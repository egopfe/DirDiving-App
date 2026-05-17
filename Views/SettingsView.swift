import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var gps: GPSManager
    @EnvironmentObject private var dive: DiveManager
    @EnvironmentObject private var watchSync: WatchSyncService
    @AppStorage("dirdiving_watch_haptics_enabled") private var hapticsEnabled = true

    var body: some View {
        ZStack {
            DiveScreenBackground()

            ScrollView {
                VStack(spacing: 7) {
                    header

                    Text("IMPOSTAZIONI")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)

                    NavigationLink {
                        AscentRateSettingsView()
                    } label: {
                        settingsRow(
                            icon: "gauge",
                            iconColor: DiveUI.green,
                            title: "Velocità risalita",
                            subtitle: "Limiti m/min persistenti",
                            showsChevron: true
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        AlarmSettingsView()
                    } label: {
                        settingsRow(
                            icon: "bell",
                            iconColor: DiveUI.yellow,
                            title: "Allarmi",
                            subtitle: "Stato soglie e promemoria",
                            showsChevron: true
                        )
                    }
                    .buttonStyle(.plain)

                    settingsRow(
                        icon: "ruler",
                        iconColor: .white,
                        title: "Unità di misura",
                        subtitle: "Locale Watch: metrico fisso (m, \u{00B0}C)"
                    )
                    settingsRow(
                        icon: "iphone.slash",
                        iconColor: DiveUI.yellow,
                        title: "Sync impostazioni",
                        subtitle: "Allarmi/haptics locali, non inviati a iPhone"
                    )
                    statusRow(
                        icon: "location.fill",
                        iconColor: gps.authorizationStatus == .denied ? DiveUI.red : DiveUI.green,
                        title: "GPS superficie",
                        subtitle: gpsStatusText
                    )
                    statusRow(
                        icon: "drop.fill",
                        iconColor: dive.lastErrorMessage == nil ? DiveUI.green : DiveUI.yellow,
                        title: "Sensore profondità",
                        subtitle: dive.lastErrorMessage ?? "Pronto quando disponibile"
                    )
                    statusRow(
                        icon: "applewatch.radiowaves.left.and.right",
                        iconColor: watchSync.isSupported ? DiveUI.green : DiveUI.orange,
                        title: "Sync companion",
                        subtitle: watchSync.isSupported ? watchSync.lastSyncStatus : "Non disponibile: apri app iPhone"
                    )
                    statusRow(
                        icon: "tray.and.arrow.up",
                        iconColor: watchSync.pendingTransferCount == 0 ? DiveUI.green : DiveUI.yellow,
                        title: "Coda sync",
                        subtitle: "\(watchSync.pendingTransferCount) immersioni in attesa"
                    )
                    if watchSync.pendingTransferCount > 0 || watchSync.activationState != .activated {
                        Button {
                            watchSync.retryPendingTransfers()
                            HapticService.shared.notify()
                        } label: {
                            settingsRow(
                                icon: "arrow.triangle.2.circlepath",
                                iconColor: DiveUI.cyan,
                                title: "Riprova sync",
                                subtitle: "Riattiva e svuota la coda se possibile",
                                showsChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    settingsRow(
                        icon: "sun.max",
                        iconColor: DiveUI.yellow,
                        title: "Schermo",
                        subtitle: "Gestito da watchOS"
                    )
                    settingsRow(
                        icon: "speaker.slash",
                        iconColor: DiveUI.yellow,
                        title: "Toni audio",
                        subtitle: "Non usati sott'acqua; feedback via vibrazione"
                    )
                    NavigationLink {
                        WatchShortcutHelpView()
                    } label: {
                        settingsRow(
                            icon: "button.programmable",
                            iconColor: DiveUI.cyan,
                            title: "Azione / Comandi",
                            subtitle: "Setup shortcut se supportato",
                            showsChevron: true
                        )
                    }
                    .buttonStyle(.plain)
                    settingsRow(
                        icon: "hand.tap",
                        iconColor: dive.isDepthAutomationAvailable ? DiveUI.green : DiveUI.yellow,
                        title: "Avvio manuale",
                        subtitle: dive.isDepthAutomationAvailable ? "Fallback solo se sensore non disponibile" : "Disponibile su schermata live"
                    )
                    Toggle(isOn: $hapticsEnabled) {
                        settingsRow(
                            icon: "iphone.radiowaves.left.and.right",
                            iconColor: hapticsEnabled ? DiveUI.blue : .white.opacity(0.5),
                            title: "Vibrazione",
                            subtitle: hapticsEnabled ? "Attiva per warning e conferme" : "Disattivata"
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
                            title: "Info",
                            subtitle: "App, sync, device",
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
            return gps.lastPoint == nil ? "Autorizzato, in attesa fix" : "Fix disponibile"
        case .denied, .restricted:
            return "Permesso negato: abilita da iPhone"
        case .notDetermined:
            return "Richiesto al primo uso"
        @unknown default:
            return "Stato permesso sconosciuto"
        }
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

    private func settingsRow(icon: String, iconColor: Color, title: String, subtitle: String, showsChevron: Bool = false) -> some View {
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
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
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
        .frame(minHeight: 35)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(0.52))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(.white.opacity(0.24), lineWidth: 1)
                )
        )
    }

    private func statusRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        settingsRow(icon: icon, iconColor: iconColor, title: title, subtitle: subtitle)
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
                        icon: "stopwatch",
                        title: "Cronometro",
                        body: "Configura START/STOP tramite Azione / Comandi Rapidi se watchOS espone l'intent."
                    )
                    helpPanel(
                        icon: "arrow.clockwise",
                        title: "Reset",
                        body: "Reset cronometro e disponibile come intent separato quando supportato dal sistema."
                    )
                    helpPanel(
                        icon: "exclamationmark.triangle",
                        title: "Limite watchOS",
                        body: "DIR DIVING non puo intercettare direttamente il tasto laterale o una pressione lunga arbitraria."
                    )
                    helpPanel(
                        icon: "hand.tap",
                        title: "Avvio manuale",
                        body: "Se il rilevamento automatico profondita non e disponibile, usa AVVIO MANUALE nella schermata live."
                    )
                }
                .padding(.horizontal, 11)
                .padding(.top, 9)
                .padding(.bottom, 8)
            }
        }
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
