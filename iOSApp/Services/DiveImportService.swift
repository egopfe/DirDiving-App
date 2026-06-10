import Foundation
import CryptoKit

enum DiveImportService {
    struct ImportSummary {
        let session: DiveSession
        let skippedMalformedCount: Int
        let sourceDatePreserved: Bool

        func message(alreadyImported: Bool) -> String {
            let imported = alreadyImported ? 0 : 1
            let duplicates = alreadyImported ? 1 : 0
            let dateStatus = sourceDatePreserved
                ? DIRIOSLocalizer.string("import.summary.date_preserved")
                : DIRIOSLocalizer.string("import.summary.date_fallback")
            return String(
                format: DIRIOSLocalizer.string("import.summary.format"),
                imported,
                duplicates,
                skippedMalformedCount,
                dateStatus
            )
        }
    }

    enum ImportError: LocalizedError {
        case unreadableFile
        case missingColumns
        case emptyProfile
        case invalidRows(Int)
        case fileTooLarge

        var errorDescription: String? {
            switch self {
            case .unreadableFile: return DIRIOSLocalizer.string("import.error.unreadable")
            case .missingColumns: return DIRIOSLocalizer.string("import.error.missing_columns")
            case .emptyProfile: return DIRIOSLocalizer.string("import.error.empty_profile")
            case .invalidRows(let count):
                return String(
                    format: DIRIOSLocalizer.string("import.error.invalid_rows"),
                    count,
                    Int(IOSAlgorithmConfiguration.maxImportExportDepthMeters)
                )
            case .fileTooLarge: return DIRIOSLocalizer.formatted("import.error.file_too_large", Int(maxImportBytes / 1_048_576))
            }
        }
    }

    // F10: cap CSV files at 10 MB before loading them into memory, so a giant
    // user-selected file cannot OOM-crash the app. Bound chosen as a multiple of
    // realistic Subsurface exports (hundreds of KB per dive).
    static let maxImportBytes: Int = IOSAlgorithmConfiguration.maxImportBytes

    static func importCSV(from url: URL) -> Result<ImportSummary, ImportError> {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess { url.stopAccessingSecurityScopedResource() }
        }

        if let values = try? url.resourceValues(forKeys: [.fileSizeKey]),
           let size = values.fileSize, size > maxImportBytes {
            return .failure(.fileTooLarge)
        }

        guard let contents = try? String(contentsOf: url, encoding: .utf8) else {
            return .failure(.unreadableFile)
        }
        guard contents.utf8.count <= maxImportBytes else {
            return .failure(.fileTooLarge)
        }

        guard !contents.contains("\0") else {
            return .failure(.unreadableFile)
        }
        guard maxLineLength(in: contents) <= IOSAlgorithmConfiguration.maxImportCSVRowCharacters else {
            return .failure(.invalidRows(1))
        }
        guard let rows = parseCSV(contents) else {
            return .failure(.invalidRows(1))
        }
        guard let header = rows.first(where: { row in
            let normalized = row.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            return normalized.contains("time_seconds") && normalized.contains("depth_m")
        }) else {
            return .failure(.emptyProfile)
        }

        func index(_ name: String) -> Int? {
            header.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.firstIndex(of: name)
        }
        guard
            let timeIndex = index("time_seconds"),
            let depthIndex = index("depth_m")
        else {
            return .failure(.missingColumns)
        }
        let tempIndex = index("temperature_c")

        let metadata = parseMetadata(from: rows)
        let dataRows = rows.filter { !isMetadataOrCommentRow($0) && $0 != header }
        let sourceDate = sourceStartDate(
            header: header,
            rows: dataRows,
            metadata: metadata,
            url: url
        )
        let start = sourceDate.date
        var samples: [DiveSample] = []
        var entryGPS: GPSPoint?
        var exitGPS: GPSPoint?
        var invalidRowCount = 0

        for row in dataRows {
            guard row.contains(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else { continue }
            let normalizedRow = row.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            guard row.count > max(timeIndex, depthIndex),
                  let seconds = TimeInterval(normalizedRow[timeIndex]),
                  seconds.isFinite,
                  (0...IOSAlgorithmConfiguration.maxDiveDurationSeconds).contains(seconds),
                  let depth = Double(normalizedRow[depthIndex]),
                  DiveProfileMath.sanitizedDepthMeters(depth, maxDepthMeters: IOSAlgorithmConfiguration.maxImportExportDepthMeters) != nil else {
                invalidRowCount += 1
                continue
            }
            let temperature: Double?
            if let tempIndex {
                guard row.count > tempIndex else {
                    invalidRowCount += 1
                    continue
                }
                if normalizedRow[tempIndex].isEmpty {
                    temperature = nil
                } else if let parsedTemperature = Double(normalizedRow[tempIndex]),
                          let validTemperature = DiveProfileMath.sanitizedTemperatureCelsius(parsedTemperature) {
                    temperature = validTemperature
                } else {
                    invalidRowCount += 1
                    continue
                }
            } else {
                temperature = nil
            }
            samples.append(DiveSample(timestamp: start.addingTimeInterval(seconds), depthMeters: depth, temperatureCelsius: temperature))
            if samples.count > IOSAlgorithmConfiguration.maxProfileSampleCount {
                return .failure(.invalidRows(invalidRowCount + 1))
            }

            if entryGPS == nil,
               let latIndex = index("entry_lat"), let lonIndex = index("entry_lon"),
               row.count > max(latIndex, lonIndex),
               !normalizedRow[latIndex].isEmpty || !normalizedRow[lonIndex].isEmpty {
                if let lat = Double(normalizedRow[latIndex]), let lon = Double(normalizedRow[lonIndex]),
                   isValidGPS(latitude: lat, longitude: lon) {
                    entryGPS = GPSPoint(
                        latitude: lat,
                        longitude: lon,
                        horizontalAccuracy: IOSAlgorithmConfiguration.importedGPSHorizontalAccuracyMeters,
                        timestamp: start
                    )
                } else {
                    invalidRowCount += 1
                }
            }
            if exitGPS == nil,
               let latIndex = index("exit_lat"), let lonIndex = index("exit_lon"),
               row.count > max(latIndex, lonIndex),
               !normalizedRow[latIndex].isEmpty || !normalizedRow[lonIndex].isEmpty {
                if let lat = Double(normalizedRow[latIndex]), let lon = Double(normalizedRow[lonIndex]),
                   isValidGPS(latitude: lat, longitude: lon) {
                    exitGPS = GPSPoint(
                        latitude: lat,
                        longitude: lon,
                        horizontalAccuracy: IOSAlgorithmConfiguration.importedGPSHorizontalAccuracyMeters,
                        timestamp: start.addingTimeInterval(seconds)
                    )
                } else {
                    invalidRowCount += 1
                }
            }
        }

        let sortedSamples = DiveProfileMath.sanitizedSamples(
            samples,
            maxDepthMeters: IOSAlgorithmConfiguration.maxImportExportDepthMeters
        )
        guard !sortedSamples.isEmpty else { return .failure(.emptyProfile) }
        let end = metadata.endDate ?? sortedSamples.last?.timestamp ?? start
        let summary = DiveProfileMath.summary(
            samples: sortedSamples,
            startDate: start,
            endDate: end,
            maxDepthLimit: IOSAlgorithmConfiguration.maxImportExportDepthMeters
        )
        let sessionID = metadata.sessionID ?? importID(contents: contents)
        let importedSession = DiveSession(
            id: sessionID,
            startDate: start,
            endDate: end,
            durationSeconds: summary.durationSeconds,
            maxDepthMeters: summary.maxDepthMeters,
            avgDepthMeters: summary.averageDepthMeters,
            avgWaterTemperatureCelsius: summary.averageTemperatureCelsius,
            ttv: summary.ttv,
            entryGPS: entryGPS,
            exitGPS: exitGPS,
            entryGPSFixSource: entryGPS == nil ? .noFix : .fallback,
            exitGPSFixSource: exitGPS == nil ? .noFix : .fallback,
            samples: sortedSamples,
            siteName: metadata.siteName ?? url.deletingPathExtension().lastPathComponent,
            buddy: metadata.buddy,
            notes: metadata.sessionID == nil
                ? "Imported CSV · source date preserved when present, otherwise file date fallback"
                : "Imported CSV · DIRDiving metadata restored",
            gasLabel: metadata.gasLabel ?? .oc,
            sacLitersMinute: metadata.sacLitersMinute,
            isManual: metadata.isManual ?? false,
            equipmentUsed: metadata.equipmentUsed,
            entryPressureText: metadata.entryPressureText,
            exitPressureText: metadata.exitPressureText,
            decompressionNotes: metadata.decompressionNotes,
            ccrLogbookMetadata: metadata.ccrLogbookMetadata
        )
        guard let session = try? DiveSessionAlgorithmValidator.normalizedForStorage(
            importedSession,
            allowEmptySamples: false,
            maxDepthMeters: IOSAlgorithmConfiguration.maxImportExportDepthMeters
        ) else {
            return .failure(.invalidRows(invalidRowCount + 1))
        }
        return .success(ImportSummary(session: session, skippedMalformedCount: invalidRowCount, sourceDatePreserved: sourceDate.preserved))
    }

    private struct CSVSessionMetadata {
        var sessionID: UUID?
        var startDate: Date?
        var endDate: Date?
        var isManual: Bool?
        var equipmentUsed: String?
        var entryPressureText: String?
        var exitPressureText: String?
        var decompressionNotes: String?
        var siteName: String?
        var buddy: String?
        var gasLabel: DiveGasLabel?
        var sacLitersMinute: Double?
        var ccrLogbookMetadata: CCRLogbookMetadata?
    }

    private static func isMetadataOrCommentRow(_ row: [String]) -> Bool {
        guard let first = row.first?.trimmingCharacters(in: .whitespacesAndNewlines), !first.isEmpty else {
            return true
        }
        return first.hasPrefix("#")
    }

    private static func parseMetadata(from rows: [[String]]) -> CSVSessionMetadata {
        var metadata = CSVSessionMetadata()
        for row in rows {
            guard let first = row.first?.trimmingCharacters(in: .whitespacesAndNewlines), first.hasPrefix("#") else { continue }
            if first == "# session_meta", row.count >= 6 {
                if metadata.isManual == nil {
                    metadata.isManual = row[1].trimmingCharacters(in: .whitespacesAndNewlines) == "1"
                }
                if metadata.equipmentUsed == nil {
                    metadata.equipmentUsed = nonEmpty(row.count > 2 ? row[2] : nil)
                }
                if metadata.entryPressureText == nil {
                    metadata.entryPressureText = nonEmpty(row.count > 3 ? row[3] : nil)
                }
                if metadata.exitPressureText == nil {
                    metadata.exitPressureText = nonEmpty(row.count > 4 ? row[4] : nil)
                }
                if metadata.decompressionNotes == nil {
                    metadata.decompressionNotes = nonEmpty(row.count > 5 ? row[5] : nil)
                }
                continue
            }
            let line = row.joined(separator: ",").trimmingCharacters(in: .whitespacesAndNewlines)
            if line.hasPrefix("# dirdiving_") {
                applyDirdivingMetadataLine(line, to: &metadata)
            }
        }
        return metadata
    }

    private static func applyDirdivingMetadataLine(_ line: String, to metadata: inout CSVSessionMetadata) {
        let body = line.dropFirst(2)
        guard let colon = body.firstIndex(of: ":") else { return }
        let key = String(body[..<colon]).trimmingCharacters(in: .whitespacesAndNewlines)
        let value = String(body[body.index(after: colon)...]).trimmingCharacters(in: .whitespacesAndNewlines)
        switch key {
        case "dirdiving_session_id":
            metadata.sessionID = UUID(uuidString: value)
        case "dirdiving_start_date":
            metadata.startDate = parseDate(value)
        case "dirdiving_end_date":
            metadata.endDate = parseDate(value)
        case "dirdiving_is_manual":
            metadata.isManual = value == "1"
        case "dirdiving_equipment":
            metadata.equipmentUsed = nonEmpty(value)
        case "dirdiving_entry_pressure":
            metadata.entryPressureText = nonEmpty(value)
        case "dirdiving_exit_pressure":
            metadata.exitPressureText = nonEmpty(value)
        case "dirdiving_deco_notes":
            metadata.decompressionNotes = nonEmpty(value)
        case "dirdiving_site_name":
            metadata.siteName = nonEmpty(value)
        case "dirdiving_buddy":
            metadata.buddy = nonEmpty(value)
        case "dirdiving_gas_label":
            metadata.gasLabel = DiveGasLabel(rawValue: value)
        case "dirdiving_sac":
            metadata.sacLitersMinute = Double(value)
        case "dirdiving_ccr_rebreather_model":
            applyCCRMetadata(&metadata, mutate: { $0.rebreatherModel = value })
        case "dirdiving_ccr_low_setpoint":
            if let parsed = Double(value) {
                applyCCRMetadata(&metadata, mutate: { $0.lowSetpoint = parsed })
            }
        case "dirdiving_ccr_high_setpoint":
            if let parsed = Double(value) {
                applyCCRMetadata(&metadata, mutate: { $0.highSetpoint = parsed })
            }
        case "dirdiving_ccr_setpoint_switch_depth":
            if let parsed = Double(value) {
                applyCCRMetadata(&metadata, mutate: { $0.setpointSwitchDepthMeters = parsed })
            }
        case "dirdiving_ccr_diluent_label":
            applyCCRMetadata(&metadata, mutate: { $0.diluentLabel = value })
        case "dirdiving_ccr_bailout_labels":
            applyCCRMetadata(&metadata, mutate: {
                $0.bailoutLabels = value
                    .split(separator: "|")
                    .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            })
        case "dirdiving_ccr_scrubber_notes":
            applyCCRMetadata(&metadata, mutate: { $0.scrubberNotes = value })
        case "dirdiving_ccr_o2_sensor_notes":
            applyCCRMetadata(&metadata, mutate: { $0.oxygenSensorNotes = value })
        case "dirdiving_ccr_loop_notes":
            applyCCRMetadata(&metadata, mutate: { $0.loopNotes = value })
        case "dirdiving_ccr_bailout_scenario_notes":
            applyCCRMetadata(&metadata, mutate: { $0.bailoutScenarioNotes = value })
        default:
            break
        }
    }

    private static func applyCCRMetadata(
        _ metadata: inout CSVSessionMetadata,
        mutate: (inout CCRLogbookMetadata) -> Void
    ) {
        var ccr = metadata.ccrLogbookMetadata ?? CCRLogbookMetadata()
        mutate(&ccr)
        metadata.ccrLogbookMetadata = ccr
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func sourceStartDate(
        header: [String],
        rows: [[String]],
        metadata: CSVSessionMetadata,
        url: URL
    ) -> (date: Date, preserved: Bool) {
        if let startDate = metadata.startDate {
            return (startDate, true)
        }
        let normalizedHeader = header.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let candidates = ["start_date", "start_iso8601", "date", "datetime", "timestamp"]
        for column in candidates {
            guard let columnIndex = normalizedHeader.firstIndex(of: column) else { continue }
            for row in rows where row.count > columnIndex {
                if let parsed = parseDate(row[columnIndex]) {
                    return (parsed, true)
                }
            }
        }
        if let values = try? url.resourceValues(forKeys: [.contentModificationDateKey]),
           let fileDate = values.contentModificationDate {
            return (fileDate, false)
        }
        return (Date(), false)
    }

    private static func parseCSV(_ contents: String) -> [[String]]? {
        var rows: [[String]] = []
        var row: [String] = []
        var field = ""
        var inQuotes = false
        var iterator = contents.makeIterator()

        while let character = iterator.next() {
            if character == "\"" {
                if inQuotes {
                    if let next = iterator.next() {
                        if next == "\"" {
                            field.append("\"")
                        } else {
                            inQuotes = false
                            if next == "," {
                                row.append(field)
                                if row.count > IOSAlgorithmConfiguration.maxImportCSVColumns {
                                    return nil
                                }
                                field = ""
                            } else if next == "\n" {
                                row.append(field)
                                if row.count > IOSAlgorithmConfiguration.maxImportCSVColumns {
                                    return nil
                                }
                                rows.append(row)
                                row = []
                                field = ""
                            } else if next != "\r" {
                                field.append(next)
                            }
                        }
                    } else {
                        inQuotes = false
                    }
                } else {
                    inQuotes = true
                }
            } else if character == "," && !inQuotes {
                row.append(field)
                if row.count > IOSAlgorithmConfiguration.maxImportCSVColumns {
                    return nil
                }
                field = ""
            } else if character == "\n" && !inQuotes {
                row.append(field)
                if row.count > IOSAlgorithmConfiguration.maxImportCSVColumns {
                    return nil
                }
                if row.contains(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                    rows.append(row)
                }
                row = []
                field = ""
            } else if character != "\r" {
                field.append(character)
            }
            if field.count > IOSAlgorithmConfiguration.maxImportCSVFieldCharacters {
                return nil
            }
        }

        row.append(field)
        if row.count > IOSAlgorithmConfiguration.maxImportCSVColumns {
            return nil
        }
        if row.contains(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            rows.append(row)
        }
        if inQuotes {
            return nil
        }
        return rows
    }

    private static func maxLineLength(in contents: String) -> Int {
        var current = 0
        var longest = 0
        for scalar in contents.unicodeScalars {
            if scalar == "\n" {
                longest = max(longest, current)
                current = 0
            } else if scalar != "\r" {
                current += 1
            }
        }
        return max(longest, current)
    }

    private static func sourceStartDate(header: [String], rows: [[String]], url: URL) -> (date: Date, preserved: Bool) {
        sourceStartDate(header: header, rows: rows, metadata: CSVSessionMetadata(), url: url)
    }

    private static func parseDate(_ rawValue: String) -> Date? {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let date = ISO8601DateFormatter().date(from: trimmed) {
            return date
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        for format in ["yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd", "dd/MM/yyyy HH:mm:ss", "dd/MM/yyyy"] {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: trimmed) {
                return date
            }
        }
        return nil
    }

    private static func importID(contents: String) -> UUID {
        let digest = Array(SHA256.hash(data: Data(contents.utf8)))
        return UUID(uuid: (
            digest[0], digest[1], digest[2], digest[3],
            digest[4], digest[5],
            digest[6], digest[7],
            digest[8], digest[9],
            digest[10], digest[11], digest[12], digest[13], digest[14], digest[15]
        ))
    }

    private static func isValidGPS(latitude: Double, longitude: Double) -> Bool {
        DiveProfileMath.isValidGPS(
            GPSPoint(
                latitude: latitude,
                longitude: longitude,
                horizontalAccuracy: IOSAlgorithmConfiguration.importedGPSHorizontalAccuracyMeters,
                timestamp: Date()
            )
        )
    }
}

#if DEBUG
extension DiveImportService {
    static func testHook_parseCSV(_ contents: String) -> [[String]]? {
        parseCSV(contents)
    }
}
#endif
