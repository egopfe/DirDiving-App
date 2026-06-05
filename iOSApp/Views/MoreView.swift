import SwiftUI
import UIKit
import UserNotifications
import WatchConnectivity

struct MoreView: View {
    @EnvironmentObject private var watchSync: WatchSyncService
    @EnvironmentObject private var cloudSync: CloudSyncStore
    @EnvironmentObject private var logStore: DiveLogStore
    @AppStorage(DIRIOSAppLanguage.storageKey) private var appLanguage = DIRIOSAppLanguage.system.rawValue
    @AppStorage("dirdiving_ios_units") private var units = IOSUnitPreference.metric.rawValue
    @AppStorage(PlannerCNSDescentBottomCheckSettings.storageKey) private var cnsDescentBottomCheckEnabled = PlannerCNSDescentBottomCheckSettings.defaultEnabled
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
                            Text(String(localized: "more.title"))
                                .dirScreenTitleStyle()
                            Text(String(localized: "more.header.subtitle"))
                                .font(.callout)
                                .foregroundStyle(DIRTheme.muted)
                        }
                        DIRCard(String(localized: "more.section.preferences"), icon: "gearshape.fill", accent: DIRTheme.cyan) {
                            languagePreferencePicker
                            unitsPreferenceSection
                            row(String(localized: "more.settings.sync_scope_title"), String(localized: "more.settings.sync_scope_value"))
                            row(String(localized: "units.title"), String(localized: "more.settings.units_synced"))
                            row(String(localized: "more.settings.local_only_title"), String(localized: "more.settings.local_only_value"))
                            row(String(localized: "more.planner_safety.title"), String(localized: "more.disclaimer.required"))
                            cnsDescentBottomCheckToggle
                            if DeveloperSettings.isDeveloperSectionVisible {
                                NavigationLink {
                                    DeveloperSettingsView()
                                } label: {
                                    HStack {
                                        Label(String(localized: "developer.section.title"), systemImage: "hammer.fill")
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
                                    Label(String(localized: "more.legal_safety"), systemImage: "checkmark.shield")
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
                        DIRCard(String(localized: "more.section.sync_watch"), icon: "applewatch", accent: DIRTheme.cyan) {
                            row(String(localized: "more.sync.supported"), watchSync.isSupported ? String(localized: "more.yes") : String(localized: "more.no"))
                            row(String(localized: "more.sync.state"), watchSync.userVisibleState)
                            row(String(localized: "more.sync.last_event"), watchSync.lastMessage)
                            row(String(localized: "more.sync.queue_count"), "\(watchSync.pendingWatchQueueCount)")
                            row(String(localized: "more.sync.last_success"), formattedWatchLastSuccess)
                            syncActivitySection
                            WatchPhotoTransferPanel()
                            Button {
                                watchSync.syncUnpushedSessionsToWatch()
                            } label: {
                                Label(String(localized: "more.sync.push_to_watch"), systemImage: "applewatch.and.arrow.forward")
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
                            watchSyncConflictsCard
                        }
                        if !logStore.sessionMergeConflicts.isEmpty {
                            cloudMergeConflictsCard
                        }
                        DIRCard(String(localized: "more.section.cloud_backup"), icon: "icloud", accent: DIRTheme.green) {
                            Toggle(isOn: $cloudBackupEnabled) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String(localized: "more.icloud.backup_toggle"))
                                        .foregroundStyle(.white)
                                    Text(String(localized: "more.icloud.backup_privacy"))
                                        .font(.caption2)
                                        .foregroundStyle(DIRTheme.muted)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .tint(DIRTheme.cyan)
                            .onChange(of: cloudBackupEnabled) { _, enabled in
                                CloudBackupSettings.setEnabled(enabled)
                                if enabled {
                                    logStore.synchronizeCloud()
                                }
                            }
                            row(String(localized: "more.icloud.sync_title"), cloudBackupStatusTitle)
                            row(String(localized: "more.icloud.backup_scope"), String(localized: "more.icloud.backup_scope_value"))
                            row(String(localized: "more.icloud.last_event"), cloudSync.lastSyncStatus)
                            row(String(localized: "more.icloud.last_success"), formattedCloudLastSuccess)
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
                                    Label(String(localized: "more.icloud.sync_now"), systemImage: "icloud.and.arrow.up")
                                        .font(.callout.weight(.semibold))
                                        .foregroundStyle(DIRTheme.cyan)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                            .disabled(cloudSync.isSynchronizing)
                            .accessibilityLabel("Sincronizza cloud ora")
                            .accessibilityHint("Forza salvataggio log locale e sincronizzazione iCloud KVS.")
                        }
                        DIRCard(String(localized: "more.section.reviewer"), icon: "books.vertical", accent: DIRTheme.yellow) {
                            Toggle(isOn: Binding(
                                get: { logStore.includeDemoLogbook },
                                set: { logStore.includeDemoLogbook = $0 }
                            )) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String(localized: "more.reviewer.demo_logbook"))
                                        .foregroundStyle(.white)
                                    Text(String(localized: "more.reviewer.demo_logbook_hint"))
                                        .font(.caption2)
                                        .foregroundStyle(DIRTheme.muted)
                                }
                            }
                            .tint(DIRTheme.cyan)
                        }
                        DIRCard(String(localized: "more.section.export"), icon: "square.and.arrow.up", accent: DIRTheme.cyan) {
                            row(String(localized: "Subsurface"), "CSV")
                            row(String(localized: "Bundle"), "com.egopfe.dirdiving.ios")
                            CSVImportPanel()
                        }
                        appVersionRow
                        DIRWarningBox(
                            text: String(localized: "more.safety.footer")
                        )
                    }
                    .padding(16)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .alert(String(localized: "developer.section.title"), isPresented: $developerUnlockedNotice) {
                Button(String(localized: "OK"), role: .cancel) {}
            } message: {
                Text(String(localized: "developer.unlock.confirmed"))
            }
            .alert(String(localized: "more.sync.reset_pairing"), isPresented: $showResetPairingConfirm) {
                Button(String(localized: "Cancel"), role: .cancel) {}
                Button(String(localized: "more.sync.reset_pairing_confirm"), role: .destructive) {
                    watchSync.resetPairingTrust(logStore: logStore)
                }
            } message: {
                Text(String(localized: "more.sync.reset_pairing_message"))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var formattedWatchLastSuccess: String {
        guard let date = watchSync.lastSuccessfulSyncDate else {
            return String(localized: "more.sync.last_success.none")
        }
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    private var cloudBackupStatusTitle: String {
        if !cloudSync.isICloudAvailable {
            return String(localized: "more.icloud.unavailable")
        }
        if cloudBackupEnabled {
            return String(localized: "more.icloud.backup_on")
        }
        return String(localized: "more.icloud.backup_off")
    }

    private var formattedCloudLastSuccess: String {
        guard let date = cloudSync.lastSuccessfulSyncDate else {
            return String(localized: "more.sync.last_success.none")
        }
        return date.formatted(date: .abbreviated, time: .shortened)
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

    private var cnsDescentBottomCheckToggle: some View {
        Toggle(isOn: $cnsDescentBottomCheckEnabled) {
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "more.settings.cns_descent_bottom_check"))
                    .foregroundStyle(.white)
                Text(String(localized: "planner.settings.cns_descent_bottom_15_check.description"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .tint(DIRTheme.cyan)
        .padding(.vertical, 4)
        .accessibilityHint(Text(String(localized: "more.settings.cns_descent_bottom_check.a11y")))
    }

    private var languagePreferencePicker: some View {
        let selectedLanguage = DIRIOSAppLanguage.fromStorage(appLanguage)

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(String(localized: "more.language.title"))
                    .foregroundStyle(DIRTheme.muted)
                Spacer()
                Text(selectedLanguage.title)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
            }
            .font(.callout)
            Picker(String(localized: "more.language.title"), selection: $appLanguage) {
                ForEach(DIRIOSAppLanguage.allCases) { language in
                    Text(language.title).tag(language.rawValue)
                }
            }
            .pickerStyle(.segmented)
            Text(selectedLanguage.companionDetail)
                .font(.caption2)
                .foregroundStyle(DIRTheme.yellow)
            Text(String(localized: "more.language.units_disclaimer"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 5)
    }

    private var watchSyncConflictsCard: some View {
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

    private var cloudMergeConflictsCard: some View {
        let grouped = Dictionary(grouping: logStore.sessionMergeConflicts, by: \.sessionID)
        let sessionIDs = grouped.keys.sorted { $0.uuidString < $1.uuidString }

        return DIRCard(String(localized: "cloud.merge.conflicts_title"), icon: "arrow.triangle.merge", accent: DIRTheme.orange) {
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
                            Text(String(localized: "cloud.merge.use_icloud"))
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
                            Text(String(localized: "cloud.merge.keep_local"))
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
                Text(String(localized: "sync.activity.section_title"))
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
        return DIRCard(String(localized: "more.section.about"), icon: "info.circle", accent: DIRTheme.muted) {
            row(String(localized: "Versione"), version)
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
