import Foundation
import CryptoKit

/// Canonical activity discriminator for authenticated sync envelopes (SYNC-P3-003).
enum ActivitySyncActivityType: String, Codable, CaseIterable, Sendable {
    case diving
    case apnea
    case snorkeling
    case sharedReference

    var payloadKey: String? {
        switch self {
        case .diving: return "dirdiving_dive_session"
        case .apnea: return "dirdiving_apnea_session"
        case .snorkeling: return "dirdiving_snorkeling_session_sync"
        case .sharedReference: return nil
        }
    }

    static func from(payloadKey: String) -> ActivitySyncActivityType? {
        allCases.first { $0.payloadKey == payloadKey }
    }
}

/// Message kinds carried inside signed session-sync transports.
enum ActivitySyncMessageType: String, Codable, CaseIterable, Sendable {
    case sessionUpsert
    case sessionDeleteTombstone
    case importAck
    case conflictNotice
    case settings
    case briefingCard
    case photoManagement
    case chunkManifest
    case chunkPart
}

enum ActivitySyncEnvelopeError: Error, Equatable {
    case unsupportedSchemaDowngrade
    case unsupportedSchemaVersion
    case activityPayloadKeyMismatch
    case missingEnvelopeFields
    case invalidActivityType
    case invalidMessageType
    case envelopeActivityMismatch
}

/// Routing guard: payload key and signed envelope activity must agree before inner decode.
enum ActivitySyncRoutingGuard {
    static func validate(
        payloadKey: String,
        transport: ActivitySyncSignedTransport
    ) throws {
        guard let expectedActivity = ActivitySyncActivityType.from(payloadKey: payloadKey) else {
            throw ActivitySyncEnvelopeError.invalidActivityType
        }
        if transport.version >= ActivitySyncSignedTransport.envelopeSchemaVersion {
            guard let activityRaw = transport.activityType,
                  let messageRaw = transport.messageType,
                  let messageID = transport.messageID,
                  !messageID.isEmpty,
                  let payloadHash = transport.payloadHash,
                  !payloadHash.isEmpty else {
                throw ActivitySyncEnvelopeError.missingEnvelopeFields
            }
            guard let activity = ActivitySyncActivityType(rawValue: activityRaw) else {
                throw ActivitySyncEnvelopeError.invalidActivityType
            }
            guard ActivitySyncMessageType(rawValue: messageRaw) != nil else {
                throw ActivitySyncEnvelopeError.invalidMessageType
            }
            guard activity == expectedActivity else {
                throw ActivitySyncEnvelopeError.envelopeActivityMismatch
            }
            guard messageRaw == ActivitySyncMessageType.sessionUpsert.rawValue else {
                throw ActivitySyncEnvelopeError.invalidMessageType
            }
            let computedHash = ActivitySyncSignedTransport.payloadHash(for: transport.body)
            guard payloadHash == computedHash else {
                throw ActivitySyncEnvelopeError.envelopeActivityMismatch
            }
            _ = messageID
        } else if transport.version > ActivitySyncSignedTransport.envelopeSchemaVersion {
            throw ActivitySyncEnvelopeError.unsupportedSchemaVersion
        }
    }

    /// Rejects v3+ transports presented on the wrong import route (cross-decode guard).
    static func rejectCrossRoute(
        expectedActivity: ActivitySyncActivityType,
        payloadKey: String,
        transport: ActivitySyncSignedTransport
    ) throws {
        guard payloadKey == expectedActivity.payloadKey else {
            throw ActivitySyncEnvelopeError.activityPayloadKeyMismatch
        }
        if transport.version >= ActivitySyncSignedTransport.envelopeSchemaVersion,
           let activityRaw = transport.activityType,
           let activity = ActivitySyncActivityType(rawValue: activityRaw),
           activity != expectedActivity {
            throw ActivitySyncEnvelopeError.envelopeActivityMismatch
        }
    }
}

enum ActivitySyncHMAC {
    static func signCanonical(
        transport: ActivitySyncSignedTransport,
        body: Data,
        key: SymmetricKey
    ) -> String {
        let canonical = canonicalString(transport: transport, body: body)
        let code = HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: key)
        return Data(code).base64EncodedString()
    }

    static func verify(
        transport: ActivitySyncSignedTransport,
        key: SymmetricKey
    ) -> Bool {
        let canonical = canonicalString(transport: transport, body: transport.body)
        let code = HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: key)
        let expected = Data(code).base64EncodedString()
        guard let received = Data(base64Encoded: transport.signature),
              let expectedData = Data(base64Encoded: expected) else {
            return false
        }
        return received.constantTimeEquals(expectedData)
    }

    static func canonicalString(transport: ActivitySyncSignedTransport, body: Data) -> String {
        let nonceComponent = transport.version >= ActivitySyncSignedTransport.nonceRequiredFromVersion
            ? (transport.nonce ?? "")
            : ""
        if transport.version >= ActivitySyncSignedTransport.envelopeSchemaVersion {
            return [
                "\(transport.version)",
                transport.bundleID,
                "\(transport.issuedAt.timeIntervalSince1970)",
                nonceComponent,
                transport.messageID ?? "",
                transport.activityType ?? "",
                transport.messageType ?? "",
                transport.payloadHash ?? "",
                transport.revision.map(String.init) ?? "",
                body.base64EncodedString(),
            ].joined(separator: "|")
        }
        return "\(transport.version)|\(transport.bundleID)|\(transport.issuedAt.timeIntervalSince1970)|\(nonceComponent)|\(body.base64EncodedString())"
    }
}

private extension Data {
    func constantTimeEquals(_ other: Data) -> Bool {
        guard count == other.count else { return false }
        return zip(self, other).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}
