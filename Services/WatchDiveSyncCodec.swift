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

    static func makePayload(session: DiveSession) throws -> [String: Any] {
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
        return [payloadKey: transportData]
    }

    private static func syncKey() -> SymmetricKey {
        let peer = WCSession.default.iOSAppBundleIdentifier ?? expectedCompanionBundleID
        let seed = "dirdiving.watch.sync.v1|\(peer)"
        return SymmetricKey(data: SHA256.hash(data: Data(seed.utf8)))
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

enum WatchDiveSyncError: LocalizedError {
    case payloadTooLarge

    var errorDescription: String? {
        switch self {
        case .payloadTooLarge: return "Payload sync troppo grande."
        }
    }
}
