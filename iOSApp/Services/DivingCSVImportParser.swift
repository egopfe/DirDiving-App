import Foundation

protocol DivingImportParser {
    var supportedFormats: Set<DivingImportSourceFormat> { get }
    func previewImport(from url: URL, source: DivingImportSource) -> Result<DivingImportPreviewResult, DivingImportError>
}

struct DivingCSVImportParser: DivingImportParser {
    let supportedFormats: Set<DivingImportSourceFormat> = [.dirDivingCSV, .subsurfaceCSV]

    func previewImport(from url: URL, source: DivingImportSource) -> Result<DivingImportPreviewResult, DivingImportError> {
        switch DiveImportService.importCSV(from: url) {
        case .success(let summary):
            var warnings: [DivingImportWarning] = []
            if summary.skippedMalformedCount > 0 {
                warnings.append(.invalidRowsSkipped)
            }
            if summary.session.samples.isEmpty {
                warnings.append(.missingSamples)
            } else if summary.session.samples.count < 3 {
                warnings.append(.sparseSamples)
            }
            if summary.session.avgWaterTemperatureCelsius == nil {
                warnings.append(.missingTemperature)
            }
            if summary.session.entryGPS == nil && summary.session.exitGPS == nil {
                warnings.append(.missingGPS)
            }
            guard let candidate = DivingImportCandidate.build(
                sourceFormat: source.format,
                sourceFileName: source.fileName,
                session: summary.session,
                sourceDiveID: summary.session.id.uuidString,
                warnings: warnings
            ) else {
                return .failure(.validationFailed(DIRIOSLocalizer.string("diving.import.error.empty")))
            }
            return .success(
                DivingImportPreviewResult(
                    source: source,
                    candidates: [candidate],
                    parseWarnings: summary.skippedMalformedCount > 0
                        ? [String(format: DIRIOSLocalizer.string("diving.import.warning.invalid_rows_skipped"))]
                        : [],
                    skippedCount: summary.skippedMalformedCount
                )
            )
        case .failure(let error):
            return .failure(mapCSVError(error))
        }
    }

    private func mapCSVError(_ error: DiveImportService.ImportError) -> DivingImportError {
        switch error {
        case .unreadableFile: return .unreadableFile
        case .fileTooLarge: return .fileTooLarge
        case .emptyProfile: return .emptyImport
        case .missingColumns: return .malformedFile(DIRIOSLocalizer.string("import.error.missing_columns"))
        case .invalidRows: return .malformedFile(DIRIOSLocalizer.string("diving.import.error.unreadable"))
        }
    }
}
