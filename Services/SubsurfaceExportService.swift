import Foundation

// MARK: - Watch Subsurface CSV export
// Intentionally separate from `iOSApp/Services/SubsurfaceExportService.swift` (iOS target).
// Profile columns align with iOS; metadata intentionally slimmer (`# dirdiving_watch_export: 1` only).
// See Docs/WATCH_CSV_EXPORT_POLICY.md — Watch must not emit CCR or decompression-authoritative metadata.

enum SubsurfaceExportService {
    static func makeCSV(for session: DiveSession) -> String? {
        guard !session.samples.isEmpty else { return nil }
        let samples = exportableSamples(for: session)
        guard !samples.isEmpty, let firstTimestamp = samples.first?.timestamp else { return nil }

        var rows = ["time_seconds,depth_m,temperature_c,entry_lat,entry_lon,exit_lat,exit_lon,is_manual,equipment,entry_pressure,exit_pressure,deco_notes"]
        rows.append(contentsOf: metadataLines(for: session))
        let manualMeta = [
            session.isManual ? "1" : "0",
            "",
            "",
            "",
            ""
        ].joined(separator: ",")
        rows.append("# session_meta,\(manualMeta)")

        var previousSeconds = 0
        for sample in samples {
            let elapsed = sample.timestamp.timeIntervalSince(firstTimestamp)
            guard elapsed.isFinite, elapsed >= 0 else { return nil }
            let seconds = max(previousSeconds, Int(elapsed.rounded()))
            previousSeconds = seconds
            let temp = sample.temperatureCelsius.map { String(format: "%.1f", $0) } ?? ""
            let entryLat = session.entryGPS.map { String(format: "%.6f", $0.latitude) } ?? ""
            let entryLon = session.entryGPS.map { String(format: "%.6f", $0.longitude) } ?? ""
            let exitLat = session.exitGPS.map { String(format: "%.6f", $0.latitude) } ?? ""
            let exitLon = session.exitGPS.map { String(format: "%.6f", $0.longitude) } ?? ""
            let fields = [
                String(seconds),
                String(format: "%.2f", sample.depthMeters),
                temp,
                entryLat,
                entryLon,
                exitLat,
                exitLon,
                session.isManual ? "1" : "0",
                "",
                "",
                "",
                ""
            ].map(csvField)
            rows.append(fields.joined(separator: ","))
        }
        return rows.joined(separator: "\n")
    }

    static func writeCSV(for session: DiveSession) -> URL? {
        guard !exportableSamples(for: session).isEmpty else { return nil }
        guard let csv = makeCSV(for: session) else { return nil }
        cleanupTemporaryExports()
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("DIRDiving_Export_\(UUID().uuidString).csv")
        do {
            guard let data = csv.data(using: .utf8) else { return nil }
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            return url
        } catch {
            return nil
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
            "# dirdiving_watch_export: 1"
        ]
    }

    private static func csvField(_ value: String) -> String {
        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        if escaped.contains(",") || escaped.contains("\"") || escaped.contains("\n") || escaped.contains("\r") {
            return "\"\(escaped)\""
        }
        return escaped
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

    private static func exportableSamples(for session: DiveSession) -> [DiveSample] {
        DiveAlgorithm.sanitizedSamples(session.samples)
    }
}
