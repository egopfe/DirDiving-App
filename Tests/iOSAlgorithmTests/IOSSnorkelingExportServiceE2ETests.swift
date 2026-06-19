import XCTest

@MainActor
final class IOSSnorkelingExportServiceE2ETests: XCTestCase {
    override func tearDown() {
        for url in FileManager.default.temporaryDirectory.contents().filter({ $0.pathExtension == "pdf" || $0.pathExtension == "csv" || $0.pathExtension == "json" || $0.pathExtension == "gpx" }) {
            try? FileManager.default.removeItem(at: url)
        }
        super.tearDown()
    }

    func testExportPDFCSVJSONGPXEndToEnd() throws {
        var session = makeSession()
        session.trackPoints = [
            surface(seconds: 0, lat: 44.1, lon: 8.9),
            surface(seconds: 30, lat: 44.11, lon: 8.91),
        ]
        var dip = session.dips[0]
        dip.samples = [
            SnorkelingDipSample(monotonicRelativeTimestampSeconds: 0, depthMeters: 3, temperatureCelsius: 22, verticalSpeedMetersPerSecond: 0, depthQuality: .measured)
        ]
        session.dips = [dip]
        let options = SnorkelingExportPrivacyOptions(
            locationPrecision: .exact,
            includeBuddyContactDetails: false,
            includeEmergencyContact: false,
            includeGroupContacts: false,
            locationSharingAcknowledged: true
        )

        let pdfURL = try IOSSnorkelingSessionExportService.export(session: session, format: .pdf, options: options)
        XCTAssertTrue(FileManager.default.fileExists(atPath: pdfURL.path))
        XCTAssertTrue(pdfURL.lastPathComponent.hasSuffix(".pdf"))

        let csvURL = try IOSSnorkelingSessionExportService.export(session: session, format: .csv, options: options)
        XCTAssertGreaterThan(try Data(contentsOf: csvURL).count, 10)

        let jsonURL = try IOSSnorkelingSessionExportService.export(session: session, format: .json, options: options)
        XCTAssertGreaterThan(try Data(contentsOf: jsonURL).count, 10)

        let gpxURL = try IOSSnorkelingSessionExportService.export(session: session, format: .gpx, options: options)
        let gpx = try String(contentsOf: gpxURL, encoding: .utf8)
        XCTAssertTrue(gpx.contains("<gpx"))
    }

    func testExportGPXBlockedWithoutAcknowledgement() {
        var session = makeSession()
        session.trackPoints = [surface(seconds: 0, lat: 44.1, lon: 8.9), surface(seconds: 30, lat: 44.11, lon: 8.91)]
        let options = SnorkelingExportPrivacyOptions(
            locationPrecision: .exact,
            includeBuddyContactDetails: false,
            includeEmergencyContact: false,
            includeGroupContacts: false,
            locationSharingAcknowledged: false
        )
        XCTAssertThrowsError(
            try IOSSnorkelingSessionExportService.export(session: session, format: .gpx, options: options)
        ) { error in
            XCTAssertEqual(error as? IOSSnorkelingSessionExportError, .privacyConfirmationRequired)
        }
    }

    private func makeSession() -> SnorkelingSession {
        var session = SnorkelingSession(
            startMode: .watch,
            state: .completed,
            dips: [SnorkelingDip(startedAtMonotonicSeconds: 0, durationSeconds: 60, maxDepthMeters: 5, averageDepthMeters: 4)]
        )
        session.statistics = session.refreshedStatistics()
        return session
    }

    private func surface(seconds: TimeInterval, lat: Double, lon: Double) -> SnorkelingTrackPoint {
        SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: seconds, latitude: lat, longitude: lon, gpsQuality: .measured, isUnderwater: false)
    }
}

private extension URL {
    func contents() -> [URL] {
        (try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil)) ?? []
    }
}
