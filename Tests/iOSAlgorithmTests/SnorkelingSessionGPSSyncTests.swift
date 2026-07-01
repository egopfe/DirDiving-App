import XCTest
@testable import DIRDivingiOSApp

final class SnorkelingSessionGPSSyncTests: XCTestCase {
    private var replayCacheURL: URL!

    override func setUp() {
        super.setUp()
        WatchSyncAuth.resetPeerTrust()
        SnorkelingSessionSyncCodec.resetTestHooks()
        replayCacheURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("snorkel-gps-sync-\(UUID().uuidString).json")
        SnorkelingSessionSyncCodec.testHook_bypassConnectivityChecks = true
        SnorkelingSessionSyncCodec.testHook_replayCacheFileURL = replayCacheURL
        WatchSyncTestSupport.installDeterministicSecrets()
        WatchSyncTestSupport.requirePeerSecret()
    }

    override func tearDown() {
        SnorkelingSessionSyncCodec.resetTestHooks()
        WatchSyncTestSupport.resetSecrets()
        try? FileManager.default.removeItem(at: replayCacheURL)
        super.tearDown()
    }

    func testTrackPointsSurviveWatchTransportRoundTrip() throws {
        let trackPoints = [
            SnorkelingTrackPoint(
                monotonicRelativeTimestampSeconds: 0,
                latitude: 44.40,
                longitude: 8.93,
                horizontalAccuracyMeters: 6,
                gpsQuality: .measured,
                isUnderwater: false
            ),
            SnorkelingTrackPoint(
                monotonicRelativeTimestampSeconds: 30,
                latitude: nil,
                longitude: nil,
                gpsQuality: .unavailable,
                depthMeters: 3,
                isUnderwater: true
            ),
            SnorkelingTrackPoint(
                monotonicRelativeTimestampSeconds: 90,
                latitude: 44.401,
                longitude: 8.931,
                horizontalAccuracyMeters: 10,
                gpsQuality: .stale,
                isUnderwater: false
            ),
        ]
        var session = makeCompletedSession()
        session.trackPoints = trackPoints
        session.entryPoint = trackPoints.first
        session.statistics = session.refreshedStatistics()

        let payload = try SnorkelingSessionSyncCodec.makeTestWatchTransport(session: session)
        let parsed = try SnorkelingSessionSyncCodec.parsePayload(from: payload).session

        XCTAssertEqual(parsed.trackPoints.count, 3)
        XCTAssertEqual(parsed.trackPoints[0].gpsQuality, .measured)
        XCTAssertNil(parsed.trackPoints[1].latitude)
        XCTAssertEqual(parsed.trackPoints[2].gpsQuality, .stale)
        XCTAssertEqual(parsed.entryPoint?.latitude ?? 0, 44.40, accuracy: 0.0001)
    }

    func testDistanceIgnoresUnavailableCoordinates() {
        let points = [
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 0, latitude: 44.0, longitude: 9.0, gpsQuality: .measured, isUnderwater: false),
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 1, latitude: nil, longitude: nil, gpsQuality: .unavailable, isUnderwater: true),
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 2, latitude: 44.001, longitude: 9.001, gpsQuality: .measured, isUnderwater: false),
        ]
        XCTAssertGreaterThan(SnorkelingDomainSupport.trackDistanceMeters(points), 0)
    }

    func testEmptyTrackPointsRemainValidForSync() throws {
        var session = makeCompletedSession()
        session.trackPoints = []
        session.entryPoint = nil
        session.statistics = session.refreshedStatistics()

        let payload = try SnorkelingSessionSyncCodec.makeTestWatchTransport(session: session)
        let parsed = try SnorkelingSessionSyncCodec.parsePayload(from: payload).session
        XCTAssertTrue(parsed.trackPoints.isEmpty)
        XCTAssertTrue(ActivityGPSLogbookPolicy.snorkelingSessionRemainsValidWithoutGPS(parsed))
    }

    private func makeCompletedSession() -> SnorkelingSession {
        var session = SnorkelingSession(
            startMode: .watch,
            state: .completed,
            dips: [
                SnorkelingDip(
                    startedAtMonotonicSeconds: 0,
                    durationSeconds: 75,
                    maxDepthMeters: 5,
                    averageDepthMeters: 4
                )
            ]
        )
        session.statistics = session.refreshedStatistics()
        return session
    }
}
