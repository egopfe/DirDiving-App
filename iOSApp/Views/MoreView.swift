import SwiftUI

struct MoreView: View {
    @EnvironmentObject private var watchSync: WatchSyncService
    @EnvironmentObject private var cloudSync: CloudSyncStore
    @EnvironmentObject private var logStore: DiveLogStore
    @AppStorage("dirdiving_ios_metric_units") private var metricUnits = true
    @AppStorage("dirdiving_ios_export_csv_enabled") private var csvExportEnabled = true
    @AppStorage("dirdiving_ios_watch_sync_diagnostics") private var watchSyncDiagnostics = true
    @AppStorage("dirdiving_ios_safety_mock_gates") private var safetyMockGates = true

    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 7) {
                            Text("Altro")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Watch sync, cloud backup, reviewer tools and export presentation")
                                .font(.callout)
                                .foregroundStyle(DIRTheme.muted)
                        }
                        DIRCard("SYNC WATCH", icon: "applewatch", accent: DIRTheme.cyan) {
                            row("Supportato", watchSync.isSupported ? "Si" : "No")
                            row("Stato", String(describing: watchSync.activationState))
                            row("Ultimo evento", watchSync.lastMessage)
                            row("Experimental RX", "\(watchSync.experimentalImportCount)")
                            Text(watchSync.experimentalImportStatus)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(DIRTheme.yellow)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        DIRCard("BACKUP CLOUD", icon: "icloud", accent: DIRTheme.green) {
                            row("iCloud Sync", cloudSync.isICloudAvailable ? "Attivo" : "Non disponibile")
                            row("Backup automatico", "Log e planner")
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
                        DIRCard("SETTINGS", icon: "gearshape", accent: DIRTheme.cyan) {
                            Toggle("Unità metriche (m, °C, bar)", isOn: $metricUnits)
                                .tint(DIRTheme.cyan)
                            Toggle("Export CSV abilitato", isOn: $csvExportEnabled)
                                .tint(DIRTheme.cyan)
                            Toggle("Diagnostica Watch Sync", isOn: $watchSyncDiagnostics)
                                .tint(DIRTheme.cyan)
                            Toggle("Gate safety per mock/lab", isOn: $safetyMockGates)
                                .tint(DIRTheme.yellow)
                            Text("Notifiche, permessi media e sync route/settings reale restano LAB finché i servizi non sono produzione-ready.")
                                .font(.caption)
                                .foregroundStyle(DIRTheme.yellow)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        DIRCard("EXPORT", icon: "square.and.arrow.up", accent: DIRTheme.cyan) {
                            row("Subsurface", csvExportEnabled ? "CSV" : "Disabilitato")
                            row("Bundle", "com.egopfe.dirdiving.ios")
                        }
                        DIRWarningBox(text: "DIR DIVING e un supporto informativo per logbook, analisi e pianificazione preliminare.")
                    }
                    .padding(16)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
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
}
