import XCTest

@MainActor
final class SnorkelingWatchPendingQueueTests: XCTestCase {
    override func setUp() {
        super.setUp()
        SnorkelingSyncTestSupport.installDeterministicSecrets()
        WatchSyncService.shared.testHook_resetSnorkelingPendingQueueForTests()
    }

    override func tearDown() {
        WatchSyncService.shared.testHook_resetSnorkelingPendingQueueForTests()
        SnorkelingSyncTestSupport.resetSecrets()
        super.tearDown()
    }

    @MainActor
    func testDuplicatePendingSessionReplacesByID() {
        let id = UUID()
        var session = makeSession(id: id)
        let sync = WatchSyncService.shared
        sync.testHook_enqueueSnorkelingSession(session)
        session.dips.append(SnorkelingDip(startedAtMonotonicSeconds: 90, durationSeconds: 20, maxDepthMeters: 6, averageDepthMeters: 5))
        sync.testHook_enqueueSnorkelingSession(session)
        XCTAssertEqual(sync.testHook_pendingSnorkelingSessionIDs.count, 1)
        XCTAssertEqual(sync.testHook_pendingSnorkelingSessionIDs[0], id)
    }

    @MainActor
    func testPendingQueueSurvivesRelaunchUntilSignedACK() throws {
        SnorkelingSyncTestSupport.requirePeerSecret()
        let sync = WatchSyncService.shared
        sync.testHook_resetSnorkelingPendingQueueForTests()

        let session = makeSession()
        sync.testHook_enqueueSnorkelingSession(session)
        XCTAssertEqual(sync.testHook_pendingSnorkelingSessionIDs, [session.id])

        let reloaded = sync.testHook_reloadSnorkelingPendingFromPersistence()
        XCTAssertEqual(reloaded.count, 1)
        XCTAssertEqual(reloaded[0].session.id, session.id)

        let envelope = try SnorkelingSessionSyncCodec.makePayload(session: session)
        let signature = SnorkelingSessionSyncCodec.ackSignature(
            sessionID: envelope.sessionID,
            issuedAt: envelope.issuedAt
        )
        sync.testHook_confirmSnorkelingSignedAck(
            sessionID: envelope.sessionID,
            issuedAt: envelope.issuedAt,
            signature: signature
        )
        XCTAssertTrue(sync.testHook_pendingSnorkelingSessionIDs.isEmpty)
    }

    @MainActor
    func testInvalidACKDoesNotClearPendingQueue() throws {
        SnorkelingSyncTestSupport.requirePeerSecret()
        let sync = WatchSyncService.shared
        sync.testHook_resetSnorkelingPendingQueueForTests()
        let session = makeSession()
        sync.testHook_enqueueSnorkelingSession(session)
        sync.testHook_confirmSnorkelingSignedAck(sessionID: session.id, issuedAt: Date(), signature: "bad")
        XCTAssertEqual(sync.testHook_pendingSnorkelingSessionIDs, [session.id])
    }

    @MainActor
    func testValidACKClearsOnlyMatchingSession() throws {
        SnorkelingSyncTestSupport.requirePeerSecret()
        let sync = WatchSyncService.shared
        let a = makeSession(id: UUID())
        let b = makeSession(id: UUID())
        sync.testHook_enqueueSnorkelingSession(a)
        sync.testHook_enqueueSnorkelingSession(b)
        let envelope = try SnorkelingSessionSyncCodec.makePayload(session: a)
        sync.testHook_confirmSnorkelingSignedAck(
            sessionID: envelope.sessionID,
            issuedAt: envelope.issuedAt,
            signature: SnorkelingSessionSyncCodec.ackSignature(sessionID: envelope.sessionID, issuedAt: envelope.issuedAt)
        )
        XCTAssertEqual(sync.testHook_pendingSnorkelingSessionIDs, [b.id])
    }

    private func makeSession(id: UUID = UUID()) -> SnorkelingSession {
        var session = SnorkelingSession(
            id: id,
            startMode: .watch,
            state: .completed,
            dips: [SnorkelingDip(startedAtMonotonicSeconds: 0, durationSeconds: 45, maxDepthMeters: 4, averageDepthMeters: 3)]
        )
        session.statistics = session.refreshedStatistics()
        return session
    }
}
