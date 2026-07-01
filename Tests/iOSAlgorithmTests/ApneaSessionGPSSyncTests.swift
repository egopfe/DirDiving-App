import XCTest
@testable import DIRDivingiOSApp

final class ApneaSessionGPSSyncTests: XCTestCase {
    private var replayCacheURL: URL!

    override func setUp() {
        super.setUp()
        WatchSyncAuth.resetPeerTrust()
        ApneaSessionSyncCodec.resetTestHooks()
        replayCacheURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("apnea-gps-sync-\(UUID().uuidString).json")
        ApneaSessionSyncCodec.testHook_bypassConnectivityChecks = true
        ApneaSessionSyncCodec.testHook_replayCacheFileURL = replayCacheURL
        WatchSyncTestSupport.installDeterministicSecrets()
        WatchSyncTestSupport.requirePeerSecret()
    }

    override func tearDown() {
        ApneaSessionSyncCodec.resetTestHooks()
        WatchSyncTestSupport.resetSecrets()
        try? FileManager.default.removeItem(at: replayCacheURL)
        super.tearDown()
    }

    func testSurfaceGPSPointsSurviveWatchTransportRoundTrip() throws {
        let capturedAt = Date(timeIntervalSince1970: 3_000)
        var session = makeCompletedSession()
        session.surfaceGPSPoints = [
            ApneaSurfaceGPSPoint(latitude: 44.5, longitude: 8.95, horizontalAccuracyMeters: 7, capturedAt: capturedAt),
            ApneaSurfaceGPSPoint(
                latitude: 44.501,
                longitude: 8.951,
                horizontalAccuracyMeters: 9,
                capturedAt: capturedAt.addingTimeInterval(600)
            ),
        ]

        let payload = try ApneaSessionSyncCodec.makeTestWatchTransport(session: session)
        let parsed = try ApneaSessionSyncCodec.parsePayload(from: payload).session

        XCTAssertEqual(parsed.surfaceGPSPoints.count, 2)
        XCTAssertEqual(parsed.surfaceGPSPoints[0].latitude ?? 0, 44.5, accuracy: 0.0001)
        XCTAssertEqual(parsed.surfaceGPSPoints[1].longitude ?? 0, 8.951, accuracy: 0.0001)
    }

    func testEmptySurfaceGPSPointsWithWarningRemainValidForSync() throws {
        var session = makeCompletedSession()
        session.surfaceGPSPoints = []
        session.warnings = [.gpsUnavailable]

        let payload = try ApneaSessionSyncCodec.makeTestWatchTransport(session: session)
        let parsed = try ApneaSessionSyncCodec.parsePayload(from: payload).session
        XCTAssertTrue(parsed.surfaceGPSPoints.isEmpty)
        XCTAssertTrue(parsed.warnings.contains(.gpsUnavailable))
        XCTAssertTrue(ActivityGPSLogbookPolicy.apneaSessionRemainsValidWithoutGPS(parsed))
    }

    func testSessionHasNoRouteOrNavigationFields() {
        let session = makeCompletedSession()
        let mirror = Mirror(reflecting: session)
        let labels = mirror.children.compactMap(\.label)
        XCTAssertFalse(labels.contains(where: { $0.localizedCaseInsensitiveContains("route") }))
        XCTAssertFalse(labels.contains(where: { $0.localizedCaseInsensitiveContains("bearing") }))
        XCTAssertFalse(labels.contains(where: { $0.localizedCaseInsensitiveContains("waypoint") }))
    }

    private func makeCompletedSession() -> ApneaSession {
        var session = ApneaSession(
            startMode: .watch,
            state: .completed,
            dives: [
                ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 60, maxDepthMeters: 12, averageDepthMeters: 8)
            ]
        )
        session.statistics = session.refreshedStatistics()
        return session
    }
}
