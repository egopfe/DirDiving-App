import SwiftUI

struct MoreView: View {
    @EnvironmentObject private var watchSync: WatchSyncService
    @EnvironmentObject private var cloudSync: CloudSyncStore
    @EnvironmentObject private var logStore: DiveLogStore

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
                        systemStatus
                        DIRCard("SYNC WATCH", icon: "applewatch", accent: DIRTheme.cyan) {
                            row("Supportato", watchSync.isSupported ? "Si" : "No")
                            row("Stato", String(describing: watchSync.activationState))
                            row("Ultimo evento", watchSync.lastMessage)
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
                        DIRCard("EXPORT", icon: "square.and.arrow.up", accent: DIRTheme.cyan) {
                            row("Subsurface", "CSV")
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

    private var systemStatus: some View {
        HStack(spacing: 12) {
            statusPill("WATCH", watchSync.isSupported ? DIRTheme.green : DIRTheme.orange)
            statusPill("CLOUD", cloudSync.isICloudAvailable ? DIRTheme.green : DIRTheme.yellow)
            statusPill("EXPORT", DIRTheme.cyan)
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
}
