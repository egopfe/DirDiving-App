import XCTest

final class SnorkelingLegacyV1TransportTests: XCTestCase {
    private var replayCacheURL: URL!

    override func setUp() {
        super.setUp()
        SnorkelingSessionSyncCodec.resetTestHooks()
        replayCacheURL = FileManager.default.temporaryDirectory.appendingPathComponent("snorkel-v1-\(UUID().uuidString).json")
        SnorkelingSessionSyncCodec.testHook_bypassConnectivityChecks = true
        SnorkelingSessionSyncCodec.testHook_replayCacheFileURL = replayCacheURL
        SnorkelingSyncTestSupport.installDeterministicSecrets()
    }

    override func tearDown() {
        SnorkelingSessionSyncCodec.resetTestHooks()
        SnorkelingSyncTestSupport.resetSecrets()
        try? FileManager.default.removeItem(at: replayCacheURL)
        super.tearDown()
    }

    func testLegacyV1SessionTransportImportsSuccessfully() throws {
        SnorkelingSyncTestSupport.requirePeerSecret()
        let session = makeCompletedSession()
        let payload = try SnorkelingSessionSyncCodec.makeTestWatchTransport(
            session: session,
            version: SnorkelingSessionSyncCodec.legacySchemaVersion
        )
        let parsed = try SnorkelingSessionSyncCodec.parsePayload(from: payload)
        XCTAssertEqual(parsed.session.id, session.id)
    }

    func testLegacyV1DuplicateImportIsIdempotent() throws {
        SnorkelingSyncTestSupport.requirePeerSecret()
        let session = makeCompletedSession()
        let payload = try SnorkelingSessionSyncCodec.makeTestWatchTransport(
            session: session,
            version: SnorkelingSessionSyncCodec.legacySchemaVersion,
            nonce: UUID().uuidString
        )
        _ = try SnorkelingSessionSyncCodec.parsePayload(from: payload)
        let second = try SnorkelingSessionSyncCodec.makeTestWatchTransport(
            session: session,
            version: SnorkelingSessionSyncCodec.legacySchemaVersion,
            nonce: UUID().uuidString
        )
        let reparsed = try SnorkelingSessionSyncCodec.parsePayload(from: second)
        XCTAssertEqual(reparsed.session.id, session.id)
    }

    func testMalformedLegacyV1TransportIsRejected() throws {
        SnorkelingSyncTestSupport.requirePeerSecret()
        var payload = try SnorkelingSessionSyncCodec.makeTestWatchTransport(
            session: makeCompletedSession(),
            version: SnorkelingSessionSyncCodec.legacySchemaVersion
        )
        guard var data = payload[SnorkelingSessionSyncCodec.payloadKey] as? Data else {
            return XCTFail("missing transport")
        }
        data.append(Data([0xFF]))
        payload[SnorkelingSessionSyncCodec.payloadKey] = data
        XCTAssertThrowsError(try SnorkelingSessionSyncCodec.parsePayload(from: payload))
    }

    func testCurrentV2TransportRemainsPreferred() throws {
        SnorkelingSyncTestSupport.requirePeerSecret()
        let session = makeCompletedSession()
        let v2 = try SnorkelingSessionSyncCodec.makeTestWatchTransport(session: session)
        let parsed = try SnorkelingSessionSyncCodec.parsePayload(from: v2)
        XCTAssertEqual(parsed.session.schemaVersion, SnorkelingSession.currentSchemaVersion)
    }

    private func makeCompletedSession() -> SnorkelingSession {
        var session = SnorkelingSession(startMode: .watch, state: .completed, dips: [
            SnorkelingDip(startedAtMonotonicSeconds: 0, durationSeconds: 45, maxDepthMeters: 3, averageDepthMeters: 2)
        ])
        session.statistics = session.refreshedStatistics()
        return session
    }
}
