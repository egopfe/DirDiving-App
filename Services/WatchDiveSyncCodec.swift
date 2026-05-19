import Foundation
import CryptoKit
import WatchConnectivity

enum WatchDiveSyncCodec {
    static let payloadKey = "dirdiving_dive_session"
    static let schemaVersion = 1
    static let maxPayloadBytes = 512_000

    private static let expectedCompanionBundleID = "com.egopfe.dirdiving.ios"

    struct Transport: Codable {
        let version: Int
        let bundleID: String
        let issuedAt: Date
        let body: Data
        let signature: String
    }

    // F11: callers (WatchSyncService) need the sessionID + issuedAt to verify
    // the signed ack returned by the iOS companion. The legacy `acknowledged`
    // string is still accepted for backward compatibility (older iOS builds).
    struct PayloadEnvelope {
        let message: [String: Any]
        let sessionID: UUID
        let issuedAt: Date
    }

    static func makePayload(session: DiveSession) throws -> PayloadEnvelope {
        guard WatchSyncAuth.hasPeerSecret() else {
            throw WatchDiveSyncError.missingPeerSecret
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(session)
        guard body.count <= maxPayloadBytes else {
            throw WatchDiveSyncError.payloadTooLarge
        }

        let issuedAt = Date()
        let transport = Transport(
            version: schemaVersion,
            bundleID: Bundle.main.bundleIdentifier ?? "com.egopfe.dirdiving",
            issuedAt: issuedAt,
            body: body,
            signature: ""
        )
        let signed = sign(transport, issuedAt: issuedAt, body: body)
        let transportData = try JSONEncoder().encode(signed)
        guard transportData.count <= maxPayloadBytes else {
            throw WatchDiveSyncError.payloadTooLarge
        }
        return PayloadEnvelope(
            message: [payloadKey: transportData],
            sessionID: session.id,
            issuedAt: issuedAt
        )
    }

    // F11: shared HMAC over the ack context. The iOS side computes the same
    // string and returns the base64 signature; the Watch side compares it
    // against the expected value using constant-time bytes.
    static func ackSignature(sessionID: UUID, issuedAt: Date) -> String {
        let canonical = "ack|\(sessionID.uuidString)|\(issuedAt.timeIntervalSince1970)"
        let code = HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: syncKey())
        return Data(code).base64EncodedString()
    }

    static func verifyAckSignature(_ signature: String?, sessionID: UUID, issuedAt: Date) -> Bool {
        guard let signature, let providedData = Data(base64Encoded: signature) else { return false }
        let expected = ackSignature(sessionID: sessionID, issuedAt: issuedAt)
        guard let expectedData = Data(base64Encoded: expected) else { return false }
        return providedData.constantTimeEquals(expectedData)
    }

    private static func syncKey() -> SymmetricKey {
        WatchSyncAuth.syncKey(peerBundleID: expectedCompanionBundleID)
    }

    private static func sign(_ transport: Transport, issuedAt: Date, body: Data) -> Transport {
        let mac = hmac(version: transport.version, bundleID: transport.bundleID, issuedAt: issuedAt, body: body)
        return Transport(
            version: transport.version,
            bundleID: transport.bundleID,
            issuedAt: issuedAt,
            body: body,
            signature: mac
        )
    }

    private static func hmac(version: Int, bundleID: String, issuedAt: Date, body: Data) -> String {
        let canonical = "\(version)|\(bundleID)|\(issuedAt.timeIntervalSince1970)|\(body.base64EncodedString())"
        let code = HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: syncKey())
        return Data(code).base64EncodedString()
    }
}

private extension Data {
    func constantTimeEquals(_ other: Data) -> Bool {
        guard count == other.count else { return false }
        return zip(self, other).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}

enum WatchDiveSyncError: LocalizedError {
    case payloadTooLarge
    case missingPeerSecret

    var errorDescription: String? {
        switch self {
        case .payloadTooLarge: return "Payload sync troppo grande."
        case .missingPeerSecret: return "Chiave sync companion non ancora disponibile."
        }
    }
}
