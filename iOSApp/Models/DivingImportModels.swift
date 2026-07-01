import Foundation

enum DivingImportSourceFormat: String, Codable, CaseIterable, Hashable, Sendable {
    case dirDivingCSV
    case subsurfaceCSV
    case subsurfaceXML
    case uddf
    case unknown
}

struct DivingImportSource: Hashable, Sendable {
    let url: URL
    let fileName: String
    let format: DivingImportSourceFormat
    let fileSizeBytes: Int?
}

enum DivingImportWarning: String, Codable, CaseIterable, Hashable, Sendable {
    case missingSamples
    case sparseSamples
    case missingStartDate
    case missingTemperature
    case missingGPS
    case missingGas
    case invalidRowsSkipped
    case unsupportedFieldIgnored
    case duplicateLikely
    case normalizedForStorage

    var localizationKey: String {
        switch self {
        case .missingSamples: return "diving.import.warning.missing_samples"
        case .sparseSamples: return "diving.import.warning.sparse_samples"
        case .missingStartDate: return "diving.import.warning.missing_start_date"
        case .missingTemperature: return "diving.import.warning.missing_temperature"
        case .missingGPS: return "diving.import.warning.missing_gps"
        case .missingGas: return "diving.import.warning.missing_gas"
        case .invalidRowsSkipped: return "diving.import.warning.invalid_rows_skipped"
        case .unsupportedFieldIgnored: return "diving.import.warning.unsupported_field_ignored"
        case .duplicateLikely: return "diving.import.warning.unsupported_field_ignored"
        case .normalizedForStorage: return "diving.import.warning.unsupported_field_ignored"
        }
    }
}

struct DivingImportFingerprint: Hashable, Codable, Sendable {
    let startDateBucket: Date
    let durationSeconds: Int
    let maxDepthCentimeters: Int
    let sampleCount: Int
    let sourceDiveID: String?
    let sourceComputerModel: String?
}

struct DivingImportCandidate: Identifiable, Hashable, Sendable {
    let id: UUID
    let sourceFormat: DivingImportSourceFormat
    let sourceFileName: String
    let sourceDiveID: String?
    let sourceComputerModel: String?
    let originalDiveNumber: Int?
    let session: DiveSession
    let warnings: [DivingImportWarning]
    let fingerprint: DivingImportFingerprint
    let isImportable: Bool
}

struct DivingImportPreviewResult: Sendable {
    let source: DivingImportSource
    let candidates: [DivingImportCandidate]
    let parseWarnings: [String]
    let skippedCount: Int
}

struct DivingImportCommitReport: Sendable {
    let importedCount: Int
    let skippedDuplicateCount: Int
    let failedCount: Int
    let warningsCount: Int
    let importedSessionIDs: [UUID]
}

enum DivingImportDuplicateStatus: Hashable, Sendable {
    case new
    case exactDuplicate(existingID: UUID)
    case likelyDuplicate(existingID: UUID, reason: String)
}

enum DivingImportDuplicatePolicy: Sendable {
    case skipDuplicates
    case importAnyway
}

enum DivingImportError: LocalizedError, Equatable, Sendable {
    case unreadableFile
    case unsupportedFormat
    case fileTooLarge
    case emptyImport
    case malformedFile(String)
    case validationFailed(String)

    var errorDescription: String? {
        switch self {
        case .unreadableFile:
            return DIRIOSLocalizer.string("diving.import.error.unreadable")
        case .unsupportedFormat:
            return DIRIOSLocalizer.string("diving.import.error.unsupported_format")
        case .fileTooLarge:
            return DIRIOSLocalizer.string("diving.import.error.file_too_large")
        case .emptyImport:
            return DIRIOSLocalizer.string("diving.import.error.empty")
        case .malformedFile(let detail):
            return detail
        case .validationFailed(let detail):
            return detail
        }
    }
}

enum DivingImportLimits {
    static let maxCandidatesPerFile = 500
    static let maxImportedNotesLength = 4_000
    static let startDateToleranceSeconds: TimeInterval = 60
    static let durationToleranceSeconds: TimeInterval = 30
    static let maxDepthToleranceMeters: Double = 0.5
}

extension DivingImportFingerprint {
    static func make(
        from session: DiveSession,
        sourceDiveID: String?,
        sourceComputerModel: String?
    ) -> DivingImportFingerprint {
        let calendar = Calendar.current
        let bucket = calendar.date(
            from: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: session.startDate)
        ) ?? session.startDate
        return DivingImportFingerprint(
            startDateBucket: bucket,
            durationSeconds: Int(session.durationSeconds.rounded()),
            maxDepthCentimeters: Int((session.maxDepthMeters * 100).rounded()),
            sampleCount: session.samples.count,
            sourceDiveID: sourceDiveID,
            sourceComputerModel: sourceComputerModel
        )
    }
}

extension DivingImportCandidate {
    static func build(
        sourceFormat: DivingImportSourceFormat,
        sourceFileName: String,
        session: DiveSession,
        sourceDiveID: String? = nil,
        sourceComputerModel: String? = nil,
        originalDiveNumber: Int? = nil,
        warnings: [DivingImportWarning] = [],
        allowEmptySamples: Bool = false
    ) -> DivingImportCandidate? {
        let normalized = try? DiveSessionAlgorithmValidator.normalizedForStorage(
            session,
            allowEmptySamples: allowEmptySamples,
            maxDepthMeters: IOSAlgorithmConfiguration.maxImportExportDepthMeters
        )
        let importable = normalized != nil && (!session.samples.isEmpty || allowEmptySamples)
        let storedSession = normalized ?? session
        return DivingImportCandidate(
            id: UUID(),
            sourceFormat: sourceFormat,
            sourceFileName: sourceFileName,
            sourceDiveID: sourceDiveID,
            sourceComputerModel: sourceComputerModel,
            originalDiveNumber: originalDiveNumber,
            session: storedSession,
            warnings: warnings,
            fingerprint: DivingImportFingerprint.make(
                from: storedSession,
                sourceDiveID: sourceDiveID,
                sourceComputerModel: sourceComputerModel
            ),
            isImportable: importable
        )
    }
}

enum DivingImportNotesBuilder {
    static func appendImportMetadata(
        to session: DiveSession,
        format: DivingImportSourceFormat,
        fileName: String,
        computerModel: String?,
        sourceDiveID: String?,
        warnings: [DivingImportWarning]
    ) -> DiveSession {
        var updated = session
        var lines: [String] = []
        switch format {
        case .dirDivingCSV, .subsurfaceCSV:
            lines.append("Imported log · CSV")
        case .subsurfaceXML:
            lines.append("Imported log · Subsurface XML")
        case .uddf:
            lines.append("Imported log · UDDF")
        case .unknown:
            lines.append("Imported log")
        }
        lines.append("Source file: \(fileName)")
        if let computerModel, !computerModel.isEmpty {
            lines.append("Computer: \(computerModel)")
        }
        if let sourceDiveID, !sourceDiveID.isEmpty {
            lines.append("Original dive ID: \(sourceDiveID)")
        }
        if !warnings.isEmpty {
            let warningKeys = warnings.map { DIRIOSLocalizer.string($0.localizationKey) }
            lines.append("Import warnings: \(warningKeys.joined(separator: ", "))")
        }
        let block = lines.joined(separator: "\n")
        if let existing = updated.notes, !existing.isEmpty {
            updated.notes = String((existing + "\n\n" + block).prefix(DivingImportLimits.maxImportedNotesLength))
        } else {
            updated.notes = String(block.prefix(DivingImportLimits.maxImportedNotesLength))
        }
        return updated
    }
}
