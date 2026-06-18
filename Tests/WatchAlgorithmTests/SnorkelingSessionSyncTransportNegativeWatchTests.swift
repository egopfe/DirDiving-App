import XCTest

final class SnorkelingSessionSyncTransportNegativeWatchTests: XCTestCase {
    private let peerSecret = Data(repeating: 17, count: 32).base64EncodedString()

    override func setUp() {
        super.setUp()
        WatchSyncAuth.resetPeerTrust()
        SnorkelingSessionSyncCodec.resetTestHooks()
        SnorkelingSessionSyncCodec.testHook_bypassConnectivityChecks = true
        WatchSyncAuth.ingestSharedSecretFromContext([WatchSyncAuth.contextKey: peerSecret])
    }

    override func tearDown() {
        SnorkelingSessionSyncCodec.resetTestHooks()
        WatchSyncAuth.resetPeerTrust()
        super.tearDown()
    }

    func testWatchPayloadEnvelopeBuilds() throws {
        guard WatchSyncAuth.hasPeerSecret() else { throw XCTSkip("peer secret unavailable") }
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
