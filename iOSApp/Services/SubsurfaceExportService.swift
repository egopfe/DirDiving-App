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

    static func makeCSV(for session: DiveSession) -> Result<String, ExportError> {
        var rows = ["time_seconds,depth_m,temperature_c,entry_lat,entry_lon,exit_lat,exit_lon,gas_label"]
        let samples = exportableSamples(for: session)
        guard let first = samples.first?.timestamp else { return .failure(.emptySamples) }
        let entryGPS = DiveSessionAlgorithmValidator.validGPS(session.entryGPS) ? session.entryGPS : nil
        let exitGPS = DiveSessionAlgorithmValidator.validGPS(session.exitGPS) ? session.exitGPS : nil
        for sample in samples {
            let seconds = max(0, Int(sample.timestamp.timeIntervalSince(first)))
            let temp = sample.temperatureCelsius.map { String(format: "%.1f", $0) } ?? ""
            let entryLat = entryGPS.map { String(format: "%.6f", $0.latitude) } ?? ""
            let entryLon = entryGPS.map { String(format: "%.6f", $0.longitude) } ?? ""
            let exitLat = exitGPS.map { String(format: "%.6f", $0.latitude) } ?? ""
            let exitLon = exitGPS.map { String(format: "%.6f", $0.longitude) } ?? ""
            rows.append("\(seconds),\(String(format: "%.2f", sample.depthMeters)),\(temp),\(entryLat),\(entryLon),\(exitLat),\(exitLon),\(session.gasLabel.rawValue)")
        }
        return .success(rows.joined(separator: "\n"))
    }

    static func writeCSV(for session: DiveSession) -> Result<URL, ExportError> {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("DIRDiving_\(session.id.uuidString.prefix(8)).csv")
        do {
            let csv = try makeCSV(for: session).get()
            guard let data = csv.data(using: .utf8) else {
                return .failure(.writeFailed("UTF-8"))
            }
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            return .success(url)
        } catch let error as ExportError {
            return .failure(error)
        } catch {
            return .failure(.writeFailed(error.localizedDescription))
        }
    }

    private static func exportableSamples(for session: DiveSession) -> [DiveSample] {
        DiveProfileMath.sanitizedSamples(session.samples)
    }
}
