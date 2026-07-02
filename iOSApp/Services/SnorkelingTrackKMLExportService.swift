import Foundation

enum SnorkelingTrackKMLExportService {
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

        let coordinates = points.compactMap { point -> String? in
            guard let lat = point.latitude, let lon = point.longitude else { return nil }
            return "\(lon),\(lat),0"
        }.joined(separator: " ")

        var placemarks = ""
        for marker in redacted.markers where marker.positionQuality == .measured {
            guard let lat = marker.latitude, let lon = marker.longitude,
                  SnorkelingDomainSupport.isValidCoordinate(latitude: lat, longitude: lon) else { continue }
            placemarks += """
              <Placemark>
                <name>\(xmlEscaped(marker.category.rawValue))</name>
                <Point><coordinates>\(lon),\(lat),0</coordinates></Point>
              </Placemark>
            """
        }

        let body = """
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2">
          <Document>
            <name>Snorkeling Session</name>
            <Placemark>
              <name>Surface track</name>
              <LineString>
                <tessellate>1</tessellate>
                <coordinates>\(coordinates)</coordinates>
              </LineString>
            </Placemark>
            \(placemarks)
          </Document>
        </kml>
        """
        guard let data = body.data(using: .utf8) else { return nil }
        return SnorkelingExportDocument(
            filename: SnorkelingExportFileNaming.filename(for: session, format: .kml),
            mimeType: "application/vnd.google-earth.kml+xml",
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
