import XCTest

/// iOS-side interrupted import / idempotency coverage (Watch queue tests live on watchOS).
final class SnorkelingSessionSyncInterruptedTransferTests: XCTestCase {
    private var replayCacheURL: URL!

    override func setUp() {
        super.setUp()
        SnorkelingSessionSyncCodec.resetTestHooks()
        replayCacheURL = FileManager.default.temporaryDirectory.appendingPathComponent("snorkel-int-\(UUID().uuidString).json")
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

    @MainActor
    func testIOSImportPersistsAcrossStoreRecreation() throws {
        SnorkelingSyncTestSupport.requirePeerSecret()
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        IOSSnorkelingLogbookStore.testHook_storageDirectoryURL = directory
        defer {
            IOSSnorkelingLogbookStore.testHook_storageDirectoryURL = nil
            try? FileManager.default.removeItem(at: directory)
        }

        let session = makeCompletedSession()
        let payload = try SnorkelingSessionSyncCodec.makeTestWatchTransport(session: session)
        let parsed = try SnorkelingSessionSyncCodec.parsePayload(from: payload)

        var store = IOSSnorkelingLogbookStore()
        store.resetImportedIDsForTesting()
        XCTAssertEqual(store.mergeImportedSession(parsed.session), .imported)

        let reloaded = IOSSnorkelingLogbookStore()
        XCTAssertEqual(reloaded.sessions.count, 1)
        XCTAssertEqual(reloaded.sessions.first?.id, session.id)
    }

    @MainActor
    func testRetryImportRemainsIdempotent() throws {
        SnorkelingSyncTestSupport.requirePeerSecret()
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        IOSSnorkelingLogbookStore.testHook_storageDirectoryURL = directory
        defer {
            IOSSnorkelingLogbookStore.testHook_storageDirectoryURL = nil
            try? FileManager.default.removeItem(at: directory)
        }

        let session = makeCompletedSession()
        let payload = try SnorkelingSessionSyncCodec.makeTestWatchTransport(session: session, nonce: UUID().uuidString)
        let parsed = try SnorkelingSessionSyncCodec.parsePayload(from: payload)
        let store = IOSSnorkelingLogbookStore()
        store.resetImportedIDsForTesting()
        XCTAssertEqual(store.mergeImportedSession(parsed.session), .imported)
        XCTAssertEqual(store.mergeImportedSession(parsed.session), .merged)
        XCTAssertEqual(store.sessions.count, 1)
    }

    func testSignedACKContextIsDeterministic() throws {
        SnorkelingSyncTestSupport.requirePeerSecret()
        let session = makeCompletedSession()
        let payload = try SnorkelingSessionSyncCodec.makeTestWatchTransport(session: session)
        let parsed = try SnorkelingSessionSyncCodec.parsePayload(from: payload)
        let ack = SnorkelingSessionSyncCodec.ackSignature(sessionID: parsed.session.id, issuedAt: parsed.issuedAt)
        XCTAssertFalse(ack.isEmpty)
        XCTAssertTrue(
            SnorkelingSessionSyncCodec.verifyAckSignature(
                ack,
                sessionID: parsed.session.id,
                issuedAt: parsed.issuedAt
            )
        )
    }

    private func makeCompletedSession() -> SnorkelingSession {
        var session = SnorkelingSession(
            id: UUID(),
            startMode: .watch,
            state: .completed,
            dips: [
                SnorkelingDip(startedAtMonotonicSeconds: 0, durationSeconds: 60, maxDepthMeters: 4, averageDepthMeters: 3)
            ]
        )
        session.statistics = session.refreshedStatistics()
        return session
    }
}
