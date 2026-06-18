import Foundation
import CryptoKit

enum SnorkelingRouteSyncAckSigner {
    static func makeSignature(packageID: UUID, revision: Int, checksum: String, issuedAt: Date) -> String {
        guard WatchSyncAuth.hasPeerSecret(),
              let key = try? WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios") else {
            return ""
        }
        let canonical = SnorkelingRouteSyncCodec.ackCanonical(
            packageID: packageID,
            revision: revision,
            checksum: checksum,
            issuedAt: issuedAt
        )
        let code = HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: key)
        return Data(code).base64EncodedString()
    }

    static func verify(
        _ signature: String?,
        packageID: UUID,
        revision: Int,
        checksum: String,
        issuedAt: Date
    ) -> Bool {
        guard let signature,
              !signature.isEmpty,
              let provided = Data(base64Encoded: signature) else { return false }
        let expected = makeSignature(packageID: packageID, revision: revision, checksum: checksum, issuedAt: issuedAt)
        guard !expected.isEmpty, let expectedData = Data(base64Encoded: expected) else { return false }
        return provided.constantTimeEquals(expectedData)
    }
}

private extension Data {
    func constantTimeEquals(_ other: Data) -> Bool {
        guard count == other.count else { return false }
        return zip(self, other).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}
