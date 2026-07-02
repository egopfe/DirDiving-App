import XCTest

final class SnorkelingTrackKMLExportTests: XCTestCase {
    func testKMLExportIsValidXMLAndExcludesInvalidCoordinates() {
        var session = SnorkelingSession(startMode: .watch, state: .completed, createdAt: Date())
        session.trackPoints = [
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 0, latitude: 44.4, longitude: 8.94, gpsQuality: .measured, isUnderwater: false),
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 5, latitude: 44.401, longitude: 8.941, gpsQuality: .measured, isUnderwater: false)
        ]

        let document = SnorkelingTrackKMLExportService.buildDocument(
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
        XCTAssertTrue(xml.contains("<kml"))
        XCTAssertTrue(xml.contains("8.94,44.4,0"))
        XCTAssertTrue(xml.contains("<LineString>"))
    }
}
