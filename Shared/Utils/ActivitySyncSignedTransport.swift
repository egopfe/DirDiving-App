import Foundation
import CryptoKit

/// Shared signed transport wrapper used by Diving, Apnea, and Snorkeling session codecs.
struct ActivitySyncSignedTransport: Codable, Equatable {
    static let legacySchemaVersion = 1
    static let nonceRequiredFromVersion = 2
    static let envelopeSchemaVersion = 3

    let version: Int
    let bundleID: String
    let issuedAt: Date
    let nonce: String?
    let messageID: String?
    let activityType: String?
    let messageType: String?
    let payloadHash: String?
    let revision: Int?
    let body: Data
    let signature: String

    static func payloadHash(for body: Data) -> String {
        let digest = SHA256.hash(data: body)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    static func makeSigned(
        body: Data,
        bundleID: String,
        activity: ActivitySyncActivityType,
        messageType: ActivitySyncMessageType,
        revision: Int,
        syncKey: SymmetricKey,
        issuedAt: Date = Date(),
        nonce: String = UUID().uuidString,
        messageID: String = UUID().uuidString
    ) -> ActivitySyncSignedTransport {
        let payloadHash = payloadHash(for: body)
        var unsigned = ActivitySyncSignedTransport(
            version: envelopeSchemaVersion,
            bundleID: bundleID,
            issuedAt: issuedAt,
            nonce: nonce,
            messageID: messageID,
            activityType: activity.rawValue,
            messageType: messageType.rawValue,
            payloadHash: payloadHash,
            revision: revision,
            body: body,
            signature: ""
        )
        let signature = ActivitySyncHMAC.signCanonical(transport: unsigned, body: body, key: syncKey)
        unsigned = ActivitySyncSignedTransport(
            version: unsigned.version,
            bundleID: unsigned.bundleID,
            issuedAt: unsigned.issuedAt,
            nonce: unsigned.nonce,
            messageID: unsigned.messageID,
            activityType: unsigned.activityType,
            messageType: unsigned.messageType,
            payloadHash: unsigned.payloadHash,
            revision: unsigned.revision,
            body: unsigned.body,
            signature: signature
        )
        return unsigned
    }

    func signed(with syncKey: SymmetricKey, issuedAt: Date) -> ActivitySyncSignedTransport {
        let signature = ActivitySyncHMAC.signCanonical(transport: self, body: body, key: syncKey)
        return ActivitySyncSignedTransport(
            version: version,
            bundleID: bundleID,
            issuedAt: issuedAt,
            nonce: nonce,
            messageID: messageID,
            activityType: activityType,
            messageType: messageType,
            payloadHash: payloadHash,
            revision: revision,
            body: body,
            signature: signature
        )
    }

    func verify(with syncKey: SymmetricKey) -> Bool {
        ActivitySyncHMAC.verify(transport: self, key: syncKey)
    }
}
