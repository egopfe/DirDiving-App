import SwiftUI
import UIKit

struct MoreView: View {
    @EnvironmentObject private var watchSync: WatchSyncService
    @EnvironmentObject private var cloudSync: CloudSyncStore
    @EnvironmentObject private var logStore: DiveLogStore
    @AppStorage("dirdiving_ios_units") private var units = "Metrico (m, °C)"
    @AppStorage("dirdiving_ios_export_format") private var exportFormat = "Subsurface CSV"
    @AppStorage("dirdiving_ios_show_onboarding") private var showOnboarding = true

    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 7) {
                            Text("Settings")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Sync, cloud backup, units, export and review preferences")
                                .font(.callout)
                                .foregroundStyle(DIRTheme.muted)
                        }
                        systemStatus
                        onboardingCard
                        DIRCard("PREFERENZE APP", icon: "gearshape.fill", accent: DIRTheme.cyan) {
                            unitPreferencePicker
                            lockedPreference("Export predefinito", value: exportFormat, note: "Unico formato disponibile oggi.")
                            row("Sync impostazioni", "Locale-only")
                            row("Planner safety", "Disclaimer richiesto")
                            infoNote("Le unità convertono la visualizzazione iOS di profondità, temperatura, distanza e SAC. Dati salvati, import/export CSV e planner restano metrici per compatibilità e sicurezza.")
                        }
                        DIRCard("ALLARMI E NOTIFICHE", icon: "bell.badge", accent: DIRTheme.yellow) {
                            row("Allarmi immersione", "Gestiti su Apple Watch")
                            row("Notifiche iOS", "Permessi gestiti da iOS")
                            row("Stato autorizzazione", "Verifica in Impostazioni")
                            Button {
                                openAppSettings()
                            } label: {
                                actionLabel("Apri Impostazioni iOS", systemImage: "gearshape")
                            }
                            .buttonStyle(.plain)
                            infoNote("TODO: sincronizzare soglie allarmi e haptics Watch quando esiste un contratto settings bidirezionale.")
                        }
                        DIRCard("SYNC WATCH", icon: "applewatch", accent: DIRTheme.cyan) {
                            row("Supportato", watchSync.isSupported ? "Si" : "No")
                            row("Stato", String(describing: watchSync.activationState))
                            row("Esito", watchSync.userVisibleState)
                            row("Settings Watch", "Non sincronizzati")
                            if watchSync.activationState == .activated && !WatchSyncAuth.hasPeerSecret() {
                                emptyState(
                                    title: "Associazione Watch non verificata",
                                    message: "La chiave di sync non e ancora stata ricevuta dal Watch. I payload non vengono trattati come attendibili finche l'associazione non e completata.",
                                    action: "Riprova sincronizzazione"
                                )
                            }
                            if !watchSync.isSupported || watchSync.activationState != .activated {
                                emptyState(
                                    title: "Sync Watch non attivo",
                                    message: "Apri l'app Watch/iPhone e riprova. I log possono arrivare tramite coda quando WatchConnectivity torna disponibile.",
                                    action: "Riprova Watch Sync"
                                )
                            }
                            row("Import riusciti", "\(watchSync.importedSessionCount)")
                            row("Import falliti", "\(watchSync.failedImportCount)")
                            row("Conflitti", "\(watchSync.conflicts.count)")
                            row("Ultimo evento", watchSync.lastMessage)
                            ForEach(watchSync.conflicts) { conflict in
                                conflictRow(conflict)
                            }
                            Button {
                                watchSync.retryActivation(logStore: logStore)
                            } label: {
                                actionLabel("Riprova Watch Sync", systemImage: "arrow.triangle.2.circlepath")
                            }
                            .buttonStyle(.plain)
                        }
                        DIRCard("BACKUP CLOUD", icon: "icloud", accent: DIRTheme.green) {
                            row("iCloud Sync", cloudSync.isICloudAvailable ? "Attivo" : "Non disponibile")
                            row("Backup automatico", "Log, planner e attrezzatura")
                            row("Conflitti cloud", "Ultimo salvataggio KVS")
                            row("Eliminazioni", "Rimozione locale + prossima sync")
                            row("Ultimo evento", cloudSync.lastSyncStatus)
                            if !cloudSync.isICloudAvailable {
                                emptyState(
                                    title: "Backup cloud non disponibile",
                                    message: "Abilita iCloud e verifica il profilo di firma. I dati restano salvati localmente.",
                                    action: "Controlla iCloud"
                                )
                            }
                            Button {
                                logStore.synchronizeCloud()
                                cloudSync.synchronize()
                            } label: {
                                actionLabel("Sincronizza ora", systemImage: "icloud.and.arrow.up")
                            }
                            .buttonStyle(.plain)
                        }
                        DIRCard("REVIEWER", icon: "books.vertical", accent: DIRTheme.yellow) {
                            Toggle(isOn: Binding(
                                get: { logStore.includeDemoLogbook },
                                set: { logStore.includeDemoLogbook = $0 }
                            )) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Logbook dimostrativo")
                                        .foregroundStyle(.white)
                                    Text("Carica 5 immersioni demo per revisione App Store.")
                                        .font(.caption2)
                                        .foregroundStyle(DIRTheme.muted)
                                }
                            }
                            .tint(DIRTheme.cyan)
                        }
                        DIRCard("EXPORT", icon: "square.and.arrow.up", accent: DIRTheme.cyan) {
                            row("Formato", exportFormat)
                            row("Bundle", "com.egopfe.dirdiving.ios")
                            row("Import", "CSV Subsurface da Logbook")
                            infoNote("Solo Subsurface CSV e disponibile oggi. Altri formati restano Planned/TODO.")
                        }
                        DIRWarningBox(text: "DIR DIVING non e un computer subacqueo certificato: usa log, planner e analisi come supporto informativo.")
                    }
                    .padding(16)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var systemStatus: some View {
        HStack(spacing: 12) {
            statusPill("WATCH", watchSync.isSupported ? DIRTheme.green : DIRTheme.orange)
            statusPill("CLOUD", cloudSync.isICloudAvailable ? DIRTheme.green : DIRTheme.yellow)
            statusPill("EXPORT", DIRTheme.cyan)
        }
    }

    private var onboardingCard: some View {
        DIRCard("ONBOARDING", icon: "questionmark.circle", accent: DIRTheme.yellow) {
            Toggle("Mostra note operative", isOn: $showOnboarding)
                .foregroundStyle(.white)
                .tint(DIRTheme.cyan)
            if showOnboarding {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Depth entitlement: i dati profondità arrivano dal Watch quando il profilo firmato abilita i sensori.")
                    Text("GPS: entry/exit sono surface-only; nessun tracking subacqueo.")
                    Text("Sync: se il Watch non e raggiungibile, i log arrivano tramite coda WatchConnectivity.")
                    Text("Export: apri un dettaglio immersione e genera il CSV Subsurface.")
                }
                .font(.footnote)
                .foregroundStyle(DIRTheme.muted)
            }
        }
    }

    private var unitPreferencePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Unità")
                    .foregroundStyle(DIRTheme.muted)
                Spacer()
                Text(IOSUnitPreference.fromStorage(units).shortLabel)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
            }
            .font(.callout)
            Picker("Unità", selection: $units) {
                ForEach(IOSUnitPreference.allCases) { preference in
                    Text(preference.shortLabel).tag(preference.rawValue)
                }
            }
            .pickerStyle(.segmented)
            Text("Persistita localmente; non sincronizzata con Apple Watch.")
                .font(.caption2)
                .foregroundStyle(DIRTheme.yellow)
        }
        .padding(.vertical, 5)
    }

    private func statusPill(_ text: String, _ color: Color) -> some View {
        HStack(spacing: 7) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .shadow(color: color.opacity(0.45), radius: 5, x: 0, y: 0)
            Text(text)
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(color)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(color.opacity(0.10))
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(color.opacity(0.32), lineWidth: 1))
        )
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(DIRTheme.muted)
            Spacer()
            Text(value).foregroundStyle(.white)
        }
        .font(.callout)
        .padding(.vertical, 4)
    }

    private func lockedPreference(_ title: String, value: String, note: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .foregroundStyle(DIRTheme.muted)
                Spacer()
                Text(value)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
            }
            .font(.callout)
            Text(note)
                .font(.caption2)
                .foregroundStyle(DIRTheme.yellow)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 5)
    }

    private func infoNote(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(DIRTheme.muted)
            .fixedSize(horizontal: false, vertical: true)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.surface2.opacity(0.56)))
    }

    private func emptyState(title: String, message: String, action: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.callout.weight(.bold))
                .foregroundStyle(.white)
            Text(message)
                .font(.caption)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
            Text(action.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(DIRTheme.cyan)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(DIRTheme.cyan.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(DIRTheme.cyan.opacity(0.32), lineWidth: 1))
        )
    }

    private func actionLabel(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.callout.weight(.semibold))
            .foregroundStyle(DIRTheme.cyan)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan, lineWidth: 1))
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func conflictRow(_ conflict: WatchSyncService.SyncConflict) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Conflitto \(conflict.incoming.startDate.formatted(.dateTime.day().month().hour().minute()))")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text("REVIEW")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(DIRTheme.yellow)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().stroke(DIRTheme.yellow.opacity(0.72), lineWidth: 1))
            }
            Text("Locale: \(conflict.localSummary) | Watch: \(Formatters.depth(conflict.incoming.maxDepthMeters, units: IOSUnitPreference.fromStorage(units)).text) / \(Formatters.time(conflict.incoming.durationSeconds))")
                .font(.caption)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 8) {
                Button("Mantieni locale") { watchSync.resolveConflictKeepingLocal(conflict) }
                Button("Usa Watch") { watchSync.resolveConflictUsingIncoming(conflict) }
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(DIRTheme.cyan)
        }
        .padding(.vertical, 7)
    }
}
