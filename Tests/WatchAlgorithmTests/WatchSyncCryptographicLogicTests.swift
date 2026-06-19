import XCTest
import CryptoKit

/// Pure HMAC / ACK cryptographic logic on Watch — never skips on Keychain unavailability.
final class WatchSyncCryptographicLogicTests: XCTestCase {
    private let localSecret = WatchSyncTestSupport.deterministicLocalSecret
    private let peerSecret = WatchSyncTestSupport.deterministicPeerSecret

    override func setUp() {
        super.setUp()
        WatchSyncTestSupport.installDeterministicSecrets(local: localSecret, peer: peerSecret)
        WatchDiveSyncCodec.replayCache.reset()
    }

    override func tearDown() {
        WatchDiveSyncCodec.replayCache.reset()
        WatchSyncTestSupport.resetSecrets()
        super.tearDown()
    }

    func testNoPeerSecretDeriveSyncKeyFails() {
        WatchSyncTestSupport.resetSecrets()
        XCTAssertFalse(WatchSyncAuth.hasPeerSecret())
        XCTAssertThrowsError(try WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios.watch")) { error in
            XCTAssertEqual(error as? WatchSyncAuthError, .missingPeerSecret)
        }
    }

    func testValidPeerSecretDerivesDeterministicKey() throws {
        let first = try WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios.watch")
        let second = try WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios.watch")
        XCTAssertEqual(Data(first.withUnsafeBytes { Data($0) }), Data(second.withUnsafeBytes { Data($0) }))
    }

    func testWrongPeerSecretChangesDerivedKey() throws {
        let baseline = try WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios.watch")
        WatchSyncTestSupport.installDeterministicSecrets(
            local: localSecret,
            peer: Data(repeating: 99, count: 32)
        )
        let rotated = try WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios.watch")
        XCTAssertNotEqual(Data(baseline.withUnsafeBytes { Data($0) }), Data(rotated.withUnsafeBytes { Data($0) }))
    }

    func testDiveImportAckSignatureRoundTrip() throws {
        let sessionID = UUID()
        let issuedAt = Date(timeIntervalSince1970: 1_700_000_100)
        let signature = WatchDiveSyncCodec.ackSignature(sessionID: sessionID, issuedAt: issuedAt)
        XCTAssertFalse(signature.isEmpty)
        XCTAssertTrue(WatchDiveSyncCodec.verifyAckSignature(signature, sessionID: sessionID, issuedAt: issuedAt))
    }

    func testDiveImportAckRejectsTamperedSignature() {
        let sessionID = UUID()
        let issuedAt = Date()
        let signature = WatchDiveSyncCodec.ackSignature(sessionID: sessionID, issuedAt: issuedAt)
        XCTAssertFalse(WatchDiveSyncCodec.verifyAckSignature("invalid", sessionID: sessionID, issuedAt: issuedAt))
        XCTAssertFalse(WatchDiveSyncCodec.verifyAckSignature(signature, sessionID: UUID(), issuedAt: issuedAt))
    }

    func testApneaPlanAckSignatureVerifies() {
        let packageID = UUID()
        let revision = 4
        let checksum = String(repeating: "d", count: 64)
        let issuedAt = Date(timeIntervalSince1970: 1_700_000_200)
        let signature = ApneaSyncAckSigner.makeSignature(
            packageID: packageID,
            revision: revision,
            checksum: checksum,
            issuedAt: issuedAt
        )
        XCTAssertTrue(
            ApneaSyncAckSigner.verify(
                signature,
                packageID: packageID,
                revision: revision,
                checksum: checksum,
                issuedAt: issuedAt
            )
        )
    }

    func testApneaSessionAckSignatureRoundTrip() throws {
        let sessionID = UUID()
        let issuedAt = Date(timeIntervalSince1970: 1_700_000_300)
        let signature = ApneaSessionSyncCodec.ackSignature(sessionID: sessionID, issuedAt: issuedAt)
        let key = try WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios")
        let canonical = "apneaAck|\(sessionID.uuidString)|\(issuedAt.timeIntervalSince1970)"
        let expected = Data(HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: key))
        guard let provided = Data(base64Encoded: signature) else {
            return XCTFail("invalid base64 signature")
        }
        XCTAssertEqual(provided, expected)
    }

    func testCompanionPhotoSignedRequestReplayRejected() {
        let requestID = UUID().uuidString
        let issuedAt = Date()
        var payload: [String: Any] = [
            "type": WatchSyncKeys.companionPhotoInventoryRequestType,
            WatchSyncKeys.companionPhotoInventoryRequestIDKey: requestID,
            WatchSyncKeys.companionPhotoManagementIssuedAtKey: issuedAt.timeIntervalSince1970,
        ]
        payload[WatchSyncKeys.companionPhotoManagementSignatureKey] = CompanionPhotoManagementAuth.sign(
            type: WatchSyncKeys.companionPhotoInventoryRequestType,
            requestID: requestID,
            issuedAt: issuedAt,
            extra: "",
            peerBundleID: "com.egopfe.dirdiving.ios"
        ) ?? ""
        XCTAssertTrue(CompanionPhotoManagementSupport.verifySignedRequest(payload))
        XCTAssertFalse(CompanionPhotoManagementSupport.verifySignedRequest(payload))
    }
}
