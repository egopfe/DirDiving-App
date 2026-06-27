import SwiftUI

/// Diving-owned settings scroll content for unified Settings and the More tab.
struct IOSDivingSettingsEmbeddedContent: View {
    @EnvironmentObject private var watchSync: WatchSyncService
    @EnvironmentObject private var cloudSync: CloudSyncStore
    @EnvironmentObject private var logStore: DiveLogStore
    @EnvironmentObject private var sharedSettings: SharedIOSSettingsStore
    @State private var showResetPairingConfirm = false
    @State private var versionTapCount = 0
    @State private var developerUnlockedNotice = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
                        DIRCard(DIRIOSLocalizer.string("more.section.preferences"), icon: "gearshape.fill", accent: DIRTheme.cyan) {
                            languagePreferencePicker
                            unitsPreferenceSection
                            row(DIRIOSLocalizer.string("more.settings.sync_scope_title"), DIRIOSLocalizer.string("more.settings.sync_scope_value"))
                            row(DIRIOSLocalizer.string("more.planner_safety.title"), DIRIOSLocalizer.string("more.disclaimer.required"))
                            cnsDescentBottomSettingsSummary
                            NavigationLink {
                                PlannerAscentSpeedSettingsView()
                            } label: {
                                HStack {
                                    Label(
                                        DIRIOSLocalizer.string("settings.planner_ascent_speeds.title"),
                                        systemImage: "arrow.up.circle"
                                    )
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
                        }

                        DIRCard(DIRIOSLocalizer.string("more.section.sync_watch"), icon: "applewatch", accent: DIRTheme.cyan) {
                            accessibleInfoRow(
                                title: DIRIOSLocalizer.string("more.sync.supported"),
                                value: watchSync.isSupported ? DIRIOSLocalizer.string("more.yes") : DIRIOSLocalizer.string("more.no"),
                                identifier: "more.sync.supported"
                            )
                            accessibleInfoRow(
                                title: DIRIOSLocalizer.string("more.sync.state"),
                                value: watchSync.userVisibleState,
                                identifier: "more.sync.state"
                            )
                            accessibleInfoRow(
                                title: DIRIOSLocalizer.string("more.sync.last_event"),
                                value: watchSync.lastMessage,
                                identifier: "more.sync.last_event"
                            )
                            accessibleInfoRow(
                                title: DIRIOSLocalizer.string("more.sync.queue_count"),
                                value: "\(watchSync.pendingWatchQueueCount)",
                                identifier: "more.sync.queue_count",
                                hint: watchSync.pendingWatchQueueCount > 0
                                    ? DIRIOSLocalizer.string("more.sync.queue_count.a11y.hint")
                                    : nil
                            )
                            accessibleInfoRow(
                                title: DIRIOSLocalizer.string("more.sync.last_success"),
                                value: formattedWatchLastSuccess,
                                identifier: "more.sync.last_success"
                            )
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
                            .accessibilityLabel(DIRIOSLocalizer.string("more.sync.push_to_watch"))
                            .accessibilityHint(DIRIOSLocalizer.string("more.sync.push_to_watch.a11y.hint"))
                            .accessibilityIdentifier("more.sync.push_to_watch")
                            .disabled(!watchSync.isSupported)
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
                            .accessibilityLabel(DIRIOSLocalizer.string("more.sync.reset_pairing"))
                            .accessibilityHint(DIRIOSLocalizer.string("more.sync.reset_pairing.a11y.hint"))
                            .accessibilityIdentifier("more.sync.reset_pairing")
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel(DIRIOSLocalizer.string("more.section.sync_watch"))
                        if !watchSync.conflicts.isEmpty {
                            watchSyncConflictsCard
                        }
                        if !logStore.sessionMergeConflicts.isEmpty {
                            cloudMergeConflictsCard
                        }
                        DIRCard(DIRIOSLocalizer.string("more.section.cloud_backup"), icon: "icloud", accent: DIRTheme.green) {
                            Toggle(isOn: $sharedSettings.cloudBackupEnabled) {
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
                            .onChange(of: sharedSettings.cloudBackupEnabled) { _, enabled in
                                if enabled {
                                    Task { @MainActor in
                                        logStore.synchronizeCloud()
                                    }
                                }
                            }
                            row(DIRIOSLocalizer.string("more.icloud.sync_title"), cloudBackupStatusTitle)
                            row(DIRIOSLocalizer.string("more.icloud.backup_scope"), DIRIOSLocalizer.string("more.icloud.backup_scope_value"))
                            accessibleInfoRow(
                                title: DIRIOSLocalizer.string("more.icloud.last_event"),
                                value: cloudSync.lastSyncStatus,
                                identifier: "more.icloud.last_event"
                            )
                            accessibleInfoRow(
                                title: DIRIOSLocalizer.string("more.icloud.last_success"),
                                value: formattedCloudLastSuccess,
                                identifier: "more.icloud.last_success"
                            )
                            if let cloudDecodeError = cloudSync.lastDecodeError {
                                Text(cloudDecodeError)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(DIRTheme.orange)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .accessibilityLabel(
                                        DIRIOSLocalizer.formatted("more.icloud.decode_error.a11y", cloudDecodeError)
                                    )
                                    .accessibilityIdentifier("more.icloud.decode_error")
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
                            .accessibilityLabel(DIRIOSLocalizer.string("more.icloud.sync_now"))
                            .accessibilityHint(DIRIOSLocalizer.string("more.icloud.sync_now.a11y.hint"))
                            .accessibilityIdentifier("more.icloud.sync_now")
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
                            row(DIRIOSLocalizer.string("more.export.subsurface"), "CSV")
                            row(DIRIOSLocalizer.string("more.export.bundle_id"), "com.egopfe.dirdiving.ios")
                            CSVImportPanel()
                        }
                        appVersionRow
        }
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
        if sharedSettings.cloudBackupEnabled {
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
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(DIRIOSLocalizer.string("settings.units.depth.title"))
                        .foregroundStyle(DIRTheme.muted)
                    Spacer()
                    Text(sharedSettings.units.shortLabel)
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                }
                .font(.callout)
                Picker(DIRIOSLocalizer.string("settings.units.depth.title"), selection: $sharedSettings.units) {
                    ForEach(IOSUnitPreference.allCases) { option in
                        Text(option.shortLabel).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(DIRIOSLocalizer.string("settings.units.pressure.title"))
                        .foregroundStyle(DIRTheme.muted)
                    Spacer()
                    Text(sharedSettings.pressureUnit == .bar
                        ? DIRIOSLocalizer.string("settings.units.pressure.bar")
                        : DIRIOSLocalizer.string("settings.units.pressure.psi"))
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                }
                .font(.callout)
                Picker(DIRIOSLocalizer.string("settings.units.pressure.title"), selection: $sharedSettings.pressureUnit) {
                    ForEach(PressureUnit.allCases) { unit in
                        Text(unit == .bar
                             ? DIRIOSLocalizer.string("settings.units.pressure.bar")
                             : DIRIOSLocalizer.string("settings.units.pressure.psi")
                        ).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
            }

            Text(DIRIOSLocalizer.string("settings.units.sync_note"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 5)
        .onChange(of: sharedSettings.units) { _, newValue in
            watchSync.pushUnitsPreference(newValue.rawValue)
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(DIRIOSLocalizer.string("more.language.title"))
                    .foregroundStyle(DIRTheme.muted)
                Spacer()
                Text(sharedSettings.language.localizedTitle)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
            }
            .font(.callout)
            Picker(DIRIOSLocalizer.string("more.language.title"), selection: $sharedSettings.language) {
                ForEach(DIRIOSAppLanguage.allCases) { language in
                    Text(language.localizedTitle).tag(language)
                }
            }
            .pickerStyle(.segmented)
            Text(sharedSettings.language.localizedDetail)
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
                        .accessibilityLabel(DIRIOSLocalizer.string("more.sync.use_watch"))
                        .accessibilityHint(DIRIOSLocalizer.string("more.sync.use_watch.a11y.hint"))
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
                        .accessibilityLabel(DIRIOSLocalizer.string("more.sync.keep_local"))
                        .accessibilityHint(DIRIOSLocalizer.string("more.sync.keep_local.a11y.hint"))
                    }
                }
                .padding(.vertical, 4)
                .accessibilityElement(children: .contain)
                .accessibilityLabel(conflict.localSummary)
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
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(activity.title). \(activity.detail)")
                    .accessibilityIdentifier("more.sync.activity.\(activity.id.uuidString)")
                }
            }
        }
    }

    private var appVersionRow: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "n/d"
        return DIRCard(DIRIOSLocalizer.string("more.section.about"), icon: "info.circle", accent: DIRTheme.muted) {
            row(DIRIOSLocalizer.string("settings.version.label"), version)
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

    private func accessibleInfoRow(
        title: String,
        value: String,
        identifier: String,
        hint: String? = nil
    ) -> some View {
        HStack {
            Text(title).foregroundStyle(DIRTheme.muted)
            Spacer()
            Text(value).foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
        }
        .font(.callout)
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value)
        .accessibilityHint(hint ?? "")
        .accessibilityIdentifier(identifier)
    }
}
