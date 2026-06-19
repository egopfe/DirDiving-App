import XCTest

final class IOSSnorkelingDashboardMapGapTests: XCTestCase {
    func testDashboardMapModelSegmentsGapsAtThreshold() {
        let points = [
            surface(seconds: 0, lat: 44.1, lon: 8.9),
            surface(seconds: 20, lat: 44.11, lon: 8.91),
            surface(seconds: 60, lat: 44.12, lon: 8.92),
        ]
        let session = SnorkelingSession(startMode: .watch, state: .completed, trackPoints: points)
        let model = SnorkelingSessionMapPresentation.make(from: session)
        XCTAssertTrue(model.isAvailable)
        XCTAssertEqual(model.gapCount, 1)
        XCTAssertEqual(model.segments.count, 2)
    }

    func testDashboardPresentationUsesGapAwareModel() {
        let points = [
            surface(seconds: 0, lat: 44.1, lon: 8.9),
            surface(seconds: 20, lat: 44.11, lon: 8.91),
            surface(seconds: 60, lat: 44.12, lon: 8.92),
        ]
        let session = SnorkelingSession(startMode: .watch, state: .completed, trackPoints: points)
        let presentation = IOSSnorkelingDashboardPresentationMapper.make(
            lastSession: session,
            sessions: [session],
            statistics: SnorkelingLogbookStatistics.aggregate(from: [session]),
            watchConnectivityText: "ok",
            watchConnectivityIsPositive: true,
            syncStatusText: "ok",
            syncStatusIsPositive: true
        )
        XCTAssertTrue(presentation.mapPreviewAvailable)
        XCTAssertEqual(presentation.mapPreviewModel?.gapCount, 1)
        XCTAssertEqual(presentation.mapPreviewModel?.segments.count, 2)
    }

    func testNoFalseBridgeAcrossGap() {
        let model = SnorkelingSessionMapPresentation.make(from: SnorkelingSession(
            startMode: .watch,
            state: .completed,
            trackPoints: [
                surface(seconds: 0, lat: 44.1, lon: 8.9),
                surface(seconds: 100, lat: 44.2, lon: 8.95),
            ]
        ))
        XCTAssertEqual(model.segments.count, 2)
        XCTAssertEqual(model.segments[0].coordinates.count, 1)
        XCTAssertEqual(model.segments[1].coordinates.count, 1)
    }

    private func surface(seconds: TimeInterval, lat: Double, lon: Double) -> SnorkelingTrackPoint {
        SnorkelingTrackPoint(
            monotonicRelativeTimestampSeconds: seconds,
            latitude: lat,
            longitude: lon,
            gpsQuality: .measured,
            isUnderwater: false
        )
    }
}
