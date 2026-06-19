import XCTest

final class SnorkelingDistanceConsistencyTests: XCTestCase {
    func testLivePersistedAndStatisticsDistanceMatchWithinTolerance() throws {
        let points = [
            SnorkelingTrackPoint(
                monotonicRelativeTimestampSeconds: 0,
                latitude: 44.405,
                longitude: 8.946,
                gpsQuality: .measured,
                depthMeters: 0,
                isUnderwater: false
            ),
            SnorkelingTrackPoint(
                monotonicRelativeTimestampSeconds: 10,
                latitude: 44.40505,
                longitude: 8.94605,
                gpsQuality: .measured,
                depthMeters: 0,
                isUnderwater: false
            ),
            SnorkelingTrackPoint(
                monotonicRelativeTimestampSeconds: 20,
                latitude: 44.40510,
                longitude: 8.94610,
                gpsQuality: .measured,
                depthMeters: 1.2,
                isUnderwater: true
            )
        ]

        let liveDistance = SnorkelingDomainSupport.trackDistanceMeters(points)
        let stats = SnorkelingSessionStatistics.aggregate(from: [], trackPoints: points, markers: [], events: [])
        XCTAssertEqual(stats.totalDistanceMeters, liveDistance, accuracy: 0.001)

        let encoded = try JSONEncoder().encode(points)
        let restored = try JSONDecoder().decode([SnorkelingTrackPoint].self, from: encoded)
        let restoredDistance = SnorkelingDomainSupport.trackDistanceMeters(restored)
        XCTAssertEqual(restoredDistance, liveDistance, accuracy: 0.001)
    }

    func testUnderwaterFixesAreExcludedFromDistance() {
        let underwaterOnly = [
            SnorkelingTrackPoint(
                monotonicRelativeTimestampSeconds: 0,
                latitude: 44.405,
                longitude: 8.946,
                gpsQuality: .measured,
                depthMeters: 2,
                isUnderwater: true
            ),
            SnorkelingTrackPoint(
                monotonicRelativeTimestampSeconds: 10,
                latitude: 44.406,
                longitude: 8.947,
                gpsQuality: .measured,
                depthMeters: 3,
                isUnderwater: true
            )
        ]
        XCTAssertEqual(SnorkelingDomainSupport.trackDistanceMeters(underwaterOnly), 0)
    }

    func testStaleAndPoorAccuracyFixesDoNotIncreaseDistance() {
        let points = [
            SnorkelingTrackPoint(
                monotonicRelativeTimestampSeconds: 0,
                latitude: 44.405,
                longitude: 8.946,
                gpsQuality: .measured,
                depthMeters: 0,
                isUnderwater: false
            ),
            SnorkelingTrackPoint(
                monotonicRelativeTimestampSeconds: 5,
                latitude: 44.4052,
                longitude: 8.9462,
                gpsQuality: .stale,
                depthMeters: 0,
                isUnderwater: false
            ),
            SnorkelingTrackPoint(
                monotonicRelativeTimestampSeconds: 10,
                latitude: 44.4054,
                longitude: 8.9464,
                gpsQuality: .measured,
                depthMeters: 0,
                isUnderwater: false
            )
        ]
        let withStale = SnorkelingDomainSupport.trackDistanceMeters(points)
        let withoutStale = SnorkelingDomainSupport.trackDistanceMeters([points[0], points[2]])
        XCTAssertEqual(withStale, withoutStale, accuracy: 0.001)
    }

    func testDuplicateTimestampDoesNotDoubleCountSegment() {
        let points = [
            SnorkelingTrackPoint(
                monotonicRelativeTimestampSeconds: 0,
                latitude: 44.405,
                longitude: 8.946,
                gpsQuality: .measured,
                depthMeters: 0,
                isUnderwater: false
            ),
            SnorkelingTrackPoint(
                monotonicRelativeTimestampSeconds: 0,
                latitude: 44.4051,
                longitude: 8.9461,
                gpsQuality: .measured,
                depthMeters: 0,
                isUnderwater: false
            ),
            SnorkelingTrackPoint(
                monotonicRelativeTimestampSeconds: 10,
                latitude: 44.4052,
                longitude: 8.9462,
                gpsQuality: .measured,
                depthMeters: 0,
                isUnderwater: false
            )
        ]
        let distance = SnorkelingDomainSupport.trackDistanceMeters(points)
        XCTAssertGreaterThan(distance, 0)
        XCTAssertLessThan(distance, 100)
    }
}
