import Foundation

enum SubsurfaceExportService {
    enum ExportError: LocalizedError, Equatable {
        case emptySamples
        case writeFailed(String)

        var errorDescription: String? {
            switch self {
            case .emptySamples: return "Nessun campione da esportare."
            case .writeFailed(let reason): return "Export CSV non riuscito: \(reason)"
            }
        }
    }

    static func makeCSV(for session: DiveSession) -> String? {
        guard let normalized = try? DiveSessionAlgorithmValidator.normalizedForStorage(
            session,
            allowEmptySamples: false,
            maxDepthMeters: IOSAlgorithmConfiguration.maxImportExportDepthMeters
        ) else {
            return nil
        }
        let samples = DiveProfileMath.sanitizedSamples(
            normalized.samples,
            maxDepthMeters: IOSAlgorithmConfiguration.maxImportExportDepthMeters
        )
        guard let first = samples.first?.timestamp else { return nil }
        var rows = ["time_seconds,depth_m,temperature_c,entry_lat,entry_lon,exit_lat,exit_lon,is_manual,equipment,entry_pressure,exit_pressure,deco_notes"]
        rows.append(contentsOf: metadataLines(for: normalized))
        let manualMeta = [
            normalized.isManual ? "1" : "0",
            csvEscape(normalized.equipmentUsed ?? ""),
            csvEscape(normalized.entryPressureText ?? ""),
            csvEscape(normalized.exitPressureText ?? ""),
            csvEscape(normalized.decompressionNotes ?? "")
        ].joined(separator: ",")
        rows.append("# session_meta,\(manualMeta)")
        var previousSeconds = 0
        for sample in samples {
            let elapsed = sample.timestamp.timeIntervalSince(first)
            guard elapsed.isFinite, elapsed >= 0 else { return nil }
            let seconds = max(previousSeconds, Int(elapsed.rounded()))
            previousSeconds = seconds
            let temp = sample.temperatureCelsius.map { String(format: "%.1f", $0) } ?? ""
            let entryLat = normalized.entryGPS.map { String(format: "%.6f", $0.latitude) } ?? ""
            let entryLon = normalized.entryGPS.map { String(format: "%.6f", $0.longitude) } ?? ""
            let exitLat = normalized.exitGPS.map { String(format: "%.6f", $0.latitude) } ?? ""
            let exitLon = normalized.exitGPS.map { String(format: "%.6f", $0.longitude) } ?? ""
            rows.append("\(seconds),\(String(format: "%.2f", sample.depthMeters)),\(temp),\(entryLat),\(entryLon),\(exitLat),\(exitLon)")
        }
    }

    private static func metadataLines(for session: DiveSession) -> [String] {
        let formatter = ISO8601DateFormatter()
        return [
            "# session_meta",
            "# dirdiving_session_id: \(session.id.uuidString)",
            "# dirdiving_start_date: \(formatter.string(from: session.startDate))",
            "# dirdiving_end_date: \(formatter.string(from: session.endDate))",
            "# dirdiving_is_manual: \(session.isManual ? 1 : 0)",
            "# dirdiving_equipment: \(csvEscape(session.equipmentUsed ?? ""))",
            "# dirdiving_entry_pressure: \(csvEscape(session.entryPressureText ?? ""))",
            "# dirdiving_exit_pressure: \(csvEscape(session.exitPressureText ?? ""))",
            "# dirdiving_deco_notes: \(csvEscape(session.decompressionNotes ?? ""))",
            "# dirdiving_site_name: \(csvEscape(session.siteName ?? ""))",
            "# dirdiving_buddy: \(csvEscape(session.buddy ?? ""))",
            "# dirdiving_gas_label: \(session.gasLabel.rawValue)",
            "# dirdiving_sac: \(session.sacLitersMinute.map { String(format: "%.2f", $0) } ?? "")"
        ]
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
            guard let csv = makeCSV(for: session), let data = csv.data(using: .utf8) else {
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
