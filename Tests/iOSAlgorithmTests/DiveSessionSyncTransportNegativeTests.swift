import XCTest
@testable import DIRDivingiOSApp

/// Symmetric Diving session transport negative-path coverage (SYNC-P3-001).
final class DiveSessionSyncTransportNegativeTests: XCTestCase {
    private var replayCacheURL: URL!

    override func setUp() {
        super.setUp()
        WatchSyncAuth.resetPeerTrust()
        WatchDiveSyncCodec.resetTestHooks()
        replayCacheURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("dive-replay-\(UUID().uuidString).json")
        WatchDiveSyncCodec.testHook_bypassConnectivityChecks = true
        WatchSyncTestSupport.installDeterministicSecrets()
        WatchSyncTestSupport.requirePeerSecret()
    }

    override func tearDown() {
        WatchDiveSyncCodec.resetTestHooks()
        WatchSyncTestSupport.resetSecrets()
        try? FileManager.default.removeItem(at: replayCacheURL)
        super.tearDown()
    }

    func testSupportedV3TransportImports() throws {
        let session = makeCompletedSession()
        let payload = try WatchDiveSyncCodec.makeTestWatchTransport(session: session)
        let parsed = try WatchDiveSyncCodec.parsePayload(from: payload)
        XCTAssertEqual(parsed.session.id, session.id)
    }

    func testFutureSessionVersionIsRejected() throws {
        let session = makeCompletedSession()
        let payload = try WatchDiveSyncCodec.makeTestWatchTransport(
            session: session,
            version: WatchDiveSyncCodec.schemaVersion + 1
        )
        XCTAssertThrowsError(try WatchDiveSyncCodec.parsePayload(from: payload)) { error in
            XCTAssertEqual(error as? WatchDiveSyncError, .unsupportedVersion)
        }
    }

    func testReplayedSessionTransportNonceIsRejected() throws {
        let session = makeCompletedSession()
        let nonce = UUID().uuidString
        let payload = try WatchDiveSyncCodec.makeTestWatchTransport(session: session, nonce: nonce)
        _ = try WatchDiveSyncCodec.parsePayload(from: payload)
        XCTAssertThrowsError(try WatchDiveSyncCodec.parsePayload(from: payload)) { error in
            XCTAssertEqual(error as? WatchDiveSyncError, .replayedPayload)
        }
    }

    func testWrongBundleIDRejected() throws {
        let session = makeCompletedSession()
        let payload = try WatchDiveSyncCodec.makeTestWatchTransport(
            session: session,
            bundleID: "com.example.other"
        )
        XCTAssertThrowsError(try WatchDiveSyncCodec.parsePayload(from: payload)) { error in
            XCTAssertEqual(error as? WatchDiveSyncError, .invalidSender)
        }
    }

    func testInvalidSignatureRejected() throws {
        var payload = try WatchDiveSyncCodec.makeTestWatchTransport(session: makeCompletedSession())
        guard var data = payload[WatchDiveSyncCodec.payloadKey] as? Data else {
            return XCTFail("missing transport data")
        }
        data.append(Data([0xFF]))
        payload[WatchDiveSyncCodec.payloadKey] = data
        XCTAssertThrowsError(try WatchDiveSyncCodec.parsePayload(from: payload))
    }

    private func makeCompletedSession() -> DiveSession {
        let start = Date(timeIntervalSince1970: 2_000)
        let end = start.addingTimeInterval(90)
        let samples = [
            DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 20),
            DiveSample(timestamp: end, depthMeters: 22, temperatureCelsius: 20),
        ]
        let summary = DiveProfileMath.summary(samples: samples, startDate: start, endDate: end)
        return DiveSession(
            id: UUID(),
            startDate: start,
            endDate: end,
            durationSeconds: summary.durationSeconds,
            maxDepthMeters: summary.maxDepthMeters,
            avgDepthMeters: summary.averageDepthMeters,
            avgWaterTemperatureCelsius: summary.averageTemperatureCelsius,
            ttv: summary.ttv,
            entryGPS: nil,
            exitGPS: nil,
            samples: samples
        )
    }
}
