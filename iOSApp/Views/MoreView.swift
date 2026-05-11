import SwiftUI

struct MoreView: View {
    @EnvironmentObject private var watchSync: WatchSyncService

    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Altro")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        DIRCard("SYNC WATCH", icon: "applewatch") {
                            row("Supportato", watchSync.isSupported ? "Si" : "No")
                            row("Stato", String(describing: watchSync.activationState))
                            row("Ultimo evento", watchSync.lastMessage)
                        }
                        DIRCard("BACKUP CLOUD", icon: "icloud") {
                            row("iCloud Sync", "Predisposto")
                            row("Backup automatico", "Da abilitare")
                        }
                        DIRCard("EXPORT", icon: "square.and.arrow.up") {
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
