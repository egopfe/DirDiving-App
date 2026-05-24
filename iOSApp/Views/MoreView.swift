import SwiftUI

struct MoreView: View {
    @EnvironmentObject private var watchSync: WatchSyncService
    @EnvironmentObject private var cloudSync: CloudSyncStore
    @EnvironmentObject private var logStore: DiveLogStore
    @AppStorage(DIRIOSAppLanguage.storageKey) private var appLanguage = DIRIOSAppLanguage.system.rawValue
    @AppStorage("dirdiving_ios_units") private var units = IOSUnitPreference.metric.rawValue
    @State private var showResetPairingConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 7) {
                            Text(String(localized: "Altro"))
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(String(localized: "more.header.subtitle"))
                                .font(.callout)
                                .foregroundStyle(DIRTheme.muted)
                        }
                        DIRCard(String(localized: "PREFERENZE APP"), icon: "gearshape.fill", accent: DIRTheme.cyan) {
                            languagePreferencePicker
                            unitsPreferenceSection
                            row(String(localized: "more.settings.sync_scope_title"), String(localized: "more.settings.sync_scope_value"))
                            row(String(localized: "units.title"), String(localized: "more.settings.units_synced"))
                            row(String(localized: "more.settings.local_only_title"), String(localized: "more.settings.local_only_value"))
                            row(String(localized: "Planner safety"), String(localized: "Disclaimer richiesto"))
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
                        DIRCard(String(localized: "SYNC WATCH"), icon: "applewatch", accent: DIRTheme.cyan) {
                            row(String(localized: "more.sync.supported"), watchSync.isSupported ? String(localized: "more.yes") : String(localized: "more.no"))
                            row(String(localized: "more.sync.state"), watchSync.userVisibleState)
                            row(String(localized: "more.sync.last_event"), watchSync.lastMessage)
                            WatchPhotoTransferPanel()
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
                            Button(role: .destructive) {
                                showResetPairingConfirm = true
                            } label: {
                                Label(String(localized: "more.sync.reset_pairing"), systemImage: "arrow.counterclockwise")
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(DIRTheme.orange)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.orange.opacity(0.8), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                        if !watchSync.conflicts.isEmpty {
                            syncConflictsCard
                        }
                        DIRCard(String(localized: "BACKUP CLOUD"), icon: "icloud", accent: DIRTheme.green) {
                            row(String(localized: "iCloud Sync"), cloudSync.isICloudAvailable ? String(localized: "more.icloud.active") : String(localized: "more.icloud.unavailable"))
                            row(String(localized: "Backup automatico"), String(localized: "Log e planner"))
                            row(String(localized: "Ultimo evento"), cloudSync.lastSyncStatus)
                            Button {
                                logStore.synchronizeCloud()
                                cloudSync.synchronize()
                            } label: {
                                Label(String(localized: "Sincronizza ora"), systemImage: "icloud.and.arrow.up")
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(DIRTheme.cyan)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                        DIRCard(String(localized: "REVIEWER"), icon: "books.vertical", accent: DIRTheme.yellow) {
                            Toggle(isOn: Binding(
                                get: { logStore.includeDemoLogbook },
                                set: { logStore.includeDemoLogbook = $0 }
                            )) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String(localized: "Logbook dimostrativo"))
                                        .foregroundStyle(.white)
                                    Text(String(localized: "Carica 5 immersioni demo per revisione App Store."))
                                        .font(.caption2)
                                        .foregroundStyle(DIRTheme.muted)
                                }
                            }
                            .tint(DIRTheme.cyan)
                        }
                        DIRCard(String(localized: "EXPORT"), icon: "square.and.arrow.up", accent: DIRTheme.cyan) {
                            row(String(localized: "Subsurface"), "CSV")
                            row(String(localized: "Bundle"), "com.egopfe.dirdiving.ios")
                            CSVImportPanel()
                        }
                        DIRWarningBox(
                            text: String(localized: "DIR DIVING e uno strumento di supporto per logbook, analisi e pianificazione preliminare. Non sostituisce formazione, procedure del dive center, equipaggiamento certificato o il giudizio umano. L'app non e un computer subacqueo certificato salvo esplicita omologazione futura. Output del planner indicativi: verificarli con strumenti certificati. GPS utile in superficie; sott'acqua e in copertura e inaffidabile o assente.")
                        )
                    }
                    .padding(16)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .alert(String(localized: "more.sync.reset_pairing"), isPresented: $showResetPairingConfirm) {
                Button(String(localized: "Cancel"), role: .cancel) {}
                Button(String(localized: "more.sync.reset_pairing_confirm"), role: .destructive) {
                    watchSync.resetPairingTrust(logStore: logStore)
                }
            } message: {
                Text(String(localized: "more.sync.reset_pairing_message"))
            }
        }
    }

    private var unitsPreferenceSection: some View {
        let preference = IOSUnitPreference.fromStorage(units)

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(String(localized: "units.title"))
                    .foregroundStyle(DIRTheme.muted)
                Spacer()
                Text(preference.shortLabel)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
            }
            .font(.callout)
            Picker(String(localized: "units.title"), selection: $units) {
                ForEach(IOSUnitPreference.allCases) { option in
                    Text(option.shortLabel).tag(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
            Text(String(localized: "settings.units.sync_note"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 5)
        .onChange(of: units) { _, newValue in
            watchSync.pushUnitsPreference(newValue)
        }
    }

    private var languagePreferencePicker: some View {
        let selectedLanguage = DIRIOSAppLanguage.fromStorage(appLanguage)

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(String(localized: "Lingua"))
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
