import Foundation

struct ApneaExportDocument: Equatable, Sendable {
    var filename: String
    var mimeType: String
    var data: Data
}

enum ApneaSessionExportEngine {
    static func buildCSV(
        for session: ApneaSession,
        options: ApneaExportPrivacyOptions = .redacted
    ) -> ApneaExportDocument? {
        let redacted = ApneaExportPrivacyPolicy.redactedSession(session, options: options)
        var rows = ["session_id,dive_index,sample_offset_s,depth_m,temperature_c,vertical_speed_mps,quality"]
        for (diveIndex, dive) in redacted.dives.enumerated() {
            for sample in dive.normalizedSamples() {
                let temp = sample.temperatureCelsius.map { String(format: "%.1f", $0) } ?? ""
                rows.append(
                    [
                        csvField(redacted.id.uuidString),
                        String(diveIndex),
                        String(format: "%.2f", sample.monotonicRelativeTimestampSeconds),
                        String(format: "%.2f", sample.depthMeters),
                        temp,
                        String(format: "%.2f", sample.verticalSpeedMetersPerSecond),
                        csvField(sample.quality.rawValue),
                    ].joined(separator: ",")
                )
            }
        }
        guard rows.count > 1, let data = rows.joined(separator: "\n").data(using: .utf8) else {
            return nil
        }
        return ApneaExportDocument(
            filename: ApneaExportFileNaming.filename(for: session, format: .csv),
            mimeType: "text/csv",
            data: data
        )
    }

    static func buildJSON(
        for session: ApneaSession,
        options: ApneaExportPrivacyOptions = .redacted
    ) throws -> ApneaExportDocument {
        let redacted = ApneaExportPrivacyPolicy.redactedSession(session, options: options)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let data = try encoder.encode(redacted)
        return ApneaExportDocument(
            filename: ApneaExportFileNaming.filename(for: session, format: .json),
            mimeType: "application/json",
            data: data
        )
    }

    static func buildGPX(
        for session: ApneaSession,
        options: ApneaExportPrivacyOptions
    ) -> ApneaExportDocument? {
        guard ApneaExportPrivacyPolicy.canExportLocation(options: options, session: session) else {
            return nil
        }
        let points = session.surfaceGPSPoints
            .filter { $0.latitude.isFinite && $0.longitude.isFinite }
            .sorted { $0.capturedAt < $1.capturedAt }
        guard points.count >= 2 else { return nil }

        let formatter = ISO8601DateFormatter()
        var body = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="DIR Diving Apnea">
          <trk>
            <name>Apnea surface track</name>
            <trkseg>
        """
        for point in points {
            body += """
              <trkpt lat="\(point.latitude)" lon="\(point.longitude)">
                <time>\(formatter.string(from: point.capturedAt))</time>
              </trkpt>
            """
        }
        body += """
            </trkseg>
          </trk>
        </gpx>
        """
        guard let data = body.data(using: .utf8) else { return nil }
        return ApneaExportDocument(
            filename: ApneaExportFileNaming.filename(for: session, format: .gpx),
            mimeType: "application/gpx+xml",
            data: data
        )
    }

    static func buildPDFLines(
        for session: ApneaSession,
        options: ApneaExportPrivacyOptions = .redacted
    ) -> [String] {
        let redacted = ApneaExportPrivacyPolicy.redactedSession(session, options: options)
        let stats = redacted.refreshedStatistics()
        var lines = [
            "DIR Diving Apnea Session",
            "Session ID: \(redacted.id.uuidString)",
            "Date: \(ISO8601DateFormatter().string(from: redacted.createdAt))",
            "Dives: \(stats.diveCount)",
            "Max depth: \(String(format: "%.1f m", stats.sessionMaxDepthMeters))",
            "Total underwater: \(String(format: "%.0f s", stats.totalUnderwaterSeconds))",
            "Total recovery: \(String(format: "%.0f s", stats.totalRecoverySeconds))",
        ]
        if let buddy = redacted.buddy?.name, !buddy.isEmpty {
            lines.append("Buddy: \(buddy)")
        }
        if !redacted.surfaceGPSPoints.isEmpty, options.includeSurfaceGPS {
            lines.append("Surface GPS points: \(redacted.surfaceGPSPoints.count)")
        }
        if let equipment = redacted.equipment {
            if let suit = equipment.suitNotes, !suit.isEmpty { lines.append("Suit: \(suit)") }
            if let lanyard = equipment.lanyardDescription, !lanyard.isEmpty { lines.append("Lanyard: \(lanyard)") }
        }
        lines.append("Generated for personal logbook use only.")
        return lines
    }

    static func buildChartSummaryText(for session: ApneaSession) -> String {
        let charts = ApneaSessionChartBuilder.build(from: session)
        guard charts.hasDepthData else { return "No chart data available." }
        let maxDepth = charts.depthPoints.map(\.depthMeters).max() ?? 0
        return "Apnea depth chart summary: \(charts.diveBars.count) dives, peak depth \(String(format: "%.1f m", maxDepth))."
    }

    private static func csvField(_ value: String) -> String {
        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        if escaped.contains(",") || escaped.contains("\"") || escaped.contains("\n") {
            return "\"\(escaped)\""
        }
        return escaped
    }
}
