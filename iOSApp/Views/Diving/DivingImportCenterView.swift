import SwiftUI
import UniformTypeIdentifiers

struct DivingImportCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var logStore: DiveLogStore

    @State private var showImporter = false
    @State private var isAnalyzing = false
    @State private var errorMessage: String?
    @State private var preview: DivingImportPreviewResult?
    @State private var rows: [DivingImportPreviewRow] = []
    @State private var commitReport: DivingImportCommitReport?
    @State private var phase: Phase = .selectFile

    private enum Phase {
        case selectFile
        case preview
        case report
    }

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        disclaimer
                        switch phase {
                        case .selectFile:
                            selectFileSection
                        case .preview:
                            previewSection
                        case .report:
                            reportSection
                        }
                        if let errorMessage {
                            Text(errorMessage)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(DIRTheme.orange)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .dirCompanionScrollSurface()
            }
            .navigationTitle(DIRIOSLocalizer.string("diving.import.center.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(DIRIOSLocalizer.string("common.cancel")) { dismiss() }
                }
            }
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.commaSeparatedText, .plainText, .xml, .data],
                allowsMultipleSelection: false
            ) { result in
                handleFileSelection(result)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(DIRIOSLocalizer.string("diving.import.center.subtitle"))
                .font(.callout)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var disclaimer: some View {
        Text(DIRIOSLocalizer.string("diving.import.presentation.disclaimer"))
            .font(.caption)
            .foregroundStyle(DIRTheme.muted)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(DIRTheme.surface.opacity(0.7))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.hairline, lineWidth: 1))
            )
    }

    private var selectFileSection: some View {
        VStack(spacing: 12) {
            Button {
                showImporter = true
            } label: {
                Label(DIRIOSLocalizer.string("diving.import.select_file"), systemImage: "doc.badge.plus")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 10).stroke(DIRTheme.cyan, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(isAnalyzing)
            if isAnalyzing {
                ProgressView()
                    .tint(DIRTheme.cyan)
            }
        }
    }

    @ViewBuilder
    private var previewSection: some View {
        if let preview {
            sourceCard(preview.source, diveCount: preview.candidates.count)
            Text(DIRIOSLocalizer.string("diving.import.preview.title"))
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
            ForEach(rows.indices, id: \.self) { index in
                previewRowContent(at: index)
            }
            Button {
                commitReport = DivingImportCoordinator.commit(rows: rows, into: logStore)
                phase = .report
            } label: {
                Text(DIRIOSLocalizer.string("diving.import.import_selected"))
                    .font(.callout.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(DIRTheme.cyan))
            }
            .buttonStyle(.plain)
            .disabled(rows.filter(\.isSelected).isEmpty)
        }
    }

    @ViewBuilder
    private var reportSection: some View {
        if let commitReport {
            Text(DIRIOSLocalizer.string("diving.import.report.title"))
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
            reportLine(DIRIOSLocalizer.string("diving.import.report.imported"), value: commitReport.importedCount)
            reportLine(DIRIOSLocalizer.string("diving.import.report.duplicates_skipped"), value: commitReport.skippedDuplicateCount)
            reportLine(DIRIOSLocalizer.string("diving.import.report.failed"), value: commitReport.failedCount)
            reportLine(DIRIOSLocalizer.string("diving.import.report.warnings"), value: commitReport.warningsCount)
            Button {
                dismiss()
            } label: {
                Text(DIRIOSLocalizer.string("common.done"))
                    .font(.callout.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(DIRTheme.cyan))
            }
            .buttonStyle(.plain)
        }
    }

    private func sourceCard(_ source: DivingImportSource, diveCount: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(source.fileName)
                .font(.callout.weight(.semibold))
                .foregroundStyle(.white)
            HStack {
                Text(DIRIOSLocalizer.string("diving.import.detected_format"))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
                Spacer()
                Text(formatLabel(source.format))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
            }
            HStack {
                Text(DIRIOSLocalizer.string("diving.import.dives_found"))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
                Spacer()
                Text("\(diveCount)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
            }
            if let size = source.fileSizeBytes {
                Text(ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(DIRTheme.surface.opacity(0.8))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(DIRTheme.hairline, lineWidth: 1))
        )
    }

    private func previewRowContent(at index: Int) -> some View {
        let value = rows[index]
        return HStack(alignment: .top, spacing: 10) {
            Toggle(
                "",
                isOn: Binding(
                    get: { rows[index].isSelected },
                    set: { rows[index].isSelected = $0 }
                )
            )
                .labelsHidden()
                .disabled(!value.candidate.isImportable || isDuplicate(value.duplicateStatus))
            VStack(alignment: .leading, spacing: 4) {
                Text(value.candidate.session.startDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
                HStack(spacing: 8) {
                    Text(Formatters.time(value.candidate.session.durationSeconds))
                    Text(Formatters.depth(value.candidate.session.maxDepthMeters, units: .metric).text)
                    Text("\(value.candidate.session.samples.count) samples")
                }
                .font(.caption)
                .foregroundStyle(DIRTheme.muted)
                HStack(spacing: 6) {
                    statusBadge(for: value)
                    if !value.candidate.warnings.isEmpty {
                        Text("\(value.candidate.warnings.count) warnings")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(DIRTheme.yellow)
                    }
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(DIRTheme.surface.opacity(0.6))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.hairline, lineWidth: 1))
        )
    }

    private func statusBadge(for row: DivingImportPreviewRow) -> some View {
        let (label, color): (String, Color) = {
            if !row.candidate.isImportable {
                return (DIRIOSLocalizer.string("diving.import.status.not_importable"), DIRTheme.muted)
            }
            switch row.duplicateStatus {
            case .new:
                return (DIRIOSLocalizer.string("diving.import.status.new"), DIRTheme.green)
            case .exactDuplicate:
                return (DIRIOSLocalizer.string("diving.import.status.duplicate"), DIRTheme.orange)
            case .likelyDuplicate:
                return (DIRIOSLocalizer.string("diving.import.status.likely_duplicate"), DIRTheme.yellow)
            }
        }()
        return Text(label)
            .font(.caption2.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(color.opacity(0.8), lineWidth: 1))
    }

    private func reportLine(_ title: String, value: Int) -> some View {
        HStack {
            Text(title)
                .font(.callout)
                .foregroundStyle(DIRTheme.muted)
            Spacer()
            Text("\(value)")
                .font(.callout.weight(.semibold))
                .foregroundStyle(.white)
        }
    }

    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            analyze(url)
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    private func analyze(_ url: URL) {
        isAnalyzing = true
        errorMessage = nil
        defer { isAnalyzing = false }
        switch DivingImportParserRegistry.previewImport(from: url) {
        case .success(let result):
            preview = result
            rows = DivingImportDeduplicator.buildPreviewRows(from: result, existingSessions: logStore.sessions)
            phase = .preview
        case .failure(let error):
            errorMessage = error.localizedDescription
            phase = .selectFile
        }
    }

    private func formatLabel(_ format: DivingImportSourceFormat) -> String {
        switch format {
        case .dirDivingCSV: return "DirDiving CSV"
        case .subsurfaceCSV: return "Subsurface CSV"
        case .subsurfaceXML: return "Subsurface XML"
        case .uddf: return "UDDF"
        case .unknown: return "Unknown"
        }
    }

    private func isDuplicate(_ status: DivingImportDuplicateStatus) -> Bool {
        switch status {
        case .new: return false
        case .exactDuplicate, .likelyDuplicate: return true
        }
    }
}
