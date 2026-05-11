import SwiftUI

struct MoreView: View {
    @EnvironmentObject private var watchSync: WatchSyncService
    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        DIRSectionHeader(title: "Altro", subtitle: "Sync, backup, export e informazioni")
                        DIRCard("Sync Watch", icon: "applewatch") {
                            row("Supportato", watchSync.isSupported ? "Sì" : "No")
                            row("Stato", String(describing: watchSync.activationState))
                            row("Ultimo evento", watchSync.lastMessage)
                        }
                        DIRCard("Backup Cloud", icon: "icloud") {
                            row("iCloud Sync", "Predisposto")
                            row("Backup automatico", "Da abilitare")
                        }
                        DIRCard("Info", icon: "info.circle") {
                            row("Versione", "1.0")
                            row("Bundle", "com.egopfe.dirdiving.ios")
                        }
                        DIRWarningBox(text: "DIR DIVING è un supporto informativo per logbook, analisi e pianificazione preliminare.")
                    }.padding()
                }
            }.navigationTitle("Altro").navigationBarTitleDisplayMode(.inline)
        }
    }
    private func row(_ title: String, _ value: String) -> some View {
        HStack { Text(title).foregroundStyle(DIRTheme.muted); Spacer(); Text(value).foregroundStyle(.white) }
    }
}
