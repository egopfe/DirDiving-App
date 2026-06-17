import SwiftUI

struct IOSApneaSessionsListView: View {
    @EnvironmentObject private var logbook: IOSApneaLogbookStore

    var body: some View {
        DIRScreenContainer {
            if logbook.sessions.isEmpty {
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
            } else {
                List(logbook.sessions) { session in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.headline)
                        HStack {
                            Text(String(format: "%.1f m", session.statistics.sessionMaxDepthMeters))
                            Spacer()
                            Text("\(session.statistics.diveCount)")
                            Spacer()
                            Text(Formatters.time(session.statistics.sessionDurationSeconds))
                        }
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(DIRTheme.muted)
                    }
                    .padding(.vertical, 4)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle(DIRIOSLocalizer.string("apnea.ios.sessions.title"))
    }
}

struct IOSApneaStatisticsView: View {
    @EnvironmentObject private var logbook: IOSApneaLogbookStore
    @State private var range: ApneaStatisticsRange = .allTime

    private var stats: ApneaAggregateStatistics {
        logbook.aggregate(range: range)
    }

    var body: some View {
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

                    if stats.sessionCount == 0 {
                        Text(DIRIOSLocalizer.string("apnea.ios.stats.empty"))
                            .foregroundStyle(DIRTheme.muted)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                    } else {
                        DIRCard(DIRIOSLocalizer.string("apnea.ios.stats.title"), icon: "chart.bar.fill", accent: DIRTheme.cyan) {
                            statRow(DIRIOSLocalizer.string("apnea.ios.stats.avg_max_depth"), String(format: "%.1f m", stats.averageSessionMaxDepthMeters))
                            statRow(DIRIOSLocalizer.string("apnea.ios.stats.avg_apnea"), Formatters.time(stats.averageDiveDurationSeconds))
                            statRow(DIRIOSLocalizer.string("apnea.ios.stats.total_underwater"), Formatters.time(stats.totalUnderwaterSeconds))
                            statRow(DIRIOSLocalizer.string("apnea.ios.stats.avg_recovery"), Formatters.time(stats.averageRecoverySeconds))
                            statRow(DIRIOSLocalizer.string("apnea.ios.stats.total_dives"), "\(stats.totalDiveCount)")
                            statRow(DIRIOSLocalizer.string("apnea.ios.stats.cumulative_depth"), String(format: "%.0f m", stats.cumulativeDepthMeters))
                            statRow(DIRIOSLocalizer.string("apnea.ios.stats.best_depth"), String(format: "%.1f m", stats.bestSessionMaxDepthMeters))
                            statRow(DIRIOSLocalizer.string("apnea.ios.stats.longest_apnea"), Formatters.time(stats.bestDiveDurationSeconds))
                        }
                    }
                }
                .padding(18)
            }
            .dirCompanionScrollSurface()
        }
        .navigationTitle(DIRIOSLocalizer.string("apnea.ios.stats.nav_title"))
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
