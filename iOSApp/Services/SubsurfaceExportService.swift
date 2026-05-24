import Foundation

enum SubsurfaceExportService {
    enum ExportError: LocalizedError {
        case emptySamples
        case writeFailed(String)

        var errorDescription: String? {
            switch self {
            case .emptySamples: return "Nessun campione da esportare."
            case .writeFailed(let reason): return "Export CSV non riuscito: \(reason)"
            }
        }
    }

    static func makeCSV(for session: DiveSession) -> String {
        var rows = ["time_seconds,depth_m,temperature_c,entry_lat,entry_lon,exit_lat,exit_lon,is_manual,equipment,entry_pressure,exit_pressure,deco_notes"]
        let manualMeta = [
            session.isManual ? "1" : "0",
            csvEscape(session.equipmentUsed ?? ""),
            csvEscape(session.entryPressureText ?? ""),
            csvEscape(session.exitPressureText ?? ""),
            csvEscape(session.decompressionNotes ?? "")
        ].joined(separator: ",")
        rows.append("# session_meta,\(manualMeta)")
        guard let first = session.samples.first?.timestamp else { return rows.joined(separator: "\n") }
        for sample in session.samples {
            let seconds = Int(sample.timestamp.timeIntervalSince(first))
            let temp = sample.temperatureCelsius.map { String(format: "%.1f", $0) } ?? ""
            let entryLat = session.entryGPS.map { String(format: "%.6f", $0.latitude) } ?? ""
            let entryLon = session.entryGPS.map { String(format: "%.6f", $0.longitude) } ?? ""
            let exitLat = session.exitGPS.map { String(format: "%.6f", $0.latitude) } ?? ""
            let exitLon = session.exitGPS.map { String(format: "%.6f", $0.longitude) } ?? ""
            rows.append("\(seconds),\(String(format: "%.2f", sample.depthMeters)),\(temp),\(entryLat),\(entryLon),\(exitLat),\(exitLon)")
        }
        return rows.joined(separator: "\n")
    }

    private static func csvEscape(_ value: String) -> String {
        value.replacingOccurrences(of: "\"", with: "\"\"")
    }

    static func writeCSV(for session: DiveSession) -> Result<URL, ExportError> {
        guard !session.samples.isEmpty else { return .failure(.emptySamples) }
        cleanupTemporaryExports()
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("DIRDiving_Export_\(UUID().uuidString).csv")
        do {
            guard let data = makeCSV(for: session).data(using: .utf8) else {
                return .failure(.writeFailed("UTF-8"))
            }
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            return .success(url)
        } catch {
            return .failure(.writeFailed(error.localizedDescription))
        }
    }

    private static func cleanupTemporaryExports() {
        let directory = FileManager.default.temporaryDirectory
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else { return }

        let expiration = Date().addingTimeInterval(-86_400)
        for file in files where file.lastPathComponent.hasPrefix("DIRDiving_") && file.pathExtension == "csv" {
            let values = try? file.resourceValues(forKeys: [.contentModificationDateKey])
            if (values?.contentModificationDate ?? .distantPast) < expiration {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
}
