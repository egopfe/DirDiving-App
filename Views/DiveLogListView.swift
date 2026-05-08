import SwiftUI

struct DiveLogListView: View {
    @EnvironmentObject private var log: DiveLogStore

    var body: some View {
        List {
            if log.sessions.isEmpty { Text("Nessuna immersione").foregroundStyle(.secondary) }
            ForEach(log.sessions) { session in
                NavigationLink {
                    DiveDetailView(session: session)
                } label: {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(session.startDate.formatted(date: .abbreviated, time: .shortened)).font(.headline)
                        Text("Max \(Formatters.one(session.maxDepthMeters)) m · \(Formatters.time(session.durationSeconds))").font(.caption2)
                    }
                }
            }.onDelete(perform: log.delete)
        }
        .navigationTitle("Log")
    }
}
