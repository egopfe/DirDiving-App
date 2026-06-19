import XCTest

final class SnorkelingSessionSyncTransportNegativeWatchTests: XCTestCase {
    override func setUp() {
        super.setUp()
        SnorkelingSessionSyncCodec.resetTestHooks()
        SnorkelingSessionSyncCodec.testHook_bypassConnectivityChecks = true
        SnorkelingSyncTestSupport.installDeterministicSecrets()
        SnorkelingSyncTestSupport.requirePeerSecret()
    }

    override func tearDown() {
        SnorkelingSessionSyncCodec.resetTestHooks()
        SnorkelingSyncTestSupport.resetSecrets()
        super.tearDown()
    }

    func testWatchPayloadEnvelopeBuilds() throws {
        let session = makeCompletedSession()
        let envelope = try SnorkelingSessionSyncCodec.makePayload(session: session)
        XCTAssertEqual(envelope.sessionID, session.id)
        XCTAssertNotNil(envelope.message[SnorkelingSessionSyncCodec.payloadKey])
    }

    func testDuplicatePendingQueueReplacesBySessionID() {
        let sessionID = UUID()
        var session = makeCompletedSession()
        session = SnorkelingSession(
            id: sessionID,
            startMode: .watch,
            state: .completed,
            dips: session.dips
        )
        var queue = [
            SnorkelingSyncPendingTransfer(session: session),
            SnorkelingSyncPendingTransfer(session: session)
        ]
        queue.removeAll { $0.session.id == session.id }
        queue.append(SnorkelingSyncPendingTransfer(session: session))
        XCTAssertEqual(queue.count, 1)
    }

    private func makeCompletedSession() -> SnorkelingSession {
        var session = SnorkelingSession(
            startMode: .watch,
            state: .completed,
            dips: [
                SnorkelingDip(
                    startedAtMonotonicSeconds: 0,
                    durationSeconds: 60,
                    maxDepthMeters: 4,
                    averageDepthMeters: 3
                )
            ]
        )
        session.statistics = session.refreshedStatistics()
        return session
    }
}
