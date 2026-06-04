import SwiftUI

struct DiveDetailView: View {
    let session: DiveSession
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var log: DiveLogStore
    @AppStorage(DIRUnitPreference.storageKey) private var watchUnits = DIRUnitPreference.metric.rawValue
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
                    if session.exceededSupportedDepthRange {
                        exceededDepthLogBanner
                    }
                    if session.isManual && !session.hasDepthProfile {
                        manualNoDepthLogBanner
                    }
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
            ExportView(fileName: exportCompletionFileName ?? "export.csv", exportURL: exportURL)
        }
        .confirmationDialog(String(localized: "log.delete.confirm.title"), isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button(String(localized: "log.delete.confirm.action"), role: .destructive) {
                log.delete(id: session.id)
                HapticService.shared.notify()
                dismiss()
            }
            Button(String(localized: "log.delete.cancel"), role: .cancel) {
                HapticService.shared.confirm()
            }
        } message: {
            Text(String(localized: "log.delete.confirm.message"))
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            WatchDetailBackButton()
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
            .font(DiveUI.Typography.secondaryLabel)
            .foregroundStyle(DiveUI.blue)
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.9)
    }

    private var summaryCards: some View {
        let depthDisplay = WatchDepthFormatting.display(meters: session.maxDepthMeters, units: DIRUnitPreference.fromStorage(watchUnits))
        return HStack(spacing: 4) {
            detailMetricCard(
                title: "PROF. MASSIMA",
                value: depthDisplay.valueText,
                unit: depthDisplay.unitLabel,
                color: session.exceededSupportedDepthRange ? DiveUI.red : DiveUI.blue
            )
            detailMetricCard(title: "DURATA", value: durationMinutesText, unit: "min", color: .white)
        }
    }

    private var exceededDepthLogBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.octagon.fill")
                .font(.system(size: 12, weight: .black))
            Text(String(localized: "depth.safety.log.outside_range"))
                .font(DiveUI.Typography.warningBody)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
        }
        .foregroundStyle(DiveUI.red)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(DiveUI.red.opacity(0.12))
                .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous).stroke(DiveUI.red.opacity(0.72), lineWidth: 1))
        )
    }

    private func detailMetricCard(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 1) {
            Text(title)
                .font(DiveUI.Typography.metricLabel)
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.9)

            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(color)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Text(unit)
                    .font(DiveUI.Typography.unitLabel)
                    .foregroundStyle(color)
                    .padding(.bottom, 1)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44)
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
                point: session.entryGPS,
                isEntry: true,
                status: fixSourceText(session.entryGPSFixSource),
                color: DiveUI.green
            )
            gpsRow(
                title: "PUNTO FINE",
                point: session.exitGPS,
                isEntry: false,
                status: fixSourceText(session.exitGPSFixSource),
                color: DiveUI.red
            )
            Text(String(localized: "dive.detail.gps.export_for_full"))
                .font(DiveUI.Typography.rowSubtitle)
                .foregroundStyle(DiveUI.secondaryText)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func gpsRow(title: String, point: GPSPoint?, isEntry: Bool, status: String, color: Color) -> some View {
        let summary = coordinateSummary(for: point, isEntry: isEntry)
        let fullCoordinate = coordinateLine(for: point, fallback: String(localized: "GPS non disponibile"))
        return HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(DiveUI.Typography.secondaryLabel)
                    .foregroundStyle(color)
                    .lineLimit(1)
                Text(summary)
                    .font(DiveUI.Typography.rowTitle)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(status)
                    .font(DiveUI.Typography.rowSubtitle)
                    .foregroundStyle(color)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(color)
                .symbolRenderingMode(.hierarchical)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 8)
        .frame(minHeight: 44)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(summary). \(status). \(fullCoordinate)")
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.black.opacity(0.48))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(color.opacity(0.7), lineWidth: 1)
                )
        )
    }

    private var sessionPersistenceClass: DiveSessionPersistenceClass {
        log.persistenceClass(for: session)
    }

    private var manualNoDepthLogBanner: some View {
        Text(String(localized: "log.manual.nodepth.banner"))
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(DiveUI.cyan)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(DiveUI.cyan.opacity(0.10))
                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(DiveUI.cyan.opacity(0.65), lineWidth: 1))
            )
    }

    private var exportPanel: some View {
        VStack(spacing: 8) {
            if !sessionPersistenceClass.allowsExport {
                Text(session.isManual && !session.hasDepthProfile
                     ? String(localized: "log.export.manual.nodepth.unavailable")
                     : String(localized: "log.export.unavailable"))
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .multilineTextAlignment(.center)
            }

            Button {
                guard sessionPersistenceClass.allowsExport else {
                    exportMessage = session.isManual && !session.hasDepthProfile
                        ? String(localized: "log.export.manual.nodepth.unavailable")
                        : String(localized: "logbook.export.failed")
                    HapticService.shared.notify()
                    return
                }
                exportURL = SubsurfaceExportService.writeCSV(for: session)
                exportMessage = exportURL == nil ? String(localized: "logbook.export.failed") : nil
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
                    .minimumScaleFactor(0.9)
                    .frame(maxWidth: .infinity, minHeight: 40)
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
                    .font(DiveUI.Typography.secondaryLabel)
                    .foregroundStyle(DiveUI.blue)
                    .frame(maxWidth: .infinity, minHeight: 40)
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
                    .font(DiveUI.Typography.secondaryLabel)
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

    private func coordinateSummary(for point: GPSPoint?, isEntry: Bool) -> String {
        guard point != nil else {
            return String(localized: "GPS non disponibile")
        }
        return isEntry
            ? String(localized: "dive.detail.gps.start_available")
            : String(localized: "dive.detail.gps.end_available")
    }

    private func coordinateLine(for point: GPSPoint?, fallback: String) -> String {
        guard let point else {
            return fallback
        }
        return "\(coordinateText(value: point.latitude, positive: "N", negative: "S"))   \(coordinateText(value: point.longitude, positive: "E", negative: "W"))"
    }

    private func fixSourceText(_ source: GPSFixSource) -> String {
        switch source {
        case .fix: return String(localized: "gps.fix.surface")
        case .fallback: return String(localized: "gps.fix.last_known")
        case .noFix: return String(localized: "gps.fix.no_fix")
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