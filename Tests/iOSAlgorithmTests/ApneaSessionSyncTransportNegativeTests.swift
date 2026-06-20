import XCTest

/// Session transport negative-path coverage: unsupported version, replay, malformed signed payloads.
final class ApneaSessionSyncTransportNegativeTests: XCTestCase {
    private let peerSecret = Data(repeating: 9, count: 32).base64EncodedString()
    private var replayCacheURL: URL!

    override func setUp() {
        super.setUp()
        WatchSyncAuth.resetPeerTrust()
        ApneaSessionSyncCodec.resetTestHooks()
        replayCacheURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("apnea-replay-\(UUID().uuidString).json")
        ApneaSessionSyncCodec.testHook_bypassConnectivityChecks = true
        ApneaSessionSyncCodec.testHook_replayCacheFileURL = replayCacheURL
        ApneaSyncTestSupport.installDeterministicSecrets()
        ApneaSyncTestSupport.requirePeerSecret()
    }

    override func tearDown() {
        ApneaSessionSyncCodec.resetTestHooks()
        ApneaSyncTestSupport.resetSecrets()
        try? FileManager.default.removeItem(at: replayCacheURL)
        super.tearDown()
    }

    func testSupportedV2TransportImports() throws {
        let session = makeCompletedSession()
        let payload = try ApneaSessionSyncCodec.makeTestWatchTransport(session: session)
        let parsed = try ApneaSessionSyncCodec.parsePayload(from: payload)
        XCTAssertEqual(parsed.session.id, session.id)
    }

    func testFutureSessionVersionIsRejected() throws {
        let session = makeCompletedSession()
        let payload = try ApneaSessionSyncCodec.makeTestWatchTransport(
            session: session,
            version: ApneaSessionSyncCodec.schemaVersion + 1
        )
        XCTAssertThrowsError(try ApneaSessionSyncCodec.parsePayload(from: payload)) { error in
            XCTAssertEqual(error as? ApneaSessionSyncError, .unsupportedVersion)
        }
    }

    func testUnsupportedOldSessionVersionRejected() throws {
        let session = makeCompletedSession()
        let payload = try ApneaSessionSyncCodec.makeTestWatchTransport(session: session, version: 0)
        XCTAssertThrowsError(try ApneaSessionSyncCodec.parsePayload(from: payload)) { error in
            XCTAssertEqual(error as? ApneaSessionSyncError, .unsupportedVersion)
        }
    }

    func testReplayedSessionTransportNonceIsRejected() throws {
        let session = makeCompletedSession()
        let nonce = UUID().uuidString
        let payload = try ApneaSessionSyncCodec.makeTestWatchTransport(session: session, nonce: nonce)
        _ = try ApneaSessionSyncCodec.parsePayload(from: payload)
        XCTAssertThrowsError(try ApneaSessionSyncCodec.parsePayload(from: payload)) { error in
            XCTAssertEqual(error as? ApneaSessionSyncError, .replayedPayload)
        }
    }

    func testModifiedPayloadWithReusedNonceIsRejected() throws {
        let sessionA = makeCompletedSession()
        let sessionB = makeCompletedSession()
        let nonce = UUID().uuidString
        let first = try ApneaSessionSyncCodec.makeTestWatchTransport(session: sessionA, nonce: nonce)
        _ = try ApneaSessionSyncCodec.parsePayload(from: first)
        let second = try ApneaSessionSyncCodec.makeTestWatchTransport(session: sessionB, nonce: nonce)
        XCTAssertThrowsError(try ApneaSessionSyncCodec.parsePayload(from: second)) { error in
            XCTAssertEqual(error as? ApneaSessionSyncError, .replayedPayload)
        }
    }

    func testReplayCachePersistsAcrossServiceRecreation() throws {
        let session = makeCompletedSession()
        let nonce = UUID().uuidString
        let payload = try ApneaSessionSyncCodec.makeTestWatchTransport(session: session, nonce: nonce)
        _ = try ApneaSessionSyncCodec.parsePayload(from: payload)

        ApneaSessionSyncCodec.replayCache.reset()
        ApneaSessionSyncCodec.bootstrapReplayCacheIfNeeded()

        XCTAssertThrowsError(try ApneaSessionSyncCodec.parsePayload(from: payload)) { error in
            XCTAssertEqual(error as? ApneaSessionSyncError, .replayedPayload)
        }
    }

    func testWrongBundleIDRejected() throws {
        let session = makeCompletedSession()
        let payload = try ApneaSessionSyncCodec.makeTestWatchTransport(
            session: session,
            bundleID: "com.example.other"
        )
        XCTAssertThrowsError(try ApneaSessionSyncCodec.parsePayload(from: payload)) { error in
            XCTAssertEqual(error as? ApneaSessionSyncError, .invalidSender)
        }
    }

    func testInvalidSignatureRejected() throws {
        var payload = try ApneaSessionSyncCodec.makeTestWatchTransport(session: makeCompletedSession())
        guard var data = payload[ApneaSessionSyncCodec.payloadKey] as? Data else {
            return XCTFail("missing transport data")
        }
        if let suffix = "}".data(using: .utf8) {
            data.append(suffix)
            payload[ApneaSessionSyncCodec.payloadKey] = data
        }
        XCTAssertThrowsError(try ApneaSessionSyncCodec.parsePayload(from: payload))
    }

    @MainActor
    func testUnsupportedVersionDoesNotEnterLogbook() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        IOSApneaLogbookStore.testHook_storageDirectoryURL = directory
        defer {
            IOSApneaLogbookStore.testHook_storageDirectoryURL = nil
            try? FileManager.default.removeItem(at: directory)
        }

        let store = IOSApneaLogbookStore()
        store.resetImportedIDsForTesting()
        let payload = try ApneaSessionSyncCodec.makeTestWatchTransport(
            session: makeCompletedSession(),
            version: 99
        )
        XCTAssertThrowsError(try ApneaSessionSyncCodec.parsePayload(from: payload))
        XCTAssertEqual(store.sessions.count, 0)
    }

    private func makeCompletedSession() -> ApneaSession {
        var session = ApneaSession(
            startMode: .watch,
            state: .completed,
            dives: [
                ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 75, maxDepthMeters: 18, averageDepthMeters: 12)
            ]
        )
        session.statistics = session.refreshedStatistics()
        return session
    }
}
