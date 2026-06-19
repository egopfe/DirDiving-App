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
}
