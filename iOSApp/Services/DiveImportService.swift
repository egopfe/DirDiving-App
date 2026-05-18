import Foundation
import CryptoKit

enum DiveImportService {
    enum ImportError: LocalizedError {
        case unreadableFile
        case missingColumns
        case emptyProfile
        case invalidRows(Int)

        var errorDescription: String? {
            switch self {
            case .unreadableFile: return "File import non leggibile."
            case .missingColumns: return "CSV non compatibile: colonne richieste mancanti."
            case .emptyProfile: return "CSV senza campioni immersione."
            case .invalidRows(let count): return "CSV non valido: \(count) righe con data, durata, profondita o temperatura non valide."
            }
        }
    }

    static func importCSV(from url: URL) -> Result<DiveSession, ImportError> {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess { url.stopAccessingSecurityScopedResource() }
        }

        guard let contents = try? String(contentsOf: url, encoding: .utf8) else {
            return .failure(.unreadableFile)
        }

        let rows = contents
            .split(whereSeparator: \.isNewline)
            .map { $0.split(separator: ",", omittingEmptySubsequences: false).map(String.init) }
        guard let header = rows.first else { return .failure(.emptyProfile) }

        func index(_ name: String) -> Int? { header.firstIndex(of: name) }
        guard
            let timeIndex = index("time_seconds"),
            let depthIndex = index("depth_m"),
            let tempIndex = index("temperature_c")
        else {
            return .failure(.missingColumns)
        }

        let start = sourceStartDate(header: header, rows: Array(rows.dropFirst()), url: url)
        var samples: [DiveSample] = []
        var entryGPS: GPSPoint?
        var exitGPS: GPSPoint?
        var invalidRowCount = 0

        for row in rows.dropFirst() {
            guard row.contains(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else { continue }
            guard row.count > max(timeIndex, depthIndex, tempIndex),
                  let seconds = TimeInterval(row[timeIndex]),
                  seconds >= 0,
                  let depth = Double(row[depthIndex]),
                  depth >= 0 else {
                invalidRowCount += 1
                continue
            }
            let temperature: Double?
            if row[tempIndex].isEmpty {
                temperature = nil
            } else if let parsedTemperature = Double(row[tempIndex]) {
                temperature = parsedTemperature
            } else {
                invalidRowCount += 1
                continue
            }
            samples.append(DiveSample(timestamp: start.addingTimeInterval(seconds), depthMeters: max(0, depth), temperatureCelsius: temperature))

            if entryGPS == nil,
               let latIndex = index("entry_lat"), let lonIndex = index("entry_lon"),
               row.count > max(latIndex, lonIndex),
               let lat = Double(row[latIndex]), let lon = Double(row[lonIndex]) {
                entryGPS = GPSPoint(latitude: lat, longitude: lon, horizontalAccuracy: -1, timestamp: start)
            }
            if exitGPS == nil,
               let latIndex = index("exit_lat"), let lonIndex = index("exit_lon"),
               row.count > max(latIndex, lonIndex),
               let lat = Double(row[latIndex]), let lon = Double(row[lonIndex]) {
                exitGPS = GPSPoint(latitude: lat, longitude: lon, horizontalAccuracy: -1, timestamp: start.addingTimeInterval(seconds))
            }
        }

        guard invalidRowCount == 0 else { return .failure(.invalidRows(invalidRowCount)) }
        guard !samples.isEmpty else { return .failure(.emptyProfile) }
        let end = samples.last?.timestamp ?? start
        let depths = samples.map(\.depthMeters)
        let temps = samples.compactMap(\.temperatureCelsius)
        let avgDepth = depths.reduce(0, +) / Double(depths.count)
        let session = DiveSession(
            id: importID(contents: contents),
            startDate: start,
            endDate: end,
            durationSeconds: end.timeIntervalSince(start),
            maxDepthMeters: depths.max() ?? 0,
            avgDepthMeters: avgDepth,
            avgWaterTemperatureCelsius: temps.isEmpty ? nil : temps.reduce(0, +) / Double(temps.count),
            ttv: avgDepth + end.timeIntervalSince(start) / 60,
            entryGPS: entryGPS,
            exitGPS: exitGPS,
            samples: samples,
            siteName: url.deletingPathExtension().lastPathComponent,
            notes: "Imported CSV · source date preserved when present, otherwise file date fallback",
            gasLabel: .oc
        )
        return .success(session)
    }

    private static func sourceStartDate(header: [String], rows: [[String]], url: URL) -> Date {
        let candidates = ["start_date", "start_iso8601", "date", "datetime", "timestamp"]
        for column in candidates {
            guard let columnIndex = header.firstIndex(of: column) else { continue }
            for row in rows where row.count > columnIndex {
                if let parsed = parseDate(row[columnIndex]) {
                    return parsed
                }
            }
        }
        if let values = try? url.resourceValues(forKeys: [.contentModificationDateKey]),
           let fileDate = values.contentModificationDate {
            return fileDate
        }
        return Date()
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
}
