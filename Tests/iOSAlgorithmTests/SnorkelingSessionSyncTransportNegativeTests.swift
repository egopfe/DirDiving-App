import XCTest

/// Cryptographic session transport negative-path coverage — never XCTSkip on peer secret.
final class SnorkelingSessionSyncTransportNegativeTests: XCTestCase {
    private var replayCacheURL: URL!

    override func setUp() {
        super.setUp()
        SnorkelingSessionSyncCodec.resetTestHooks()
        replayCacheURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("snorkeling-replay-\(UUID().uuidString).json")
        SnorkelingSessionSyncCodec.testHook_bypassConnectivityChecks = true
        SnorkelingSessionSyncCodec.testHook_replayCacheFileURL = replayCacheURL
        SnorkelingSyncTestSupport.installDeterministicSecrets()
        SnorkelingSyncTestSupport.requirePeerSecret()
    }

    override func tearDown() {
        SnorkelingSessionSyncCodec.resetTestHooks()
        SnorkelingSyncTestSupport.resetSecrets()
        try? FileManager.default.removeItem(at: replayCacheURL)
        super.tearDown()
    }

    func testSupportedV2TransportImports() throws {
        let session = makeCompletedSession()
        let payload = try SnorkelingSessionSyncCodec.makeTestWatchTransport(session: session)
        let parsed = try SnorkelingSessionSyncCodec.parsePayload(from: payload)
        XCTAssertEqual(parsed.session.id, session.id)
    }

    func testFutureSessionVersionIsRejected() throws {
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
        let session = makeCompletedSession()
        let nonce = UUID().uuidString
        let payload = try SnorkelingSessionSyncCodec.makeTestWatchTransport(session: session, nonce: nonce)
        _ = try SnorkelingSessionSyncCodec.parsePayload(from: payload)
        XCTAssertThrowsError(try SnorkelingSessionSyncCodec.parsePayload(from: payload)) { error in
            XCTAssertEqual(error as? SnorkelingSessionSyncError, .replayedPayload)
        }
    }

    func testInvalidSignatureRejected() throws {
        var payload = try SnorkelingSessionSyncCodec.makeTestWatchTransport(session: makeCompletedSession())
        guard var data = payload[SnorkelingSessionSyncCodec.payloadKey] as? Data else {
            return XCTFail("missing transport data")
        }
        data.append(Data("}".utf8))
        payload[SnorkelingSessionSyncCodec.payloadKey] = data
        XCTAssertThrowsError(try SnorkelingSessionSyncCodec.parsePayload(from: payload))
    }

    func testWrongBundleIDRejected() throws {
        let payload = try SnorkelingSessionSyncCodec.makeTestWatchTransport(
            session: makeCompletedSession(),
            bundleID: "com.example.other"
        )
        XCTAssertThrowsError(try SnorkelingSessionSyncCodec.parsePayload(from: payload)) { error in
            XCTAssertEqual(error as? SnorkelingSessionSyncError, .invalidSender)
        }
    }

    func testSignedAckRoundTrip() throws {
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

    func testInvalidAckSignatureRejected() {
        let sessionID = UUID()
        let issuedAt = Date()
        XCTAssertFalse(
            SnorkelingSessionSyncCodec.verifyAckSignature("invalid", sessionID: sessionID, issuedAt: issuedAt)
        )
    }

    func testWrongAckSessionIDRejected() throws {
        let sessionID = UUID()
        let otherID = UUID()
        let issuedAt = Date()
        let signature = SnorkelingSessionSyncCodec.ackSignature(sessionID: sessionID, issuedAt: issuedAt)
        XCTAssertFalse(
            SnorkelingSessionSyncCodec.verifyAckSignature(signature, sessionID: otherID, issuedAt: issuedAt)
        )
    }

    func testStaleTimestampRejected() throws {
        let session = makeCompletedSession()
        let stale = Date(timeIntervalSinceNow: -(SnorkelingSessionSyncCodec.maxIssuedAtSkew + 120))
        let payload = try SnorkelingSessionSyncCodec.makeTestWatchTransport(session: session, issuedAt: stale)
        XCTAssertThrowsError(try SnorkelingSessionSyncCodec.parsePayload(from: payload)) { error in
            XCTAssertEqual(error as? SnorkelingSessionSyncError, .stalePayload)
        }
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
