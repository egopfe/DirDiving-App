import XCTest
@testable import DIRDivingWatchApp

@MainActor
final class WatchSyncServiceIntegrationTests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        WatchSyncTestSupport.resetSecrets()
        WatchSyncTestSupport.installDeterministicSecrets()
        WatchSyncService.shared.testHook_resetPendingQueueForTests()
    }

    override func tearDown() async throws {
        WatchSyncService.shared.testHook_resetPendingQueueForTests()
        WatchSyncTestSupport.resetSecrets()
        try await super.tearDown()
    }

    func testSignedAckDequeuesPendingSession() throws {
        let sync = WatchSyncService.shared
        let session = sampleSession()
        sync.testHook_enqueueSession(session)
        XCTAssertEqual(sync.testHook_pendingSessionIDs, [session.id])

        let issuedAt = Date()
        let signature = WatchDiveSyncCodec.ackSignature(sessionID: session.id, issuedAt: issuedAt)
        XCTAssertFalse(signature.isEmpty)
        sync.testHook_confirmSignedAck(sessionID: session.id, issuedAt: issuedAt, signature: signature)
        XCTAssertTrue(sync.testHook_pendingSessionIDs.isEmpty)
        XCTAssertEqual(sync.acknowledgedTransferCount, 1)
    }

    func testInvalidAckDoesNotDequeuePendingSession() throws {
        let sync = WatchSyncService.shared
        let session = sampleSession()
        sync.testHook_enqueueSession(session)
        sync.testHook_confirmSignedAck(sessionID: session.id, issuedAt: Date(), signature: "invalid")
        XCTAssertEqual(sync.testHook_pendingSessionIDs, [session.id])
    }

    func testSignedImportAckPayloadParsesOnWatch() throws {
        let sessionID = UUID()
        let issuedAt = Date()
        let payload = WatchDiveSyncCodec.makeImportAckPayload(sessionID: sessionID, issuedAt: issuedAt)
        let parsed = try XCTUnwrap(WatchDiveSyncCodec.parseImportAck(from: payload))
        XCTAssertEqual(parsed.sessionID, sessionID)
        XCTAssertTrue(WatchDiveSyncCodec.verifyAckSignature(parsed.signature, sessionID: sessionID, issuedAt: issuedAt))
    }

    func testUserInfoDeliveryDoesNotDequeueWithoutSignedAck() throws {
        let sync = WatchSyncService.shared
        let session = sampleSession()
        sync.testHook_enqueueSession(session)
        sync.testHook_markUserInfoDelivered(sessionID: session.id, error: nil)
        XCTAssertEqual(sync.testHook_pendingSessionIDs, [session.id])
        XCTAssertNotNil(sync.testHook_pendingTransfers.first?.userInfoDeliveredAt)
    }

    func testUserInfoDeliveryFailureIncrementsFailedCount() throws {
        let sync = WatchSyncService.shared
        let session = sampleSession()
        sync.testHook_enqueueSession(session)
        let before = sync.failedTransferCount
        sync.testHook_markUserInfoDelivered(sessionID: session.id, error: NSError(domain: "test", code: 1))
        XCTAssertEqual(sync.failedTransferCount, before + 1)
        XCTAssertEqual(sync.testHook_pendingSessionIDs, [session.id])
    }

    func testImportedCompanionSessionIsNotReEnqueued() throws {
        let session = sampleSession()
        WatchDiveSyncCodec.saveImportedFromCompanionIDs([session.id])
        WatchSyncService.shared.testHook_markImportedFromCompanionSession(session.id)
        WatchSyncService.shared.transfer(session)
        XCTAssertTrue(WatchSyncService.shared.testHook_pendingSessionIDs.isEmpty)
    }

    private func sampleSession() -> DiveSession {
        let start = Date(timeIntervalSince1970: 2_000)
        return DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(90),
            durationSeconds: 90,
            maxDepthMeters: 22,
            avgDepthMeters: 14,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 15.5,
            entryGPS: nil,
            exitGPS: nil,
            samples: [DiveSample(timestamp: start, depthMeters: 22, temperatureCelsius: 19)]
        )
    }
}
