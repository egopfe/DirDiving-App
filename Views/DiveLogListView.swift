import SwiftUI

struct DiveLogListView: View {
    @EnvironmentObject private var log: DiveLogStore
    @EnvironmentObject private var watchSync: WatchSyncService
    @State private var listExportURL: URL?
    @State private var listExportMessage: String?

    var body: some View {
        ZStack {
            DiveScreenBackground()

            ScrollView {
                VStack(spacing: 7) {
                    header
                    if let loadError = log.loadErrorMessage {
                        errorBanner(loadError)
                    }

                    sessionList
                    exportButton
                }
                .padding(.horizontal, 12)
                .padding(.top, 9)
                .padding(.bottom, 8)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            HStack(alignment: .center) {
                HStack(spacing: 5) {
                    DiveOctopusLogo(accent: DiveUI.yellow)
                        .frame(width: 23, height: 22, alignment: .leading)
                        .scaleEffect(0.68)
                    Text("DIR DIVING")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.yellow)
                        .lineLimit(1)
                }

                Spacer()

                DiveClockText(size: 14)
            }

            Text("IMMERSIONI")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .kerning(0.4)
                .frame(maxWidth: .infinity)
        }
    }

    private var emptyState: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color.black.opacity(0.54))
            .overlay(
                VStack(spacing: 4) {
                    Text("NESSUNA IMMERSIONE")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.yellow)
                    Text("I log appariranno qui dopo la prima immersione.")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(DiveUI.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(8)
            )
            .frame(minHeight: 88)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.white.opacity(0.24), lineWidth: 1)
            )
    }

    private var sessionList: some View {
        VStack(spacing: 0) {
            if log.sessions.isEmpty {
                emptyState
            } else {
                ForEach(Array(log.sessions.enumerated()), id: \.element.id) { index, session in
                    logRow(session: session, index: index)
                    if index < log.sessions.count - 1 {
                        Divider()
                            .overlay(.white.opacity(0.12))
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.black.opacity(0.48))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(0.24), lineWidth: 1)
                )
        )
    }

    private func errorBanner(_ message: String) -> some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(DiveUI.red.opacity(0.12))
            .overlay(
                Text(message)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(DiveUI.red)
                    .multilineTextAlignment(.center)
                    .padding(7)
            )
            .frame(minHeight: 34)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(DiveUI.red.opacity(0.72), lineWidth: 1)
            )
    }

    private var exportButton: some View {
        VStack(spacing: 5) {
            Button {
                guard let latest = log.sessions.first else {
                    listExportURL = nil
                    listExportMessage = "Nessuna immersione da esportare"
                    HapticService.shared.notify()
                    return
                }
                listExportURL = SubsurfaceExportService.writeCSV(for: latest)
                listExportMessage = listExportURL == nil ? "Export CSV non riuscito" : nil
                if listExportURL == nil {
                    HapticService.shared.notify()
                } else {
                    HapticService.shared.confirm()
                }
            } label: {
                Text("ESPORTA ULTIMA (SUBSURFACE)")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.green)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
                    .frame(maxWidth: .infinity, minHeight: 32)
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(DiveUI.green.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .stroke(DiveUI.green.opacity(0.78), lineWidth: 1.2)
                    )
                    .shadow(color: DiveUI.green.opacity(0.18), radius: 5, x: 0, y: 0)
            )

            if let listExportURL {
                ShareLink(item: listExportURL) {
                    Text("CONDIVIDI CSV")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.blue)
                        .frame(maxWidth: .infinity, minHeight: 26)
                        .background(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(DiveUI.blue.opacity(0.82), lineWidth: 1))
                }
            } else if let listExportMessage {
                Text(listExportMessage)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func logRow(session: DiveSession, index: Int) -> some View {
        NavigationLink {
            DiveDetailView(session: session)
        } label: {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(logDate(session.startDate))
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .monospacedDigit()
                        Spacer(minLength: 5)
                        Text(logTime(session.startDate))
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .monospacedDigit()
                    }

                    HStack(alignment: .lastTextBaseline, spacing: 13) {
                        Text("\(Formatters.one(session.maxDepthMeters)) m")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                        Text("\(durationMinutes(session.durationSeconds)) min")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 19, weight: .black))
                    .foregroundStyle(DiveUI.green)
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .frame(minHeight: 36)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                log.delete(id: session.id)
            } label: {
                Label("Elimina", systemImage: "trash")
            }
        }
    }

    private func logDate(_ date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }

    private func logTime(_ date: Date) -> String {
        Self.timeFormatter.string(from: date)
    }

    private func durationMinutes(_ interval: TimeInterval) -> String {
        "\(max(0, Int((interval / 60).rounded())))"
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}