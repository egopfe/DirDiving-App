import SwiftUI
import UniformTypeIdentifiers

enum DivingImportExportTab: String, CaseIterable, Identifiable {
    case importTab
    case exportTab

    var id: String { rawValue }
}

struct DivingImportExportCenterView: View {
    @Environment(\.dismiss) private var dismiss

    let initialTab: DivingImportExportTab
    @State private var selectedTab: DivingImportExportTab

    init(initialTab: DivingImportExportTab = .importTab) {
        self.initialTab = initialTab
        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                VStack(spacing: 0) {
                    Picker("", selection: $selectedTab) {
                        Text(DIRIOSLocalizer.string("diving.import_export.tab.import"))
                            .tag(DivingImportExportTab.importTab)
                        Text(DIRIOSLocalizer.string("diving.import_export.tab.export"))
                            .tag(DivingImportExportTab.exportTab)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    switch selectedTab {
                    case .importTab:
                        DivingImportTabContent()
                    case .exportTab:
                        DivingExportTabContent()
                    }
                }
            }
            .navigationTitle(DIRIOSLocalizer.string("diving.import_export.center.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(DIRIOSLocalizer.string("common.cancel")) { dismiss() }
                }
            }
        }
    }
}

/// Backward-compatible wrapper for import-only entry points.
struct DivingImportCenterView: View {
    var body: some View {
        DivingImportExportCenterView(initialTab: .importTab)
    }
}

struct DivingImportTabContent: View {
    @EnvironmentObject private var logStore: DiveLogStore

    @State private var showImporter = false
    @State private var isAnalyzing = false
    @State private var errorMessage: String?
    @State private var preview: DivingImportPreviewResult?
    @State private var rows: [DivingImportPreviewRow] = []
    @State private var commitReport: DivingImportCommitReport?
    @State private var phase: ImportPhase = .selectFile

    private enum ImportPhase {
        case selectFile
        case preview
        case report
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                centerSubtitle(DIRIOSLocalizer.string("diving.import_export.center.subtitle"))
                importExportDisclaimer(DIRIOSLocalizer.string("diving.export.disclaimer"))
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
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.commaSeparatedText, .plainText, .xml, .data],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result)
        }
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
                ProgressView().tint(DIRTheme.cyan)
            }
        }
    }

    @ViewBuilder
    private var previewSection: some View {
        if let preview {
            importSourceCard(preview.source, diveCount: preview.candidates.count)
            Text(DIRIOSLocalizer.string("diving.import.preview.title"))
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
            ForEach(rows.indices, id: \.self) { index in
                importPreviewRow(at: index)
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
            importReportLine(DIRIOSLocalizer.string("diving.import.report.imported"), value: commitReport.importedCount)
            importReportLine(DIRIOSLocalizer.string("diving.import.report.duplicates_skipped"), value: commitReport.skippedDuplicateCount)
            importReportLine(DIRIOSLocalizer.string("diving.import.report.failed"), value: commitReport.failedCount)
            importReportLine(DIRIOSLocalizer.string("diving.import.report.warnings"), value: commitReport.warningsCount)
            Button {
                phase = .selectFile
                preview = nil
                rows = []
                self.commitReport = nil
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

    private func importPreviewRow(at index: Int) -> some View {
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
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(DIRTheme.surface.opacity(0.6))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.hairline, lineWidth: 1))
        )
    }

    private func isDuplicate(_ status: DivingImportDuplicateStatus) -> Bool {
        switch status {
        case .new: return false
        case .exactDuplicate, .likelyDuplicate: return true
        }
    }
}

struct DivingExportTabContent: View {
    @EnvironmentObject private var logStore: DiveLogStore

    @State private var selectedFormat: DivingExportFormat = .csv
    @State private var candidates: [DivingExportCandidate] = []
    @State private var exportURL: URL?
    @State private var exportReport: DivingExportReport?
    @State private var exportErrorMessage: String?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                centerSubtitle(DIRIOSLocalizer.string("diving.import_export.center.subtitle"))
                importExportDisclaimer(DIRIOSLocalizer.string("diving.export.disclaimer"))

                Text(DIRIOSLocalizer.string("diving.export.title"))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 8) {
                    Text(DIRIOSLocalizer.string("diving.export.format"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DIRTheme.muted)
                    Picker(DIRIOSLocalizer.string("diving.export.format"), selection: $selectedFormat) {
                        ForEach(DivingExportFormat.allCases) { format in
                            Text(DIRIOSLocalizer.string(format.localizationKey)).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Text(DIRIOSLocalizer.formatted("diving.export.selected_count", selectedCount))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)

                ForEach(candidates.indices, id: \.self) { index in
                    exportCandidateRow(at: index)
                }

                Button {
                    generateExport()
                } label: {
                    Text(DIRIOSLocalizer.string("diving.export.generate"))
                        .font(.callout.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(DIRTheme.cyan))
                }
                .buttonStyle(.plain)
                .disabled(selectedCount == 0)

                if let exportURL {
                    ShareLink(
                        item: exportURL,
                        preview: SharePreview(
                            DIRIOSLocalizer.string("diving.export.share"),
                            icon: Image(systemName: "square.and.arrow.up")
                        )
                    ) {
                        Text(DIRIOSLocalizer.string("diving.export.share"))
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(DIRTheme.cyan)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(DIRTheme.cyan, lineWidth: 1))
                    }
                }

                if let exportReport {
                    exportReportSection(exportReport)
                }

                if let exportErrorMessage {
                    Text(exportErrorMessage)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DIRTheme.orange)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .dirCompanionScrollSurface()
        .onAppear { reloadCandidates() }
        .onChange(of: logStore.sessions.count) { _, _ in reloadCandidates() }
    }

    private var selectedCount: Int {
        candidates.filter(\.isSelected).count
    }

    private func reloadCandidates() {
        let realSessions = logStore.sessions.filter { !$0.isDemoDive }
        candidates = DivingExportCoordinator.buildCandidates(from: realSessions)
    }

    private func exportCandidateRow(at index: Int) -> some View {
        let value = candidates[index]
        return HStack(alignment: .top, spacing: 10) {
            Toggle(
                "",
                isOn: Binding(
                    get: { candidates[index].isSelected },
                    set: { candidates[index].isSelected = $0 }
                )
            )
            .labelsHidden()
            .disabled(!value.isExportable)
            VStack(alignment: .leading, spacing: 4) {
                Text(value.session.startDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
                HStack(spacing: 8) {
                    Text(Formatters.time(value.session.durationSeconds))
                    Text(Formatters.depth(value.session.maxDepthMeters, units: .metric).text)
                }
                .font(.caption)
                .foregroundStyle(DIRTheme.muted)
                if !value.warnings.isEmpty {
                    Text("\(value.warnings.count) warnings")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(DIRTheme.yellow)
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

    private func generateExport() {
        exportErrorMessage = nil
        exportURL = nil
        exportReport = nil
        let selected = candidates.filter(\.isSelected).map(\.session)
        switch DivingExportCoordinator.export(sessions: selected, format: selectedFormat) {
        case .success(let report):
            exportReport = report
            exportURL = report.url
        case .failure(let error):
            exportErrorMessage = error.localizedDescription
        }
    }

    private func exportReportSection(_ report: DivingExportReport) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(DIRIOSLocalizer.string("diving.export.report.title"))
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
            importReportLine(DIRIOSLocalizer.string("diving.export.report.exported"), value: report.exportedCount)
            importReportLine(DIRIOSLocalizer.string("diving.export.report.skipped"), value: report.skippedCount)
            importReportLine(DIRIOSLocalizer.string("diving.export.report.warnings"), value: report.warningsCount)
            Text(DIRIOSLocalizer.string(selectedFormat.localizationKey))
                .font(.caption)
                .foregroundStyle(DIRTheme.cyan)
        }
    }
}

private func centerSubtitle(_ text: String) -> some View {
    Text(text)
        .font(.callout)
        .foregroundStyle(DIRTheme.muted)
        .fixedSize(horizontal: false, vertical: true)
}

private func importExportDisclaimer(_ text: String) -> some View {
    Text(text)
        .font(.caption)
        .foregroundStyle(DIRTheme.muted)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(DIRTheme.surface.opacity(0.7))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.hairline, lineWidth: 1))
        )
}

private func importSourceCard(_ source: DivingImportSource, diveCount: Int) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(source.fileName)
            .font(.callout.weight(.semibold))
            .foregroundStyle(.white)
        HStack {
            Text(DIRIOSLocalizer.string("diving.import.detected_format"))
                .font(.caption)
                .foregroundStyle(DIRTheme.muted)
            Spacer()
            Text(importFormatLabel(source.format))
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
    }
    .padding(12)
    .background(
        RoundedRectangle(cornerRadius: 10)
            .fill(DIRTheme.surface.opacity(0.8))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(DIRTheme.hairline, lineWidth: 1))
    )
}

private func importReportLine(_ title: String, value: Int) -> some View {
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

private func importFormatLabel(_ format: DivingImportSourceFormat) -> String {
    switch format {
    case .dirDivingCSV: return "DirDiving CSV"
    case .subsurfaceCSV: return "Subsurface CSV"
    case .subsurfaceXML: return "Subsurface XML"
    case .uddf: return "UDDF"
    case .unknown: return "Unknown"
    }
}
