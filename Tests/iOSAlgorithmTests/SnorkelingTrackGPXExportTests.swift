import XCTest

final class SnorkelingTrackGPXExportTests: XCTestCase {
    func testGPXExportIsValidXMLAndExcludesInvalidCoordinates() {
        var session = SnorkelingSession(startMode: .watch, state: .completed, createdAt: Date())
        session.trackPoints = [
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 0, latitude: 44.4, longitude: 8.94, gpsQuality: .measured, isUnderwater: false),
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 5, latitude: 999, longitude: 8.941, gpsQuality: .measured, isUnderwater: false),
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 10, latitude: 44.401, longitude: 8.941, gpsQuality: .measured, isUnderwater: false)
        ]

        let document = SnorkelingTrackGPXExportService.buildDocument(
            for: session,
            options: SnorkelingExportPrivacyOptions(
                locationPrecision: .exact,
                includeBuddyContactDetails: false,
                includeEmergencyContact: false,
                includeGroupContacts: false,
                locationSharingAcknowledged: true
            )
        )
        let xml = String(data: try! XCTUnwrap(document?.data), encoding: .utf8)!

        XCTAssertTrue(xml.contains("<?xml version=\"1.0\""))
        XCTAssertTrue(xml.contains("<gpx"))
        XCTAssertTrue(xml.contains("lat=\"44.4\""))
        XCTAssertFalse(xml.contains("lat=\"999\""))
    }
}
