import XCTest

final class SnorkelingPhotoMarkerIntegrationTests: XCTestCase {
    func testMarkerPhotoReferenceEncodesInSessionJSON() throws {
        let photoID = UUID()
        let marker = SnorkelingMarker(
            category: .photoSpot,
            monotonicRelativeTimestampSeconds: 12,
            photoReferenceID: photoID
        )
        var session = SnorkelingSession(startMode: .watch, state: .completed)
        session.markers = [marker]

        let data = try JSONEncoder().encode(session)
        let decoded = try JSONDecoder().decode(SnorkelingSession.self, from: data)
        XCTAssertEqual(decoded.markers.first?.photoReferenceID, photoID)
    }

    func testPhotoAttachmentMappingUsesMarkerID() {
        let sessionID = UUID()
        let markerID = UUID()
        let attachmentID = UUID()
        let attachments = [
            SnorkelingSessionPhotoAttachment(
                id: attachmentID,
                sessionID: sessionID,
                markerID: markerID,
                localFilename: "photo.jpg"
            )
        ]
        let map = SnorkelingMarkerLogbookPresentationPolicy.photoAttachmentIDs(
            for: sessionID,
            attachments: attachments
        )
        XCTAssertEqual(map[markerID], attachmentID)
    }

    func testLogbookRowReflectsPhotoAttachment() {
        let marker = SnorkelingMarker(
            id: UUID(),
            category: .reef,
            monotonicRelativeTimestampSeconds: 5,
            photoReferenceID: UUID()
        )
        let row = SnorkelingMarkerLogbookPresentationPolicy.makeRow(marker: marker)
        XCTAssertTrue(row.hasPhoto)
        XCTAssertNotNil(row.photoAttachmentID)
    }
}
