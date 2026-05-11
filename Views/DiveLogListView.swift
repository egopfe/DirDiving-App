import SwiftUI

struct DiveLogListView: View {
    @EnvironmentObject private var log: DiveLogStore

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 8) {
                    header

                    if log.sessions.isEmpty {
                        emptyState
                    } else {
                        ForEach(Array(log.sessions.enumerated()), id: \.element.id) { index, session in
                            logRow(session: session, index: index)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
        }
    }

    private var header: some View {
        HStack {
            Text("DIVE LOG")
                .font(.headline.bold())
                .foregroundStyle(DiveUI.blue)
            Spacer()
            Text("\(log.sessions.count)")
                .font(.headline.monospacedDigit().bold())
                .foregroundStyle(DiveUI.green)
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
                    DiveCommandButton("DEL", systemImage: "trash", color: DiveUI.red) {
                        log.delete(at: IndexSet(integer: index))
                    }
                    .frame(width: 72)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

