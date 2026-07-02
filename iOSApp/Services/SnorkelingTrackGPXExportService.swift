import Foundation

enum SnorkelingTrackGPXExportService {
    static func buildDocument(
        for session: SnorkelingSession,
        options: SnorkelingExportPrivacyOptions
    ) -> SnorkelingExportDocument? {
        guard SnorkelingExportPrivacyPolicy.canExportLocation(options: options, session: session) else {
            return nil
        }
        let redacted = SnorkelingExportPrivacyPolicy.redactedSession(session, options: options)
        let points = SnorkelingExportPrivacyPolicy.measuredSurfacePoints(from: redacted)
            .filter { point in
                guard let lat = point.latitude, let lon = point.longitude else { return false }
                return SnorkelingDomainSupport.isValidCoordinate(latitude: lat, longitude: lon)
            }
            .sorted { $0.monotonicRelativeTimestampSeconds < $1.monotonicRelativeTimestampSeconds }
        guard points.count >= 2 else { return nil }

        let formatter = ISO8601DateFormatter()
        var body = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="DIR Diving Snorkeling" xmlns="http://www.topografix.com/GPX/1/1">
          <metadata>
            <name>Snorkeling Session</name>
            <time>\(formatter.string(from: session.createdAt))</time>
          </metadata>
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
        for marker in redacted.markers where marker.positionQuality == .measured {
            guard let lat = marker.latitude, let lon = marker.longitude,
                  SnorkelingDomainSupport.isValidCoordinate(latitude: lat, longitude: lon) else { continue }
            let time = marker.wallClockTimestamp ?? session.createdAt.addingTimeInterval(marker.monotonicRelativeTimestampSeconds)
            body += """
              <wpt lat="\(lat)" lon="\(lon)">
                <name>\(xmlEscaped(marker.category.rawValue))</name>
                <time>\(formatter.string(from: time))</time>
              </wpt>
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

    private static func xmlEscaped(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
