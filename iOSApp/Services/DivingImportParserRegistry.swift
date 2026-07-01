import Foundation

enum DivingImportParserRegistry {
    private static let csvParser = DivingCSVImportParser()
    private static let xmlParser = SubsurfaceXMLImportParser()
    private static let uddfParser = UDDFImportParser()

    static func parser(for format: DivingImportSourceFormat) -> DivingImportParser? {
        switch format {
        case .dirDivingCSV, .subsurfaceCSV: return csvParser
        case .subsurfaceXML: return xmlParser
        case .uddf: return uddfParser
        case .unknown: return nil
        }
    }

    static func previewImport(from url: URL) -> Result<DivingImportPreviewResult, DivingImportError> {
        let source = DivingImportFormatDetector.makeSource(from: url)
        guard source.format != .unknown else {
            return .failure(.unsupportedFormat)
        }
        if let size = source.fileSizeBytes, size > IOSAlgorithmConfiguration.maxImportBytes {
            return .failure(.fileTooLarge)
        }
        guard let parser = parser(for: source.format) else {
            return .failure(.unsupportedFormat)
        }
        return parser.previewImport(from: url, source: source)
    }
}
