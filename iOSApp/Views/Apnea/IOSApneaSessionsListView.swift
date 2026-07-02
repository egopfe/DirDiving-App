import SwiftUI

struct IOSApneaSessionsListView: View {
    @EnvironmentObject private var logbook: IOSApneaLogbookStore
    @EnvironmentObject private var demoLogbookSettings: IOSActivityDemoLogbookSettingsStore
    @EnvironmentObject private var coordinator: IOSCompanionStoreCoordinator
    @EnvironmentObject private var logbookVisibility: IOSActivityLogbookVisibilitySettingsStore
    @AppStorage(IOSUnitPreference.storageKey) private var unitsRaw = IOSUnitPreference.metric.rawValue

    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(unitsRaw) }

    private var showsUnifiedLogbook: Bool {
        logbookVisibility.showAllActivitiesInApneaLogbook
    }

    private var realEntries: [IOSApneaLogbookDisplayEntry] {
        IOSLogbookDisplayComposer.apneaEntries(realSessions: logbook.sessions, demoSessions: [])
    }

    private var demoEntries: [IOSApneaLogbookDisplayEntry] {
        guard demoLogbookSettings.isApneaFakeLogbookEnabled else { return [] }
        return IOSLogbookDisplayComposer.apneaEntries(
            realSessions: [],
            demoSessions: FakeApneaLogbookProvider.entries()
        )
    }

    private var hasRealLogs: Bool { !logbook.sessions.isEmpty }
    private var hasDemoLogs: Bool { !demoEntries.isEmpty }
    private var isEmpty: Bool { !hasRealLogs && !hasDemoLogs }
    @State private var unifiedLogbookSelection: IOSUnifiedLogbookSelection?

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                if showsUnifiedLogbook {
                    ScrollView(showsIndicators: false) {
                        IOSUnifiedLogbookListView(
                            hostActivity: .apnea,
                            selection: $unifiedLogbookSelection
                        )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }
                    .dirCompanionScrollSurface()
                } else if isEmpty {
                    emptyState
                } else {
                    List {
                        if hasDemoLogs && !hasRealLogs {
                            demoOnlyBanner
                                .listRowBackground(Color.clear)
                        }
                        if hasRealLogs {
                            if hasDemoLogs {
                                Section(DIRIOSLocalizer.string("settings.demo_logbook.real_logs")) {
                                    ForEach(realEntries) { entry in
                                        sessionLink(entry)
                                    }
                                }
                                .listRowBackground(Color.clear)
                            } else {
                                ForEach(realEntries) { entry in
                                    sessionLink(entry)
                                }
                                .listRowBackground(Color.clear)
                            }
                        }
                        if hasDemoLogs {
                            Section(DIRIOSLocalizer.string("settings.demo_logbook.demo_logs")) {
                                ForEach(demoEntries) { entry in
                                    sessionLink(entry)
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle(DIRIOSLocalizer.string("apnea.ios.sessions.title"))
            .iosUnifiedLogbookNavigationDestination(selection: $unifiedLogbookSelection)
        }
    }

    private var demoOnlyBanner: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(DIRIOSLocalizer.string("settings.demo_logbook.viewing_demo_banner"))
                .font(.callout.weight(.semibold))
                .foregroundStyle(DIRTheme.orange)
            Text(DIRIOSLocalizer.string("settings.demo_logbook.not_saved_real"))
                .font(.caption)
                .foregroundStyle(DIRTheme.muted)
        }
        .padding(.vertical, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "doc.text")
                .font(.largeTitle)
                .foregroundStyle(DIRTheme.muted)
            Text(DIRIOSLocalizer.string("apnea.ios.sessions.empty"))
                .font(.callout)
                .foregroundStyle(DIRTheme.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Spacer()
        }
    }

    @ViewBuilder
    private func sessionLink(_ entry: IOSApneaLogbookDisplayEntry) -> some View {
        NavigationLink {
            IOSApneaSessionDetailView(session: entry.session, isDemoSession: entry.isDemo)
        } label: {
            sessionRow(for: entry)
        }
    }

    private func sessionRow(for entry: IOSApneaLogbookDisplayEntry) -> some View {
        let row = IOSApneaLogbookPresentationMapper.sessionRow(entry.session, units: unitPreference)
        return HStack(spacing: 12) {
            if entry.isDemo {
                DemoLogbookBadge()
            }
            if row.showsQualityWarning {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(DIRTheme.orange)
                    .accessibilityLabel(DIRIOSLocalizer.string("apnea.ios.session.warning.data_quality"))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(row.dateText)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(row.maxDepthText)
                    .font(.subheadline)
                    .foregroundStyle(DIRTheme.cyan)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(row.diveCountText)
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.white)
                Text(row.durationText)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(DIRTheme.muted)
            }
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(DIRTheme.muted)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

struct IOSApneaStatisticsView: View {
    @EnvironmentObject private var logbook: IOSApneaLogbookStore
    @AppStorage(IOSUnitPreference.storageKey) private var unitsRaw = IOSUnitPreference.metric.rawValue
    @State private var range: ApneaStatisticsRange = .allTime
    @State private var eligibleOnly = true

    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(unitsRaw) }

    private var filteredSessions: [ApneaSession] {
        let realOnly = logbook.sessions.filter { !DemoApneaSessionCatalog.isDemoSession(id: $0.id) }
        let ranged = ApneaLogbookStatistics.filteredSessions(in: range, from: realOnly)
        guard eligibleOnly else { return ranged }
        return ranged.filter {
            ApneaRecordEligibilityPolicy.isEligibleForRecords($0, options: .default)
        }
    }

    private var stats: ApneaAggregateStatistics {
        ApneaLogbookStatistics.aggregate(from: filteredSessions, range: .allTime)
    }

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Picker("", selection: $range) {
                            Text(DIRIOSLocalizer.string("apnea.ios.stats.range.7d")).tag(ApneaStatisticsRange.last7Days)
                            Text(DIRIOSLocalizer.string("apnea.ios.stats.range.30d")).tag(ApneaStatisticsRange.last30Days)
                            Text(DIRIOSLocalizer.string("apnea.ios.stats.range.1y")).tag(ApneaStatisticsRange.lastYear)
                            Text(DIRIOSLocalizer.string("apnea.ios.stats.range.all")).tag(ApneaStatisticsRange.allTime)
                        }
                        .pickerStyle(.segmented)

                        Toggle(DIRIOSLocalizer.string("apnea.ios.stats.eligible_only"), isOn: $eligibleOnly)
                            .tint(DIRTheme.cyan)
                            .padding(.horizontal, 2)

                        NavigationLink {
                            IOSApneaPersonalRecordsView()
                        } label: {
                            HStack {
                                Text(DIRIOSLocalizer.string("apnea.ios.records.title"))
                                    .foregroundStyle(DIRTheme.cyan)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(DIRTheme.muted)
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                                    .stroke(DIRTheme.cyan.opacity(0.35), lineWidth: 1)
                            )
                        }

                        if stats.sessionCount == 0 {
                            Text(DIRIOSLocalizer.string("apnea.ios.stats.empty"))
                                .foregroundStyle(DIRTheme.muted)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 40)
                        } else {
                            DIRCard(DIRIOSLocalizer.string("apnea.ios.stats.title"), icon: "chart.bar.fill", accent: DIRTheme.cyan) {
                                statRow(DIRIOSLocalizer.string("apnea.ios.stats.avg_max_depth"), Formatters.depth(stats.averageSessionMaxDepthMeters, units: unitPreference).text)
                                statRow(DIRIOSLocalizer.string("apnea.ios.stats.avg_apnea"), Formatters.stopwatch(stats.averageDiveDurationSeconds))
                                statRow(DIRIOSLocalizer.string("apnea.ios.stats.total_underwater"), Formatters.stopwatch(stats.totalUnderwaterSeconds))
                                statRow(DIRIOSLocalizer.string("apnea.ios.stats.avg_recovery"), Formatters.stopwatch(stats.averageRecoverySeconds))
                                statRow(DIRIOSLocalizer.string("apnea.ios.stats.total_dives"), "\(stats.totalDiveCount)")
                                statRow(DIRIOSLocalizer.string("apnea.ios.stats.cumulative_depth"), Formatters.depth(stats.cumulativeDepthMeters, units: unitPreference).text)
                                statRow(DIRIOSLocalizer.string("apnea.ios.stats.best_depth"), Formatters.depth(stats.bestSessionMaxDepthMeters, units: unitPreference).text)
                                statRow(DIRIOSLocalizer.string("apnea.ios.stats.longest_apnea"), Formatters.stopwatch(stats.bestDiveDurationSeconds))
                            }
                        }
                    }
                    .padding(18)
                }
                .dirCompanionScrollSurface()
            }
            .navigationTitle(DIRIOSLocalizer.string("apnea.ios.stats.nav_title"))
        }
    }

    private func statRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(DIRTheme.muted)
            Spacer()
            Text(value)
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .font(.subheadline)
    }
}
