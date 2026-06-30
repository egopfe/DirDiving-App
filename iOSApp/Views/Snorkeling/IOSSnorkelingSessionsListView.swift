import SwiftUI

struct IOSSnorkelingSessionsListView: View {
    @EnvironmentObject private var logbook: IOSSnorkelingLogbookStore
    @EnvironmentObject private var demoLogbookSettings: IOSActivityDemoLogbookSettingsStore
    @AppStorage(IOSUnitPreference.storageKey) private var unitsRaw = IOSUnitPreference.metric.rawValue

    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(unitsRaw) }

    private var realEntries: [IOSSnorkelingLogbookDisplayEntry] {
        IOSLogbookDisplayComposer.snorkelingEntries(realSessions: logbook.sessions, demoSessions: [])
    }

    private var demoEntries: [IOSSnorkelingLogbookDisplayEntry] {
        guard demoLogbookSettings.isSnorkelingFakeLogbookEnabled else { return [] }
        return IOSLogbookDisplayComposer.snorkelingEntries(
            realSessions: [],
            demoSessions: FakeSnorkelingLogbookProvider.entries()
        )
    }

    private var hasRealLogs: Bool { !logbook.sessions.isEmpty }
    private var hasDemoLogs: Bool { !demoEntries.isEmpty }
    private var isEmpty: Bool { !hasRealLogs && !hasDemoLogs }

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                if isEmpty {
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
            .navigationTitle(DIRIOSLocalizer.string("snorkeling.ios.sessions.title"))
        }
        .accessibilityIdentifier("snorkeling.ios.logbook")
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
            Text(DIRIOSLocalizer.string("snorkeling.ios.sessions.empty"))
                .font(.callout)
                .foregroundStyle(DIRTheme.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Spacer()
        }
    }

    @ViewBuilder
    private func sessionLink(_ entry: IOSSnorkelingLogbookDisplayEntry) -> some View {
        NavigationLink {
            IOSSnorkelingSessionDetailView(session: entry.session, isDemoSession: entry.isDemo)
        } label: {
            sessionRow(for: entry)
        }
    }

    private func sessionRow(for entry: IOSSnorkelingLogbookDisplayEntry) -> some View {
        let row = IOSSnorkelingLogbookPresentationMapper.sessionRow(entry.session, units: unitPreference)
        return HStack(spacing: 12) {
            if entry.isDemo {
                DemoLogbookBadge()
            }
            if row.showsQualityWarning {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(DIRTheme.orange)
                    .accessibilityLabel(DIRIOSLocalizer.string("snorkeling.ios.session.warning.data_quality"))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(row.dateText)
                    .font(.headline)
                    .foregroundStyle(.white)
                if let location = row.locationText {
                    Text(location)
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                }
                Text(row.maxDepthText)
                    .font(.subheadline)
                    .foregroundStyle(DIRTheme.cyan)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(row.dipCountText)
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.white)
                Text(row.durationText)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(DIRTheme.muted)
                Text(row.distanceText)
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(DIRTheme.muted)
            }
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(DIRTheme.muted)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(DIRIOSLocalizer.string("snorkeling.ios.sessions.title")), \(row.dateText)"
        )
    }
}

struct IOSSnorkelingStatisticsView: View {
    @EnvironmentObject private var logbook: IOSSnorkelingLogbookStore
    @AppStorage(IOSUnitPreference.storageKey) private var unitsRaw = IOSUnitPreference.metric.rawValue
    @State private var range: SnorkelingStatisticsRange = .allTime
    @State private var eligibleOnly = true

    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(unitsRaw) }

    private var stats: SnorkelingAggregateStatistics {
        let realOnly = logbook.sessions.filter { !DemoSnorkelingSessionCatalog.isDemoSession(id: $0.id) }
        let scoped = SnorkelingLogbookAnalytics.filteredSessions(in: range, from: realOnly)
        let sessions = eligibleOnly
            ? scoped.filter { SnorkelingRecordEligibilityPolicy.isEligibleForRecords($0) }
            : scoped
        return SnorkelingLogbookAnalytics.aggregate(from: sessions, range: .allTime)
    }

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Picker("", selection: $range) {
                            Text(DIRIOSLocalizer.string("snorkeling.ios.stats.range.7d")).tag(SnorkelingStatisticsRange.last7Days)
                            Text(DIRIOSLocalizer.string("snorkeling.ios.stats.range.30d")).tag(SnorkelingStatisticsRange.last30Days)
                            Text(DIRIOSLocalizer.string("snorkeling.ios.stats.range.1y")).tag(SnorkelingStatisticsRange.lastYear)
                            Text(DIRIOSLocalizer.string("snorkeling.ios.stats.range.all")).tag(SnorkelingStatisticsRange.allTime)
                        }
                        .pickerStyle(.segmented)

                        Toggle(DIRIOSLocalizer.string("snorkeling.ios.stats.eligible_only"), isOn: $eligibleOnly)
                            .tint(DIRTheme.cyan)
                            .padding(.horizontal, 2)

                        NavigationLink {
                            IOSSnorkelingPersonalRecordsView()
                        } label: {
                            HStack {
                                Text(DIRIOSLocalizer.string("snorkeling.ios.records.title"))
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
                            Text(DIRIOSLocalizer.string("snorkeling.ios.stats.empty"))
                                .foregroundStyle(DIRTheme.muted)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 40)
                        } else {
                            DIRCard(DIRIOSLocalizer.string("snorkeling.ios.stats.title"), icon: "chart.bar.fill", accent: DIRTheme.cyan) {
                                statRow(
                                    DIRIOSLocalizer.string("snorkeling.ios.stats.avg_max_depth"),
                                    Formatters.depth(stats.averageSessionMaxDepthMeters, units: unitPreference).text
                                )
                                statRow(
                                    DIRIOSLocalizer.string("snorkeling.ios.stats.avg_dip"),
                                    Formatters.stopwatch(stats.averageDipDurationSeconds)
                                )
                                statRow(
                                    DIRIOSLocalizer.string("snorkeling.ios.stats.total_water_time"),
                                    Formatters.stopwatch(stats.totalWaterTimeSeconds)
                                )
                                statRow(
                                    DIRIOSLocalizer.string("snorkeling.ios.stats.avg_speed"),
                                    Formatters.surfaceSpeed(stats.averageSurfaceSpeedMetersPerSecond, units: unitPreference).text
                                )
                                statRow(
                                    DIRIOSLocalizer.string("snorkeling.ios.stats.total_dips"),
                                    "\(stats.totalDipCount)"
                                )
                                statRow(
                                    DIRIOSLocalizer.string("snorkeling.ios.stats.best_depth"),
                                    Formatters.depth(stats.bestSessionMaxDepthMeters, units: unitPreference).text
                                )
                                statRow(
                                    DIRIOSLocalizer.string("snorkeling.ios.stats.longest_dip"),
                                    Formatters.stopwatch(stats.longestDipSeconds)
                                )
                                statRow(
                                    DIRIOSLocalizer.string("snorkeling.ios.stats.best_distance"),
                                    formatDistance(stats.bestSessionDistanceMeters)
                                )
                                statRow(
                                    DIRIOSLocalizer.string("snorkeling.ios.stats.most_dips"),
                                    "\(stats.mostDipsInSession)"
                                )
                                statRow(
                                    DIRIOSLocalizer.string("snorkeling.ios.stats.longest_session"),
                                    Formatters.stopwatch(stats.longestSessionDurationSeconds)
                                )
                                statRow(
                                    DIRIOSLocalizer.string("snorkeling.ios.stats.total_markers"),
                                    "\(stats.totalMarkerCount)"
                                )
                            }
                        }
                    }
                    .padding(18)
                }
                .dirCompanionScrollSurface()
            }
            .navigationTitle(DIRIOSLocalizer.string("snorkeling.ios.stats.nav_title"))
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

    private func formatDistance(_ meters: Double) -> String {
        Formatters.distance(meters, units: unitPreference).text
    }
}

struct IOSSnorkelingPersonalRecordsView: View {
    @EnvironmentObject private var logbook: IOSSnorkelingLogbookStore
    @AppStorage(IOSUnitPreference.storageKey) private var unitsRaw = IOSUnitPreference.metric.rawValue
    @State private var includeDegraded = false
    @State private var includeSimulated = false

    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(unitsRaw) }
    private var summary: SnorkelingPersonalRecordsSummary {
        logbook.personalRecords(
            options: SnorkelingRecordEligibilityOptions(
                includeSimulatedSessions: includeSimulated,
                includeDegradedData: includeDegraded
            )
        )
    }
    private var records: [IOSSnorkelingPersonalRecordPresentation] {
        IOSSnorkelingLogbookPresentationMapper.personalRecords(summary, units: unitPreference)
    }

    var body: some View {
        DIRScreenContainer {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    filterCard
                    if records.isEmpty {
                        Text(DIRIOSLocalizer.string("snorkeling.ios.records.empty"))
                            .foregroundStyle(DIRTheme.muted)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                    } else {
                        ForEach(records) { record in
                            DIRCard(record.title, accent: DIRTheme.green) {
                                Text(record.valueText)
                                    .font(.title2.bold())
                                    .foregroundStyle(.white)
                                Text(record.dateText)
                                    .font(.caption)
                                    .foregroundStyle(DIRTheme.muted)
                                Text(record.contextText)
                                    .font(.subheadline)
                                    .foregroundStyle(DIRTheme.cyan)
                                if let tie = record.tieText {
                                    Text(tie)
                                        .font(.caption)
                                        .foregroundStyle(DIRTheme.orange)
                                }
                            }
                        }
                    }
                }
                .padding(18)
            }
            .dirCompanionScrollSurface()
        }
        .navigationTitle(DIRIOSLocalizer.string("snorkeling.ios.records.title"))
    }

    private var filterCard: some View {
        DIRCard(DIRIOSLocalizer.string("snorkeling.ios.records.filters"), accent: DIRTheme.cyan) {
            Toggle(DIRIOSLocalizer.string("snorkeling.ios.records.include_degraded"), isOn: $includeDegraded)
                .tint(DIRTheme.cyan)
            Toggle(DIRIOSLocalizer.string("snorkeling.ios.records.include_simulated"), isOn: $includeSimulated)
                .tint(DIRTheme.cyan)
            Text(
                String(
                    format: DIRIOSLocalizer.string("snorkeling.ios.records.eligible_format"),
                    summary.eligibleSessionCount,
                    summary.excludedSessionCount
                )
            )
            .font(.caption)
            .foregroundStyle(DIRTheme.muted)
        }
    }
}
