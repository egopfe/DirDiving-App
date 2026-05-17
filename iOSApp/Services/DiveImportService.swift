import Foundation

enum DiveImportService {
    enum ImportError: LocalizedError {
        case unreadableFile
        case missingColumns
        case emptyProfile

        var errorDescription: String? {
            switch self {
            case .unreadableFile: return "File import non leggibile."
            case .missingColumns: return "CSV non compatibile: colonne richieste mancanti."
            case .emptyProfile: return "CSV senza campioni immersione."
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

        let start = Date()
        var samples: [DiveSample] = []
        var entryGPS: GPSPoint?
        var exitGPS: GPSPoint?

        for row in rows.dropFirst() {
            guard row.count > max(timeIndex, depthIndex, tempIndex),
                  let seconds = TimeInterval(row[timeIndex]),
                  let depth = Double(row[depthIndex]) else { continue }
            let temperature = row[tempIndex].isEmpty ? nil : Double(row[tempIndex])
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
                exitGPS = GPSPoint(latitude: lat, longitude: lon, horizontalAccuracy: -1, timestamp: start)
            }
        }

        guard !samples.isEmpty else { return .failure(.emptyProfile) }
        let end = samples.last?.timestamp ?? start
        let depths = samples.map(\.depthMeters)
        let temps = samples.compactMap(\.temperatureCelsius)
        let avgDepth = depths.reduce(0, +) / Double(depths.count)
        let session = DiveSession(
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
            notes: "Imported CSV",
            gasLabel: .oc
        )
        return .success(session)
    }
}
