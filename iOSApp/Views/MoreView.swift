import SwiftUI

struct MoreView: View {
    @EnvironmentObject private var watchSync: WatchSyncService
    @EnvironmentObject private var cloudSync: CloudSyncStore
    @EnvironmentObject private var logStore: DiveLogStore
    @AppStorage(DIRIOSAppLanguage.storageKey) private var appLanguage = DIRIOSAppLanguage.system.rawValue

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
                        DIRCard("PREFERENZE APP", icon: "gearshape.fill", accent: DIRTheme.cyan) {
                            languagePreferencePicker
                            row("Sync impostazioni", "Locale-only")
                            row("Planner safety", "Disclaimer richiesto")
                            NavigationLink {
                                IOSLegalSafetyView()
                            } label: {
                                HStack {
                                    Label("Legal & Safety", systemImage: "checkmark.shield")
                                        .foregroundStyle(DIRTheme.cyan)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(DIRTheme.muted)
                                }
                                .font(.callout.weight(.semibold))
                                .padding(.vertical, 6)
                            }
                            .buttonStyle(.plain)
                        }
                        DIRCard("SYNC WATCH", icon: "applewatch", accent: DIRTheme.cyan) {
                            row(String(localized: "more.sync.supported"), watchSync.isSupported ? String(localized: "more.yes") : String(localized: "more.no"))
                            row(String(localized: "more.sync.state"), watchSync.userVisibleState)
                            row(String(localized: "more.sync.last_event"), watchSync.lastMessage)
                            Button {
                                watchSync.syncUnpushedSessionsToWatch()
                            } label: {
                                Label(String(localized: "more.sync.push_to_watch"), systemImage: "arrow.up.applewatch")
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(DIRTheme.cyan)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                        if !watchSync.conflicts.isEmpty {
                            syncConflictsCard
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
                        DIRWarningBox(
                            text: String(localized: "DIR DIVING e uno strumento di supporto per logbook, analisi e pianificazione preliminare. Non sostituisce formazione, procedure del dive center, equipaggiamento certificato o il giudizio umano. L'app non e un computer subacqueo certificato salvo esplicita omologazione futura. Output del planner indicativi: verificarli con strumenti certificati. GPS utile in superficie; sott'acqua e in copertura e inaffidabile o assente.")
                        )
                    }
                    .padding(16)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
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
            Text("Changing language does not change units, calculations or saved data.")
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 5)
    }

    private var syncConflictsCard: some View {
        DIRCard(String(localized: "more.sync.conflicts_title"), icon: "arrow.triangle.merge", accent: DIRTheme.orange) {
            ForEach(watchSync.conflicts) { conflict in
                VStack(alignment: .leading, spacing: 8) {
                    Text(conflict.localSummary)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(String(format: String(localized: "more.sync.conflict_incoming"), Formatters.one(conflict.incoming.maxDepthMeters), Formatters.time(conflict.incoming.durationSeconds)))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                    HStack(spacing: 8) {
                        Button {
                            watchSync.resolveConflictUsingIncoming(conflict)
                        } label: {
                            Text(String(localized: "more.sync.use_watch"))
                                .font(.caption.weight(.bold))
                                .foregroundStyle(DIRTheme.cyan)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(RoundedRectangle(cornerRadius: 6).stroke(DIRTheme.cyan, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        Button {
                            watchSync.resolveConflictKeepingLocal(conflict)
                        } label: {
                            Text(String(localized: "more.sync.keep_local"))
                                .font(.caption.weight(.bold))
                                .foregroundStyle(DIRTheme.yellow)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(RoundedRectangle(cornerRadius: 6).stroke(DIRTheme.yellow, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
                if conflict.id != watchSync.conflicts.last?.id {
                    Divider().overlay(DIRTheme.hairline)
                }
            }
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(DIRTheme.muted)
            Spacer()
            Text(value).foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
        }
        .font(.callout)
        .padding(.vertical, 4)
    }
}
