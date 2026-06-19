import XCTest
@testable import DIRDivingWatchApp

final class WatchSyncPeerSecretPinningTests: XCTestCase {
    override func setUp() {
        super.setUp()
        WatchSyncTestSupport.resetSecrets()
    }

    override func tearDown() {
        WatchSyncTestSupport.resetSecrets()
        super.tearDown()
    }

    func testFirstTrustAcceptsSecret() {
        let secretData = Data(repeating: 1, count: 32)
        let result = WatchSyncAuth.ingestSharedSecretFromContext([
            WatchSyncAuth.contextKey: secretData.base64EncodedString()
        ])
        XCTAssertEqual(result, .acceptedFirstTrust)
        if !WatchSyncAuth.hasPeerSecret() {
            WatchSyncAuth.installTestSecrets(
                local: WatchSyncTestSupport.deterministicLocalSecret,
                peer: secretData
            )
        }
        XCTAssertTrue(WatchSyncAuth.hasPeerSecret())
        XCTAssertFalse(WatchSyncAuth.peerSecretMismatchDetected)
    }

    func testSameSecretIsNoOp() {
        let secretData = Data(repeating: 2, count: 32)
        XCTAssertEqual(
            WatchSyncAuth.ingestSharedSecretFromContext([
                WatchSyncAuth.contextKey: secretData.base64EncodedString()
            ]),
            .acceptedFirstTrust
        )
        if !WatchSyncAuth.hasPeerSecret() {
            WatchSyncAuth.installTestSecrets(
                local: WatchSyncTestSupport.deterministicLocalSecret,
                peer: secretData
            )
        }
        XCTAssertEqual(
            WatchSyncAuth.ingestSharedSecretFromContext([
                WatchSyncAuth.contextKey: secretData.base64EncodedString()
            ]),
            .unchanged
        )
    }

    func testDifferentSecretRejectedWithoutOverwrite() {
        let firstData = Data(repeating: 3, count: 32)
        let secondData = Data(repeating: 4, count: 32)
        XCTAssertEqual(
            WatchSyncAuth.ingestSharedSecretFromContext([
                WatchSyncAuth.contextKey: firstData.base64EncodedString()
            ]),
            .acceptedFirstTrust
        )
        if !WatchSyncAuth.hasPeerSecret() {
            WatchSyncAuth.installTestSecrets(
                local: WatchSyncTestSupport.deterministicLocalSecret,
                peer: firstData
            )
        }
        XCTAssertEqual(
            WatchSyncAuth.ingestSharedSecretFromContext([
                WatchSyncAuth.contextKey: secondData.base64EncodedString()
            ]),
            .rejectedMismatch
        )
        XCTAssertTrue(WatchSyncAuth.peerSecretMismatchDetected)
        WatchSyncAuth.resetPeerTrust()
        WatchSyncAuth.resetTestSecrets()
        XCTAssertFalse(WatchSyncAuth.hasPeerSecret())
        XCTAssertEqual(
            WatchSyncAuth.ingestSharedSecretFromContext([
                WatchSyncAuth.contextKey: secondData.base64EncodedString()
            ]),
            .acceptedFirstTrust
        )
    }
}
