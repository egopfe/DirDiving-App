import SwiftUI

struct DiveLogListView: View {
    @EnvironmentObject private var log: DiveLogStore
    @EnvironmentObject private var watchSync: WatchSyncService

    var body: some View {
        ZStack {
            DiveScreenBackground()

            ScrollView {
                VStack(spacing: 10) {
                    header
                    if let loadError = log.loadErrorMessage {
                        DivePanel(stroke: DiveUI.red) {
                            Text(loadError)
                                .font(.caption2.bold())
                                .foregroundStyle(DiveUI.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    DivePanel(stroke: DiveUI.blue) {
                        Text(watchSync.lastSyncStatus)
                            .font(.caption2.bold())
                            .foregroundStyle(DiveUI.secondaryText)
                            .multilineTextAlignment(.center)
                    }

                    if log.sessions.isEmpty {
                        emptyState
                    } else {
                        ForEach(Array(log.sessions.enumerated()), id: \.element.id) { index, session in
                            logRow(session: session, index: index)
                        }
                    }
                }
                .padding(.horizontal, DiveUI.screenPadding)
                .padding(.vertical, 8)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            DiveScreenHeader("DIVE LOG", subtitle: "SYNCED SESSIONS", accent: DiveUI.blue, systemImage: "list.bullet.rectangle")
            HStack {
                Text("SESSIONI")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.secondaryText)
                Spacer()
                DiveStatusPill("\(log.sessions.count)", color: DiveUI.green)
            }
        }
    }

    private var emptyState: some View {
        DivePanel(stroke: DiveUI.yellow) {
            VStack(spacing: 4) {
                Text("NESSUNA IMMERSIONE")
                    .font(.headline.bold())
                    .foregroundStyle(DiveUI.yellow)
                Text("I log appariranno qui dopo la prima immersione.")
                    .font(.caption2)
                    .foregroundStyle(DiveUI.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func logRow(session: DiveSession, index: Int) -> some View {
        HStack(spacing: 8) {
            NavigationLink {
                DiveDetailView(session: session)
            } label: {
                DivePanel(stroke: DiveUI.subtleStroke) {
                    HStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.startDate.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                            Text(Formatters.time(session.durationSeconds))
                                .font(.caption2.monospacedDigit())
                                .foregroundStyle(DiveUI.yellow)
                        }
                        Spacer()
                        DiveMetric("MAX", value: Formatters.one(session.maxDepthMeters), unit: "m")
                    }
                }
            }
            .buttonStyle(.plain)

            DiveCommandButton("DEL", systemImage: "trash", color: DiveUI.red) {
                log.delete(id: session.id)
            }
            .frame(width: 72)
        }
    }
}\n