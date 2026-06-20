import XCTest

final class ActivitySyncSignedAckSymmetryTests: XCTestCase {
    override func setUp() {
        super.setUp()
        WatchSyncTestSupport.installDeterministicSecrets()
    }

    override func tearDown() {
        WatchSyncTestSupport.resetSecrets()
        super.tearDown()
    }

    func testDivingApneaSnorkelingAcksVerify() throws {
        let sessionID = UUID()
        let issuedAt = Date()
        let diveAck = WatchDiveSyncCodec.ackSignature(sessionID: sessionID, issuedAt: issuedAt)
        let apneaAck = ApneaSessionSyncCodec.ackSignature(sessionID: sessionID, issuedAt: issuedAt)
        let snorkelAck = SnorkelingSessionSyncCodec.ackSignature(sessionID: sessionID, issuedAt: issuedAt)
        XCTAssertTrue(WatchDiveSyncCodec.verifyAckSignature(diveAck, sessionID: sessionID, issuedAt: issuedAt))
        XCTAssertTrue(ApneaSessionSyncCodec.verifyAckSignature(apneaAck, sessionID: sessionID, issuedAt: issuedAt))
        XCTAssertTrue(SnorkelingSessionSyncCodec.verifyAckSignature(snorkelAck, sessionID: sessionID, issuedAt: issuedAt))
        XCTAssertFalse(WatchDiveSyncCodec.verifyAckSignature(apneaAck, sessionID: sessionID, issuedAt: issuedAt))
    }
}
