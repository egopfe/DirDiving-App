import Foundation
import CryptoKit

enum BuddyPairingKeyAgreement {
    static let info = Data("dirmotion.buddy.v1".utf8)

    static func makeEphemeralKeyPair() -> P256.KeyAgreement.PrivateKey {
        P256.KeyAgreement.PrivateKey()
    }

    static func deriveSessionKey(
        privateKey: P256.KeyAgreement.PrivateKey,
        peerPublicKeyData: Data,
        sessionId: String
    ) throws -> Data {
        let peerKey = try P256.KeyAgreement.PublicKey(x963Representation: peerPublicKeyData)
        let shared = try privateKey.sharedSecretFromKeyAgreement(with: peerKey)
        let symmetric = shared.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(sessionId.utf8),
            sharedInfo: info,
            outputByteCount: 32
        )
        return symmetric.withUnsafeBytes { Data($0) }
    }

    static func confirmationCode(sessionId: String, keyData: Data) -> String {
        var material = Data(sessionId.utf8)
        material.append(keyData)
        let digest = SHA256.hash(data: material)
        let value = digest.prefix(4).reduce(UInt32(0)) { ($0 << 8) | UInt32($1) } % 1_000_000
        return String(format: "%03d-%03d", value / 1000, value % 1000)
    }

    static func fingerprint(for keyData: Data) -> String {
        let digest = SHA256.hash(data: keyData)
        return digest.prefix(4).map { String(format: "%02X", $0) }.joined(separator: ":")
    }

    static func pairingSessionId(localId: String, remoteId: String) -> String {
        [localId, remoteId].sorted().joined(separator: ":")
    }

    static func shouldSendOffer(localDeviceId: String, remoteDeviceId: String) -> Bool {
        localDeviceId.compare(remoteDeviceId, options: .literal) == .orderedAscending
    }
}
