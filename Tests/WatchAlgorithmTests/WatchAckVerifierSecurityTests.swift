import XCTest
@testable import DIRDivingWatchApp

final class WatchAckVerifierSecurityTests: XCTestCase {
    func testEmptyAckRejected() {
        XCTAssertFalse(WatchDiveSyncCodec.verifyAckSignature("", sessionID: UUID(), issuedAt: Date()))
    }

    func testLegacyAcknowledgedStringRejected() {
        XCTAssertFalse(WatchDiveSyncCodec.verifyAckSignature("acknowledged", sessionID: UUID(), issuedAt: Date()))
    }
}
