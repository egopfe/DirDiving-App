import SwiftUI
import UIKit
import UserNotifications
import WatchConnectivity

struct MoreView: View {
    @EnvironmentObject private var watchSync: WatchSyncService
    @EnvironmentObject private var cloudSync: CloudSyncStore
    @EnvironmentObject private var logStore: DiveLogStore
    @AppStorage("dirdiving_ios_units") private var units = "Metrico (m, °C)"
    @AppStorage("dirdiving_ios_export_format") private var exportFormat = "Subsurface CSV"
    @AppStorage("dirdiving_ios_show_onboarding") private var showOnboarding = true
    @AppStorage(DIRIOSAppLanguage.storageKey) private var appLanguage = DIRIOSAppLanguage.system.rawValue
    @State private var notificationStatus = "Non verificato"
    @State private var showResetPairingConfirmation = false

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
                                .lineLimit(1)
                                .minimumScaleFactor(0.78)
                            Text("Sync, cloud backup, units, export and review preferences")
                                .font(.callout)
                                .foregroundStyle(DIRTheme.muted)
                                .lineLimit(2)
                                .minimumScaleFactor(0.82)
                        }
                        systemStatus
                        onboardingCard
                        DIRCard("PREFERENZE APP", icon: "gearshape.fill", accent: DIRTheme.cyan) {
                            languagePreferencePicker
                            unitPreferencePicker
                            lockedPreference("Export predefinito", value: exportFormat, note: "Unico formato disponibile oggi.")
                            infoRow("Sync impostazioni", "Locale-only")
                            infoRow("Planner safety", "Disclaimer richiesto")
                            infoNote("Le unità convertono la visualizzazione iOS di profondità, temperatura, distanza e SAC. Dati salvati, import/export CSV e planner restano metrici per compatibilità e sicurezza.")
                        }
                        DIRCard("ALLARMI E NOTIFICHE", icon: "bell.badge", accent: DIRTheme.yellow) {
                            infoRow("Allarmi immersione", "Gestiti su Apple Watch")
                            infoRow("Notifiche iOS", "Permessi gestiti da iOS")
                            infoRow("Stato autorizzazione", notificationStatus)
                            Button {
                                HapticFeedback.tap()
                                requestNotificationAuthorization()
                            } label: {
                                actionLabel("Richiedi permesso notifiche", systemImage: "bell.badge.fill")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Richiedi permesso notifiche")
                            .accessibilityHint("Apre il prompt iOS per autorizzare avvisi, suoni e badge.")
                            Button {
                                HapticFeedback.tap()
                                openSystemSettings()
                            } label: {
                                actionLabel("Apri Impostazioni iOS", systemImage: "gearshape")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Apri impostazioni notifiche iOS")
                            .accessibilityHint("Apre le Impostazioni di sistema per gestire i permessi notifiche.")
                            infoNote("Soglie allarmi Watch restano locali · Planned: contratto settings bidirezionale.")
                        }
                        DIRCard("SYNC WATCH", icon: "applewatch", accent: DIRTheme.cyan) {
                            infoRow("Supportato", watchSync.isSupported ? "Si" : "No")
                            infoRow("Stato", activationStateLabel(watchSync.activationState))
                            infoRow("Esito", watchSync.userVisibleState)
                            infoRow("Peer verificato", WatchSyncAuth.hasPeerSecret() ? "Si" : "No")
                            infoRow("Ultimo sync", watchSync.lastMessage)
                            infoRow("Settings Watch", "Solo unità · Planned per allarmi")
                            infoRow("iPhone -> Watch", WatchSyncAuth.hasPeerSecret() ? "Push verificato attivo (\(watchSync.pendingOutboundCount) pending)" : "In attesa peer secret · push gated")
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
                            infoRow("Import riusciti", "\(watchSync.importedSessionCount)")
                            infoRow("Import falliti", "\(watchSync.failedImportCount)")
                            infoRow("Conflitti", "\(watchSync.conflicts.count)")
                            infoRow("Ultimo evento", watchSync.lastMessage)
                            infoRow("Delivery per log", "TODO: stato per-sessione planned")
                            ForEach(watchSync.conflicts) { conflict in
                                conflictRow(conflict)
                            }
                            Button {
                                HapticFeedback.confirm()
                                watchSync.retryActivation(logStore: logStore)
                            } label: {
                                actionLabel(retryWatchSyncDisabled ? "Riprova Watch Sync (idle)" : "Riprova Watch Sync", systemImage: "arrow.triangle.2.circlepath")
                            }
                            .buttonStyle(.plain)
                            .disabled(retryWatchSyncDisabled)
                            .accessibilityLabel("Riprova Watch Sync")
                            .accessibilityHint(retryWatchSyncDisabled ? "Sync attivo e nessun retry necessario." : "Riattiva WatchConnectivity e riprova gli import.")
                            Button {
                                HapticFeedback.destructive()
                                showResetPairingConfirmation = true
                            } label: {
                                destructiveActionLabel("Reset trust / re-pair", systemImage: "lock.rotation")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Reset trust Watch")
                            .accessibilityHint("Rimuove solo il peer secret locale e richiede una nuova associazione verificata.")
                            infoNote("Il reset rimuove solo il peer secret locale attendibile. I payload Watch restano non verificati finche non arriva una nuova associazione sicura; non viene usata alcuna chiave deterministica di fallback.")
                        }
                        DIRCard("BACKUP CLOUD", icon: "icloud", accent: DIRTheme.green) {
                            infoRow("iCloud Sync", cloudSync.isICloudAvailable ? "Attivo" : "Non disponibile")
                            infoRow("Backup automatico", "Log, planner e attrezzatura")
                            infoRow("Conflitti cloud", "Ultimo salvataggio KVS")
                            infoRow("Eliminazioni", "Rimozione locale + prossima sync")
                            infoRow("Ultimo evento", cloudSync.lastSyncStatus)
                            infoNote("Merge cloud: log locali e iCloud vengono confrontati per ID stabile; se esistono due versioni dello stesso ID viene mantenuta la versione piu completa/recente secondo la policy dell'app. Attrezzatura e planner usano ultimo salvataggio KVS e non hanno ancora risoluzione per-campo.")
                            if !cloudSync.isICloudAvailable {
                                emptyState(
                                    title: "Backup cloud non disponibile",
                                    message: "Abilita iCloud e verifica il profilo di firma. I dati restano salvati localmente.",
                                    action: "Controlla iCloud"
                                )
                            }
                            Button {
                                HapticFeedback.confirm()
                                logStore.synchronizeCloud()
                                cloudSync.synchronize()
                            } label: {
                                actionLabel("Sincronizza ora", systemImage: "icloud.and.arrow.up")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Sincronizza cloud ora")
                            .accessibilityHint("Forza salvataggio log locale e sincronizzazione iCloud KVS.")
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
                            infoRow("Formato", exportFormat)
                            infoRow("Subsurface CSV", "Default")
                            infoRow("GPX", "Planned")
                            infoRow("UDDF", "Planned")
                            infoRow("Bundle", "com.egopfe.dirdiving.ios")
                            infoRow("Import", "CSV Subsurface da Logbook")
                            infoNote("Solo Subsurface CSV e disponibile oggi. Altri formati restano Planned/TODO.")
                        }
                        DIRWarningBox(text: "DIR DIVING non e un computer subacqueo certificato: usa log, planner e analisi come supporto informativo.")
                    }
                    .padding(16)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear { refreshNotificationStatus() }
            .confirmationDialog("Resettare trust Watch?", isPresented: $showResetPairingConfirmation, titleVisibility: .visible) {
                Button("Reset trust e nuova associazione", role: .destructive) {
                    HapticFeedback.destructive()
                    watchSync.resetPairingTrust(logStore: logStore)
                }
                Button("Annulla", role: .cancel) {}
            } message: {
                Text("La chiave peer verificata viene rimossa da questo iPhone. I nuovi payload saranno considerati non verificati finche Watch e iPhone non scambiano una nuova chiave attendibile.")
            }
        }
    }

    private var languagePreferencePicker: some View {
        let selectedLanguage = DIRIOSAppLanguage.fromStorage(appLanguage)

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Lingua")
                    .foregroundStyle(DIRTheme.muted)
                Spacer()
                Text(selectedLanguage.title)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
            }
            .font(.callout)
            Picker("Lingua", selection: $appLanguage) {
                ForEach(DIRIOSAppLanguage.allCases) { language in
                    Text(language.title).tag(language.rawValue)
                }
            }
            .pickerStyle(.segmented)
            Text(selectedLanguage.companionDetail)
                .font(.caption2)
                .foregroundStyle(DIRTheme.yellow)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
            Text("Changing language does not change units, calculations or saved data.")
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 5)
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
            .onChange(of: units) { _, newValue in
                watchSync.pushUnitsPreference(newValue)
            }
            Text("Persistita localmente; broadcast iOS -> Watch via WatchConnectivity context (solo metric oggi).")
                .font(.caption2)
                .foregroundStyle(DIRTheme.yellow)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
            Text("Contratto unidirezionale iOS -> Watch attivo: viene inviata la chiave \"units\" via applicationContext; oggi il Watch resta metrico finche la conversione locale non e implementata.")
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
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

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(DIRTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
            Spacer()
            Text(value)
                .foregroundStyle(.white.opacity(0.86))
                .fontWeight(.semibold)
                .lineLimit(2)
                .minimumScaleFactor(0.74)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(DIRTheme.surface2.opacity(0.36))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.05), lineWidth: 1))
        )
        .accessibilityElement(children: .combine)
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
            Text("Stato: \(action)")
                .font(.caption2.weight(.bold))
                .foregroundStyle(DIRTheme.yellow)
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
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan, lineWidth: 1))
    }

    private func destructiveActionLabel(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.callout.weight(.semibold))
            .foregroundStyle(DIRTheme.red)
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.red.opacity(0.78), lineWidth: 1))
    }

    private func activationStateLabel(_ state: WCSessionActivationState) -> String {
        switch state {
        case .activated: return "Attivo"
        case .inactive: return "Non attivo"
        case .notActivated: return "In attesa"
        @unknown default: return "Sconosciuto"
        }
    }

    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status = settings.authorizationStatus
            switch status {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                    Task { @MainActor in refreshNotificationStatus() }
                }
            default:
                Task { @MainActor in refreshNotificationStatus() }
            }
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func refreshNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status: String
            switch settings.authorizationStatus {
            case .authorized:
                status = "Authorized"
            case .denied:
                status = "Denied"
            case .notDetermined:
                status = "Not determined"
            case .provisional:
                status = "Provisional"
            case .ephemeral:
                status = "Ephemeral"
            @unknown default:
                status = "Sconosciuto"
            }
            Task { @MainActor in notificationStatus = status }
        }
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
                Button("Mantieni locale") {
                    HapticFeedback.notify()
                    watchSync.resolveConflictKeepingLocal(conflict)
                }
                .accessibilityLabel("Mantieni versione locale")
                .accessibilityHint("Ignora la versione Watch per questo conflitto.")
                Button("Usa Watch") {
                    HapticFeedback.success()
                    watchSync.resolveConflictUsingIncoming(conflict)
                }
                .accessibilityLabel("Usa versione Watch")
                .accessibilityHint("Sostituisce la versione locale con quella ricevuta dal Watch.")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(DIRTheme.cyan)
        }
        .padding(.vertical, 7)
    }

    private var retryWatchSyncDisabled: Bool {
        watchSync.activationState == .activated && watchSync.failedImportCount == 0 && watchSync.conflicts.isEmpty
    }
}
