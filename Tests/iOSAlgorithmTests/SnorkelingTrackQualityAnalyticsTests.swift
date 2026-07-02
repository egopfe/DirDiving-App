import XCTest

final class SnorkelingTrackQualityAnalyticsTests: XCTestCase {
    func testTrackQualityCountsMeasuredStaleAndUnavailable() {
        var session = SnorkelingSession(startMode: .watch, state: .completed)
        session.trackPoints = [
            trackPoint(seconds: 0, quality: .measured),
            trackPoint(seconds: 5, quality: .stale),
            trackPoint(seconds: 10, quality: .unavailable),
        ]
        let analytics = SnorkelingTrackQualityAnalyticsPolicy.make(session: session)
        XCTAssertEqual(analytics.totalPoints, 3)
        XCTAssertEqual(analytics.measuredPoints, 1)
        XCTAssertEqual(analytics.stalePoints, 1)
        XCTAssertEqual(analytics.unavailablePoints, 1)
        XCTAssertEqual(analytics.measuredPercentage, 33.33, accuracy: 0.5)
    }

    func testTrackQualityDetectsGPSGaps() {
        var session = SnorkelingSession(startMode: .watch, state: .completed)
        session.trackPoints = [
            trackPoint(seconds: 0, quality: .measured),
            trackPoint(seconds: 10, quality: .measured),
            trackPoint(seconds: 120, quality: .measured),
        ]
        let analytics = SnorkelingTrackQualityAnalyticsPolicy.make(session: session)
        XCTAssertEqual(analytics.gpsGaps, 1)
        XCTAssertEqual(analytics.longestGapSeconds ?? 0, 110, accuracy: 0.1)
    }

    func testEmptyTrackUsesUnavailableQualityKey() {
        let session = SnorkelingSession(startMode: .watch, state: .completed)
        let analytics = SnorkelingTrackQualityAnalyticsPolicy.make(session: session)
        XCTAssertEqual(analytics.totalPoints, 0)
        XCTAssertEqual(analytics.qualityKey, "snorkeling.logbook.track_quality.unavailable")
    }

    private func trackPoint(seconds: TimeInterval, quality: SnorkelingGPSQuality) -> SnorkelingTrackPoint {
        SnorkelingTrackPoint(
            monotonicRelativeTimestampSeconds: seconds,
            wallClockTimestamp: Date(timeIntervalSince1970: 1_700_000_000 + seconds),
            latitude: 44.10,
            longitude: 8.90,
            horizontalAccuracyMeters: 12,
            gpsQuality: quality,
            isUnderwater: false
        )
    }
}
