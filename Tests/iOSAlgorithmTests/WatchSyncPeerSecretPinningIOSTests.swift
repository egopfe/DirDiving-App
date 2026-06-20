import XCTest
@testable import DIRDivingiOSApp

final class WatchSyncPeerSecretPinningIOSTests: XCTestCase {
    override func setUp() {
        super.setUp()
        WatchSyncTestSupport.resetSecrets()
    }

    override func tearDown() {
        WatchSyncTestSupport.resetSecrets()
        super.tearDown()
    }

    func testDifferentSecretRejectedOnIOS() throws {
        WatchSyncTestSupport.installDeterministicSecrets(
            local: Data(repeating: 5, count: 32),
            peer: Data(repeating: 5, count: 32)
        )
        let second = Data(repeating: 6, count: 32).base64EncodedString()
        WatchSyncTestSupport.requirePeerSecret()
        XCTAssertEqual(WatchSyncAuth.ingestSharedSecretFromContext([WatchSyncAuth.contextKey: second]), .rejectedMismatch)
        XCTAssertTrue(WatchSyncAuth.peerSecretMismatchDetected)
    }
}
