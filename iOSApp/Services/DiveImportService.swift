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
                ? String(localized: "import.summary.date_preserved")
                : String(localized: "import.summary.date_fallback")
            return String(
                format: String(localized: "import.summary.format"),
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
            case .unreadableFile: return String(localized: "import.error.unreadable")
            case .missingColumns: return String(localized: "import.error.missing_columns")
            case .emptyProfile: return String(localized: "import.error.empty_profile")
            case .invalidRows(let count): return String(format: String(localized: "import.error.invalid_rows"), count)
            case .fileTooLarge: return String(format: String(localized: "import.error.file_too_large"), Int(maxImportBytes / 1_048_576))
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

        let rows = parseCSV(contents)
        guard let header = rows.first else { return .failure(.emptyProfile) }

        func index(_ name: String) -> Int? { header.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.firstIndex(of: name) }
        guard
            let timeIndex = index("time_seconds"),
            let depthIndex = index("depth_m"),
            let tempIndex = index("temperature_c")
        else {
            return .failure(.missingColumns)
        }

        let sourceDate = sourceStartDate(header: header, rows: Array(rows.dropFirst()), url: url)
        let start = sourceDate.date
        var samples: [DiveSample] = []
        var entryGPS: GPSPoint?
        var exitGPS: GPSPoint?
        var invalidRowCount = 0

        for row in rows.dropFirst() {
            guard row.contains(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else { continue }
            let normalizedRow = row.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            guard row.count > max(timeIndex, depthIndex, tempIndex),
                  let seconds = TimeInterval(normalizedRow[timeIndex]),
                  seconds.isFinite,
                  (0...IOSAlgorithmConfiguration.maxDiveDurationSeconds).contains(seconds),
                  let depth = Double(normalizedRow[depthIndex]),
                  DiveProfileMath.sanitizedDepthMeters(depth, maxDepthMeters: IOSAlgorithmConfiguration.maxImportExportDepthMeters) != nil else {
                invalidRowCount += 1
                continue
            }
            let temperature: Double?
            if normalizedRow[tempIndex].isEmpty {
                temperature = nil
            } else if let parsedTemperature = Double(normalizedRow[tempIndex]),
                      let validTemperature = DiveProfileMath.sanitizedTemperatureCelsius(parsedTemperature) {
                temperature = validTemperature
            } else {
                invalidRowCount += 1
                continue
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
        let end = sortedSamples.last?.timestamp ?? start
        let summary = DiveProfileMath.summary(
            samples: sortedSamples,
            startDate: start,
            endDate: end,
            maxDepthLimit: IOSAlgorithmConfiguration.maxImportExportDepthMeters
        )
        let importedSession = DiveSession(
            id: importID(contents: contents),
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
            siteName: url.deletingPathExtension().lastPathComponent,
            notes: "Imported CSV · source date preserved when present, otherwise file date fallback",
            gasLabel: .oc
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

    private static func parseCSV(_ contents: String) -> [[String]] {
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
                                field = ""
                            } else if next == "\n" {
                                row.append(field)
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
                field = ""
            } else if character == "\n" && !inQuotes {
                row.append(field)
                if row.contains(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                    rows.append(row)
                }
                row = []
                field = ""
            } else if character != "\r" {
                field.append(character)
            }
        }

        row.append(field)
        if row.contains(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            rows.append(row)
        }
        return rows
    }

    private static func sourceStartDate(header: [String], rows: [[String]], url: URL) -> (date: Date, preserved: Bool) {
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
