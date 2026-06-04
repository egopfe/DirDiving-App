import XCTest
@testable import DIRDivingWatchApp

final class WatchSyncPeerSecretPinningTests: XCTestCase {
    override func setUp() {
        super.setUp()
        WatchSyncAuth.resetPeerTrust()
    }

    override func tearDown() {
        WatchSyncAuth.resetPeerTrust()
        super.tearDown()
    }

    func testFirstTrustAcceptsSecret() throws {
        let secret = Data(repeating: 1, count: 32).base64EncodedString()
        let result = WatchSyncAuth.ingestSharedSecretFromContext([WatchSyncAuth.contextKey: secret])
        guard WatchSyncAuth.hasPeerSecret() else {
            throw XCTSkip("Peer secret unavailable in test keychain")
        }
        XCTAssertEqual(result, .acceptedFirstTrust)
        XCTAssertFalse(WatchSyncAuth.peerSecretMismatchDetected)
    }

    func testSameSecretIsNoOp() throws {
        let secret = Data(repeating: 2, count: 32).base64EncodedString()
        XCTAssertEqual(WatchSyncAuth.ingestSharedSecretFromContext([WatchSyncAuth.contextKey: secret]), .acceptedFirstTrust)
        guard WatchSyncAuth.hasPeerSecret() else {
            throw XCTSkip("Peer secret unavailable in test keychain")
        }
        XCTAssertEqual(WatchSyncAuth.ingestSharedSecretFromContext([WatchSyncAuth.contextKey: secret]), .unchanged)
    }

    func testDifferentSecretRejectedWithoutOverwrite() throws {
        let first = Data(repeating: 3, count: 32).base64EncodedString()
        let second = Data(repeating: 4, count: 32).base64EncodedString()
        XCTAssertEqual(WatchSyncAuth.ingestSharedSecretFromContext([WatchSyncAuth.contextKey: first]), .acceptedFirstTrust)
        guard WatchSyncAuth.hasPeerSecret() else {
            throw XCTSkip("Peer secret unavailable in test keychain")
        }
        XCTAssertEqual(WatchSyncAuth.ingestSharedSecretFromContext([WatchSyncAuth.contextKey: second]), .rejectedMismatch)
        XCTAssertTrue(WatchSyncAuth.peerSecretMismatchDetected)
        WatchSyncAuth.resetPeerTrust()
        XCTAssertFalse(WatchSyncAuth.hasPeerSecret())
        XCTAssertEqual(WatchSyncAuth.ingestSharedSecretFromContext([WatchSyncAuth.contextKey: second]), .acceptedFirstTrust)
    }
}
