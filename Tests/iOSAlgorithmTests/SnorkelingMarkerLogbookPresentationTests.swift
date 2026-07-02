import XCTest

final class SnorkelingMarkerLogbookPresentationTests: XCTestCase {
    func testCategoryCountsIgnoreEmptyCategories() {
        let markers = [
            SnorkelingMarker(category: .reef, monotonicRelativeTimestampSeconds: 10),
            SnorkelingMarker(category: .reef, monotonicRelativeTimestampSeconds: 20),
            SnorkelingMarker(category: .marineLife, monotonicRelativeTimestampSeconds: 30)
        ]
        let counts = SnorkelingMarkerLogbookPresentationPolicy.categoryCounts(markers: markers)
        XCTAssertEqual(counts.count, 2)
        XCTAssertEqual(counts.first(where: { $0.category == .reef })?.count, 2)
        XCTAssertEqual(counts.first(where: { $0.category == .marineLife })?.count, 1)
    }

    func testRowsIncludeDistanceFromEntryWhenAvailable() {
        let marker = SnorkelingMarker(
            category: .buoy,
            monotonicRelativeTimestampSeconds: 42,
            distanceFromEntryMeters: 88
        )
        let row = SnorkelingMarkerLogbookPresentationPolicy.makeRow(marker: marker)
        XCTAssertNotNil(row.distanceFromEntryText)
        XCTAssertTrue(row.distanceFromEntryText?.contains("88") == true)
    }

    func testRowIncludesPhotoReferenceWhenPresent() {
        let photoID = UUID()
        let marker = SnorkelingMarker(
            category: .photoSpot,
            monotonicRelativeTimestampSeconds: 10,
            photoReferenceID: photoID
        )
        let row = SnorkelingMarkerLogbookPresentationPolicy.makeRow(marker: marker)
        XCTAssertTrue(row.hasPhoto)
        XCTAssertEqual(row.photoAttachmentID, photoID)
    }
}
