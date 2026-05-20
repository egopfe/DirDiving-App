import SwiftUI

struct DiveDetailView: View {
    let session: DiveSession
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var log: DiveLogStore
    @State private var exportURL: URL?
    @State private var exportMessage: String?
    @State private var exportCompletionFileName: String?
    @State private var showExportCompletion = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        ZStack {
            DiveScreenBackground()

            ScrollView {
                VStack(spacing: 6) {
                    header
                    dateLine
                    summaryCards
                    gpsRows
                    exportPanel
                    deletePanel
                }
                .padding(.horizontal, 10)
                .padding(.top, 9)
                .padding(.bottom, 8)
            }
        }
        .navigationDestination(isPresented: $showExportCompletion) {
            ExportView(fileName: exportCompletionFileName ?? "export.csv")
        }
        .confirmationDialog("Eliminare immersione?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Elimina log", role: .destructive) {
                log.delete(id: session.id)
                HapticService.shared.notify()
                dismiss()
            }
            Button("Annulla", role: .cancel) {
                HapticService.shared.confirm()
            }
        } message: {
            Text("Il log verra rimosso dal Watch e dalla prossima sincronizzazione.")
        }
    }

    private var header: some View {
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
    }

    private var dateLine: some View {
        Text("\(Self.dateFormatter.string(from: session.startDate))   \(Self.timeFormatter.string(from: session.startDate))")
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .foregroundStyle(DiveUI.blue)
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.78)
    }

    private var summaryCards: some View {
        HStack(spacing: 4) {
            detailMetricCard(title: "PROF. MASSIMA", value: Formatters.one(session.maxDepthMeters), unit: "m", color: DiveUI.blue)
            detailMetricCard(title: "DURATA", value: durationMinutesText, unit: "min", color: .white)
        }
    }

    private func detailMetricCard(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.system(size: 7, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(color)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                Text(unit)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(color)
                    .padding(.bottom, 1)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 36)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.black.opacity(0.45))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var gpsRows: some View {
        VStack(spacing: 3) {
            gpsRow(
                title: "PUNTO INIZIO",
                coordinate: coordinateLine(for: session.entryGPS, fallback: "GPS non disponibile"),
                status: fixSourceText(session.entryGPSFixSource),
                color: DiveUI.green
            )
            gpsRow(
                title: "PUNTO FINE",
                coordinate: coordinateLine(for: session.exitGPS, fallback: "GPS non disponibile"),
                status: fixSourceText(session.exitGPSFixSource),
                color: DiveUI.red
            )
        }
    }

    private func gpsRow(title: String, coordinate: String, status: String, color: Color) -> some View {
        HStack(spacing: 6) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(color)
                    .lineLimit(1)
                Text(coordinate)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
                Text(status)
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundStyle(color)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 21, weight: .black))
                .foregroundStyle(color)
                .symbolRenderingMode(.hierarchical)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 5)
        .frame(minHeight: 39)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.black.opacity(0.48))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(color.opacity(0.7), lineWidth: 1)
                )
        )
    }

    private var exportPanel: some View {
        VStack(spacing: 8) {
            Button {
                exportURL = SubsurfaceExportService.writeCSV(for: session)
                exportMessage = exportURL == nil ? String(localized: "Export CSV non riuscito") : nil
                if let exportURL {
                    exportCompletionFileName = exportURL.lastPathComponent
                    showExportCompletion = true
                    HapticService.shared.confirm()
                } else {
                    HapticService.shared.notify()
                }
            } label: {
                Text("ESPORTA (SUBSURFACE)")
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

            if let exportURL {
                ShareLink(item: exportURL) {
                    HStack(spacing: 5) {
                        Text("CONDIVIDI CSV")
                        Image(systemName: "square.and.arrow.up")
                    }
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(DiveUI.blue.opacity(0.82), lineWidth: 1)
                    )
                }
            } else if let exportMessage {
                Text(exportMessage)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var deletePanel: some View {
        Button {
            showDeleteConfirmation = true
            HapticService.shared.notify()
        } label: {
            HStack(spacing: 7) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 12, weight: .black))
                Text("ELIMINA LOG")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                Spacer(minLength: 0)
                Text("CONFERMA")
                    .font(.system(size: 9, weight: .black, design: .rounded))
            }
            .foregroundStyle(DiveUI.red)
            .padding(.horizontal, 9)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(DiveUI.red.opacity(0.10))
                    .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous).stroke(DiveUI.red.opacity(0.72), lineWidth: 1.2))
            )
        }
        .buttonStyle(.plain)
    }

    private var durationMinutesText: String {
        "\(max(0, Int((session.durationSeconds / 60).rounded())))"
    }

    private func coordinateLine(for point: GPSPoint?, fallback: String) -> String {
        guard let point else {
            return fallback
        }
        return "\(coordinateText(value: point.latitude, positive: "N", negative: "S"))   \(coordinateText(value: point.longitude, positive: "E", negative: "W"))"
    }

    private func fixSourceText(_ source: GPSFixSource) -> String {
        switch source {
        case .fix: return String(localized: "FIX SUPERFICIE")
        case .fallback: return String(localized: "ULTIMO PUNTO NOTO")
        case .noFix: return String(localized: "NO-FIX")
        }
    }

    private func coordinateText(value: Double, positive: String, negative: String) -> String {
        let direction = value >= 0 ? positive : negative
        return String(format: "%.6f\u{00B0} %@", abs(value), direction)
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