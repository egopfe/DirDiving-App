import XCTest
@testable import DIRDivingiOSApp

final class WatchSyncPeerSecretPinningIOSTests: XCTestCase {
    override func setUp() {
        super.setUp()
        WatchSyncAuth.resetPeerTrust()
    }

    override func tearDown() {
        WatchSyncAuth.resetPeerTrust()
        super.tearDown()
    }

    func testDifferentSecretRejectedOnIOS() throws {
        let first = Data(repeating: 5, count: 32).base64EncodedString()
        let second = Data(repeating: 6, count: 32).base64EncodedString()
        XCTAssertEqual(WatchSyncAuth.ingestSharedSecretFromContext([WatchSyncAuth.contextKey: first]), .acceptedFirstTrust)
        guard WatchSyncAuth.hasPeerSecret() else {
            throw XCTSkip("Peer secret unavailable in test keychain")
        }
        XCTAssertEqual(WatchSyncAuth.ingestSharedSecretFromContext([WatchSyncAuth.contextKey: second]), .rejectedMismatch)
        XCTAssertTrue(WatchSyncAuth.peerSecretMismatchDetected)
    }
}
