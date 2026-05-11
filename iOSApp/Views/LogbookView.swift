import SwiftUI

struct LogbookView: View {
    @EnvironmentObject private var logStore: DiveLogStore
    @State private var search = ""
    private var filtered: [DiveSession] {
        search.isEmpty ? logStore.sessions : logStore.sessions.filter { ($0.siteName ?? "").localizedCaseInsensitiveContains(search) }
    }
    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        DIRSectionHeader(title: "DIR DIVING", subtitle: "iOS Companion")
                        DIRSearchBar(text: $search)
                        ForEach(filtered) { session in
                            NavigationLink { DiveDetailView(session: session) } label: { DiveLogCard(session: session) }
                                .buttonStyle(.plain)
                        }
                    }.padding()
                }
            }
            .navigationTitle("Logbook")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
struct DiveLogCard: View {
    let session: DiveSession
    var body: some View {
        DIRCard {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14).fill(LinearGradient(colors: [DIRTheme.cyan.opacity(0.55), DIRTheme.surface2], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Image(systemName: "water.waves").font(.largeTitle).foregroundStyle(.white.opacity(0.9))
                }.frame(width: 74, height: 74)
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(session.siteName ?? "Immersione").font(.headline).foregroundStyle(.white)
                        if session.buddy != nil {
                            Text("BUDDY").font(.caption2.bold()).foregroundStyle(.black).padding(.horizontal, 5).padding(.vertical, 2).background(DIRTheme.yellow).clipShape(Capsule())
                        }
                    }
                    Text(session.startDate.formatted(date: .abbreviated, time: .shortened)).font(.caption).foregroundStyle(DIRTheme.muted)
                    HStack {
                        Text("Max \(Formatters.one(session.maxDepthMeters)) m")
                        Text("T. \(Formatters.time(session.durationSeconds)) min")
                        Text(session.gasLabel.rawValue)
                    }.font(.caption).foregroundStyle(DIRTheme.cyan)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(DIRTheme.muted)
            }
        }
    }
}
