import Foundation

enum SubsurfaceExportService {
    static func makeCSV(for session: DiveSession) -> String {
        var rows = ["time_seconds,depth_m,temperature_c,entry_lat,entry_lon,exit_lat,exit_lon"]
        let samples = exportableSamples(for: session)
        guard let firstTimestamp = samples.first?.timestamp else { return rows.joined(separator: "\n") }
        for sample in samples {
            let seconds = max(0, Int(sample.timestamp.timeIntervalSince(firstTimestamp)))
            let temp = sample.temperatureCelsius.map { String(format: "%.1f", $0) } ?? ""
            let entryLat = session.entryGPS.map { String(format: "%.6f", $0.latitude) } ?? ""
            let entryLon = session.entryGPS.map { String(format: "%.6f", $0.longitude) } ?? ""
            let exitLat = session.exitGPS.map { String(format: "%.6f", $0.latitude) } ?? ""
            let exitLon = session.exitGPS.map { String(format: "%.6f", $0.longitude) } ?? ""
            rows.append("\(seconds),\(String(format: "%.2f", sample.depthMeters)),\(temp),\(entryLat),\(entryLon),\(exitLat),\(exitLon)")
        }
        return rows.joined(separator: "\n")
    }

    // F3: Watch export now matches iOS hardening:
    //  - file written with `.atomic` + `.completeFileProtection`
    //  - filename uses an opaque UUID instead of the dive start date
    //  - stale exports cleaned up after 24 h
    // CSV business format (column order + headers) is intentionally unchanged.
    static func writeCSV(for session: DiveSession) -> URL? {
        guard !exportableSamples(for: session).isEmpty else { return nil }
        let csv = makeCSV(for: session)
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
