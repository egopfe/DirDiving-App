import SwiftUI
import UniformTypeIdentifiers

struct LogbookView: View {
    @EnvironmentObject private var logStore: DiveLogStore
    @State private var search = ""
    @State private var showImporter = false
    @State private var importMessage: String?
    @State private var pendingDelete: DiveSession?

    private var filtered: [DiveSession] {
        search.isEmpty ? logStore.sessions : logStore.sessions.filter { ($0.siteName ?? "").localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        header
                        importStatus
                        logbookSearchBar
                        if filtered.isEmpty {
                            emptyState
                        } else {
                            Text("MAGGIO 2024")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .tracking(0.6)
                                .foregroundStyle(DIRTheme.cyan)
                                .padding(.top, 4)
                            ForEach(Array(filtered.enumerated()), id: \.element.id) { index, session in
                                HStack(spacing: 7) {
                                    NavigationLink { DiveDetailView(session: session) } label: {
                                        DiveLogCard(session: session, index: index)
                                    }
                                    .buttonStyle(.plain)

                                    if !session.isDemoDive {
                                        Button(role: .destructive) {
                                            pendingDelete = session
                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundStyle(DIRTheme.red)
                                                .frame(width: 30, height: 64)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                        .fill(DIRTheme.red.opacity(0.08))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                                .stroke(DIRTheme.red.opacity(0.28), lineWidth: 1)
                                                        )
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.commaSeparatedText, .plainText]) { result in
                switch result {
                case .success(let url):
                    switch DiveImportService.importCSV(from: url) {
                    case .success(let session):
                        logStore.add(session)
                        importMessage = "Import completato: \(session.siteName ?? "Immersione")"
                    case .failure(let error):
                        importMessage = error.localizedDescription
                    }
                case .failure(let error):
                    importMessage = error.localizedDescription
                }
            }
            .confirmationDialog(
                "Eliminare immersione?",
                isPresented: Binding(
                    get: { pendingDelete != nil },
                    set: { if !$0 { pendingDelete = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Elimina", role: .destructive) {
                    if let pendingDelete {
                        logStore.delete(id: pendingDelete.id)
                    }
                    pendingDelete = nil
                }
                Button("Annulla", role: .cancel) {
                    pendingDelete = nil
                }
            } message: {
                Text("L'immersione verra rimossa dal logbook locale e dalla prossima sincronizzazione KVS.")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center) {
                Text("Logbook")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Spacer()
                Button {
                    showImporter = true
                } label: {
                    Text("IMPORT CSV")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(DIRTheme.cyan)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Capsule().stroke(DIRTheme.cyan.opacity(0.75), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private var importStatus: some View {
        if let importMessage {
            Text(importMessage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(importMessage.contains("completato") ? DIRTheme.green : DIRTheme.yellow)
                .fixedSize(horizontal: false, vertical: true)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.surface.opacity(0.8)))
        }
    }

    private var logbookSearchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(DIRTheme.muted)
            TextField("Cerca immersioni", text: $search)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.white)
                .tint(DIRTheme.cyan)
        }
        .padding(.horizontal, 10)
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(red: 0.055, green: 0.070, blue: 0.095))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.white.opacity(0.045), lineWidth: 1)
                )
        )
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: logStore.sessions.isEmpty ? "tray" : "magnifyingglass")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(DIRTheme.cyan)
                VStack(alignment: .leading, spacing: 3) {
                    Text(logStore.sessions.isEmpty ? "Nessuna immersione registrata" : "Nessun risultato")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text(logStore.sessions.isEmpty ? "Sincronizza Apple Watch o importa un CSV Subsurface per iniziare." : "Modifica la ricerca o importa un nuovo CSV.")
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Button {
                showImporter = true
            } label: {
                Text(logStore.sessions.isEmpty ? "IMPORTA CSV" : "IMPORTA NUOVO CSV")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(DIRTheme.cyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan.opacity(0.7), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(DIRTheme.surface.opacity(0.86))
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(DIRTheme.cyan.opacity(0.28), lineWidth: 1))
        )
    }
}

struct DiveLogCard: View {
    let session: DiveSession
    let index: Int
    @AppStorage("dirdiving_ios_units") private var units = IOSUnitPreference.metric.rawValue

    var body: some View {
        HStack(spacing: 10) {
            dateBlock
            DiveThumbnail(index: index)
                .frame(width: 58, height: 58)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(session.siteName ?? "Immersione")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                    if session.buddy != nil {
                        Text("BUDDY")
                            .font(.system(size: 8, weight: .bold, design: .rounded))
                            .foregroundStyle(DIRTheme.yellow)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(DIRTheme.yellow, lineWidth: 1))
                    }
                }
                Text("Max \(Formatters.depth(session.maxDepthMeters, units: unitPreference).text)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(DIRTheme.muted)
                HStack {
                    Text("T. \(Formatters.time(session.durationSeconds)) min")
                    Text(session.gasLabel.rawValue)
                        .padding(.leading, 8)
                    Spacer(minLength: 4)
                    Text(Formatters.optionalTemperature(session.avgWaterTemperatureCelsius, units: unitPreference))
                }
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(DIRTheme.muted)
            }
            Spacer(minLength: 4)
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(DIRTheme.muted.opacity(0.82))
        }
        .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
        .padding(.horizontal, 4)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(Color(red: 0.030, green: 0.043, blue: 0.060).opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(Color.white.opacity(0.045), lineWidth: 1)
                )
        )
    }

    private var unitPreference: IOSUnitPreference {
        IOSUnitPreference.fromStorage(units)
    }

    private var dateBlock: some View {
        VStack(spacing: 1) {
            Text(session.startDate.formatted(.dateTime.day()))
                .font(.system(size: 23, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
            Text("MAG")
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(DIRTheme.muted)
            Text(Formatters.clock(session.startDate))
                .font(.system(size: 9, weight: .regular, design: .rounded).monospacedDigit())
                .foregroundStyle(DIRTheme.muted)
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
            LinearGradient(colors: [.clear, .black.opacity(0.34)], startPoint: .top, endPoint: .bottom)
            Circle()
                .fill(.white.opacity(0.16))
                .frame(width: 42, height: 42)
                .offset(x: -22, y: -24)
            Image(systemName: index == 2 ? "water.waves" : "photo")
                .font(.system(size: 25, weight: .semibold))
                .foregroundStyle(.white.opacity(0.78))
                .rotationEffect(.degrees(index == 2 ? -18 : 0))
            ForEach(0..<5) { bubble in
                Circle()
                    .fill(.white.opacity(0.16))
                    .frame(width: CGFloat(3 + bubble), height: CGFloat(3 + bubble))
                    .offset(x: CGFloat(15 - bubble * 7), y: CGFloat(-18 + bubble * 8))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(DIRTheme.cyan.opacity(0.18), lineWidth: 1)
        )
    }
}
