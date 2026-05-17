import SwiftUI

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
                            Picker("Unità", selection: $units) {
                                Text("Metrico (m, °C)").tag("Metrico (m, °C)")
                            }
                            .pickerStyle(.menu)
                            .tint(DIRTheme.cyan)
                            Picker("Export", selection: $exportFormat) {
                                Text("Subsurface CSV").tag("Subsurface CSV")
                            }
                            .pickerStyle(.menu)
                            .tint(DIRTheme.cyan)
                            row("Planner safety", "Disclaimer richiesto")
                            row("Permessi", "Gestiti da iOS")
                        }
                        DIRCard("SYNC WATCH", icon: "applewatch", accent: DIRTheme.cyan) {
                            row("Supportato", watchSync.isSupported ? "Si" : "No")
                            row("Stato", String(describing: watchSync.activationState))
                            row("Esito", watchSync.userVisibleState)
                            row("Import riusciti", "\(watchSync.importedSessionCount)")
                            row("Import falliti", "\(watchSync.failedImportCount)")
                            row("Ultimo evento", watchSync.lastMessage)
                            Button {
                                watchSync.retryActivation(logStore: logStore)
                            } label: {
                                Label("Riprova Watch Sync", systemImage: "arrow.triangle.2.circlepath")
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(DIRTheme.cyan)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                        DIRCard("BACKUP CLOUD", icon: "icloud", accent: DIRTheme.green) {
                            row("iCloud Sync", cloudSync.isICloudAvailable ? "Attivo" : "Non disponibile")
                            row("Backup automatico", "Log e planner")
                            row("Conflitti", "Risoluzione manuale non disponibile")
                            row("Ultimo evento", cloudSync.lastSyncStatus)
                            Button {
                                logStore.synchronizeCloud()
                                cloudSync.synchronize()
                            } label: {
                                Label("Sincronizza ora", systemImage: "icloud.and.arrow.up")
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(DIRTheme.cyan)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan, lineWidth: 1))
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
                            row("Import", "Non disponibile in main")
                        }
                        DIRCard("FUNZIONI FUTURE", icon: "lock", accent: DIRTheme.yellow) {
                            disabledFeatureRow("Explore", "Coming soon: mappe e route non sono release-ready in main.")
                            disabledFeatureRow("Analysis", "Coming soon: analytics avanzate restano disabilitate in main.")
                            disabledFeatureRow("Equipment", "Coming soon: profili attrezzatura richiedono persistenza dedicata.")
                        }
                        DIRWarningBox(text: "DIR DIVING e un supporto informativo per logbook, analisi e pianificazione preliminare.")
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

    private func disabledFeatureRow(_ title: String, _ message: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text("COMING SOON")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(DIRTheme.yellow)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().stroke(DIRTheme.yellow.opacity(0.72), lineWidth: 1))
            }
            Text(message)
                .font(.caption)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 7)
    }
}
