import Foundation
import CryptoKit

enum CompanionPhotoManagementAuth {
    static let maxSkew: TimeInterval = 3_600
    static var requestReplayCache = SyncNonceReplayCache(maxEntries: 256)
    static var responseReplayCache = SyncNonceReplayCache(maxEntries: 256)

    static func sign(
        type: String,
        requestID: String,
        issuedAt: Date,
        extra: String,
        peerBundleID: String
    ) -> String? {
        guard WatchSyncAuth.hasPeerSecret(),
              let key = try? WatchSyncAuth.deriveSyncKey(peerBundleID: peerBundleID) else { return nil }
        let canonical = "\(type)|\(requestID)|\(issuedAt.timeIntervalSince1970)|\(extra)"
        let code = HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: key)
        return Data(code).base64EncodedString()
    }

    static func verify(
        payload: [String: Any],
        type: String,
        requestID: String,
        extra: String,
        peerBundleID: String,
        replayCache: SyncNonceReplayCache
    ) -> Bool {
        guard let issuedAtInterval = payload[WatchSyncKeys.companionPhotoManagementIssuedAtKey] as? TimeInterval,
              let signature = payload[WatchSyncKeys.companionPhotoManagementSignatureKey] as? String,
              !signature.isEmpty else { return false }
        let issuedAt = Date(timeIntervalSince1970: issuedAtInterval)
        guard abs(issuedAt.timeIntervalSinceNow) <= maxSkew else { return false }
        let replayKey = "\(type)|\(requestID)|\(issuedAtInterval)|\(extra)"
        if replayCache.isReplay(replayKey) { return false }
        guard let expected = sign(
            type: type,
            requestID: requestID,
            issuedAt: issuedAt,
            extra: extra,
            peerBundleID: peerBundleID
        ),
              let provided = Data(base64Encoded: signature),
              let expectedData = Data(base64Encoded: expected),
              provided.constantTimeEquals(expectedData) else { return false }
        return replayCache.register(replayKey)
    }
}

private extension Data {
    func constantTimeEquals(_ other: Data) -> Bool {
        guard count == other.count else { return false }
        return zip(self, other).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}
