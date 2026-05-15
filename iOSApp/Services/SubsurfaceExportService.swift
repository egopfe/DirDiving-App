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
        var rows = ["time_seconds,depth_m,temperature_c,entry_lat,entry_lon,exit_lat,exit_lon"]
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

    static func writeCSV(for session: DiveSession) -> Result<URL, ExportError> {
        guard !session.samples.isEmpty else { return .failure(.emptySamples) }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("DIRDiving_\(session.id.uuidString.prefix(8)).csv")
        do {
            guard let data = makeCSV(for: session).data(using: .utf8) else {
                return .failure(.writeFailed("UTF-8"))
            }
            try data.write(to: url, options: .atomic)
            return .success(url)
        } catch {
            return .failure(.writeFailed(error.localizedDescription))
        }
    }
}
