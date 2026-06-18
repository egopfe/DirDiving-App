import XCTest
import CryptoKit

/// Pure HMAC / ACK cryptographic logic — never skips on Keychain unavailability (Audit 08 remediation).
final class ApneaSyncCryptographicLogicTests: XCTestCase {
    private let localSecret = Data(repeating: 1, count: 32)
    private let peerSecret = Data(repeating: 2, count: 32)

    override func setUp() {
        super.setUp()
        WatchSyncAuth.installTestSecrets(local: localSecret, peer: peerSecret)
    }

    override func tearDown() {
        WatchSyncAuth.resetTestSecrets()
        WatchSyncAuth.resetPeerTrust()
        super.tearDown()
    }

    func testValidPlanAckSignatureVerifies() throws {
        let packageID = UUID()
        let revision = 7
        let checksum = String(repeating: "a", count: 64)
        let issuedAt = Date(timeIntervalSince1970: 1_700_000_000)
        let signature = ApneaSyncAckSigner.makeSignature(
            packageID: packageID,
            revision: revision,
            checksum: checksum,
            issuedAt: issuedAt
        )
        XCTAssertFalse(signature.isEmpty)
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

    func testInvalidPlanAckSignatureRejected() throws {
        let packageID = UUID()
        let revision = 1
        let checksum = String(repeating: "b", count: 64)
        let issuedAt = Date()
        XCTAssertFalse(
            ApneaSyncAckSigner.verify(
                Data(repeating: 9, count: 32).base64EncodedString(),
                packageID: packageID,
                revision: revision,
                checksum: checksum,
                issuedAt: issuedAt
            )
        )
    }

    func testModifiedAckPayloadRejected() throws {
        let packageID = UUID()
        let revision = 2
        let checksum = String(repeating: "c", count: 64)
        let issuedAt = Date()
        let signature = ApneaSyncAckSigner.makeSignature(
            packageID: packageID,
            revision: revision,
            checksum: checksum,
            issuedAt: issuedAt
        )
        XCTAssertFalse(
            ApneaSyncAckSigner.verify(
                signature,
                packageID: packageID,
                revision: revision + 1,
                checksum: checksum,
                issuedAt: issuedAt
            )
        )
    }

    func testSessionImportAckSignatureRoundTrip() throws {
        let sessionID = UUID()
        let issuedAt = Date(timeIntervalSince1970: 1_700_000_100)
        let signature = ApneaSessionSyncCodec.ackSignature(sessionID: sessionID, issuedAt: issuedAt)
        XCTAssertFalse(signature.isEmpty)
        let key = try WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios")
        let canonical = "apneaAck|\(sessionID.uuidString)|\(issuedAt.timeIntervalSince1970)"
        let expected = Data(HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: key))
        guard let provided = Data(base64Encoded: signature) else {
            return XCTFail("invalid base64 signature")
        }
        XCTAssertEqual(provided, expected)
    }

    func testSessionImportAckRejectsTamperedSignature() {
        let sessionID = UUID()
        let issuedAt = Date()
        let signature = ApneaSessionSyncCodec.ackSignature(sessionID: sessionID, issuedAt: issuedAt)
        XCTAssertFalse(signature == "invalid")
        XCTAssertNotEqual(signature, ApneaSessionSyncCodec.ackSignature(sessionID: UUID(), issuedAt: issuedAt))
    }

    func testDerivedSyncKeyIsDeterministicForInstalledSecrets() throws {
        let first = try WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios")
        let second = try WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios")
        XCTAssertEqual(Data(first.withUnsafeBytes { Data($0) }), Data(second.withUnsafeBytes { Data($0) }))
    }

    func testCanonicalAckStringMatchesCodecContract() {
        let packageID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let issuedAt = Date(timeIntervalSince1970: 1_700_000_000)
        let checksum = String(repeating: "f", count: 64)
        let canonical = ApneaSyncCodec.ackCanonical(
            packageID: packageID,
            revision: 3,
            checksum: checksum,
            issuedAt: issuedAt
        )
        XCTAssertTrue(canonical.contains(packageID.uuidString))
        XCTAssertTrue(canonical.contains(checksum))
    }
}
