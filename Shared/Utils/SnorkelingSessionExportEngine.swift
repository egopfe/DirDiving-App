import Foundation

struct SnorkelingExportDocument: Equatable, Sendable {
    var filename: String
    var mimeType: String
    var data: Data
}

enum SnorkelingSessionExportEngine {
    static func buildCSV(
        for session: SnorkelingSession,
        options: SnorkelingExportPrivacyOptions = .redacted
    ) -> SnorkelingExportDocument? {
        let redacted = SnorkelingExportPrivacyPolicy.redactedSession(session, options: options)
        var rows = ["session_id,dip_index,sample_offset_s,depth_m,temperature_c,vertical_speed_mps,depth_quality"]
        for (dipIndex, dip) in redacted.dips.enumerated() {
            for sample in SnorkelingDomainSupport.normalizedDipSamples(dip.samples) {
                let temp = sample.temperatureCelsius.map { String(format: "%.1f", $0) } ?? ""
                rows.append(
                    [
                        csvField(redacted.id.uuidString),
                        String(dipIndex),
                        String(format: "%.2f", sample.monotonicRelativeTimestampSeconds),
                        String(format: "%.2f", sample.depthMeters),
                        temp,
                        String(format: "%.2f", sample.verticalSpeedMetersPerSecond),
                        csvField(sample.depthQuality.rawValue),
                    ].joined(separator: ",")
                )
            }
        }
        guard rows.count > 1, let data = rows.joined(separator: "\n").data(using: .utf8) else {
            return nil
        }
        return SnorkelingExportDocument(
            filename: SnorkelingExportFileNaming.filename(for: session, format: .csv),
            mimeType: "text/csv",
            data: data
        )
    }

    static func buildJSON(
        for session: SnorkelingSession,
        options: SnorkelingExportPrivacyOptions = .redacted
    ) throws -> SnorkelingExportDocument {
        let redacted = SnorkelingExportPrivacyPolicy.redactedSession(session, options: options)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let data = try encoder.encode(redacted)
        return SnorkelingExportDocument(
            filename: SnorkelingExportFileNaming.filename(for: session, format: .json),
            mimeType: "application/json",
            data: data
        )
    }

    static func buildGPX(
        for session: SnorkelingSession,
        options: SnorkelingExportPrivacyOptions
    ) -> SnorkelingExportDocument? {
        guard SnorkelingExportPrivacyPolicy.canExportLocation(options: options, session: session) else {
            return nil
        }
        let redacted = SnorkelingExportPrivacyPolicy.redactedSession(session, options: options)
        let points = SnorkelingExportPrivacyPolicy.measuredSurfacePoints(from: redacted)
            .sorted { $0.monotonicRelativeTimestampSeconds < $1.monotonicRelativeTimestampSeconds }
        guard points.count >= 2 else { return nil }

        let formatter = ISO8601DateFormatter()
        var body = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="DIR Diving Snorkeling">
          <trk>
            <name>Snorkeling surface track</name>
            <trkseg>
        """
        for point in points {
            guard let lat = point.latitude, let lon = point.longitude else { continue }
            let time = point.wallClockTimestamp ?? session.createdAt.addingTimeInterval(point.monotonicRelativeTimestampSeconds)
            body += """
              <trkpt lat="\(lat)" lon="\(lon)">
                <time>\(formatter.string(from: time))</time>
              </trkpt>
            """
        }
        body += """
            </trkseg>
          </trk>
        </gpx>
        """
        guard let data = body.data(using: .utf8) else { return nil }
        return SnorkelingExportDocument(
            filename: SnorkelingExportFileNaming.filename(for: session, format: .gpx),
            mimeType: "application/gpx+xml",
            data: data
        )
    }

    static func buildPDFLines(
        for session: SnorkelingSession,
        options: SnorkelingExportPrivacyOptions = .redacted
    ) -> [String] {
        let redacted = SnorkelingExportPrivacyPolicy.redactedSession(session, options: options)
        let stats = redacted.refreshedStatistics()
        var lines = [
            "DIR Diving Snorkeling Session",
            "Session ID: \(redacted.id.uuidString)",
            "Date: \(ISO8601DateFormatter().string(from: redacted.createdAt))",
            "Dips: \(stats.dipCount)",
            "Max depth: \(String(format: "%.1f m", stats.sessionMaxDepthMeters))",
            "Distance: \(String(format: "%.0f m", stats.totalDistanceMeters))",
            "Water time: \(String(format: "%.0f s", stats.totalDipSeconds))",
            "Duration: \(String(format: "%.0f s", stats.sessionDurationSeconds))",
        ]
        if let buddy = redacted.buddy?.name, !buddy.isEmpty {
            lines.append("Buddy: \(buddy)")
        }
        let surfaceCount = SnorkelingExportPrivacyPolicy.measuredSurfacePoints(from: redacted).count
        if surfaceCount > 0, options.locationPrecision != .removed {
            lines.append("Surface GPS points: \(surfaceCount) (\(options.locationPrecision.rawValue))")
        }
        if let equipment = redacted.equipment {
            if let mask = equipment.maskNotes, !mask.isEmpty { lines.append("Mask: \(mask)") }
            if let fins = equipment.finsNotes, !fins.isEmpty { lines.append("Fins: \(fins)") }
            if let suit = equipment.suitNotes, !suit.isEmpty { lines.append("Suit: \(suit)") }
        }
        lines.append("Generated for personal logbook use only.")
        return lines
    }

    static func buildChartSummaryText(for session: SnorkelingSession) -> String {
        let charts = SnorkelingSessionChartBuilder.build(from: session)
        guard charts.hasDepthData else { return "No chart data available." }
        let maxDepth = charts.depthPoints.map(\.depthMeters).max() ?? 0
        return "Snorkeling chart summary: \(charts.dipBars.count) dips, peak depth \(String(format: "%.1f m", maxDepth))."
    }

    private static func csvField(_ value: String) -> String {
        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        if escaped.contains(",") || escaped.contains("\"") || escaped.contains("\n") {
            return "\"\(escaped)\""
        }
        return escaped
    }
}
