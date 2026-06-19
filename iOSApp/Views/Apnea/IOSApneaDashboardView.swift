import SwiftUI

struct IOSApneaDashboardView: View {
    @EnvironmentObject private var logbook: IOSApneaLogbookStore
    @EnvironmentObject private var watchSync: WatchSyncService
    @EnvironmentObject private var apneaNavigation: IOSApneaNavigationStore

    private var presentation: IOSApneaDashboardPresentation {
        IOSApneaDashboardPresentationMapper.make(
            lastSession: logbook.lastSession,
            aggregate: logbook.aggregate(),
            watchConnectivityText: watchConnectivityText,
            watchConnectivityIsPositive: watchConnectivityIsPositive
        )
    }

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        if presentation.hasLastSession, let session = logbook.lastSession {
                            lastSessionCard(session: session)
                        } else if let empty = presentation.emptyStateText {
                            Text(DIRIOSLocalizer.string(empty))
                                .font(.callout)
                                .foregroundStyle(DIRTheme.muted)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                        metricsGrid
                        watchStatusCard
                        newSessionButton
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                }
                .dirCompanionScrollSurface()
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(DIRIOSLocalizer.string("apnea.ios.dashboard.title"))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            Spacer()
            Button {
                apneaNavigation.showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .foregroundStyle(DIRTheme.cyan)
            }
            .accessibilityLabel(DIRIOSLocalizer.string("apnea.ios.settings.title"))
        }
    }

    private func lastSessionCard(session: ApneaSession) -> some View {
        NavigationLink {
            IOSApneaSessionDetailView(session: session)
        } label: {
            DIRCard(DIRIOSLocalizer.string("apnea.ios.dashboard.last_session"), icon: "clock.fill", accent: DIRTheme.cyan) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(presentation.lastSessionDateText)
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(DIRTheme.muted)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(DIRIOSLocalizer.string("apnea.ios.dashboard.last_session.a11y"))
        .accessibilityHint(DIRIOSLocalizer.string("apnea.ios.dashboard.last_session.hint"))
    }

    private var metricsGrid: some View {
        VStack(spacing: 10) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                metricTile(DIRIOSLocalizer.string("apnea.ios.dashboard.max_depth"), presentation.maxDepthText)
                metricTile(DIRIOSLocalizer.string("apnea.ios.dashboard.best_time"), presentation.bestTimeText)
                metricTile(DIRIOSLocalizer.string("apnea.ios.dashboard.dives"), presentation.diveCountText)
                metricTile(DIRIOSLocalizer.string("apnea.ios.dashboard.total_time"), presentation.sessionDurationText)
            }
            DIRCard(accent: DIRTheme.cyan) {
                metricTile(DIRIOSLocalizer.string("apnea.ios.dashboard.total_recovery"), presentation.totalRecoveryText)
            }
        }
    }

    private func metricTile(_ title: String, _ value: String) -> some View {
        DIRMetricTile(title: title, value: value, color: .white)
    }

    private var watchStatusCard: some View {
        DIRCard(DIRIOSLocalizer.string("apnea.ios.dashboard.watch_status"), icon: "applewatch", accent: presentation.watchConnectivityIsPositive ? DIRTheme.green : DIRTheme.orange) {
            Text(presentation.watchConnectivityText)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(presentation.watchConnectivityIsPositive ? DIRTheme.green : DIRTheme.orange)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var newSessionButton: some View {
        Button {
            apneaNavigation.showPlanner = true
        } label: {
            Text(DIRIOSLocalizer.string("apnea.ios.dashboard.new_session"))
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                        .fill(LinearGradient(colors: [DIRTheme.cyan, DIRTheme.cyan.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                )
        }
        .buttonStyle(.plain)
        .accessibilityHint(DIRIOSLocalizer.string("apnea.ios.dashboard.new_session.hint"))
    }

    private var watchConnectivityText: String {
        if !watchSync.isSupported { return DIRIOSLocalizer.string("apnea.ios.watch.unsupported") }
        if watchSync.activationState != .activated { return DIRIOSLocalizer.string("apnea.ios.watch.not_active") }
        return watchSync.userVisibleState
    }

    private var watchConnectivityIsPositive: Bool {
        watchSync.isSupported && watchSync.activationState == .activated
    }
}
