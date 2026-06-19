import XCTest

/// Watch-side session transport negative paths and offline autonomy.
final class ApneaSessionSyncTransportNegativeWatchTests: XCTestCase {
    override func setUp() {
        super.setUp()
        WatchSyncTestSupport.installDeterministicSecrets()
        ApneaSessionSyncCodec.resetTestHooks()
        ApneaSessionSyncCodec.testHook_bypassConnectivityChecks = true
    }

    override func tearDown() {
        ApneaSessionSyncCodec.resetTestHooks()
        WatchSyncTestSupport.resetSecrets()
        super.tearDown()
    }

    func testWatchMakePayloadProducesV2Transport() throws {
        WatchSyncTestSupport.requirePeerSecret()
        let session = ApneaSession(
            startMode: .watch,
            state: .completed,
            dives: [ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 60, maxDepthMeters: 14, averageDepthMeters: 10)]
        )
        let envelope = try ApneaSessionSyncCodec.makePayload(session: session)
        XCTAssertNotNil(envelope.message[ApneaSessionSyncCodec.payloadKey])
    }

    func testUnsupportedVersionOnWatchParseRejected() throws {
        WatchSyncTestSupport.requirePeerSecret()
        let session = ApneaSession(
            startMode: .watch,
            state: .completed,
            dives: [ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 60, maxDepthMeters: 14, averageDepthMeters: 10)]
        )
        let envelope = try ApneaSessionSyncCodec.makePayload(session: session)
        guard var data = envelope.message[ApneaSessionSyncCodec.payloadKey] as? Data else {
            return XCTFail("missing transport")
        }
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           var mutable = json as? [String: Any] {
            mutable["version"] = 99
            data = try JSONSerialization.data(withJSONObject: mutable)
        }
        let payload = [ApneaSessionSyncCodec.payloadKey: data]
        XCTAssertThrowsError(try ApneaSessionSyncCodec.parsePayload(from: payload)) { error in
            XCTAssertEqual(error as? ApneaSessionSyncError, .unsupportedVersion)
        }
    }
}
