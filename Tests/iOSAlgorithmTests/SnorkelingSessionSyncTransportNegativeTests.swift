import XCTest

final class SnorkelingSessionSyncTransportNegativeTests: XCTestCase {
    private let peerSecret = Data(repeating: 13, count: 32).base64EncodedString()
    private var replayCacheURL: URL!

    override func setUp() {
        super.setUp()
        WatchSyncAuth.resetPeerTrust()
        SnorkelingSessionSyncCodec.resetTestHooks()
        replayCacheURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("snorkeling-replay-\(UUID().uuidString).json")
        SnorkelingSessionSyncCodec.testHook_bypassConnectivityChecks = true
        SnorkelingSessionSyncCodec.testHook_replayCacheFileURL = replayCacheURL
        WatchSyncAuth.ingestSharedSecretFromContext([WatchSyncAuth.contextKey: peerSecret])
    }

    override func tearDown() {
        SnorkelingSessionSyncCodec.resetTestHooks()
        WatchSyncAuth.resetPeerTrust()
        try? FileManager.default.removeItem(at: replayCacheURL)
        super.tearDown()
    }

    func testSupportedV2TransportImports() throws {
        guard WatchSyncAuth.hasPeerSecret() else { throw XCTSkip("peer secret unavailable") }
        let session = makeCompletedSession()
        let payload = try SnorkelingSessionSyncCodec.makeTestWatchTransport(session: session)
        let parsed = try SnorkelingSessionSyncCodec.parsePayload(from: payload)
        XCTAssertEqual(parsed.session.id, session.id)
    }

    func testFutureSessionVersionIsRejected() throws {
        guard WatchSyncAuth.hasPeerSecret() else { throw XCTSkip("peer secret unavailable") }
        let session = makeCompletedSession()
        let payload = try SnorkelingSessionSyncCodec.makeTestWatchTransport(
            session: session,
            version: SnorkelingSessionSyncCodec.schemaVersion + 1
        )
        XCTAssertThrowsError(try SnorkelingSessionSyncCodec.parsePayload(from: payload)) { error in
            XCTAssertEqual(error as? SnorkelingSessionSyncError, .unsupportedVersion)
        }
    }

    func testReplayedSessionTransportNonceIsRejected() throws {
        guard WatchSyncAuth.hasPeerSecret() else { throw XCTSkip("peer secret unavailable") }
        let session = makeCompletedSession()
        let nonce = UUID().uuidString
        let payload = try SnorkelingSessionSyncCodec.makeTestWatchTransport(session: session, nonce: nonce)
        _ = try SnorkelingSessionSyncCodec.parsePayload(from: payload)
        XCTAssertThrowsError(try SnorkelingSessionSyncCodec.parsePayload(from: payload)) { error in
            XCTAssertEqual(error as? SnorkelingSessionSyncError, .replayedPayload)
        }
    }

    func testInvalidSignatureRejected() throws {
        guard WatchSyncAuth.hasPeerSecret() else { throw XCTSkip("peer secret unavailable") }
        var payload = try SnorkelingSessionSyncCodec.makeTestWatchTransport(session: makeCompletedSession())
        guard var data = payload[SnorkelingSessionSyncCodec.payloadKey] as? Data else {
            return XCTFail("missing transport data")
        }
        if let suffix = "}".data(using: .utf8) {
            data.append(suffix)
            payload[SnorkelingSessionSyncCodec.payloadKey] = data
        }
        XCTAssertThrowsError(try SnorkelingSessionSyncCodec.parsePayload(from: payload))
    }

    func testSignedAckRoundTrip() throws {
        guard WatchSyncAuth.hasPeerSecret() else { throw XCTSkip("peer secret unavailable") }
        let sessionID = UUID()
        let issuedAt = Date()
        let signature = SnorkelingSessionSyncCodec.ackSignature(sessionID: sessionID, issuedAt: issuedAt)
        XCTAssertTrue(
            SnorkelingSessionSyncCodec.verifyAckSignature(signature, sessionID: sessionID, issuedAt: issuedAt)
        )
        let payload = SnorkelingSessionSyncCodec.makeImportAckPayload(sessionID: sessionID, issuedAt: issuedAt)
        let parsed = SnorkelingSessionSyncCodec.parseImportAck(from: payload)
        XCTAssertEqual(parsed?.sessionID, sessionID)
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
