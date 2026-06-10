import SwiftUI

struct MoreView: View {
    @EnvironmentObject private var watchSync: WatchSyncService
    @EnvironmentObject private var cloudSync: CloudSyncStore
    @EnvironmentObject private var logStore: DiveLogStore
    @AppStorage(DIRIOSAppLanguage.storageKey) private var appLanguage = DIRIOSAppLanguage.system.rawValue
    @AppStorage("dirdiving_ios_units") private var units = IOSUnitPreference.metric.rawValue
    @AppStorage(CloudBackupSettings.enabledKey) private var cloudBackupEnabled = false
    @State private var showResetPairingConfirm = false
    @State private var versionTapCount = 0
    @State private var developerUnlockedNotice = false

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 7) {
                            Text(DIRIOSLocalizer.string("settings.title"))
                                .dirScreenTitleStyle()
                            Text(DIRIOSLocalizer.string("more.header.subtitle"))
                                .font(.callout)
                                .foregroundStyle(DIRTheme.muted)
                        }
                        DIRCard(DIRIOSLocalizer.string("more.section.preferences"), icon: "gearshape.fill", accent: DIRTheme.cyan) {
                            languagePreferencePicker
                            unitsPreferenceSection
                            row(DIRIOSLocalizer.string("more.settings.sync_scope_title"), DIRIOSLocalizer.string("more.settings.sync_scope_value"))
                            row(DIRIOSLocalizer.string("more.planner_safety.title"), DIRIOSLocalizer.string("more.disclaimer.required"))
                            cnsDescentBottomSettingsSummary
                            if DeveloperSettings.isDeveloperSectionVisible {
                                NavigationLink {
                                    DeveloperSettingsView()
                                } label: {
                                    HStack {
                                        Label(DIRIOSLocalizer.string("developer.section.title"), systemImage: "hammer.fill")
                                            .foregroundStyle(DIRTheme.yellow)
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
                            NavigationLink {
                                IOSLegalSafetyView()
                            } label: {
                                HStack {
                                    Label(DIRIOSLocalizer.string("more.legal_safety"), systemImage: "checkmark.shield")
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
                        DIRCard(DIRIOSLocalizer.string("more.section.sync_watch"), icon: "applewatch", accent: DIRTheme.cyan) {
                            row(DIRIOSLocalizer.string("more.sync.supported"), watchSync.isSupported ? DIRIOSLocalizer.string("more.yes") : DIRIOSLocalizer.string("more.no"))
                            row(DIRIOSLocalizer.string("more.sync.state"), watchSync.userVisibleState)
                            row(DIRIOSLocalizer.string("more.sync.last_event"), watchSync.lastMessage)
                            row(DIRIOSLocalizer.string("more.sync.queue_count"), "\(watchSync.pendingWatchQueueCount)")
                            row(DIRIOSLocalizer.string("more.sync.last_success"), formattedWatchLastSuccess)
                            syncActivitySection
                            Button {
                                watchSync.syncUnpushedSessionsToWatch()
                            } label: {
                                Label(DIRIOSLocalizer.string("more.sync.push_to_watch"), systemImage: "applewatch.and.arrow.forward")
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
                                Label(DIRIOSLocalizer.string("more.sync.reset_pairing"), systemImage: "arrow.counterclockwise")
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(DIRTheme.orange)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.orange.opacity(0.8), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                        if !watchSync.conflicts.isEmpty {
                            watchSyncConflictsCard
                        }
                        if !logStore.sessionMergeConflicts.isEmpty {
                            cloudMergeConflictsCard
                        }
                        DIRCard(DIRIOSLocalizer.string("more.section.cloud_backup"), icon: "icloud", accent: DIRTheme.green) {
                            Toggle(isOn: $cloudBackupEnabled) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(DIRIOSLocalizer.string("more.icloud.backup_toggle"))
                                        .foregroundStyle(.white)
                                    Text(DIRIOSLocalizer.string("more.icloud.backup_privacy"))
                                        .font(.caption2)
                                        .foregroundStyle(DIRTheme.muted)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .tint(DIRTheme.cyan)
                            .onChange(of: cloudBackupEnabled) { _, enabled in
                                CloudBackupSettings.setEnabled(enabled)
                                if enabled {
                                    Task { @MainActor in
                                        logStore.synchronizeCloud()
                                    }
                                }
                            }
                            row(DIRIOSLocalizer.string("more.icloud.sync_title"), cloudBackupStatusTitle)
                            row(DIRIOSLocalizer.string("more.icloud.backup_scope"), DIRIOSLocalizer.string("more.icloud.backup_scope_value"))
                            row(DIRIOSLocalizer.string("more.icloud.last_event"), cloudSync.lastSyncStatus)
                            row(DIRIOSLocalizer.string("more.icloud.last_success"), formattedCloudLastSuccess)
                            if let cloudDecodeError = cloudSync.lastDecodeError {
                                Text(cloudDecodeError)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(DIRTheme.orange)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .accessibilityLabel(cloudDecodeError)
                            }
                            Button {
                                cloudSync.clearDecodeError()
                                logStore.synchronizeCloud()
                                cloudSync.synchronize()
                            } label: {
                                HStack(spacing: 8) {
                                    if cloudSync.isSynchronizing {
                                        ProgressView()
                                            .tint(DIRTheme.cyan)
                                    }
                                    Label(DIRIOSLocalizer.string("more.icloud.sync_now"), systemImage: "icloud.and.arrow.up")
                                        .font(.callout.weight(.semibold))
                                        .foregroundStyle(DIRTheme.cyan)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                            .disabled(cloudSync.isSynchronizing)
                        }
                        DIRCard(DIRIOSLocalizer.string("more.section.reviewer"), icon: "books.vertical", accent: DIRTheme.yellow) {
                            Toggle(isOn: Binding(
                                get: { logStore.includeDemoLogbook },
                                set: { logStore.includeDemoLogbook = $0 }
                            )) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(DIRIOSLocalizer.string("more.reviewer.demo_logbook"))
                                        .foregroundStyle(.white)
                                    Text(DIRIOSLocalizer.string("more.reviewer.demo_logbook_hint"))
                                        .font(.caption2)
                                        .foregroundStyle(DIRTheme.muted)
                                }
                            }
                            .tint(DIRTheme.cyan)
                        }
                        DIRCard(DIRIOSLocalizer.string("more.section.export"), icon: "square.and.arrow.up", accent: DIRTheme.cyan) {
                            row(DIRIOSLocalizer.string("Subsurface"), "CSV")
                            row(DIRIOSLocalizer.string("Bundle"), "com.egopfe.dirdiving.ios")
                            CSVImportPanel()
                        }
                        appVersionRow
                        DIRWarningBox(
                            text: DIRIOSLocalizer.string("more.safety.footer")
                        )
                    }
                    .padding(16)
                }
                .dirCompanionScrollSurface()
            }
            .toolbar(.hidden, for: .navigationBar)
            .alert(DIRIOSLocalizer.string("developer.section.title"), isPresented: $developerUnlockedNotice) {
                Button(DIRIOSLocalizer.string("common.ok"), role: .cancel) {}
            } message: {
                Text(DIRIOSLocalizer.string("developer.unlock.confirmed"))
            }
            .alert(DIRIOSLocalizer.string("more.sync.reset_pairing"), isPresented: $showResetPairingConfirm) {
                Button(DIRIOSLocalizer.string("common.cancel"), role: .cancel) {}
                Button(DIRIOSLocalizer.string("more.sync.reset_pairing_confirm"), role: .destructive) {
                    watchSync.resetPairingTrust(logStore: logStore)
                }
            } message: {
                Text(DIRIOSLocalizer.string("more.sync.reset_pairing_message"))
            }
        }
        .dirCompanionTabRoot()
    }

    private var formattedWatchLastSuccess: String {
        guard let date = watchSync.lastSuccessfulSyncDate else {
            return DIRIOSLocalizer.string("more.sync.last_success.none")
        }
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    private var cloudBackupStatusTitle: String {
        if !cloudSync.isICloudAvailable {
            return DIRIOSLocalizer.string("more.icloud.unavailable")
        }
        if cloudBackupEnabled {
            return DIRIOSLocalizer.string("more.icloud.backup_on")
        }
        return DIRIOSLocalizer.string("more.icloud.backup_off")
    }

    private var formattedCloudLastSuccess: String {
        guard let date = cloudSync.lastSuccessfulSyncDate else {
            return DIRIOSLocalizer.string("more.sync.last_success.none")
        }
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    private var unitsPreferenceSection: some View {
        let preference = IOSUnitPreference.fromStorage(units)

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(DIRIOSLocalizer.string("units.title"))
                    .foregroundStyle(DIRTheme.muted)
                Spacer()
                Text(preference.shortLabel)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
            }
            .font(.callout)
            Picker(DIRIOSLocalizer.string("units.title"), selection: $units) {
                ForEach(IOSUnitPreference.allCases) { option in
                    Text(option.shortLabel).tag(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
            Text(DIRIOSLocalizer.string("settings.units.sync_note"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 5)
        .onChange(of: units) { _, newValue in
            watchSync.pushUnitsPreference(newValue)
        }
    }

    private var cnsDescentBottomSettingsSummary: some View {
        row(
            DIRIOSLocalizer.string("more.settings.cns_descent_bottom_summary_title"),
            PlannerCNSDescentBottomCheckSettings.isEnabled
                ? String(
                    format: DIRIOSLocalizer.string("more.settings.cns_descent_bottom_summary_on"),
                    Formatters.zero(Double(PlannerCNSDescentBottomCheckSettings.thresholdPercent))
                )
                : DIRIOSLocalizer.string("more.settings.cns_descent_bottom_summary_off")
        )
    }

    private var languagePreferencePicker: some View {
        let selectedLanguage = DIRIOSAppLanguage.fromStorage(appLanguage)

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(DIRIOSLocalizer.string("more.language.title"))
                    .foregroundStyle(DIRTheme.muted)
                Spacer()
                Text(selectedLanguage.localizedTitle)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
            }
            .font(.callout)
            Picker(DIRIOSLocalizer.string("more.language.title"), selection: $appLanguage) {
                ForEach(DIRIOSAppLanguage.allCases) { language in
                    Text(language.localizedTitle).tag(language.rawValue)
                }
            }
            .pickerStyle(.segmented)
            Text(selectedLanguage.localizedDetail)
                .font(.caption2)
                .foregroundStyle(DIRTheme.yellow)
            Text(DIRIOSLocalizer.string("more.language.units_disclaimer"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 5)
    }

    private var watchSyncConflictsCard: some View {
        DIRCard(DIRIOSLocalizer.string("more.sync.conflicts_title"), icon: "arrow.triangle.merge", accent: DIRTheme.orange) {
            ForEach(watchSync.conflicts) { conflict in
                VStack(alignment: .leading, spacing: 8) {
                    Text(conflict.localSummary)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(DIRIOSLocalizer.formatted("more.sync.conflict_incoming", Formatters.one(conflict.incoming.maxDepthMeters), Formatters.time(conflict.incoming.durationSeconds)))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                    HStack(spacing: 8) {
                        Button {
                            watchSync.resolveConflictUsingIncoming(conflict)
                        } label: {
                            Text(DIRIOSLocalizer.string("more.sync.use_watch"))
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
                            Text(DIRIOSLocalizer.string("more.sync.keep_local"))
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

    private var cloudMergeConflictsCard: some View {
        let grouped = Dictionary(grouping: logStore.sessionMergeConflicts, by: \.sessionID)
        let sessionIDs = grouped.keys.sorted { $0.uuidString < $1.uuidString }

        return DIRCard(DIRIOSLocalizer.string("cloud.merge.conflicts_title"), icon: "arrow.triangle.merge", accent: DIRTheme.orange) {
            ForEach(sessionIDs, id: \.self) { sessionID in
                let conflicts = grouped[sessionID] ?? []
                VStack(alignment: .leading, spacing: 8) {
                    if let siteName = logStore.session(id: sessionID)?.siteName, !siteName.isEmpty {
                        Text(siteName)
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    ForEach(conflicts) { conflict in
                        Text(conflict.userMessage)
                            .font(.caption)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    HStack(spacing: 8) {
                        Button {
                            logStore.resolveSessionMergeConflictUsingCloud(sessionID: sessionID)
                        } label: {
                            Text(DIRIOSLocalizer.string("cloud.merge.use_icloud"))
                                .font(.caption.weight(.bold))
                                .foregroundStyle(DIRTheme.cyan)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(RoundedRectangle(cornerRadius: 6).stroke(DIRTheme.cyan, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        Button {
                            logStore.resolveSessionMergeConflictKeepingLocal(sessionID: sessionID)
                        } label: {
                            Text(DIRIOSLocalizer.string("cloud.merge.keep_local"))
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
                if sessionID != sessionIDs.last {
                    Divider().overlay(DIRTheme.hairline)
                }
            }
        }
    }

    @ViewBuilder
    private var syncActivitySection: some View {
        if !watchSync.recentActivity.isEmpty {
            Divider().overlay(DIRTheme.hairline)
            VStack(alignment: .leading, spacing: 8) {
                Text(DIRIOSLocalizer.string("sync.activity.section_title"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.muted)
                ForEach(Array(watchSync.recentActivity.prefix(4))) { activity in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(activity.title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(activity.detail)
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private var appVersionRow: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "n/d"
        return DIRCard(DIRIOSLocalizer.string("more.section.about"), icon: "info.circle", accent: DIRTheme.muted) {
            row(DIRIOSLocalizer.string("Versione"), version)
                .developerVersionUnlock(tapCount: $versionTapCount) {
                    developerUnlockedNotice = true
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
