import XCTest

final class SnorkelingLogbookTrackQualityPresentationTests: XCTestCase {
    func testMissingGPSDoesNotCrashAndShowsUnavailableTrackQuality() {
        let session = SnorkelingSession(
            startMode: .manual,
            state: .completed,
            trackPoints: [],
            markers: []
        )
        let presentation = SnorkelingLogbookDetailPresentationPolicy.make(session: session)
        XCTAssertEqual(presentation.trackQualityKey, "snorkeling.logbook.track_quality.unavailable")
        XCTAssertEqual(presentation.trackPointCount, 0)
        XCTAssertEqual(presentation.markerCount, 0)
    }

    func testMarkerCountDisplaysCorrectly() {
        let marker = SnorkelingMarker(
            category: .reef,
            monotonicRelativeTimestampSeconds: 12,
            latitude: 44.1,
            longitude: 8.2
        )
        let session = SnorkelingSession(
            startMode: .manual,
            state: .completed,
            markers: [marker]
        )
        XCTAssertEqual(
            SnorkelingLogbookDetailPresentationPolicy.make(session: session).markerCount,
            1
        )
    }

    func testGoodTrackQualityFromMeasuredPoints() {
        let points = (0..<10).map { index in
            SnorkelingTrackPoint(
                monotonicRelativeTimestampSeconds: Double(index),
                latitude: 44.1,
                longitude: 8.2,
                gpsQuality: .measured
            )
        }
        let session = SnorkelingSession(
            startMode: .manual,
            state: .completed,
            trackPoints: points
        )
        XCTAssertEqual(
            SnorkelingLogbookDetailPresentationPolicy.make(session: session).trackQualityKey,
            "snorkeling.logbook.track_quality.good"
        )
    }
}
