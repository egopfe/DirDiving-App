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
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        DIRSearchBar(text: $search)
                        Text("MAGGIO 2024")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(DIRTheme.cyan)
                            .padding(.top, 8)
                        ForEach(Array(filtered.enumerated()), id: \.element.id) { index, session in
                            HStack(spacing: 8) {
                                NavigationLink { DiveDetailView(session: session) } label: {
                                    DiveLogCard(session: session, index: index)
                                }
                                .buttonStyle(.plain)

                                if !session.isDemoDive {
                                    Button(role: .destructive) {
                                        logStore.delete(id: session.id)
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.body.weight(.semibold))
                                            .foregroundStyle(DIRTheme.red)
                                            .frame(width: 36, height: 36)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 18)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Logbook")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "plus")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(DIRTheme.cyan)
                Image(systemName: "ellipsis.circle")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(DIRTheme.cyan)
            }
            Text("Dive history, sync status and inspection-ready session cards")
                .font(.callout)
                .foregroundStyle(DIRTheme.muted)
        }
    }
}

struct DiveLogCard: View {
    let session: DiveSession
    let index: Int

    var body: some View {
        HStack(spacing: 12) {
            dateBlock
            DiveThumbnail(index: index)
                .frame(width: 72, height: 72)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(session.siteName ?? "Immersione")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    if session.buddy != nil {
                        Text("BUDDY")
                            .font(.system(size: 8, weight: .bold, design: .rounded))
                            .foregroundStyle(DIRTheme.yellow)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(DIRTheme.yellow, lineWidth: 1))
                    }
                }
                Text("Max \(Formatters.one(session.maxDepthMeters)) m")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.86))
                HStack {
                    Text("T. \(Formatters.time(session.durationSeconds)) min")
                    Spacer()
                    Text(session.gasLabel.rawValue)
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.86))
            }
            Spacer(minLength: 6)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.72))
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(DIRTheme.surface.opacity(0.8))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(DIRTheme.hairline, lineWidth: 1))
                .shadow(color: DIRTheme.cyan.opacity(0.06), radius: 10, x: 0, y: 6)
        )
    }

    private var dateBlock: some View {
        VStack(spacing: 1) {
            Text(session.startDate.formatted(.dateTime.day()))
                .font(.system(size: 27, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("MAG")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.white.opacity(0.75))
            Text(Formatters.clock(session.startDate))
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(width: 38)
    }
}

struct DiveThumbnail: View {
    let index: Int

    private var colors: [Color] {
        [
            [DIRTheme.cyan, Color(red: 0.03, green: 0.22, blue: 0.30)],
            [Color(red: 0.0, green: 0.58, blue: 0.70), Color(red: 0.01, green: 0.11, blue: 0.16)],
            [Color(red: 0.04, green: 0.70, blue: 0.82), Color(red: 0.0, green: 0.06, blue: 0.10)],
            [Color(red: 0.02, green: 0.42, blue: 0.58), Color(red: 0.0, green: 0.07, blue: 0.11)]
        ][index % 4]
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle()
                .fill(.white.opacity(0.16))
                .frame(width: 52, height: 52)
                .offset(x: -26, y: -30)
            Image(systemName: index == 2 ? "water.waves" : "photo")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.white.opacity(0.82))
                .rotationEffect(.degrees(index == 2 ? -18 : 0))
            ForEach(0..<5) { bubble in
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: CGFloat(3 + bubble), height: CGFloat(3 + bubble))
                    .offset(x: CGFloat(18 - bubble * 8), y: CGFloat(-22 + bubble * 9))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
